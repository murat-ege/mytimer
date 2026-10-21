import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../controllers/stopwatch_controller.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/workout_log.dart';
import '../../repositories/workout_log_repository.dart';
import '../../shared/theme/app_typography.dart';
import '../../shared/widgets/stat_item.dart';
import 'widgets/circular_action_button.dart';
import 'widgets/stopwatch_lap_tile.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final StopwatchController _controller = StopwatchController();
  final WorkoutLogRepository _logRepository = WorkoutLogRepository();
  late final AppLifecycleListener _lifecycleListener;

  static const Color _themeColor = Color(0xFF00E5FF);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onUpdate);
    _lifecycleListener = AppLifecycleListener(
      onResume: () => _controller.syncWithRealTime(),
    );
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _saveToLog() {
    final l10n = AppLocalizations.of(context);
    final noteCtrl = TextEditingController();
    final elapsedSecs = _controller.elapsedMs ~/ 1000;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          l10n?.save ?? 'Save to Workout Log',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time: ${StopwatchController.formatMs(_controller.elapsedMs)} • ${_controller.laps.length} Splits',
              style: const TextStyle(color: _themeColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: l10n?.workoutNote ?? 'Workout Note',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: l10n?.workoutNoteHint ?? 'e.g. 5km run, chipper finish',
                hintStyle: const TextStyle(color: Colors.white30),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _themeColor)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n?.cancel ?? 'CANCEL', style: const TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _themeColor, foregroundColor: Colors.black),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final log = WorkoutLog(
                id: const Uuid().v4(),
                timerType: 'stopwatch',
                title: 'STOPWATCH (${StopwatchController.formatMs(_controller.elapsedMs, showMs: false)})',
                defaultDefinition: 'Timed Effort • ${_controller.laps.length} Splits recorded',
                userNote: noteCtrl.text.trim(),
                totalDurationSeconds: elapsedSecs,
                completedAt: DateTime.now(),
              );
              await _logRepository.saveLog(log);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Workout saved to log!')),
                );
              }
            },
            child: Text(l10n?.save ?? 'SAVE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final laps = _controller.laps;
    final fastest = _controller.fastestLapMs;
    final slowest = _controller.slowestLapMs;
    final canSave = _controller.elapsedMs > 0 && !_controller.isRunning;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n?.stopwatch ?? 'STOPWATCH',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.bookmark_add_outlined,
              color: canSave ? _themeColor : Colors.white24,
            ),
            tooltip: l10n?.save ?? 'Save to Log',
            onPressed: canSave ? _saveToLog : null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          children: [
            // Time Display Card (Styled exactly like Countdown screen)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1E1E), Color(0xFF262626)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _themeColor.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: _themeColor.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: (_controller.isRunning
                                  ? const Color(0xFF00E676)
                                  : (_controller.elapsedMs > 0
                                      ? const Color(0xFFFF9100)
                                      : _themeColor))
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: (_controller.isRunning
                                    ? const Color(0xFF00E676)
                                    : (_controller.elapsedMs > 0
                                        ? const Color(0xFFFF9100)
                                        : _themeColor))
                                .withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _controller.isRunning
                                    ? const Color(0xFF00E676)
                                    : (_controller.elapsedMs > 0
                                        ? const Color(0xFFFF9100)
                                        : _themeColor),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _controller.isRunning
                                  ? 'RUNNING'
                                  : (_controller.elapsedMs > 0 ? 'PAUSED' : 'READY'),
                              style: TextStyle(
                                color: _controller.isRunning
                                    ? const Color(0xFF00E676)
                                    : (_controller.elapsedMs > 0
                                        ? const Color(0xFFFF9100)
                                        : _themeColor),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Digital Display
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      StopwatchController.formatMs(_controller.elapsedMs),
                      maxLines: 1,
                      style: AppTypography.timerDigits(
                        color: Colors.white,
                        fontSize: 56,
                        letterSpacing: -1,
                      ),
                    ),
                  ),

                  // Quick Stats Row inside card when laps exist
                  if (laps.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: StatItem(
                              label: l10n?.round ?? 'SPLITS',
                              value: '${laps.length}',
                              color: _themeColor,
                            ),
                          ),
                          Container(width: 1, height: 26, color: Colors.white12),
                          Expanded(
                            child: StatItem(
                              label: 'BEST',
                              value: fastest != null
                                  ? StopwatchController.formatMs(fastest)
                                  : '--:--',
                              color: const Color(0xFF00E676),
                            ),
                          ),
                          Container(width: 1, height: 26, color: Colors.white12),
                          Expanded(
                            child: StatItem(
                              label: 'SLOWEST',
                              value: slowest != null
                                  ? StopwatchController.formatMs(slowest)
                                  : '--:--',
                              color: const Color(0xFFFF3D00),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Control Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reset / Lap Button
                  CircularActionButton(
                    icon: _controller.isRunning
                        ? Icons.flag_rounded
                        : Icons.refresh_rounded,
                    label: _controller.isRunning
                        ? (l10n?.lap ?? 'SPLIT')
                        : (l10n?.reset ?? 'RESET'),
                    color: Colors.white12,
                    textColor: Colors.white,
                    onTap: () {
                      if (_controller.isRunning) {
                        _controller.recordLap();
                      } else {
                        _controller.reset();
                      }
                    },
                  ),

                  // Start / Stop Button
                  CircularActionButton(
                    icon: _controller.isRunning
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    label: _controller.isRunning
                        ? (l10n?.pause ?? 'PAUSE')
                        : (l10n?.start ?? 'START'),
                    color: _controller.isRunning
                        ? const Color(0xFFFF3D00)
                        : const Color(0xFF00E676),
                    textColor: Colors.black,
                    onTap: () {
                      if (_controller.isRunning) {
                        _controller.pause();
                      } else {
                        _controller.start();
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Laps Container
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A1A1A), Color(0xFF222222)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n?.round ?? 'SPLIT #',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            l10n?.roundTime ?? 'SPLIT TIME',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            l10n?.totalTime ?? 'TOTAL',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white10, height: 1),

                    // Laps List
                    Expanded(
                      child: laps.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.flag_outlined,
                                    color: Colors.white.withValues(alpha: 0.2),
                                    size: 36,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No splits recorded yet',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.35),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 4.0),
                              itemCount: laps.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(color: Colors.white10, height: 1),
                              itemBuilder: (context, index) {
                                final lap = laps[index];
                                return StopwatchLapTile(
                                  lap: lap,
                                  fastestMs: fastest,
                                  slowestMs: slowest,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
