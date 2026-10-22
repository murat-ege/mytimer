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

class HyroxDoublesTimerScreen extends StatefulWidget {
  const HyroxDoublesTimerScreen({super.key});

  @override
  State<HyroxDoublesTimerScreen> createState() => _HyroxDoublesTimerScreenState();
}

class _HyroxDoublesTimerScreenState extends State<HyroxDoublesTimerScreen> {
  final SoundService _soundService = SoundService();
  final VoiceCoachService _voiceCoach = VoiceCoachService();
  final WorkoutLogRepository _logRepository = WorkoutLogRepository();

  int _switchIntervalSeconds = 45; // 30s, 45s, 60s, 90s, 120s
  int _totalSwitches = 16; // 8 rounds each partner
  final int _prepSeconds = 0;
  String _partnerAName = 'Partner A';
  String _partnerBName = 'Partner B';

  // Execution state
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isPrep = false;

  int _secondsRemaining = 45;
  int _currentSwitch = 1;
  bool _isPartnerA = true;
  int _totalElapsedSeconds = 0;

  Timer? _timer;
  late final AppLifecycleListener _lifecycleListener;

  static const Color _partnerAColor = Color(0xFFFFE600); // HYROX Yellow
  static const Color _partnerBColor = Color(0xFF00E5FF); // Electric Cyan

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: () {},
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lifecycleListener.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
      _isPrep = _prepSeconds > 0;
      _secondsRemaining = _prepSeconds > 0 ? _prepSeconds : _switchIntervalSeconds;
      _currentSwitch = 1;
      _isPartnerA = true;
      _totalElapsedSeconds = 0;
    });

    if (_isPrep) {
      _voiceCoach.speak('Get Ready! 10 seconds');
    } else {
      _soundService.playWorkBeep();
      _voiceCoach.speak('$_partnerAName, Go!');
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (_isPaused || !_isRunning) return;

    setState(() {
      _totalElapsedSeconds++;
      if (_secondsRemaining > 1) {
        _secondsRemaining--;
        if (_secondsRemaining <= 3) {
          _soundService.playCountdownBeep();
        }
      } else {
        // Transition
        if (_isPrep) {
          _isPrep = false;
          _secondsRemaining = _switchIntervalSeconds;
          _soundService.playWorkBeep();
          _voiceCoach.speak('$_partnerAName, Go!');
          HapticFeedback.heavyImpact();
        } else {
          // Switch partner
          if (_currentSwitch < _totalSwitches) {
            _currentSwitch++;
            _isPartnerA = !_isPartnerA;
            _secondsRemaining = _switchIntervalSeconds;
            _soundService.playWorkBeep();
            final activeName = _isPartnerA ? _partnerAName : _partnerBName;
            _voiceCoach.speak('Switch! $activeName, Work!');
            HapticFeedback.heavyImpact();
          } else {
            _finishWorkout();
          }
        }
      }
    });
  }

  void _manualSwitch() {
    if (!_isRunning || _isPrep) return;
    HapticFeedback.heavyImpact();
    setState(() {
      if (_currentSwitch < _totalSwitches) {
        _currentSwitch++;
        _isPartnerA = !_isPartnerA;
        _secondsRemaining = _switchIntervalSeconds;
        _soundService.playWorkBeep();
        final activeName = _isPartnerA ? _partnerAName : _partnerBName;
        _voiceCoach.speak('Switch! $activeName, Work!');
      } else {
        _finishWorkout();
      }
    });
  }

  void _pauseResume() {
    setState(() => _isPaused = !_isPaused);
    if (_isPaused) {
      _soundService.playRestBeep();
    } else {
      _soundService.playWorkBeep();
    }
  }

  void _finishWorkout() {
    _timer?.cancel();
    setState(() => _isRunning = false);
    _soundService.playCompleteFanfare();
    _voiceCoach.speak('Workout Complete! Great teamwork!');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFinishDialog();
    });
  }

  void _showFinishDialog() {
    final noteCtrl = TextEditingController();
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: Color(0xFFFFE600)),
            SizedBox(width: 8),
            Text('DOUBLES COMPLETE!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Time: ${_formatTime(_totalElapsedSeconds)} • $_totalSwitches Partner Switches',
              style: const TextStyle(color: Color(0xFFFFE600), fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: l10n?.workoutNote ?? 'Workout Note',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'Station, distance, reps or team notes...',
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
              backgroundColor: const Color(0xFFFFE600),
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final log = WorkoutLog(
                id: const Uuid().v4(),
                timerType: 'hyrox',
                title: 'HYROX DOUBLES (${_switchIntervalSeconds}s Switch x $_totalSwitches)',
                defaultDefinition: 'Partner Switch Timer • $_partnerAName & $_partnerBName',
                userNote: noteCtrl.text.trim(),
                totalDurationSeconds: _totalElapsedSeconds,
                completedAt: DateTime.now(),
                completedRounds: _totalSwitches,
                totalRounds: _totalSwitches,
              );
              await _logRepository.saveLog(log);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Doubles workout saved to Workout Log!'),
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

  String _formatTime(int totalSeconds) {
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
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
                l10n?.hyroxDoublesTimer ?? 'Doubles & Relay (IGYG)',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _isRunning ? _buildRunningView(l10n) : _buildSetupView(l10n, themeColor),
      ),
      bottomNavigationBar: _isRunning
          ? null
          : Container(
              color: const Color(0xFF121212),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
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
                    onPressed: _startTimer,
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded, color: Colors.black, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'START DOUBLES TIMER',
                            style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 1.2),
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

  Widget _buildSetupView(AppLocalizations? l10n, Color themeColor) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // Intro Card
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
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.people_alt_rounded, color: Color(0xFFFFE600), size: 28),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'I GO YOU GO (IGYG) SWITCH TIMER',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1.1),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Optimize pacing for HYROX Doubles & Relay. Keep transitions rapid and seamless with loud whistle cues and dual partner color changes.',
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Switch Interval Selector
        Text(
          l10n?.switchInterval ?? 'SWITCH INTERVAL DURATION',
          style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [30, 45, 60, 90, 120].map((secs) {
            final isSelected = _switchIntervalSeconds == secs;
            return ChoiceChip(
              label: Text(
                '${secs}s Switch',
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              selected: isSelected,
              selectedColor: themeColor,
              backgroundColor: const Color(0xFF1E1E1E),
              side: BorderSide(color: isSelected ? themeColor : Colors.white12),
              onSelected: (val) {
                if (val) setState(() => _switchIntervalSeconds = secs);
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Total Switches
        const Text(
          'TOTAL SWITCHES / ROUNDS',
          style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [8, 12, 16, 20, 24, 30].map((count) {
            final isSelected = _totalSwitches == count;
            final each = count ~/ 2;
            return ChoiceChip(
              label: Text(
                '$count Total ($each each)',
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              selectedColor: themeColor,
              backgroundColor: const Color(0xFF1E1E1E),
              side: BorderSide(color: isSelected ? themeColor : Colors.white12),
              onSelected: (val) {
                if (val) setState(() => _totalSwitches = count);
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Partner Custom Names
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _partnerAName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: l10n?.partnerA ?? 'PARTNER A',
                  labelStyle: const TextStyle(color: _partnerAColor, fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: _partnerAColor)),
                ),
                onChanged: (val) => _partnerAName = val.trim().isEmpty ? 'Partner A' : val.trim(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: _partnerBName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: l10n?.partnerB ?? 'PARTNER B',
                  labelStyle: const TextStyle(color: _partnerBColor, fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: _partnerBColor)),
                ),
                onChanged: (val) => _partnerBName = val.trim().isEmpty ? 'Partner B' : val.trim(),
              ),
            ),
          ],
        ),

      ],
    );
  }

  Widget _buildRunningView(AppLocalizations? l10n) {
    final activeColor = _isPrep
        ? const Color(0xFFFFB300)
        : (_isPartnerA ? _partnerAColor : _partnerBColor);
    final activeName = _isPrep
        ? 'GET READY'
        : (_isPartnerA ? _partnerAName.toUpperCase() : _partnerBName.toUpperCase());

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      color: activeColor.withValues(alpha: 0.08),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Top switch header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _isPrep ? 'PREP' : 'SWITCH $_currentSwitch OF $_totalSwitches',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
              Text(
                'Total Time: ${_formatTime(_totalElapsedSeconds)}',
                style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const Spacer(),

          // Giant Active Partner Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: activeColor, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_isPrep ? Icons.hourglass_top_rounded : Icons.flash_on_rounded, color: activeColor, size: 28),
                const SizedBox(width: 10),
                Text(
                  _isPrep ? 'GET READY' : '$activeName - WORK',
                  style: TextStyle(
                    color: activeColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Giant Countdown Number
          FittedBox(
            child: Text(
              _secondsRemaining.toString().padLeft(2, '0'),
              style: TextStyle(
                color: activeColor,
                fontSize: 130,
                fontWeight: FontWeight.w900,
                letterSpacing: -2,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            _isPrep
                ? 'Countdown to start...'
                : 'Next switch: ${_isPartnerA ? _partnerBName : _partnerAName}',
            style: const TextStyle(color: Colors.white54, fontSize: 15, fontWeight: FontWeight.bold),
          ),

          const Spacer(),

          // Early Switch button
          if (!_isPrep)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.sync_rounded, color: Colors.black),
                label: Text(
                  l10n?.switchPartner ?? 'SWITCH PARTNER NOW!',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isPaused ? null : _manualSwitch,
              ),
            ),

          const SizedBox(height: 12),

          // Pause / Finish controls
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, color: Colors.white70),
                  label: Text(_isPaused ? (l10n?.resume ?? 'RESUME') : (l10n?.pause ?? 'PAUSE'), style: const TextStyle(color: Colors.white70)),
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
                  label: const Text('FINISH', style: TextStyle(color: Color(0xFFFF5252))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF5252)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _finishWorkout,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
