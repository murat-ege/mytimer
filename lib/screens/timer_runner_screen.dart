import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/workout_controller.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/custom_routine.dart';
import '../models/timer_phase.dart';
import '../services/sound_service.dart';

class TimerRunnerScreen extends StatefulWidget {
  final CustomRoutine routine;

  const TimerRunnerScreen({super.key, required this.routine});

  @override
  State<TimerRunnerScreen> createState() => _TimerRunnerScreenState();
}

class _TimerRunnerScreenState extends State<TimerRunnerScreen> {
  late final WorkoutController _controller;
  final SoundService _soundService = SoundService();
  bool _isLandscape = false;

  @override
  void initState() {
    super.initState();
    _controller = WorkoutController(routine: widget.routine);
    _controller.addListener(_onControllerUpdate);

    // Auto start after a brief moment so user can get ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.start();
    });
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _toggleOrientation() {
    setState(() {
      _isLandscape = !_isLandscape;
    });
    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final curSegment = _controller.currentSegment;
    final phase = _controller.currentPhase;
    final primaryColor = phase.primaryColor;
    final backgroundColor = phase.backgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () {
                      _controller.pause();
                      _showExitDialog();
                    },
                  ),
                  Expanded(
                    child: Text(
                      widget.routine.name.toUpperCase(),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _soundService.soundEnabled
                              ? Icons.volume_up
                              : Icons.volume_off,
                          color: _soundService.soundEnabled
                              ? primaryColor
                              : Colors.white38,
                          size: 26,
                        ),
                        onPressed: () {
                          setState(() {
                            _soundService.soundEnabled = !_soundService.soundEnabled;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _isLandscape
                              ? Icons.screen_lock_landscape
                              : Icons.screen_lock_portrait,
                          color: Colors.white70,
                          size: 26,
                        ),
                        onPressed: _toggleOrientation,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Linear Progress Bar for total workout
            LinearProgressIndicator(
              value: _controller.overallProgress,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 4,
            ),

            // Main Display Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Round Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        _controller.isFinished
                            ? (l10n?.completed ?? 'TAMAMLANDI!')
                            : (curSegment != null && curSegment.roundIndex > 0)
                                ? '${l10n?.round ?? "TUR"} ${_controller.currentRound} / ${_controller.totalRounds}'
                                : (l10n?.prep ?? 'HAZIRLIK'),
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Phase Name (WORK, REST, etc.)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _controller.isFinished
                            ? (l10n?.finished ?? 'TEBRİKLER!')
                            : (curSegment?.title.toUpperCase() ?? phase.displayName),
                        key: ValueKey('${curSegment?.title}_${_controller.currentSegmentIndex}'),
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Huge Digits Timer
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _controller.formattedRemainingTime,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 130,
                          fontWeight: FontWeight.w900,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          letterSpacing: -2,
                          shadows: [
                            Shadow(
                              color: primaryColor.withValues(alpha: 0.4),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Total Elapsed & Next Interval Info
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timer_outlined, color: Colors.white54, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Toplam: ${_controller.formattedTotalElapsed}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (!_controller.isFinished &&
                        _controller.currentSegmentIndex + 1 < _controller.segments.length)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Sıradaki: ${_controller.segments[_controller.currentSegmentIndex + 1].title} (${_controller.segments[_controller.currentSegmentIndex + 1].durationSeconds} sn)',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Controls Bar (Play/Pause, Skip, Reset)
            Container(
              padding: const EdgeInsets.only(bottom: 24, top: 12, left: 24, right: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reset Button
                  IconButton(
                    onPressed: () {
                      _controller.reset();
                    },
                    icon: const Icon(Icons.refresh, color: Colors.white70, size: 36),
                    tooltip: 'Sıfırla',
                  ),

                  // Skip Previous Button
                  IconButton(
                    onPressed: () {
                      _controller.skipPrevious();
                    },
                    icon: const Icon(Icons.skip_previous, color: Colors.white70, size: 36),
                    tooltip: 'Önceki',
                  ),

                  // Play / Pause Primary Button
                  GestureDetector(
                    onTap: () {
                      if (_controller.isRunning) {
                        _controller.pause();
                      } else {
                        if (_controller.isPaused) {
                          _controller.resume();
                        } else {
                          _controller.start();
                        }
                      }
                    },
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _controller.isRunning ? Icons.pause : Icons.play_arrow,
                        color: Colors.black,
                        size: 46,
                      ),
                    ),
                  ),

                  // Skip Next Button
                  IconButton(
                    onPressed: () {
                      _controller.skipNext();
                    },
                    icon: const Icon(Icons.skip_next, color: Colors.white70, size: 36),
                    tooltip: 'Sonraki',
                  ),

                  // Exit Button
                  IconButton(
                    onPressed: () {
                      _controller.pause();
                      _showExitDialog();
                    },
                    icon: const Icon(Icons.stop_circle_outlined, color: Colors.white70, size: 36),
                    tooltip: 'Bitir',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Antrenmandan Çıkılsın mı?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Mevcut antrenman durdurulacak. Çıkmak istediğinize emin misiniz?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _controller.resume();
            },
            child: const Text('DEVAM ET', style: TextStyle(color: Color(0xFF00E676))),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('ÇIK', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
