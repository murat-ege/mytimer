import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/custom_routine.dart';
import '../models/timer_phase.dart';
import '../services/notification_service.dart';
import '../services/sound_service.dart';
import '../services/wakelock_service.dart';

class ExecutionSegment {
  final String title;
  final TimerPhase phase;
  final int durationSeconds;
  final int roundIndex;
  final int totalRounds;

  const ExecutionSegment({
    required this.title,
    required this.phase,
    required this.durationSeconds,
    required this.roundIndex,
    required this.totalRounds,
  });
}

class WorkoutController extends ChangeNotifier {
  final CustomRoutine routine;
  final SoundService _soundService = SoundService();
  final WakelockService _wakelockService = WakelockService();
  final NotificationService _notificationService = NotificationService();

  late final List<ExecutionSegment> _segments;
  int _currentSegmentIndex = 0;
  int _secondsRemaining = 0;
  int _totalElapsedSeconds = 0;
  late final int _totalWorkoutSeconds;

  DateTime? _lastTickTime;
  Timer? _timer;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isFinished = false;

  WorkoutController({required this.routine}) {
    _buildSegments();
    _totalWorkoutSeconds = _segments
        .where((seg) => seg.phase != TimerPhase.prep)
        .fold<int>(0, (s, seg) => s + seg.durationSeconds);
    _secondsRemaining = _segments.isNotEmpty ? _segments.first.durationSeconds : 0;
  }

  void _buildSegments() {
    _segments = [];

    // Preparation interval
    if (routine.prepSeconds > 0) {
      _segments.add(
        ExecutionSegment(
          title: 'HAZIRLIK',
          phase: TimerPhase.prep,
          durationSeconds: routine.prepSeconds,
          roundIndex: 0,
          totalRounds: routine.rounds,
        ),
      );
    }

    // Rounds
    for (int r = 1; r <= routine.rounds; r++) {
      for (final interval in routine.intervals) {
        if (interval.durationSeconds > 0) {
          _segments.add(
            ExecutionSegment(
              title: interval.name,
              phase: interval.phase,
              durationSeconds: interval.durationSeconds,
              roundIndex: r,
              totalRounds: routine.rounds,
            ),
          );
        }
      }

      // Rest between rounds if any
      if (r < routine.rounds && routine.restBetweenRoundsSeconds > 0) {
        _segments.add(
          ExecutionSegment(
            title: 'TUR ARASI DİNLENME',
            phase: TimerPhase.restBetweenSets,
            durationSeconds: routine.restBetweenRoundsSeconds,
            roundIndex: r,
            totalRounds: routine.rounds,
          ),
        );
      }
    }
  }

  // Getters
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  bool get isFinished => _isFinished;
  int get secondsRemaining => _secondsRemaining;
  int get totalElapsedSeconds => _totalElapsedSeconds;
  int get totalWorkoutSeconds => _totalWorkoutSeconds;
  int get currentSegmentIndex => _currentSegmentIndex;
  List<ExecutionSegment> get segments => _segments;

  ExecutionSegment? get currentSegment =>
      _segments.isNotEmpty && _currentSegmentIndex < _segments.length
          ? _segments[_currentSegmentIndex]
          : null;

  TimerPhase get currentPhase => currentSegment?.phase ?? TimerPhase.finished;
  int get currentRound => currentSegment?.roundIndex ?? 0;
  int get totalRounds => routine.rounds;

  double get segmentProgress {
    final cur = currentSegment;
    if (cur == null || cur.durationSeconds == 0) return 1.0;
    return (cur.durationSeconds - _secondsRemaining) / cur.durationSeconds;
  }

  double get overallProgress {
    if (_totalWorkoutSeconds == 0) return 1.0;
    return (_totalElapsedSeconds / _totalWorkoutSeconds).clamp(0.0, 1.0);
  }

