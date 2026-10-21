import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';

class HyroxRaceHeroCard extends StatelessWidget {
  final Color hyroxYellow;
  final VoidCallback onTap;

  const HyroxRaceHeroCard({
    super.key,
    required this.hyroxYellow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF28240A), Color(0xFF161505), Color(0xFF121212)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: hyroxYellow, width: 2),
          boxShadow: [
            BoxShadow(
              color: hyroxYellow.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: hyroxYellow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'OFFICIAL RACE FORMAT',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_rounded, color: hyroxYellow),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              l10n?.hyroxRaceSimulator ?? 'HYROX Race Simulator & Splits',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n?.hyroxRaceSimulatorDesc ??
                  'Full 8x1km & 8 workout stations split tracker with Roxzone transition timing, target pace delta, and full race logs.',
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _featureTag('8x1km Run'),
                _featureTag('8 Stations'),
                _featureTag('Roxzone'),
                _featureTag('Pace Delta'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
