import 'package:flutter/material.dart';
import '../../../controllers/stopwatch_controller.dart';
import '../../../l10n/generated/app_localizations.dart';

class StopwatchLapTile extends StatelessWidget {
  final LapRecord lap;
  final int? fastestMs;
  final int? slowestMs;

  const StopwatchLapTile({
    super.key,
    required this.lap,
    this.fastestMs,
    this.slowestMs,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Color lapColor = Colors.white;
    String? badgeText;

    if (fastestMs != null && lap.lapTimeMs == fastestMs) {
      lapColor = const Color(0xFF00E676);
      badgeText = 'FAST';
    } else if (slowestMs != null && lap.lapTimeMs == slowestMs) {
      lapColor = const Color(0xFFFF3D00);
      badgeText = 'SLOW';
    }

    final splitLabel = l10n?.lap ?? 'Split';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$splitLabel ${lap.lapNumber.toString().padLeft(2, '0')}',
                style: TextStyle(color: lapColor, fontWeight: FontWeight.w600, fontSize: 14),
              ),
              if (badgeText != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: lapColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: lapColor.withValues(alpha: 0.4), width: 1),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: lapColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
          Text(
            StopwatchController.formatMs(lap.lapTimeMs),
            style: TextStyle(
              color: lapColor,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            StopwatchController.formatMs(lap.splitTimeMs),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
