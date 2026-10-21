import 'package:flutter/material.dart';

class QuickDurationChips extends StatelessWidget {
  final List<int> durations;
  final int selectedDuration;
  final String unit;
  final Color themeColor;
  final ValueChanged<int> onSelected;

  const QuickDurationChips({
    super.key,
    required this.durations,
    required this.selectedDuration,
    required this.unit,
    required this.themeColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: durations.map((mins) {
          final isSelected = selectedDuration == mins;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              label: Text(
                '$mins $unit',
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              backgroundColor: isSelected ? themeColor : const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: themeColor.withValues(alpha: 0.3)),
              ),
              onPressed: () => onSelected(mins),
            ),
          );
        }).toList(),
      ),
    );
  }
}
