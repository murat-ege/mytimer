import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../data/hyrox_data.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/workout_log.dart';
import '../../repositories/workout_log_repository.dart';
import '../../services/sound_service.dart';
import '../../services/voice_coach_service.dart';
import 'hyrox_standards_sheet.dart';

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
  final WorkoutLogRepository _logRepository = WorkoutLogRepository();

  // Setup options
  String _raceMode = 'full'; // 'full' (8 stations), 'half' (4 stations), 'relay' (2 stations)
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

  /// Pacing calculation: compares total elapsed vs expected target at this step
  int get _paceDeltaSeconds {
    if (_targetFinishSeconds <= 0 || _raceSteps.isEmpty) return 0;
    // Expected time at current step fraction
    final fraction = (_currentStepIndex + 1) / _raceSteps.length;
    final targetAtCurrent = (_targetFinishSeconds * fraction).round();
    return _totalElapsedSeconds - targetAtCurrent;
  }

  void _showFinishSummaryModal() {
    final noteCtrl = TextEditingController();
    final l10n = AppLocalizations.of(context);
    final themeColor = HyroxData.hyroxYellow;

    // Calculate Roxzone total
    final totalRoxzoneSecs = _completedSplits
        .where((s) => s.isRoxzone)
        .fold<int>(0, (sum, s) => sum + s.splitDurationSeconds);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.90,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF141414),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFFFFE600), width: 2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.emoji_events_rounded, color: themeColor, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HYROX FINISHER!',
                          style: TextStyle(
                            color: Color(0xFFFFE600),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'Total Time: ${_formatTime(_totalElapsedSeconds)} • ${_division.displayName}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Metric badges
              Row(
                children: [
                  Expanded(
                    child: _finishMetricCard(
                      'RACE TIME',
                      _formatTime(_totalElapsedSeconds),
                      themeColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _finishMetricCard(
                      'TOTAL SPLITS',
                      '${_completedSplits.length} recorded',
                      const Color(0xFF00E5FF),
                    ),
                  ),
                  if (_includeRoxzone) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: _finishMetricCard(
                        'ROXZONE',
                        _formatTime(totalRoxzoneSecs),
                        const Color(0xFFFF9100),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              TextField(
                controller: noteCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: l10n?.workoutNote ?? 'Race Notes',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'Pacing, heart rate, gear, Roxzone strategy...',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 14),
              const Text(
                'RACE SPLIT SUMMARY',
                style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _completedSplits.length,
                    separatorBuilder: (_, _) => const Divider(color: Colors.white10, height: 1),
                    itemBuilder: (ctx, idx) {
                      // reverse display to chronological
                      final split = _completedSplits[_completedSplits.length - 1 - idx];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Row(
                          children: [
                            Text(
                              '#${split.stepIndex}',
                              style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    split.name,
                                    style: TextStyle(
                                      color: split.isRoxzone ? const Color(0xFFFF9100) : Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    split.targetDesc,
                                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  split.formattedSplit,
                                  style: TextStyle(
                                    color: themeColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  'Total: ${split.formattedTotal}',
                                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(l10n?.cancel ?? 'DISCARD', style: const TextStyle(color: Colors.white54)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save_rounded, color: Colors.black),
                      label: Text(l10n?.save ?? 'SAVE TO LOG', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        final definitionBuffer = StringBuffer();
                        definitionBuffer.writeln('HYROX ${_division.displayName} • $_raceMode Race');
                        for (final s in _completedSplits.reversed) {
                          definitionBuffer.writeln('${s.name}: ${s.formattedSplit} (Total: ${s.formattedTotal})');
                        }

                        final log = WorkoutLog(
                          id: const Uuid().v4(),
                          timerType: 'hyrox',
                          title: 'HYROX ${_raceMode.toUpperCase()} (${_formatTime(_totalElapsedSeconds)})',
                          defaultDefinition: definitionBuffer.toString(),
                          userNote: noteCtrl.text.trim(),
                          totalDurationSeconds: _totalElapsedSeconds,
                          completedAt: DateTime.now(),
                          completedRounds: _completedSplits.length,
                          totalRounds: _raceSteps.length,
                        );

                        await _logRepository.saveLog(log);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('HYROX Race results saved to Workout Log!'),
                              backgroundColor: Color(0xFF00E676),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _finishMetricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final mins = (totalSeconds % 3600) ~/ 60;
    final secs = totalSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
        child: _isRacing ? _buildRacingView(l10n, themeColor) : _buildPreRaceSetup(l10n, themeColor),
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

  // Pre-race configuration screen
  Widget _buildPreRaceSetup(AppLocalizations? l10n, Color themeColor) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // Hero card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF262626), Color(0xFF161616)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: themeColor.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.flag_rounded, color: themeColor, size: 28),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'OFFICIAL HYROX RACE TIMER',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Full 8x1km & 8 workout stations split tracker with Roxzone transition timing and real-time pace delta.',
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Race Mode Selector
        const Text(
          'RACE FORMAT',
          style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _formatOptionCard('full', 'Full Race', '8 Runs + 8 Stations', themeColor),
            const SizedBox(width: 8),
            _formatOptionCard('half', 'Half Hyrox', '4 Runs + 4 Stations', themeColor),
            const SizedBox(width: 8),
            _formatOptionCard('relay', 'Relay Leg', '2 Runs + 2 Stations', themeColor),
          ],
        ),

        const SizedBox(height: 20),

        // Division Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n?.division ?? 'DIVISION / CATEGORY',
              style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
            GestureDetector(
              onTap: () => HyroxStandardsSheet.show(context, initialDivision: _division),
              child: Text(
                'View Weights >',
                style: TextStyle(color: themeColor, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<HyroxDivision>(
              value: _division,
              dropdownColor: const Color(0xFF1E1E1E),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down_rounded, color: themeColor),
              items: HyroxDivision.values.map((div) {
                return DropdownMenuItem(
                  value: div,
                  child: Text(
                    div.displayName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
              onChanged: (div) {
                if (div != null) setState(() => _division = div);
              },
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Target Finish Time
        Text(
          l10n?.targetFinishTime ?? 'TARGET FINISH TIME (PACE INDICATOR)',
          style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: HyroxData.targetRaceTimes.map((item) {
            final secs = item['seconds'] as int;
            final isSelected = _targetFinishSeconds == secs;
            return ChoiceChip(
              label: Text(
                '${item['title']}',
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              selectedColor: themeColor,
              backgroundColor: const Color(0xFF1E1E1E),
              side: BorderSide(color: isSelected ? themeColor : Colors.white12),
              onSelected: (val) {
                if (val) setState(() => _targetFinishSeconds = secs);
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // Roxzone Switch
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9100).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.sync_alt_rounded, color: Color(0xFFFF9100), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.roxzoneTracking ?? 'Roxzone Transition Splits',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Record In/Out transition times separately',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _includeRoxzone,
                activeThumbColor: themeColor,
                activeTrackColor: themeColor.withValues(alpha: 0.3),
                onChanged: (val) {
                  setState(() {
                    _includeRoxzone = val;
                    _rebuildRaceSteps();
                  });
                },
              ),
            ],
          ),
        ),

      ],
    );
  }

  Widget _formatOptionCard(String id, String title, String subtitle, Color themeColor) {
    final isSelected = _raceMode == id;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _raceMode = id;
            _rebuildRaceSteps();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? themeColor.withValues(alpha: 0.15) : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? themeColor : Colors.white12,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? themeColor : Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Active in-race split tracking screen
  Widget _buildRacingView(AppLocalizations? l10n, Color themeColor) {
    final currentStep = _raceSteps[_currentStepIndex];
    final isLastStep = _currentStepIndex == _raceSteps.length - 1;
    final nextStep = !isLastStep ? _raceSteps[_currentStepIndex + 1] : null;

    final HyroxStationInfo? station = currentStep['station'] as HyroxStationInfo?;
    final weight = station?.getWeightFor(_division);

    // Pace delta formatting
    final delta = _paceDeltaSeconds;
    final isAhead = delta < 0;
    final deltaText = delta == 0
        ? (l10n?.onPace ?? 'On Target')
        : (isAhead ? '-${_formatTime(delta.abs())} ${l10n?.ahead ?? "Ahead"}' : '+${_formatTime(delta)} ${l10n?.behind ?? "Behind"}');
    final deltaColor = delta == 0 ? Colors.white70 : (isAhead ? const Color(0xFF00E676) : const Color(0xFFFF5252));

    return Column(
      children: [
        // Top status bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF181818),
            border: Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Step counter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'LEG ${_currentStepIndex + 1} / ${_raceSteps.length}',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11),
                ),
              ),

              // Pace indicator badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: deltaColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: deltaColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAhead ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      color: deltaColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      deltaText,
                      style: TextStyle(color: deltaColor, fontSize: 11, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),

              // Division badge
              Text(
                _division.shortName,
                style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // Giant Timers section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Cumulative Race Time
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RACE TIME',
                        style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _formatTime(_totalElapsedSeconds),
                          style: TextStyle(
                            color: _isPaused ? Colors.white38 : themeColor,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Current Split Time
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SPLIT TIME',
                        style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _formatTime(_currentSplitSeconds),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Active Station Focus Card
        Expanded(
          flex: 4,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: currentStep['type'] == 'roxzone'
                    ? [const Color(0xFF261800), const Color(0xFF140C00)]
                    : [const Color(0xFF202020), const Color(0xFF121212)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: currentStep['type'] == 'roxzone' ? const Color(0xFFFF9100) : themeColor,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  currentStep['icon'] as IconData,
                  color: currentStep['type'] == 'roxzone' ? const Color(0xFFFF9100) : themeColor,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  currentStep['title'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  currentStep['target'] as String,
                  style: TextStyle(
                    color: themeColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (weight != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      'Weight: $weight',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                if (nextStep != null) ...[
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white38, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Up Next: ${nextStep['title']}',
                        style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Live Splits List (Recent 3)
        if (_completedSplits.isNotEmpty)
          Container(
            height: 90,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF181818),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: ListView.separated(
              itemCount: _completedSplits.length,
              separatorBuilder: (_, _) => const Divider(color: Colors.white10, height: 1),
              itemBuilder: (ctx, idx) {
                final split = _completedSplits[idx];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '#${split.stepIndex}',
                            style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            split.name,
                            style: TextStyle(
                              color: split.isRoxzone ? const Color(0xFFFF9100) : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        split.formattedSplit,
                        style: TextStyle(color: themeColor, fontSize: 13, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 12),

        // Split & Control Actions
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            children: [
              // Giant Split Button
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 6,
                  ),
                  onPressed: _isPaused ? null : _recordSplit,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.black, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        isLastStep ? 'FINISH RACE!' : (l10n?.nextSplit ?? 'RECORD SPLIT / NEXT STATION'),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Bottom control bar (Pause & Finish early)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, color: Colors.white70),
                      label: Text(
                        _isPaused ? (l10n?.resume ?? 'RESUME') : (l10n?.pause ?? 'PAUSE'),
                        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _pauseResume,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.stop_rounded, color: Color(0xFFFF5252)),
                      label: const Text(
                        'STOP / FINISH',
                        style: TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF5252)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
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
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
