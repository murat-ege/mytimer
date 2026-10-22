import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../data/hyrox_data.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/workout_log.dart';
import '../../../repositories/workout_log_repository.dart';
import '../hyrox_race_screen.dart';

class HyroxRaceFinishModal extends StatelessWidget {
  final int totalElapsedSeconds;
  final HyroxDivision division;
  final String raceMode;
  final bool includeRoxzone;
  final List<HyroxRaceSplit> completedSplits;
  final int totalSteps;
  final VoidCallback onLogSaved;

  const HyroxRaceFinishModal({
    super.key,
    required this.totalElapsedSeconds,
    required this.division,
    required this.raceMode,
    required this.includeRoxzone,
    required this.completedSplits,
    required this.totalSteps,
    required this.onLogSaved,
  });

  static Future<void> show({
    required BuildContext context,
    required int totalElapsedSeconds,
    required HyroxDivision division,
    required String raceMode,
    required bool includeRoxzone,
    required List<HyroxRaceSplit> completedSplits,
    required int totalSteps,
    required VoidCallback onLogSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HyroxRaceFinishModal(
        totalElapsedSeconds: totalElapsedSeconds,
        division: division,
        raceMode: raceMode,
        includeRoxzone: includeRoxzone,
        completedSplits: completedSplits,
        totalSteps: totalSteps,
        onLogSaved: onLogSaved,
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

  @override
  Widget build(BuildContext context) {
    final noteCtrl = TextEditingController();
    final l10n = AppLocalizations.of(context);
    final themeColor = HyroxData.hyroxYellow;
    final logRepository = WorkoutLogRepository();

    final totalRoxzoneSecs = completedSplits
        .where((s) => s.isRoxzone)
        .fold<int>(0, (sum, s) => sum + s.splitDurationSeconds);

    return Container(
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
                      'Total Time: ${_formatTime(totalElapsedSeconds)} • ${division.displayName}',
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
                  _formatTime(totalElapsedSeconds),
                  themeColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _finishMetricCard(
                  'TOTAL SPLITS',
                  '${completedSplits.length} recorded',
                  const Color(0xFF00E5FF),
                ),
              ),
              if (includeRoxzone) ...[
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
                itemCount: completedSplits.length,
                separatorBuilder: (_, _) => const Divider(color: Colors.white10, height: 1),
                itemBuilder: (ctx, idx) {
                  final split = completedSplits[completedSplits.length - 1 - idx];
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
                  onPressed: () => Navigator.of(context).pop(),
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
                    Navigator.of(context).pop();
                    final definitionBuffer = StringBuffer();
                    definitionBuffer.writeln('HYROX ${division.displayName} • $raceMode Race');
                    for (final s in completedSplits.reversed) {
                      definitionBuffer.writeln('${s.name}: ${s.formattedSplit} (Total: ${s.formattedTotal})');
                    }

                    final log = WorkoutLog(
                      id: const Uuid().v4(),
                      timerType: 'hyrox',
                      title: 'HYROX ${raceMode.toUpperCase()} (${_formatTime(totalElapsedSeconds)})',
                      defaultDefinition: definitionBuffer.toString(),
                      userNote: noteCtrl.text.trim(),
                      totalDurationSeconds: totalElapsedSeconds,
                      completedAt: DateTime.now(),
                      completedRounds: completedSplits.length,
                      totalRounds: totalSteps,
                    );

                    await logRepository.saveLog(log);
                    onLogSaved();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
