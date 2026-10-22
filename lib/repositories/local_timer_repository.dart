import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../data/hyrox_data.dart';
import '../data/timer_presets_data.dart';
import '../models/custom_routine.dart';
import '../models/timer_settings.dart';
import '../shared/utils/home_timer_helper.dart';
import 'timer_repository.dart';

class LocalTimerRepository implements TimerRepository {
  static const String _boxName = 'routines_hive_box_v1';
  static const String _settingsKey = 'timer_settings_v1';
  static const String _seededKey = 'has_seeded_default_wods_v2';

  Box<String>? _box;

  Future<Box<String>> _getBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox<String>(_boxName);
    await _seedDefaultWodsIfNecessary(_box!);
    return _box!;
  }

  /// Seeds default WODs from assets/data/default_wods.json into Hive CE
  Future<void> _seedDefaultWodsIfNecessary(Box<String> box) async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeeded = prefs.getBool(_seededKey) ?? false;

    if (!hasSeeded || box.isEmpty) {
      try {
        final jsonString =
            await rootBundle.loadString('assets/data/default_wods.json');
        final List<dynamic> decoded = jsonDecode(jsonString);

        for (final item in decoded) {
          final map = item as Map<String, dynamic>;
          final id = map['id'] as String;
          map['isPreset'] = true;

          // Always seed / refresh default preset definitions to maintain current schema and translation
          await box.put(id, jsonEncode(map));
        }
        await prefs.setBool(_seededKey, true);
      } catch (e) {
        // Fallback if bundle load fails in background or test
      }
    }

    // Ensure HYROX presets are always present
    for (final hyrox in HyroxData.getHyroxPresets()) {
      if (!box.containsKey(hyrox.id)) {
        await box.put(hyrox.id, jsonEncode(hyrox.copyWith(isPreset: true).toJson()));
      }
    }

    // Ensure standard base timer presets (Tabata, EMOM, Rounds, AMRAP, For Time, Countdown) are always present & updated
    for (final preset in TimerPresetsData.getDefaultTimerPresets()) {
      await box.put(preset.id, jsonEncode(preset.copyWith(isPreset: true).toJson()));
    }
  }

  @override
  Future<List<CustomRoutine>> getRoutines() async {
    final box = await _getBox();
    final List<CustomRoutine> routines = [];

    for (final value in box.values) {
      try {
        final decoded = jsonDecode(value) as Map<String, dynamic>;
        routines.add(CustomRoutine.fromJson(decoded));
      } catch (_) {}
    }

    // Sort: Custom routines first, then presets by category and name
    routines.sort((a, b) {
      if (a.isPreset != b.isPreset) {
        return a.isPreset ? 1 : -1; // Custom first
      }
      return a.name.compareTo(b.name);
    });

    return routines;
  }

  @override
  Future<void> saveRoutine(CustomRoutine routine) async {
    final box = await _getBox();

    // Protection rule: Classic/Preset WODs cannot be overwritten!
    // If saving a preset, convert it to a new custom routine with a new ID
    if (routine.isPreset) {
      final customCopy = routine.copyWith(
        id: const Uuid().v4(),
        name: routine.name.endsWith('(Custom)') || routine.name.endsWith('(Özel)')
            ? routine.name
            : (routine.name.contains('(') ? routine.name : '${routine.name} (Custom)'),
        isPreset: false,
        category: routine.category,
        updatedAt: DateTime.now(),
      );
      await box.put(customCopy.id, jsonEncode(customCopy.toJson()));
      return;
    }

    // Normal custom routine save / update
    await box.put(routine.id, jsonEncode(routine.toJson()));
  }

  @override
  Future<void> deleteRoutine(String id) async {
    final box = await _getBox();
    final routineString = box.get(id);

    String? deletedName;
    if (routineString != null) {
      try {
        final decoded = jsonDecode(routineString) as Map<String, dynamic>;
        final isPreset = decoded['isPreset'] as bool? ?? false;
        // Never allow deleting classic preset WODs
        if (isPreset) return;
        deletedName = decoded['name'] as String?;
      } catch (_) {}
    }

    await box.delete(id);

    // If pinned to home screen, remove it from home order
    await HomeTimerHelper.unpin(id);

    // If any timer's last loaded routine was this deleted routine, clear it
    final prefs = await SharedPreferences.getInstance();
    const timerTypes = ['countdown', 'tabata', 'rounds', 'fortime', 'emom', 'amrap'];
    for (final type in timerTypes) {
      final key = 'last_loaded_routine_$type';
      final jsonStr = prefs.getString(key);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        try {
          final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
          if (decoded['id'] == id || (deletedName != null && decoded['name'] == deletedName)) {
            await prefs.remove(key);
          }
        } catch (_) {}
      }
    }
  }

  @override
  Future<TimerSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_settingsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return const TimerSettings();
    }
    try {
      return TimerSettings.fromJson(jsonDecode(jsonString));
    } catch (_) {
      return const TimerSettings();
    }
  }

  @override
  Future<void> saveSettings(TimerSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  @override
  Future<void> saveLastLoadedRoutine(String timerType, CustomRoutine routine) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_loaded_routine_$timerType', jsonEncode(routine.toJson()));
  }

  @override
  Future<CustomRoutine?> getLastLoadedRoutine(String timerType) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('last_loaded_routine_$timerType');
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final routine = CustomRoutine.fromJson(decoded);

      // Verify that this routine still exists in storage
      // If deleted, remove cached last loaded routine and return null
      final box = await _getBox();
      if (!box.containsKey(routine.id)) {
        await prefs.remove('last_loaded_routine_$timerType');
        return null;
      }

      return routine;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearLastLoadedRoutine(String timerType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_loaded_routine_$timerType');
  }

  @override
  Future<void> syncWithCloud() async {
    // Ready for future backend sync with Firebase / REST
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
