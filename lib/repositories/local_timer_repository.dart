import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/crossfit_wods.dart';
import '../models/custom_routine.dart';
import '../models/timer_settings.dart';
import 'timer_repository.dart';

class LocalTimerRepository implements TimerRepository {
  static const String _routinesKey = 'custom_timer_routines_v2';
  static const String _settingsKey = 'timer_settings_v1';

  @override
  Future<List<CustomRoutine>> getRoutines() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_routinesKey);
    final allPredefined = CrossFitWodsData.getAllWods();

    if (jsonString == null || jsonString.isEmpty) {
      await _saveRoutinesToPrefs(prefs, allPredefined);
      return allPredefined;
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      final savedRoutines = decoded
          .map((item) => CustomRoutine.fromJson(item as Map<String, dynamic>))
          .toList();

      // Merge predefined WODs if not already present
      final savedIds = savedRoutines.map((r) => r.id).toSet();
      bool needsResave = false;
      for (final w in allPredefined) {
        if (!savedIds.contains(w.id)) {
          savedRoutines.add(w);
          needsResave = true;
        }
      }
      if (needsResave) {
        await _saveRoutinesToPrefs(prefs, savedRoutines);
      }
      return savedRoutines;
    } catch (e) {
      return allPredefined;
    }
  }

  @override
  Future<void> saveRoutine(CustomRoutine routine) async {
    final prefs = await SharedPreferences.getInstance();
    final routines = await getRoutines();
    final index = routines.indexWhere((r) => r.id == routine.id);

    if (index >= 0) {
      routines[index] = routine;
    } else {
      routines.insert(0, routine);
    }

    await _saveRoutinesToPrefs(prefs, routines);
  }

  @override
  Future<void> deleteRoutine(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final routines = await getRoutines();
    routines.removeWhere((r) => r.id == id);
    await _saveRoutinesToPrefs(prefs, routines);
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
  Future<void> syncWithCloud() async {
    // Ready for remote backend sync
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _saveRoutinesToPrefs(
      SharedPreferences prefs, List<CustomRoutine> routines) async {
    final encoded = jsonEncode(routines.map((r) => r.toJson()).toList());
    await prefs.setString(_routinesKey, encoded);
  }
}
