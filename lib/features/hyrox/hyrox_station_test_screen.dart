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
import '../../shared/theme/app_typography.dart';

class HyroxStationTestScreen extends StatefulWidget {
  final int initialStationIndex;

  const HyroxStationTestScreen({
    super.key,
    this.initialStationIndex = 1,
  });

  @override
  State<HyroxStationTestScreen> createState() => _HyroxStationTestScreenState();
}

class _HyroxStationTestScreenState extends State<HyroxStationTestScreen> {
  final SoundService _soundService = SoundService();
  final VoiceCoachService _voiceCoach = VoiceCoachService();
  final WorkoutLogRepository _logRepository = WorkoutLogRepository();

  late int _selectedStationIndex;
  HyroxDivision _division = HyroxDivision.menOpen;

  bool _isRunning = false;
  bool _isPaused = false;
  int _elapsedMs = 0;
  final List<int> _splitsMs = [];

  Timer? _ticker;
  DateTime? _startTime;
  int _accumulatedMs = 0;
  late final AppLifecycleListener _lifecycleListener;

  static const Color _themeColor = Color(0xFFFFE600);

  @override
  void initState() {
    super.initState();
    _selectedStationIndex = widget.initialStationIndex;
    _lifecycleListener = AppLifecycleListener(
      onResume: _syncRealTime,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _lifecycleListener.dispose();
    super.dispose();
  }

  void _syncRealTime() {
    if (_isRunning && !_isPaused && _startTime != null) {
      final now = DateTime.now();
      setState(() {
        _elapsedMs = _accumulatedMs + now.difference(_startTime!).inMilliseconds;
      });
    }
  }

  HyroxStationInfo get _currentStation {
    return HyroxData.stations.firstWhere(
      (s) => s.index == _selectedStationIndex,
      orElse: () => HyroxData.stations.first,
    );
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
      _elapsedMs = 0;
      _accumulatedMs = 0;
      _splitsMs.clear();
      _startTime = DateTime.now();
    });

