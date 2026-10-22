import 'package:flutter/material.dart';

import '../../../data/hyrox_data.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../hyrox_standards_sheet.dart';

class HyroxRaceSetupView extends StatelessWidget {
  final String raceMode;
  final ValueChanged<String> onRaceModeChanged;
  final HyroxDivision division;
  final ValueChanged<HyroxDivision> onDivisionChanged;
  final int targetFinishSeconds;
  final ValueChanged<int> onTargetFinishSecondsChanged;
  final bool includeRoxzone;
  final ValueChanged<bool> onIncludeRoxzoneChanged;

  const HyroxRaceSetupView({
    super.key,
    required this.raceMode,
    required this.onRaceModeChanged,
    required this.division,
    required this.onDivisionChanged,
    required this.targetFinishSeconds,
    required this.onTargetFinishSecondsChanged,
    required this.includeRoxzone,
    required this.onIncludeRoxzoneChanged,
  });

  Widget _formatOptionCard(String id, String title, String subtitle, Color themeColor) {
    final isSelected = raceMode == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => onRaceModeChanged(id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? themeColor.withValues(alpha: 0.15) : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? themeColor : Colors.white12,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? themeColor : Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeColor = HyroxData.hyroxYellow;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // Hero card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF262626), Color(0xFF161616)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: themeColor.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.flag_rounded, color: themeColor, size: 28),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'OFFICIAL HYROX RACE TIMER',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Full 8x1km & 8 workout stations split tracker with Roxzone transition timing and real-time pace delta.',
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Race Mode Selector
        const Text(
          'RACE FORMAT',
          style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _formatOptionCard('full', 'Full Race', '8 Runs + 8 Stations', themeColor),
            const SizedBox(width: 8),
            _formatOptionCard('half', 'Half Hyrox', '4 Runs + 4 Stations', themeColor),
            const SizedBox(width: 8),
            _formatOptionCard('relay', 'Relay Leg', '2 Runs + 2 Stations', themeColor),
          ],
        ),

        const SizedBox(height: 20),

        // Division Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n?.division ?? 'DIVISION / CATEGORY',
              style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
            GestureDetector(
              onTap: () => HyroxStandardsSheet.show(context, initialDivision: division),
              child: Text(
                'View Weights >',
                style: TextStyle(color: themeColor, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<HyroxDivision>(
              value: division,
              dropdownColor: const Color(0xFF1E1E1E),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down_rounded, color: themeColor),
              items: HyroxDivision.values.map((div) {
                return DropdownMenuItem(
                  value: div,
                  child: Text(
                    div.displayName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
              onChanged: (div) {
                if (div != null) onDivisionChanged(div);
              },
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Target Finish Time
        Text(
          l10n?.targetFinishTime ?? 'TARGET FINISH TIME (PACE INDICATOR)',
          style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: HyroxData.targetRaceTimes.map((item) {
            final secs = item['seconds'] as int;
            final isSelected = targetFinishSeconds == secs;
            return ChoiceChip(
              label: Text(
                '${item['title']}',
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              selectedColor: themeColor,
              backgroundColor: const Color(0xFF1E1E1E),
              side: BorderSide(color: isSelected ? themeColor : Colors.white12),
              onSelected: (val) {
                if (val) onTargetFinishSecondsChanged(secs);
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // Roxzone Switch
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9100).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.sync_alt_rounded, color: Color(0xFFFF9100), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.roxzoneTracking ?? 'Roxzone Transition Splits',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Record In/Out transition times separately',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch(
                value: includeRoxzone,
                activeThumbColor: themeColor,
                activeTrackColor: themeColor.withValues(alpha: 0.3),
                onChanged: onIncludeRoxzoneChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
