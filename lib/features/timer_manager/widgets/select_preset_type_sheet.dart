import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/home_timer_helper.dart';

class SelectPresetTypeSheet extends StatelessWidget {
  const SelectPresetTypeSheet({super.key});

  static Future<String?> show(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const SelectPresetTypeSheet(),
    );
    return result?['cat'];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final standardTimers = [
      {'cat': 'tabata', 'name': 'Tabata', 'desc': '20s Work / 10s Rest • 8 Rounds'},
      {'cat': 'emom', 'name': 'EMOM', 'desc': '1 Min Interval • 10 Rounds'},
      {'cat': 'rounds', 'name': l10n?.roundsTypeOption ?? 'Rounds', 'desc': '3 Min Work / 1 Min Rest • 3 Rounds'},
      {'cat': 'amrap', 'name': 'AMRAP', 'desc': '12 Min Time Cap'},
      {'cat': 'fortime', 'name': 'For Time', 'desc': '15 Min Cap'},
      {'cat': 'countdown', 'name': l10n?.countdownTypeOption ?? 'Countdown', 'desc': '5 Min Standard Countdown'},
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.selectTimerType ?? 'Select Timer Type',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...standardTimers.map((t) {
              final cat = t['cat']!;
              final color = HomeTimerHelper.getCategoryColor(cat);
              final icon = HomeTimerHelper.getCategoryIcon(cat);
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                title: Text(
                  t['name']!,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  t['desc']!,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white38,
                  size: 14,
                ),
                onTap: () => Navigator.of(context).pop(t),
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
