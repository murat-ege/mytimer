import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/hyrox_data.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/sound_service.dart';
import '../../services/voice_coach_service.dart';
import 'hyrox_standards_sheet.dart';
import 'widgets/hyrox_race_active_view.dart';
import 'widgets/hyrox_race_finish_modal.dart';
import 'widgets/hyrox_race_setup_view.dart';

class HyroxRaceSplit {
  final int stepIndex;
  final String name;
  final String targetDesc;
  final int splitDurationSeconds;
  final int elapsedSecondsAtSplit;
  final bool isRoxzone;
  final bool isRun;

  const HyroxRaceSplit({
    required this.stepIndex,
    required this.name,
    required this.targetDesc,
    required this.splitDurationSeconds,
    required this.elapsedSecondsAtSplit,
    this.isRoxzone = false,
    this.isRun = false,
  });

  String get formattedSplit {
    final mins = splitDurationSeconds ~/ 60;
    final secs = splitDurationSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String get formattedTotal {
    final hours = elapsedSecondsAtSplit ~/ 3600;
    final mins = (elapsedSecondsAtSplit % 3600) ~/ 60;
    final secs = elapsedSecondsAtSplit % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class HyroxRaceScreen extends StatefulWidget {
  const HyroxRaceScreen({super.key});

  @override
  State<HyroxRaceScreen> createState() => _HyroxRaceScreenState();
}

class _HyroxRaceScreenState extends State<HyroxRaceScreen> {
  final SoundService _soundService = SoundService();
  final VoiceCoachService _voiceCoach = VoiceCoachService();

  // Setup options
  String _raceMode = 'full'; // 'full', 'half', 'relay'
  HyroxDivision _division = HyroxDivision.menOpen;
  int _targetFinishSeconds = 4500; // Sub 75 min default
  bool _includeRoxzone = false;

  // Race execution state
  bool _isRacing = false;
  bool _isPaused = false;
  bool _isFinished = false;

  Timer? _timer;
  DateTime? _raceStartTime;
  DateTime? _splitStartTime;
  int _accumulatedElapsedSeconds = 0;
  int _currentSplitAccumulatedSeconds = 0;

  int _totalElapsedSeconds = 0;
  int _currentSplitSeconds = 0;

  int _currentStepIndex = 0;
  List<Map<String, dynamic>> _raceSteps = [];
  final List<HyroxRaceSplit> _completedSplits = [];

  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _rebuildRaceSteps();

    _lifecycleListener = AppLifecycleListener(
      onResume: _syncRealTime,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lifecycleListener.dispose();
    super.dispose();
  }

  void _syncRealTime() {
    if (_isRacing && !_isPaused && _raceStartTime != null && _splitStartTime != null) {
      final now = DateTime.now();
      setState(() {
        _totalElapsedSeconds = _accumulatedElapsedSeconds + now.difference(_raceStartTime!).inSeconds;
        _currentSplitSeconds = _currentSplitAccumulatedSeconds + now.difference(_splitStartTime!).inSeconds;
      });
    }
  }

  void _rebuildRaceSteps() {
    final List<Map<String, dynamic>> steps = [];
    int maxStations = 8;
    if (_raceMode == 'half') maxStations = 4;
    if (_raceMode == 'relay') maxStations = 2;

    for (int i = 0; i < maxStations; i++) {
      final station = HyroxData.stations[i];

      // 1km Run before station
      steps.add({
        'type': 'run',
        'title': 'RUN ${i + 1}',
        'target': _raceMode == 'half' ? '1000m / 500m Run' : '1000m Run',
        'icon': Icons.directions_run_rounded,
        'station': null,
      });

      // Roxzone In (if enabled)
      if (_includeRoxzone) {
        steps.add({
          'type': 'roxzone',
          'title': 'ROXZONE IN (Station ${i + 1})',
          'target': 'Transition into Arch',
          'icon': Icons.sync_alt_rounded,
          'station': null,
        });
      }

      // Station
      steps.add({
        'type': 'station',
        'title': 'STATION ${i + 1}: ${station.name.toUpperCase()}',
        'target': station.distanceOrReps,
        'icon': station.icon,
        'station': station,
      });

      // Roxzone Out (if enabled)
      if (_includeRoxzone && i < maxStations - 1) {
        steps.add({
          'type': 'roxzone',
          'title': 'ROXZONE OUT (To Run ${i + 2})',
          'target': 'Exit Arch to Track',
          'icon': Icons.sync_alt_rounded,
          'station': null,
        });
      }
    }

    setState(() {
      _raceSteps = steps;
      _currentStepIndex = 0;
    });
  }

  void _startRace() {
    setState(() {
      _isRacing = true;
      _isPaused = false;
      _isFinished = false;
      _totalElapsedSeconds = 0;
      _currentSplitSeconds = 0;
      _accumulatedElapsedSeconds = 0;
      _currentSplitAccumulatedSeconds = 0;
      _currentStepIndex = 0;
      _completedSplits.clear();
      _raceStartTime = DateTime.now();
      _splitStartTime = DateTime.now();
    });

    _soundService.playWorkBeep();
    _announceCurrentStep();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused && _isRacing && !_isFinished) {
        _syncRealTime();
      }
    });
  }

  void _announceCurrentStep() {
    if (_currentStepIndex < _raceSteps.length) {
      final step = _raceSteps[_currentStepIndex];
      final title = step['title'] as String;
      _voiceCoach.speak(title);
    }
  }