  String get formattedRemainingTime {
    final mins = _secondsRemaining ~/ 60;
    final secs = _secondsRemaining % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String get formattedTotalElapsed {
    final mins = _totalElapsedSeconds ~/ 60;
    final secs = _totalElapsedSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String get formattedTotalWorkoutTime {
    final mins = _totalWorkoutSeconds ~/ 60;
    final secs = _totalWorkoutSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void start() {
    if (_isFinished) return;
    _isRunning = true;
    _isPaused = false;
    _lastTickTime = DateTime.now();
    _wakelockService.enable();
    _soundService.startBackgroundKeepAlive();
    _onSegmentStarted();
    _startTicker();
    notifyListeners();
  }

  void pause() {
    if (!_isRunning) return;
    _timer?.cancel();
    _isRunning = false;
    _isPaused = true;
    _lastTickTime = null;
    _soundService.stopBackgroundKeepAlive();
    _updateNotification();
    notifyListeners();
  }

  void resume() {
    if (!_isPaused || _isFinished) return;
    _isRunning = true;
    _isPaused = false;
    _lastTickTime = DateTime.now();
    _wakelockService.enable();
    _soundService.startBackgroundKeepAlive();
    _startTicker();
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _isFinished = false;
    _lastTickTime = null;
    _currentSegmentIndex = 0;
    _secondsRemaining = _segments.isNotEmpty ? _segments.first.durationSeconds : 0;
    _totalElapsedSeconds = 0;
    _wakelockService.disable();
    _soundService.stopBackgroundKeepAlive();
    _notificationService.cancelWorkoutNotification();
    notifyListeners();
  }

  void _recalculateTotalElapsed() {
    int elapsed = 0;
    for (int i = 0; i < _currentSegmentIndex; i++) {
      if (_segments[i].phase != TimerPhase.prep) {
        elapsed += _segments[i].durationSeconds;
      }
    }
    _totalElapsedSeconds = elapsed;
  }

  void skipNext() {
    if (_currentSegmentIndex + 1 < _segments.length) {
      _currentSegmentIndex++;
      _secondsRemaining = _segments[_currentSegmentIndex].durationSeconds;
      _recalculateTotalElapsed();
      _lastTickTime = DateTime.now();
      _onSegmentStarted();
      notifyListeners();
    } else {
      _finishWorkout();
    }
  }

  void skipPrevious() {
    if (_currentSegmentIndex > 0) {
      _currentSegmentIndex--;
      _secondsRemaining = _segments[_currentSegmentIndex].durationSeconds;
      _recalculateTotalElapsed();
      _lastTickTime = DateTime.now();
      _onSegmentStarted();
      notifyListeners();
    } else {
      _currentSegmentIndex = 0;
      _secondsRemaining = _segments.isNotEmpty ? _segments.first.durationSeconds : 0;
      _totalElapsedSeconds = 0;
      _lastTickTime = DateTime.now();
      notifyListeners();
    }
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      _tick();
    });
  }

  void _tick() {
    if (!_isRunning || _isPaused || _isFinished || _lastTickTime == null) return;

    final now = DateTime.now();
    final elapsedMs = now.difference(_lastTickTime!).inMilliseconds;
    if (elapsedMs < 1000) return;

    final elapsedSeconds = elapsedMs ~/ 1000;
    _lastTickTime = _lastTickTime!.add(Duration(seconds: elapsedSeconds));

    _advanceSeconds(elapsedSeconds);
  }

  void _advanceSeconds(int elapsed) {
    if (elapsed <= 0 || _isFinished) return;

    int remainingToAdvance = elapsed;

    while (remainingToAdvance > 0 && !_isFinished) {
      if (_secondsRemaining > remainingToAdvance) {
        _secondsRemaining -= remainingToAdvance;
        if (currentPhase != TimerPhase.prep) {
          _totalElapsedSeconds += remainingToAdvance;
        }

        // Only play countdown beep if ticking in real-time
        if (elapsed == 1 && _secondsRemaining <= 3 && _secondsRemaining > 0) {
          _soundService.playCountdownBeep();
        }

        remainingToAdvance = 0;
      } else {
        final used = _secondsRemaining;
        remainingToAdvance -= used;
        if (currentPhase != TimerPhase.prep) {
          _totalElapsedSeconds += used;
        }

        if (_currentSegmentIndex + 1 < _segments.length) {
          _currentSegmentIndex++;
          _secondsRemaining = _segments[_currentSegmentIndex].durationSeconds;
          _recalculateTotalElapsed();
          _onSegmentStarted();
        } else {
          _finishWorkout();
          return;
        }
      }
    }

    _updateNotification();
    notifyListeners();
  }

  /// Synchronizes state with real wall-clock time immediately.
  /// Called when the app is brought back to foreground from background.
  void syncWithRealTime() {
    if (_isRunning && !_isPaused && !_isFinished) {
      _tick();
      notifyListeners();
    }
  }

  void _onSegmentStarted() {
    final cur = currentSegment;
    if (cur == null) return;

    if (cur.phase == TimerPhase.work) {
      _soundService.playWorkBeep();
    } else if (cur.phase == TimerPhase.rest || cur.phase == TimerPhase.restBetweenSets) {
      _soundService.playRestBeep();
    } else if (cur.phase == TimerPhase.prep) {
      _soundService.playCountdownBeep();
    }

    _updateNotification();
  }

  void _finishWorkout() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _isFinished = true;
    _lastTickTime = null;
    _secondsRemaining = 0;
    _soundService.stopBackgroundKeepAlive();
    _soundService.playCompleteFanfare();
    _wakelockService.disable();
    _notificationService.showWorkoutProgress(
      phaseTitle: 'ANTRENMAN BİTTİ',
      timeRemainingText: '00:00',
      roundInfo: 'Tebrikler! ${routine.name} tamamlandı.',
    );
    notifyListeners();
  }

  void _updateNotification() {
    final cur = currentSegment;
    if (cur == null) return;
    _notificationService.showWorkoutProgress(
      phaseTitle: cur.title,
      timeRemainingText: formattedRemainingTime,
      roundInfo: cur.phase == TimerPhase.prep
          ? 'Hazırlık: $formattedRemainingTime'
          : 'Tur ${cur.roundIndex}/${cur.totalRounds} • Toplam: $formattedTotalElapsed',
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _soundService.stopBackgroundKeepAlive();
    _wakelockService.disable();
    _notificationService.cancelWorkoutNotification();
    super.dispose();
  }
}
