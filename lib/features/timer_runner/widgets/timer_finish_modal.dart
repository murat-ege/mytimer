import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../models/custom_routine.dart';
import '../../../models/workout_log.dart';
import '../../../repositories/workout_log_repository.dart';
import '../../../services/system_date_formatter.dart';
import '../../workout_log/widgets/workout_history_modal.dart';
import '../../workout_log/workout_log_screen.dart';

class TimerFinishModal extends StatefulWidget {
  final WorkoutLog log;
  final CustomRoutine routine;
  final String formattedTotalElapsed;

  const TimerFinishModal({
    super.key,
    required this.log,
    required this.routine,
    required this.formattedTotalElapsed,
  });

  static Future<void> show({
    required BuildContext context,
    required WorkoutLog log,
    required CustomRoutine routine,
    required String formattedTotalElapsed,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TimerFinishModal(
        log: log,
        routine: routine,
        formattedTotalElapsed: formattedTotalElapsed,
      ),
    );
  }

  @override
  State<TimerFinishModal> createState() => _TimerFinishModalState();
}

class _TimerFinishModalState extends State<TimerFinishModal> {
  late final TextEditingController _noteCtrl;
  final WorkoutLogRepository _logRepository = WorkoutLogRepository();

  @override
  void initState() {
    super.initState();
    _noteCtrl = TextEditingController(text: widget.routine.description);
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final log = widget.log;

    return Container(
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
                        'Total WOD Time: ${widget.formattedTotalElapsed}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteCtrl,
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
            FutureBuilder<List<WorkoutLog>>(
              future: _logRepository.getLogsByWorkoutName(widget.routine.name),
              builder: (context, snapshot) {
                final pastLogs = (snapshot.data ?? []).where((l) => l.id != widget.log.id).toList();
                if (pastLogs.isEmpty) return const SizedBox.shrink();

                final latest = pastLogs.first;
                return Container(
                  margin: const EdgeInsets.only(top: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.history_rounded, size: 16, color: Color(0xFF00E676)),
                              const SizedBox(width: 6),
                              Text(
                                l10n?.previousWorkouts(widget.routine.name, pastLogs.length) ??
                                    'Previous ${widget.routine.name} (${pastLogs.length})',
                                style: const TextStyle(
                                  color: Color(0xFF00E676),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              WorkoutHistoryModal.show(
                                context: context,
                                workoutTitle: widget.routine.name,
                              );
                            },
                            child: Text(
                              l10n?.viewAll ?? 'View All >',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n != null
                            ? l10n.lastCompleted(
                                SystemDateFormatter.formatDateTime(latest.completedAt),
                                latest.formattedDuration,
                              )
                            : 'Last: ${SystemDateFormatter.formatDateTime(latest.completedAt)} • ${latest.formattedDuration}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (latest.userNote.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          l10n != null
                              ? l10n.noteLabel(latest.userNote)
                              : 'Note: ${latest.userNote}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
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
                        userNote: _noteCtrl.text.trim(),
                      );
                      final rootNav = Navigator.of(context);
                      await _logRepository.saveLog(updated);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
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
                      userNote: _noteCtrl.text.trim(),
                    );
                    final rootNav = Navigator.of(context);
                    await _logRepository.saveLog(updated);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
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
    );
  }
}
