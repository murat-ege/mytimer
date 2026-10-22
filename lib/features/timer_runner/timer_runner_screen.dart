import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/workout_controller.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/custom_routine.dart';
import '../../models/timer_phase.dart';
import '../../repositories/local_timer_repository.dart';
import '../../shared/theme/app_typography.dart';
import 'widgets/timer_finish_modal.dart';
import 'widgets/timer_runner_controls.dart';
import 'widgets/timer_utility_controls.dart';
import 'widgets/workout_info_dialog.dart';

class TimerRunnerScreen extends StatefulWidget {
  final CustomRoutine routine;

  const TimerRunnerScreen({super.key, required this.routine});

  @override
  State<TimerRunnerScreen> createState() => _TimerRunnerScreenState();
}

class _TimerRunnerScreenState extends State<TimerRunnerScreen> {
  late final WorkoutController _controller;
  late final AppLifecycleListener _lifecycleListener;

  final LocalTimerRepository _timerRepository = LocalTimerRepository();
  bool _confirmTimerExit = false;
  bool _hasShownFinishModal = false;
  bool _autoSaveWorkoutLog = true;

  @override
  void initState() {
    super.initState();
    _controller = WorkoutController(routine: widget.routine);
    _controller.addListener(_onControllerUpdate);

    _lifecycleListener = AppLifecycleListener(
      onResume: () => _controller.syncWithRealTime(),
      onHide: () => _controller.syncWithRealTime(),
    );

    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final s = await _timerRepository.getSettings();
      if (mounted) {
        setState(() {
          _confirmTimerExit = s.confirmTimerExit;
          _autoSaveWorkoutLog = s.autoSaveWorkoutLog;
        });
        if (s.autoStartTimer &&
            !_controller.isRunning &&
            !_controller.isPaused &&
            !_controller.isFinished) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted &&
                !_controller.isRunning &&
                !_controller.isPaused &&
                !_controller.isFinished) {
              _controller.start();
            }
          });
        }
      }
    } catch (_) {}
  }

  void _handleBackOrExit() {
    if (_confirmTimerExit && !_controller.isFinished) {
      _controller.pause();
      _showExitDialog();
    } else {
      _controller.pause();
      Navigator.of(context).pop();
    }
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
      if (_controller.isFinished && !_hasShownFinishModal) {
        _hasShownFinishModal = true;
        if (!_autoSaveWorkoutLog) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showFinishModal();
          });
        }
      }
    }
  }

  void _showFinishModal() {
    final log = _controller.recordedLog;
    if (log == null) return;
    TimerFinishModal.show(
      context: context,
      log: log,
      routine: widget.routine,
      formattedTotalElapsed: _controller.formattedTotalElapsed,
    );
  }

  void _showWorkoutInfo() {
    WorkoutInfoDialog.show(context, widget.routine);
  }

  void _toggleOrientation() {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    if (isLandscape) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
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
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return PopScope(
      canPop: !_confirmTimerExit || _controller.isFinished,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackOrExit();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            gradient: RadialGradient(
              center: Alignment(0.0, isLandscape ? 0.0 : -0.15),
              radius: 1.25,
              colors: [
                Color.alphaBlend(primaryColor.withValues(alpha: 0.35), backgroundColor),
                backgroundColor,
                Color.lerp(backgroundColor, Colors.black, 0.65)!,
              ],
              stops: const [0.0, 0.60, 1.0],
            ),
          ),
          child: SafeArea(
            child: isLandscape
                ? _buildLandscapeLayout(l10n, curSegment, phase, primaryColor)
                : _buildPortraitLayout(l10n, curSegment, phase, primaryColor),
          ),
        ),
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
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: _handleBackOrExit,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _showWorkoutInfo,
                  child: Text(
                    widget.routine.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.athleticHeader(
                      color: Colors.white,
                      fontSize: 17,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
              TimerUtilityControls(
                primaryColor: primaryColor,
                isLandscape: true,
                onToggleOrientation: _toggleOrientation,
              ),
            ],
          ),
        ),

        // Linear Progress Bar for total workout
        LinearProgressIndicator(
          value: _controller.overallProgress,
          backgroundColor: Colors.white12,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white60),
          minHeight: 2.5,
        ),
        const SizedBox(height: 1.5),
        // Linear Progress Bar for current interval (Work / Rest)
        LinearProgressIndicator(
          value: _controller.segmentProgress,
          backgroundColor: primaryColor.withValues(alpha: 0.15),
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          minHeight: 4.0,
        ),

        // Main Landscape Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Row(
              children: [
                // Left Panel: Stats and Info
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Round Indicator Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: primaryColor.withValues(alpha: 0.4), width: 1.5),
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
                            letterSpacing: 1.2,
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
                          fontSize: 26,
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
                              style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      // Next interval
                      if (!_controller.isFinished &&
                          _controller.currentSegmentIndex + 1 < _controller.segments.length)
                        Text(
                          '${l10n?.next ?? "Next"}: ${_getLocalizedTitle(_controller.segments[_controller.currentSegmentIndex + 1], l10n)} (${_controller.segments[_controller.currentSegmentIndex + 1].durationSeconds}s)',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Center Panel: Huge Digits Timer
                Expanded(
                  flex: 5,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _controller.formattedRemainingTime,
                        maxLines: 1,
                        style: AppTypography.timerDigits(
                          color: Colors.white,
                          fontSize: 180,
                          shadows: [
                            Shadow(color: primaryColor.withValues(alpha: 0.4), blurRadius: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Right Panel: Controls
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: _controller.isRunning ? 0.60 : 0.35),
                                blurRadius: _controller.isRunning ? 20 : 12,
                                spreadRadius: _controller.isRunning ? 2 : 0,
                              ),
                            ],
                          ),
                          child: Icon(
                            _controller.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.black,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildLandscapeControlBtn(
                              icon: Icons.replay_rounded,
                              tooltip: l10n?.reset ?? 'RESET',
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _controller.reset();
                              },
                            ),
                            _buildLandscapeControlBtn(
                              icon: Icons.skip_previous_rounded,
                              tooltip: l10n?.skip ?? 'PREVIOUS',
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _controller.skipPrevious();
                              },
                            ),
                            _buildLandscapeControlBtn(
                              icon: Icons.skip_next_rounded,
                              tooltip: l10n?.next ?? 'NEXT',
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _controller.skipNext();
                              },
                            ),
                            _buildLandscapeControlBtn(
                              icon: Icons.stop_circle_rounded,
                              tooltip: l10n?.quit ?? 'QUIT',
                              onTap: _handleBackOrExit,
                            ),
                          ],
                        ),
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
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
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
        // Clean Top Bar with Title and Back
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: _handleBackOrExit,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _showWorkoutInfo,
                  child: Text(
                    widget.routine.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.athleticHeader(
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline_rounded, color: Colors.white54, size: 22),
                tooltip: 'Workout Info',
                onPressed: _showWorkoutInfo,
              ),
            ],
          ),
        ),

        // Sub-Row: Audio / Voice Coach / Rotation Capsule
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TimerUtilityControls(
                    primaryColor: primaryColor,
                    onToggleOrientation: _toggleOrientation,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 4),

        // Linear Progress Bar for total workout (Full workout progress indicator)
        LinearProgressIndicator(
          value: _controller.overallProgress,
          backgroundColor: Colors.white12,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white60),
          minHeight: 2.5,
        ),
        const SizedBox(height: 1.5),
        // Linear Progress Bar for current interval (Work / Rest progress gauge)
        LinearProgressIndicator(
          value: _controller.segmentProgress,
          backgroundColor: primaryColor.withValues(alpha: 0.15),
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          minHeight: 4.0,
        ),

        // Main Content (Center)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Round Indicator Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.4), width: 1.5),
                  ),
                  child: Text(
                    _controller.isFinished
                        ? (l10n?.completed ?? 'TIME!')
                        : (curSegment != null && curSegment.roundIndex > 0)
                            ? '${l10n?.round ?? "ROUND"} ${_controller.currentRound} / ${_controller.totalRounds}'
                            : (l10n?.prep ?? 'GET READY'),
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
                    maxLines: 1,
                    style: AppTypography.timerDigits(
                      color: Colors.white,
                      fontSize: 135,
                      shadows: [
                        Shadow(color: primaryColor.withValues(alpha: 0.4), blurRadius: 24),
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
                            ? '${l10n?.prep ?? "Prep"}: ${_controller.formattedRemainingTime}'
                            : '${l10n?.totalTime ?? "Total"}: ${_controller.formattedTotalElapsed} / ${_controller.formattedTotalWorkoutTime}',
                        style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
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
                      style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),

                // If finished, show button to review/edit log
                if (_controller.isFinished) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E676),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.notes, size: 20),
                    label: Text(l10n?.addWorkoutNote ?? 'ADD WORKOUT NOTE', style: const TextStyle(fontWeight: FontWeight.w900)),
                    onPressed: _showFinishModal,
                  ),
                ],
              ],
            ),
          ),
        ),

        // Controls
        TimerRunnerControls(
          isRunning: _controller.isRunning,
          primaryColor: primaryColor,
          onReset: () => _controller.reset(),
          onSkipPrevious: () => _controller.skipPrevious(),
          onSkipNext: () => _controller.skipNext(),
          onExit: _handleBackOrExit,
          onPlayPause: () {
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
          resetTooltip: l10n?.reset ?? 'RESET',
          skipTooltip: l10n?.skip ?? 'SKIP',
          nextTooltip: l10n?.next ?? 'NEXT',
          quitTooltip: l10n?.quit ?? 'QUIT',
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
