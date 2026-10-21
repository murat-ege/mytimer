import 'dart:convert';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../models/workout_log.dart';

class WorkoutLogRepository {
  static const String _boxName = 'workout_logs_hive_box_v1';
  static final WorkoutLogRepository _instance = WorkoutLogRepository._internal();
  factory WorkoutLogRepository() => _instance;
  WorkoutLogRepository._internal();

  Box<String>? _box;

  Future<Box<String>> _getBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox<String>(_boxName);
    return _box!;
  }

  Future<List<WorkoutLog>> getLogs() async {
    final box = await _getBox();
    final List<WorkoutLog> logs = [];

    for (final value in box.values) {
      try {
        final decoded = jsonDecode(value) as Map<String, dynamic>;
        logs.add(WorkoutLog.fromJson(decoded));
      } catch (_) {}
    }

    // Sort: Latest workouts first
    logs.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return logs;
  }

  Future<void> saveLog(WorkoutLog log) async {
    final box = await _getBox();
    await box.put(log.id, jsonEncode(log.toJson()));
  }

  Future<void> deleteLog(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  Future<void> clearAllLogs() async {
    final box = await _getBox();
    await box.clear();
  }
}
