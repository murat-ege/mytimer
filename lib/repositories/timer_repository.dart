import '../models/custom_routine.dart';
import '../models/timer_settings.dart';

abstract class TimerRepository {
  Future<List<CustomRoutine>> getRoutines();
  Future<void> saveRoutine(CustomRoutine routine);
  Future<void> deleteRoutine(String id);
  Future<TimerSettings> getSettings();
  Future<void> saveSettings(TimerSettings settings);
  Future<void> syncWithCloud(); // Hook for future backend integration
}