    _soundService.playWorkBeep();
    _voiceCoach.speak('${_currentStation.name} Test, Start!');

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_isRunning && !_isPaused) {
        _syncRealTime();
      }
    });
  }

  void _recordSplit() {
    if (!_isRunning) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _splitsMs.add(_elapsedMs);
    });
    _soundService.playWorkBeep();
  }

  void _pauseResume() {
    if (_isPaused) {
      _startTime = DateTime.now();
      setState(() => _isPaused = false);
      _soundService.playWorkBeep();
    } else {
      _accumulatedMs = _elapsedMs;
      setState(() => _isPaused = true);
      _soundService.playRestBeep();
    }
  }

  void _finishTest() {
    _ticker?.cancel();
    setState(() => _isRunning = false);
    _soundService.playCompleteFanfare();
    _voiceCoach.speak('${_currentStation.name} Complete! Well done!');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSaveDialog();
    });
  }

  void _showSaveDialog() {
    final l10n = AppLocalizations.of(context);
    final noteCtrl = TextEditingController();
    final totalSecs = _elapsedMs ~/ 1000;
    final formatted = _formatMs(_elapsedMs);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Row(
          children: [
            const Icon(Icons.emoji_events_rounded, color: _themeColor),
            const SizedBox(width: 8),
            Text('${_currentStation.name} Test PR', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time: $formatted • ${_currentStation.distanceOrReps}',
              style: const TextStyle(color: _themeColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              'Weight: ${_currentStation.getWeightFor(_division)} (${_division.displayName})',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: l10n?.workoutNote ?? 'Notes',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'Damper, split pace, fatigue level...',
                hintStyle: const TextStyle(color: Colors.white30),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n?.cancel ?? 'Cancel', style: const TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _themeColor,
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final log = WorkoutLog(
                id: const Uuid().v4(),
                timerType: 'hyrox',
                title: 'HYROX TEST: ${_currentStation.name.toUpperCase()} ($formatted)',
                defaultDefinition: '${_currentStation.distanceOrReps} • Weight: ${_currentStation.getWeightFor(_division)} • ${_division.displayName}',
                userNote: noteCtrl.text.trim(),
                totalDurationSeconds: totalSecs,
                completedAt: DateTime.now(),
              );
              await _logRepository.saveLog(log);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('HYROX Station Benchmark saved!'),
                    backgroundColor: Color(0xFF00E676),
                  ),
                );
              }
            },
            child: Text(l10n?.save ?? 'SAVE TO LOG', style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  String _formatMs(int ms, {bool showMs = true}) {
    final mins = ms ~/ 60000;
    final secs = (ms % 60000) ~/ 1000;
    final tenths = (ms % 1000) ~/ 100;
    final base = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    return showMs ? '$base.$tenths' : base;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final station = _currentStation;
    final weight = station.getWeightFor(_division);

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
                color: _themeColor,
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
                l10n?.hyroxBenchmarkTests ?? 'Benchmark Tests',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Station Selector Carousel / Pills
              if (!_isRunning) ...[
                const Text(
                  'SELECT HYROX STATION',
                  style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: HyroxData.stations.map((s) {
                      final isSelected = s.index == _selectedStationIndex;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(s.icon, size: 16, color: isSelected ? Colors.black : Colors.white70),
                              const SizedBox(width: 6),
                              Text('${s.index}. ${s.name}'),
                            ],
                          ),
                          selected: isSelected,
                          selectedColor: _themeColor,
                          backgroundColor: const Color(0xFF1E1E1E),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white70,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedStationIndex = s.index);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Station Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _themeColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _themeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(station.icon, color: _themeColor, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'STATION ${station.index}: ${station.name.toUpperCase()}',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (_isRunning) return;
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: const Color(0xFF1E1E1E),
                                    builder: (ctx) => SafeArea(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: HyroxDivision.values.map((d) {
                                            return ListTile(
                                              title: Text(d.displayName, style: const TextStyle(color: Colors.white)),
                                              trailing: d == _division ? const Icon(Icons.check, color: _themeColor) : null,
                                              onTap: () {
                                                setState(() => _division = d);
                                                Navigator.of(ctx).pop();
                                              },
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      '${station.distanceOrReps} • $weight',
                                      style: const TextStyle(color: _themeColor, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_drop_down, color: _themeColor, size: 18),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 24),
                    // Benchmark reference targets
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _benchmarkBadge('PRO / ELITE', station.proPace, const Color(0xFF00E676)),
                        _benchmarkBadge('OPEN TARGET', station.openPace, const Color(0xFFFFB300)),
                        _benchmarkBadge('ROOKIE GOAL', station.rookiePace, const Color(0xFF00E5FF)),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Giant Stopwatch Display
              Center(
                child: Column(
                  children: [
                    Text(
                      _formatMs(_elapsedMs),
                      style: AppTypography.timerDigits(
                        color: _isRunning ? _themeColor : Colors.white,
                        fontSize: 68,
                        letterSpacing: -1,
                      ),
                    ),
                    if (_splitsMs.isNotEmpty)
                      Text(
                        '${_splitsMs.length} Splits recorded',
                        style: const TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),

              const Spacer(),

              // Controls
              if (!_isRunning)
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _themeColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _startTimer,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            'START ${station.name.toUpperCase()} TEST',
                            style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    // Split button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.flag_rounded, color: Colors.black),
                        label: const Text(
                          'RECORD SPLIT',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _themeColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _recordSplit,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, color: Colors.white70),
                            label: Text(_isPaused ? 'RESUME' : 'PAUSE', style: const TextStyle(color: Colors.white70)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _pauseResume,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.stop_rounded, color: Color(0xFFFF5252)),
                            label: const Text('FINISH TEST', style: TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFFF5252)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _finishTest,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _benchmarkBadge(String title, String pace, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(pace, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
