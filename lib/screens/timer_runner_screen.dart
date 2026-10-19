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
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _controller = WorkoutController(routine: widget.routine);
    _controller.addListener(_onControllerUpdate);

    _lifecycleListener = AppLifecycleListener(
      onResume: () => _controller.syncWithRealTime(),
      onHide: () => _controller.syncWithRealTime(),
    );

    // Auto start after a brief moment so user can get ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.start();
    });
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _toggleOrientation() {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    if (isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: isLandscape
            ? _buildLandscapeLayout(l10n, curSegment, phase, primaryColor)
            : _buildPortraitLayout(l10n, curSegment, phase, primaryColor),
      ),
    );
  }

  Widget _buildLandscapeLayout(
    AppLocalizations? l10n,
    ExecutionSegment? curSegment,
    TimerPhase phase,
    Color primaryColor,
  ) {
    return Column(
      children: [
        // Slim Top Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _soundService.soundEnabled ? Icons.volume_up : Icons.volume_off,
                      color: _soundService.soundEnabled ? primaryColor : Colors.white38,
                      size: 22,
                    ),
                    onPressed: () {
                      setState(() {
                        _soundService.soundEnabled = !_soundService.soundEnabled;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.screen_lock_landscape,
                      color: Colors.white70,
                      size: 22,
                    ),
                    onPressed: _toggleOrientation,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Linear Progress Bar
        LinearProgressIndicator(
          value: _controller.overallProgress,
          backgroundColor: Colors.white12,
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          minHeight: 3,
        ),

        // Main Landscape Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Row(
              children: [
                // Left Panel: Stats and Info
                Flexible(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Round Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          _controller.isFinished
                              ? (l10n?.completed ?? 'TIME!')
                              : (curSegment != null && curSegment.roundIndex > 0)
                                  ? '${l10n?.round ?? "ROUND"} ${_controller.currentRound} / ${_controller.totalRounds}'
                                  : (l10n?.prep ?? 'GET READY'),
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      // Phase Name
                      Text(
                        _controller.isFinished
                            ? (l10n?.finished ?? 'WORKOUT COMPLETE!')
                            : _getLocalizedTitle(curSegment, l10n),
                        key: ValueKey('${curSegment?.title}_${_controller.currentSegmentIndex}_land'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),

                      // Total Elapsed
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, color: Colors.white54, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _controller.currentPhase == TimerPhase.prep
                                  ? '${l10n?.prep ?? "Prep"}: ${_controller.formattedRemainingTime}'
                                  : '${l10n?.totalTime ?? "Total"}: ${_controller.formattedTotalElapsed} / ${_controller.formattedTotalWorkoutTime}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      // Next interval
                      if (!_controller.isFinished &&
                          _controller.currentSegmentIndex + 1 < _controller.segments.length)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${l10n?.next ?? "Next"}: ${_getLocalizedTitle(_controller.segments[_controller.currentSegmentIndex + 1], l10n)} (${_controller.segments[_controller.currentSegmentIndex + 1].durationSeconds} ${l10n?.seconds ?? "s"})',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Center Panel: Massive Digits
                Expanded(
                  flex: 5,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        _controller.formattedRemainingTime,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 160,
                          fontWeight: FontWeight.w900,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          letterSpacing: -2,
                          shadows: [
                            Shadow(
                              color: primaryColor.withValues(alpha: 0.4),
                              blurRadius: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Right Panel: Thumb controls
                Flexible(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.5),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            _controller.isRunning ? Icons.pause : Icons.play_arrow,
                            color: Colors.black,
                            size: 38,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Secondary Buttons Row (Reset, Prev, Next)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildLandscapeControlBtn(
                            icon: Icons.refresh,
                            tooltip: l10n?.reset ?? 'RESET',
                            onTap: _controller.reset,
                          ),
                          _buildLandscapeControlBtn(
                            icon: Icons.skip_previous,
                            tooltip: l10n?.skip ?? 'PREVIOUS',
                            onTap: _controller.skipPrevious,
                          ),
                          _buildLandscapeControlBtn(
                            icon: Icons.skip_next,
                            tooltip: l10n?.next ?? 'NEXT',
                            onTap: _controller.skipNext,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeControlBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: Colors.white70, size: 24),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(
    AppLocalizations? l10n,
    ExecutionSegment? curSegment,
    TimerPhase phase,
    Color primaryColor,
  ) {
    return Column(
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
                    icon: const Icon(
                      Icons.screen_lock_portrait,
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
                        ? (l10n?.finished ?? 'WORKOUT COMPLETE!')
                        : _getLocalizedTitle(curSegment, l10n),
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
                      const Icon(Icons.timer_outlined, color: Colors.white54, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _controller.currentPhase == TimerPhase.prep
                            ? '${l10n?.prep ?? "Hazırlık"}: ${_controller.formattedRemainingTime}'
                            : '${l10n?.totalTime ?? "Toplam"}: ${_controller.formattedTotalElapsed} / ${_controller.formattedTotalWorkoutTime}',
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
                      '${l10n?.next ?? "Next"}: ${_getLocalizedTitle(_controller.segments[_controller.currentSegmentIndex + 1], l10n)} (${_controller.segments[_controller.currentSegmentIndex + 1].durationSeconds} ${l10n?.seconds ?? "s"})',
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
                tooltip: l10n?.reset ?? 'RESET',
              ),

              // Skip Previous Button
              IconButton(
                onPressed: () {
                  _controller.skipPrevious();
                },
                icon: const Icon(Icons.skip_previous, color: Colors.white70, size: 36),
                tooltip: l10n?.skip ?? 'SKIP',
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
                tooltip: l10n?.next ?? 'NEXT',
              ),

              // Exit Button
              IconButton(
                onPressed: () {
                  _controller.pause();
                  _showExitDialog();
                },
                icon: const Icon(Icons.stop_circle_outlined, color: Colors.white70, size: 36),
                tooltip: l10n?.quit ?? 'QUIT',
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getLocalizedTitle(ExecutionSegment? segment, AppLocalizations? l10n) {
    if (segment == null) return '';
    switch (segment.phase) {
      case TimerPhase.prep:
        return l10n?.prep ?? 'PREP';
      case TimerPhase.restBetweenSets:
        return l10n?.restBetweenSets ?? 'REST BETWEEN ROUNDS';
      case TimerPhase.work:
        if (segment.title == 'ÇALIŞMA' || segment.title == 'WORK') {
          return l10n?.work ?? 'WORK';
        }
        return segment.title.toUpperCase();
      case TimerPhase.rest:
        if (segment.title == 'DİNLENME' || segment.title == 'REST') {
          return l10n?.rest ?? 'REST';
        }
        return segment.title.toUpperCase();
      case TimerPhase.cooldown:
        return l10n?.cooldown ?? 'COOLDOWN';
      case TimerPhase.finished:
        return l10n?.finished ?? 'WORKOUT COMPLETE!';
    }
  }

  void _showExitDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(l10n?.exitWorkoutTitle ?? 'Exit Workout?', style: const TextStyle(color: Colors.white)),
        content: Text(
          l10n?.exitWorkoutMessage ?? 'The current workout will be stopped. Are you sure you want to quit?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _controller.resume();
            },
            child: Text(l10n?.continueWorkout ?? 'RESUME', style: const TextStyle(color: Color(0xFF00E676))),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text(l10n?.quit ?? 'QUIT', style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
