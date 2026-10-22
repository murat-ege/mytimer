import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/custom_routine.dart';
import '../models/timer_phase.dart';
import '../models/workout_log.dart';
import '../repositories/workout_log_repository.dart';
import '../services/notification_service.dart';
import '../services/sound_service.dart';
import '../services/voice_coach_service.dart';
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
  final VoiceCoachService _voiceCoach = VoiceCoachService();
  final WakelockService _wakelockService = WakelockService();
  final NotificationService _notificationService = NotificationService();
  final WorkoutLogRepository _logRepository = WorkoutLogRepository();

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
  WorkoutLog? _recordedLog;

  WorkoutController({required this.routine}) {
    _buildSegments();
    _totalWorkoutSeconds = _segments
        .where((seg) => seg.phase != TimerPhase.prep)
        .fold<int>(0, (s, seg) => s + seg.durationSeconds);
    _secondsRemaining = _segments.isNotEmpty
        ? _segments.first.durationSeconds
        : 0;
  }

  void _buildSegments() {
    _segments = [];

    // Preparation interval
    if (routine.prepSeconds > 0) {
      _segments.add(
        ExecutionSegment(
          title: 'PREP',
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

      // Rest between rounds if any (skipped when the round already ends with
      // a REST step, otherwise the athlete would rest twice in a row).
      if (r < routine.rounds && routine.restBetweenRoundsSeconds > 0 && !routine.endsWithRestStep) {
        _segments.add(
          ExecutionSegment(
            title: 'REST BETWEEN ROUNDS',
            phase: TimerPhase.restBetweenSets,
            durationSeconds: routine.restBetweenRoundsSeconds,
            roundIndex: r,
            totalRounds: routine.rounds,
          ),
        );
      }
    }

    // Cooldown interval after all rounds
    if (routine.cooldownSeconds > 0) {
      _segments.add(
        ExecutionSegment(
          title: 'COOLDOWN',
          phase: TimerPhase.cooldown,
          durationSeconds: routine.cooldownSeconds,
          roundIndex: routine.rounds,
          totalRounds: routine.rounds,
        ),
      );
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
  WorkoutLog? get recordedLog => _recordedLog;

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
    _voiceCoach.stop();
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
    _secondsRemaining = _segments.isNotEmpty
        ? _segments.first.durationSeconds
        : 0;
    _totalElapsedSeconds = 0;
    _recordedLog = null;
    _wakelockService.disable();
    _soundService.stopBackgroundKeepAlive();
    _voiceCoach.stop();
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
      _secondsRemaining = _segments.isNotEmpty
          ? _segments.first.durationSeconds
          : 0;
      _totalElapsedSeconds = 0;
      _lastTickTime = DateTime.now();
      notifyListeners();
    }
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _tick();
    });
  }

  void _tick() {
    if (!_isRunning || _isPaused || _isFinished || _lastTickTime == null) {
      return;
    }

    final now = DateTime.now();
    final elapsedMs = now.difference(_lastTickTime!).inMilliseconds;
    if (elapsedMs < 1000) return;

    final elapsedSeconds = elapsedMs ~/ 1000;
    _lastTickTime = _lastTickTime!.add(Duration(seconds: elapsedSeconds));

    _advanceSeconds(elapsedSeconds);
  }

  void _advanceSeconds(int elapsed) {
    if (elapsed <= 0 || _isFinished) return;

    // Advance second by second so cues and intermediate transitions are never skipped
    for (int step = 0; step < elapsed && !_isFinished; step++) {
      final isCatchUp = elapsed > 1 && step < elapsed - 1;
      _advanceOneSecond(isCatchUp: isCatchUp);
    }

    _updateNotification();
    notifyListeners();
  }

  void _advanceOneSecond({required bool isCatchUp}) {
    if (_isFinished) return;

    if (_secondsRemaining > 1) {
      _secondsRemaining -= 1;
      if (currentPhase != TimerPhase.prep) {
        _totalElapsedSeconds += 1;
      }

      // Real-time audio cue (beep only, voice countdown disabled per user request)
      if (!isCatchUp && _secondsRemaining <= 3 && _secondsRemaining > 0) {
        _soundService.playCountdownBeep();
      }

      // Periodic Interval Signal (e.g., For Time cadence signal every minute)
      if (!isCatchUp &&
          routine.intervalSignalSeconds > 0 &&
          currentPhase == TimerPhase.work) {
        final cur = currentSegment;
        if (cur != null) {
          final segElapsed = cur.durationSeconds - _secondsRemaining;
          if (segElapsed > 0 &&
              segElapsed % routine.intervalSignalSeconds == 0 &&
              _secondsRemaining > 3) {
            _soundService.playWorkBeep();
            _voiceCoach.speakIntervalSignal(segElapsed ~/ 60);
          }
        }
      }

      // Halfway announcement
      if (!isCatchUp) {
        final cur = currentSegment;
        if (cur != null &&
            cur.durationSeconds >= 20 &&
            _secondsRemaining == cur.durationSeconds ~/ 2) {
          _voiceCoach.speakHalfway();
        }
      }
    } else {
      // Current segment finishes
      if (currentPhase != TimerPhase.prep) {
        _totalElapsedSeconds += 1;
      }

      if (_currentSegmentIndex + 1 < _segments.length) {
        _currentSegmentIndex++;
        _secondsRemaining = _segments[_currentSegmentIndex].durationSeconds;
        _recalculateTotalElapsed();
        if (!isCatchUp) {
          _onSegmentStarted();
        }
      } else {
        _secondsRemaining = 0;
        _finishWorkout();
      }
    }
  }

  /// Synchronizes state with real wall-clock time immediately.
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
      _voiceCoach.speakWork(
        roundIndex: cur.roundIndex,
        totalRounds: cur.totalRounds,
      );
    } else if (cur.phase == TimerPhase.rest ||
        cur.phase == TimerPhase.restBetweenSets) {
      _soundService.playRestBeep();
      _voiceCoach.speakRest();
    } else if (cur.phase == TimerPhase.cooldown) {
      _soundService.playRestBeep();
      _voiceCoach.speakCooldown();
    } else if (cur.phase == TimerPhase.prep) {
      // _soundService.playWorkBeep();
    }

    _updateNotification(force: true);
  }

  Future<WorkoutLog> recordCurrentLog() async {
    if (_recordedLog != null) return _recordedLog!;

    final duration = _totalElapsedSeconds > 0
        ? _totalElapsedSeconds
        : _totalWorkoutSeconds;

    final log = WorkoutLog(
      id: const Uuid().v4(),
      timerType: routine.category.toLowerCase(),
      title: routine.name,
      defaultDefinition: routine.description.isNotEmpty
          ? routine.description
          : '${routine.rounds} Rounds • ${_buildSummary()}',
      userNote: '',
      totalDurationSeconds: duration,
      completedAt: DateTime.now(),
      completedRounds: routine.rounds,
      totalRounds: routine.rounds,
    );
    _recordedLog = log;
    await _logRepository.saveLog(log);
    return log;
  }

  void _finishWorkout() async {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _isFinished = true;
    _lastTickTime = null;
    _secondsRemaining = 0;
    _soundService.stopBackgroundKeepAlive();
    _soundService.playCompleteFanfare();
    _voiceCoach.speakComplete();
    _wakelockService.disable();
    _notificationService.showWorkoutProgress(
      phaseTitle: 'WORKOUT COMPLETE',
      timeRemainingText: '00:00',
      roundInfo: 'Well done! ${routine.name} complete.',
    );

    await recordCurrentLog();
    notifyListeners();
  }

  String _buildSummary() {
    final intervals = routine.intervals
        .map((i) => '${i.name} (${i.durationSeconds}s)')
        .join(' / ');
    return intervals.isNotEmpty
        ? intervals
        : 'Duration: $formattedTotalWorkoutTime';
  }

  int _lastNotificationUpdateSecond = -1;

  void _updateNotification({bool force = false}) {
    final cur = currentSegment;
    if (cur == null) return;

    if (!force && _totalElapsedSeconds == _lastNotificationUpdateSecond) return;
    if (!force && _totalElapsedSeconds % 5 != 0) return;

    _lastNotificationUpdateSecond = _totalElapsedSeconds;
    _notificationService.showWorkoutProgress(
      phaseTitle: cur.title,
      timeRemainingText: formattedRemainingTime,
      roundInfo: cur.phase == TimerPhase.prep
          ? 'Prep: $formattedRemainingTime'
          : 'Round ${cur.roundIndex}/${cur.totalRounds} • Total: $formattedTotalElapsed',
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _soundService.stopBackgroundKeepAlive();
    _voiceCoach.stop();
    _wakelockService.disable();
    _notificationService.cancelWorkoutNotification();
    super.dispose();
  }
}