  void _pauseResume() {
    if (_isPaused) {
      // Resume
      _raceStartTime = DateTime.now();
      _splitStartTime = DateTime.now();
      setState(() => _isPaused = false);
      _soundService.playWorkBeep();
    } else {
      // Pause
      _accumulatedElapsedSeconds = _totalElapsedSeconds;
      _currentSplitAccumulatedSeconds = _currentSplitSeconds;
      setState(() => _isPaused = true);
      _soundService.playRestBeep();
    }
  }

  void _recordSplit() {
    if (!_isRacing || _isFinished) return;

    final currentStep = _raceSteps[_currentStepIndex];
    final split = HyroxRaceSplit(
      stepIndex: _currentStepIndex + 1,
      name: currentStep['title'] as String,
      targetDesc: currentStep['target'] as String,
      splitDurationSeconds: _currentSplitSeconds,
      elapsedSecondsAtSplit: _totalElapsedSeconds,
      isRoxzone: currentStep['type'] == 'roxzone',
      isRun: currentStep['type'] == 'run',
    );

    _completedSplits.insert(0, split); // newest first for display
    HapticFeedback.heavyImpact();
    _soundService.playWorkBeep();

    if (_currentStepIndex + 1 < _raceSteps.length) {
      setState(() {
        _currentStepIndex++;
        _currentSplitSeconds = 0;
        _currentSplitAccumulatedSeconds = 0;
        _splitStartTime = DateTime.now();
      });
      _announceCurrentStep();
    } else {
      _finishRace();
    }
  }

  void _finishRace() {
    _timer?.cancel();
    setState(() {
      _isRacing = false;
      _isFinished = true;
    });

    _soundService.playCompleteFanfare();
    _voiceCoach.speak('Race Finished! Congratulations!');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFinishSummaryModal();
    });
  }

  void _resetRace() {
    _timer?.cancel();
    setState(() {
      _isRacing = false;
      _isPaused = false;
      _isFinished = false;
      _totalElapsedSeconds = 0;
      _currentSplitSeconds = 0;
      _currentStepIndex = 0;
      _completedSplits.clear();
    });
  }

  int get _paceDeltaSeconds {
    if (_targetFinishSeconds <= 0 || _raceSteps.isEmpty) return 0;
    final expectedTotalSecs = _targetFinishSeconds;
    final expectedSecsPerStep = expectedTotalSecs / _raceSteps.length;
    final targetElapsedAtThisStep = (expectedSecsPerStep * (_currentStepIndex + 1)).round();
    return _totalElapsedSeconds - targetElapsedAtThisStep;
  }

  void _showFinishSummaryModal() {
    HyroxRaceFinishModal.show(
      context: context,
      totalElapsedSeconds: _totalElapsedSeconds,
      division: _division,
      raceMode: _raceMode,
      includeRoxzone: _includeRoxzone,
      completedSplits: _completedSplits,
      totalSteps: _raceSteps.length,
      onLogSaved: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('HYROX Race results saved to Workout Log!'),
              backgroundColor: Color(0xFF00E676),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeColor = HyroxData.hyroxYellow;

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'HYROX',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n?.hyroxRaceSimulator ?? 'Race Simulator',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Standards & Weights',
            icon: Icon(Icons.menu_book_rounded, color: themeColor),
            onPressed: () => HyroxStandardsSheet.show(context, initialDivision: _division),
          ),
        ],
      ),
      body: SafeArea(
        child: _isRacing
            ? HyroxRaceActiveView(
                raceSteps: _raceSteps,
                currentStepIndex: _currentStepIndex,
                completedSplits: _completedSplits,
                totalElapsedSeconds: _totalElapsedSeconds,
                currentSplitSeconds: _currentSplitSeconds,
                paceDeltaSeconds: _paceDeltaSeconds,
                division: _division,
                isPaused: _isPaused,
                onRecordSplit: _recordSplit,
                onPauseResume: _pauseResume,
                onFinishEarly: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF1E1E1E),
                      title: const Text('Finish HYROX Race?', style: TextStyle(color: Colors.white)),
                      content: const Text(
                        'End race now and review your current split summary?',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            _resetRace();
                          },
                          child: const Text('DISCARD & RESET', style: TextStyle(color: Color(0xFFFF5252))),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text(l10n?.cancel ?? 'Cancel', style: const TextStyle(color: Colors.white54)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: themeColor, foregroundColor: Colors.black),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            _finishRace();
                          },
                          child: const Text('FINISH NOW'),
                        ),
                      ],
                    ),
                  );
                },
              )
            : HyroxRaceSetupView(
                raceMode: _raceMode,
                onRaceModeChanged: (mode) {
                  setState(() {
                    _raceMode = mode;
                    _rebuildRaceSteps();
                  });
                },
                division: _division,
                onDivisionChanged: (div) => setState(() => _division = div),
                targetFinishSeconds: _targetFinishSeconds,
                onTargetFinishSecondsChanged: (secs) => setState(() => _targetFinishSeconds = secs),
                includeRoxzone: _includeRoxzone,
                onIncludeRoxzoneChanged: (val) {
                  setState(() {
                    _includeRoxzone = val;
                    _rebuildRaceSteps();
                  });
                },
              ),
      ),
      bottomNavigationBar: _isRacing
          ? null
          : Container(
              color: const Color(0xFF121212),
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                      shadowColor: themeColor.withValues(alpha: 0.5),
                    ),
                    onPressed: _startRace,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            l10n?.startRace ?? 'START HYROX RACE',
                            style: const TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
