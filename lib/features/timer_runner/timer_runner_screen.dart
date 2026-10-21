import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/workout_controller.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/custom_routine.dart';
import '../../models/timer_phase.dart';
import '../../repositories/workout_log_repository.dart';
import '../../services/sound_service.dart';
import '../../services/voice_coach_service.dart';
import '../workout_log/workout_log_screen.dart';
import '../../shared/theme/app_typography.dart';
import 'widgets/timer_runner_controls.dart';

class TimerRunnerScreen extends StatefulWidget {
  final CustomRoutine routine;

  const TimerRunnerScreen({super.key, required this.routine});

  @override
  State<TimerRunnerScreen> createState() => _TimerRunnerScreenState();
}

class _TimerRunnerScreenState extends State<TimerRunnerScreen> {
  late final WorkoutController _controller;
  final SoundService _soundService = SoundService();
  final VoiceCoachService _voiceCoach = VoiceCoachService();
  final WorkoutLogRepository _logRepository = WorkoutLogRepository();
  final ImagePicker _imagePicker = ImagePicker();
  late final AppLifecycleListener _lifecycleListener;

  bool _hasShownFinishModal = false;

  @override
  void initState() {
    super.initState();
    _controller = WorkoutController(routine: widget.routine);
    _controller.addListener(_onControllerUpdate);

    _lifecycleListener = AppLifecycleListener(
      onResume: () => _controller.syncWithRealTime(),
      onHide: () => _controller.syncWithRealTime(),
    );

    // Auto start after a brief moment
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.start();
    });
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
      if (_controller.isFinished && !_hasShownFinishModal) {
        _hasShownFinishModal = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showFinishModal();
        });
      }
    }
  }

  void _showFinishModal() {
    final l10n = AppLocalizations.of(context);
    final log = _controller.recordedLog;
    if (log == null) return;

    final noteCtrl = TextEditingController(text: widget.routine.description);
    String? localPhotoPath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFF00E676), width: 1)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFB300), size: 30),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.finished ?? 'WORKOUT COMPLETE!',
                            style: const TextStyle(color: Color(0xFF00E676), fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                          Text(
                            'Total WOD Time: ${_controller.formattedTotalElapsed}',
                            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: l10n?.workoutNote ?? 'Workout Notes / Score',
                    labelStyle: const TextStyle(color: Colors.white70),
                    hintText: l10n?.workoutNoteHint ?? 'Reps, weight, scaling, or how you felt',
                    hintStyle: const TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: const Color(0xFF262626),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),

                // Photo button / Preview
                if (localPhotoPath != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(localPhotoPath!),
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => setModalState(() => localPhotoPath = null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF00E5FF)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    icon: const Icon(Icons.add_a_photo_outlined, color: Color(0xFF00E5FF)),
                    label: Text(l10n?.attachPhoto ?? 'Attach Whiteboard / Score Photo', style: const TextStyle(color: Color(0xFF00E5FF))),
                    onPressed: () async {
                      try {
                        final picked = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                        if (picked != null) {
                          setModalState(() {
                            localPhotoPath = picked.path;
                          });
                        }
                      } catch (_) {}
                    },
                  ),

                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E676),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          final updated = log.copyWith(
                            userNote: noteCtrl.text.trim(),
                            imagePath: localPhotoPath ?? log.imagePath,
                          );
                          final rootNav = Navigator.of(context);
                          final modalNav = Navigator.of(ctx);
                          await _logRepository.saveLog(updated);
                          modalNav.pop();
                          rootNav.pop();
                        },
                        child: Text(l10n?.save ?? 'SAVE & EXIT', style: const TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        final updated = log.copyWith(
                          userNote: noteCtrl.text.trim(),
                          imagePath: localPhotoPath ?? log.imagePath,
                        );
                        final rootNav = Navigator.of(context);
                        final modalNav = Navigator.of(ctx);
                        await _logRepository.saveLog(updated);
                        modalNav.pop();
                        rootNav.pushReplacement(
                          MaterialPageRoute(builder: (_) => const WorkoutLogScreen()),
                        );
                      },
                      child: const Text('VIEW LOG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showWorkoutInfo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(widget.routine.name.toUpperCase(), style: const TextStyle(color: Color(0xFF00E676))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.routine.description.isNotEmpty) ...[
              Text(widget.routine.description, style: const TextStyle(color: Colors.white, height: 1.35)),
              const SizedBox(height: 12),
            ],
            Text('Rounds: ${widget.routine.rounds}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 4),
            Text('Intervals:', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
            ...widget.routine.intervals.map(
              (i) => Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                child: Text('• ${i.name}: ${i.durationSeconds}s', style: const TextStyle(color: Colors.white54)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CLOSE', style: TextStyle(color: Color(0xFF00E676))),
          ),
        ],
      ),
    );
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
                child: GestureDetector(
                  onTap: _showWorkoutInfo,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
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
                      const SizedBox(width: 4),
                      const Icon(Icons.info_outline, color: Colors.white38, size: 16),
                    ],
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
                    icon: Icon(
                      _voiceCoach.voiceEnabled ? Icons.record_voice_over : Icons.voice_over_off,
                      color: _voiceCoach.voiceEnabled ? primaryColor : Colors.white38,
                      size: 22,
                    ),
                    tooltip: 'Voice Coach Cues',
                    onPressed: () {
                      setState(() {
                        _voiceCoach.voiceEnabled = !_voiceCoach.voiceEnabled;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.screen_lock_landscape, color: Colors.white70, size: 22),
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
                              style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
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
                            style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500),
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
                        maxLines: 1,
                        style: AppTypography.timerDigits(
                          color: Colors.white,
                          fontSize: 160,
                          shadows: [
                            Shadow(color: primaryColor.withValues(alpha: 0.4), blurRadius: 28),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Right Panel: Controls
                Flexible(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                              BoxShadow(color: primaryColor.withValues(alpha: 0.5), blurRadius: 16, spreadRadius: 2),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildLandscapeControlBtn(icon: Icons.refresh, tooltip: l10n?.reset ?? 'RESET', onTap: _controller.reset),
                          _buildLandscapeControlBtn(icon: Icons.skip_previous, tooltip: l10n?.skip ?? 'PREVIOUS', onTap: _controller.skipPrevious),
                          _buildLandscapeControlBtn(icon: Icons.skip_next, tooltip: l10n?.next ?? 'NEXT', onTap: _controller.skipNext),
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
                child: GestureDetector(
                  onTap: _showWorkoutInfo,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
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
                      const SizedBox(width: 4),
                      const Icon(Icons.info_outline, color: Colors.white38, size: 16),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _soundService.soundEnabled ? Icons.volume_up : Icons.volume_off,
                      color: _soundService.soundEnabled ? primaryColor : Colors.white38,
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
                      _voiceCoach.voiceEnabled ? Icons.record_voice_over : Icons.voice_over_off,
                      color: _voiceCoach.voiceEnabled ? primaryColor : Colors.white38,
                      size: 24,
                    ),
                    tooltip: 'Voice Coach Cues',
                    onPressed: () {
                      setState(() {
                        _voiceCoach.voiceEnabled = !_voiceCoach.voiceEnabled;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.screen_lock_portrait, color: Colors.white70, size: 26),
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
                      fontSize: 130,
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
                    label: const Text('ADD WORKOUT NOTE & PHOTO', style: TextStyle(fontWeight: FontWeight.w900)),
                    onPressed: _showFinishModal,
                  ),
                ],
              ],
            ),
          ),
        ),

        TimerRunnerControls(
          isRunning: _controller.isRunning,
          primaryColor: primaryColor,
          onReset: () => _controller.reset(),
          onSkipPrevious: () => _controller.skipPrevious(),
          onSkipNext: () => _controller.skipNext(),
          onExit: () {
            _controller.pause();
            _showExitDialog();
          },
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
