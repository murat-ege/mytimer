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
    _wakelockService.enable();
    _onSegmentStarted();
    _startTicker();
    notifyListeners();
  }

  void pause() {
    if (!_isRunning) return;
    _timer?.cancel();
    _isRunning = false;
    _isPaused = true;
    _updateNotification();
    notifyListeners();
  }

  void resume() {
    if (!_isPaused || _isFinished) return;
    _isRunning = true;
    _isPaused = false;
    _wakelockService.enable();
    _startTicker();
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _isFinished = false;
    _currentSegmentIndex = 0;
    _secondsRemaining = _segments.isNotEmpty ? _segments.first.durationSeconds : 0;
    _totalElapsedSeconds = 0;
    _wakelockService.disable();
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
      _onSegmentStarted();
      notifyListeners();
    } else {
      _currentSegmentIndex = 0;
      _secondsRemaining = _segments.isNotEmpty ? _segments.first.durationSeconds : 0;
      _totalElapsedSeconds = 0;
      notifyListeners();
    }
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });
  }

  void _tick() {
    if (!_isRunning) return;

    if (_secondsRemaining > 1) {
      _secondsRemaining--;
      if (currentPhase != TimerPhase.prep) {
        _totalElapsedSeconds++;
      }

      // Countdown cue (3, 2, 1)
      if (_secondsRemaining <= 3) {
        _soundService.playCountdownBeep();
      }

      _updateNotification();
      notifyListeners();
    } else {
      if (currentPhase != TimerPhase.prep) {
        _totalElapsedSeconds++;
      }
      // Move to next segment
      if (_currentSegmentIndex + 1 < _segments.length) {
        _currentSegmentIndex++;
        _secondsRemaining = _segments[_currentSegmentIndex].durationSeconds;
        _recalculateTotalElapsed();
        _onSegmentStarted();
        notifyListeners();
      } else {
        _finishWorkout();
      }
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
    _secondsRemaining = 0;
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
    _wakelockService.disable();
    _notificationService.cancelWorkoutNotification();
    super.dispose();
  }
}
