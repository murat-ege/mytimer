import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/custom_routine.dart';
import '../models/interval_step.dart';
import '../models/timer_phase.dart';
import '../models/timer_settings.dart';
import 'timer_repository.dart';

class LocalTimerRepository implements TimerRepository {
  static const String _routinesKey = 'custom_timer_routines_v1';
  static const String _settingsKey = 'timer_settings_v1';

  @override
  Future<List<CustomRoutine>> getRoutines() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_routinesKey);

    if (jsonString == null || jsonString.isEmpty) {
      // Return default CrossFit presets for a great out-of-the-box experience
      final defaults = _getDefaultCrossFitPresets();
      await _saveRoutinesToPrefs(prefs, defaults);
      return defaults;
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded
          .map((item) => CustomRoutine.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return _getDefaultCrossFitPresets();
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
    // When backend API/Firebase is ready:
    // 1. Fetch remote user workouts
    // 2. Merge local and remote workouts
    // 3. Upload local workouts to remote
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _saveRoutinesToPrefs(
      SharedPreferences prefs, List<CustomRoutine> routines) async {
    final encoded = jsonEncode(routines.map((r) => r.toJson()).toList());
    await prefs.setString(_routinesKey, encoded);
  }

  List<CustomRoutine> _getDefaultCrossFitPresets() {
    final now = DateTime.now();
    return [
      CustomRoutine(
        id: 'crossfit_fight_gone_bad',
        name: 'Fight Gone Bad',
        description: '5 Egzersiz x 1 dk, 1 dk Dinlenme, 3 Tur',
        prepSeconds: 10,
        intervals: const [
          IntervalStep(id: 'fgb_1', name: 'Wall Ball', durationSeconds: 60, phase: TimerPhase.work),
          IntervalStep(id: 'fgb_2', name: 'Sumo Deadlift High Pull', durationSeconds: 60, phase: TimerPhase.work),
          IntervalStep(id: 'fgb_3', name: 'Box Jump', durationSeconds: 60, phase: TimerPhase.work),
          IntervalStep(id: 'fgb_4', name: 'Push Press', durationSeconds: 60, phase: TimerPhase.work),
          IntervalStep(id: 'fgb_5', name: 'Row (Kalori)', durationSeconds: 60, phase: TimerPhase.work),
        ],
        rounds: 3,
        restBetweenRoundsSeconds: 60,
        createdAt: now,
        updatedAt: now,
      ),
      CustomRoutine(
        id: 'crossfit_emom_10',
        name: 'EMOM 10 Min',
        description: 'Her dakika başında 1 tur, toplam 10 dakika',
        prepSeconds: 10,
        intervals: const [
          IntervalStep(id: 'emom_w', name: 'WORK', durationSeconds: 50, phase: TimerPhase.work),
          IntervalStep(id: 'emom_r', name: 'REST', durationSeconds: 10, phase: TimerPhase.rest),
        ],
        rounds: 10,
        restBetweenRoundsSeconds: 0,
        createdAt: now,
        updatedAt: now,
      ),
      CustomRoutine(
        id: 'crossfit_hiit_30_30',
        name: 'HIIT 30s / 30s',
        description: '30 saniye patlayıcı güç, 30 saniye dinlenme x 10 tur',
        prepSeconds: 10,
        intervals: const [
          IntervalStep(id: 'hiit_w', name: 'WORK', durationSeconds: 30, phase: TimerPhase.work),
          IntervalStep(id: 'hiit_r', name: 'REST', durationSeconds: 30, phase: TimerPhase.rest),
        ],
        rounds: 10,
        restBetweenRoundsSeconds: 0,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
