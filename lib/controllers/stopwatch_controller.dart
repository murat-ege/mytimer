import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../services/wakelock_service.dart';

class LapRecord {
  final int lapNumber;
  final int lapTimeMs;
  final int splitTimeMs;

  const LapRecord({
    required this.lapNumber,
    required this.lapTimeMs,
    required this.splitTimeMs,
  });
}

class StopwatchController extends ChangeNotifier {
  final WakelockService _wakelockService = WakelockService();
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;

  final List<LapRecord> _laps = [];
  int _lastLapSplitMs = 0;

  bool get isRunning => _stopwatch.isRunning;
  int get elapsedMs => _stopwatch.elapsedMilliseconds;
  List<LapRecord> get laps => List.unmodifiable(_laps.reversed);

  int? get fastestLapMs {
    if (_laps.length < 2) return null;
    return _laps.map((l) => l.lapTimeMs).reduce((a, b) => a < b ? a : b);
  }

  int? get slowestLapMs {
    if (_laps.length < 2) return null;
    return _laps.map((l) => l.lapTimeMs).reduce((a, b) => a > b ? a : b);
  }

  void start() {
    if (_stopwatch.isRunning) return;
    _stopwatch.start();
    _wakelockService.enable();
    _startTicker();
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void pause() {
    if (!_stopwatch.isRunning) return;
    _stopwatch.stop();
    _ticker?.cancel();
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void reset() {
    _stopwatch.stop();
    _stopwatch.reset();
    _ticker?.cancel();
    _laps.clear();
    _lastLapSplitMs = 0;
    _wakelockService.disable();
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  void recordLap() {
    if (!_stopwatch.isRunning) return;
    final currentSplit = _stopwatch.elapsedMilliseconds;
    final lapTime = currentSplit - _lastLapSplitMs;
    _lastLapSplitMs = currentSplit;

    _laps.add(
      LapRecord(
        lapNumber: _laps.length + 1,
        lapTimeMs: lapTime,
        splitTimeMs: currentSplit,
      ),
    );
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 30), (_) {
      notifyListeners();
    });
  }

  void syncWithRealTime() {
    if (_stopwatch.isRunning) {
      notifyListeners();
    }
  }

  static String formatMs(int ms, {bool showMs = true}) {
    final minutes = ms ~/ 60000;
    final seconds = (ms % 60000) ~/ 1000;
    final hundredths = (ms % 1000) ~/ 10;

    final minsStr = minutes.toString().padLeft(2, '0');
    final secsStr = seconds.toString().padLeft(2, '0');
    final hdsStr = hundredths.toString().padLeft(2, '0');

    if (showMs) {
      return '$minsStr:$secsStr.$hdsStr';
    } else {
      return '$minsStr:$secsStr';
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _wakelockService.disable();
    super.dispose();
  }
}
