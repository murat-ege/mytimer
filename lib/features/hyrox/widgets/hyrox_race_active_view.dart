import 'package:flutter/material.dart';

import '../../../data/hyrox_data.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../hyrox_race_screen.dart';

class HyroxRaceActiveView extends StatelessWidget {
  final List<Map<String, dynamic>> raceSteps;
  final int currentStepIndex;
  final List<HyroxRaceSplit> completedSplits;
  final int totalElapsedSeconds;
  final int currentSplitSeconds;
  final int paceDeltaSeconds;
  final HyroxDivision division;
  final bool isPaused;
  final VoidCallback onRecordSplit;
  final VoidCallback onPauseResume;
  final VoidCallback onFinishEarly;

  const HyroxRaceActiveView({
    super.key,
    required this.raceSteps,
    required this.currentStepIndex,
    required this.completedSplits,
    required this.totalElapsedSeconds,
    required this.currentSplitSeconds,
    required this.paceDeltaSeconds,
    required this.division,
    required this.isPaused,
    required this.onRecordSplit,
    required this.onPauseResume,
    required this.onFinishEarly,
  });

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

    final currentStep = raceSteps[currentStepIndex];
    final isLastStep = currentStepIndex == raceSteps.length - 1;
    final nextStep = !isLastStep ? raceSteps[currentStepIndex + 1] : null;

    final HyroxStationInfo? station = currentStep['station'] as HyroxStationInfo?;
    final weight = station?.getWeightFor(division);

    // Pace delta formatting
    final delta = paceDeltaSeconds;
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
                  'LEG ${currentStepIndex + 1} / ${raceSteps.length}',
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
                division.shortName,
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
                          _formatTime(totalElapsedSeconds),
                          style: TextStyle(
                            color: isPaused ? Colors.white38 : themeColor,
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
                          _formatTime(currentSplitSeconds),
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
        if (completedSplits.isNotEmpty)
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
              itemCount: completedSplits.length,
              separatorBuilder: (_, _) => const Divider(color: Colors.white10, height: 1),
              itemBuilder: (ctx, idx) {
                final split = completedSplits[idx];
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
                  onPressed: isPaused ? null : onRecordSplit,
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
                      icon: Icon(isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, color: Colors.white70),
                      label: Text(
                        isPaused ? (l10n?.resume ?? 'RESUME') : (l10n?.pause ?? 'PAUSE'),
                        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: onPauseResume,
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
                      onPressed: onFinishEarly,
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
