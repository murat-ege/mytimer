import 'package:flutter/material.dart';

class QuickChoiceChipItem<T> {
  final T value;
  final String label;

  const QuickChoiceChipItem({required this.value, required this.label});
}

class QuickChoiceChips<T> extends StatelessWidget {
  final List<QuickChoiceChipItem<T>> items;
  final T selectedValue;
  final Color activeColor;
  final ValueChanged<T> onSelected;

  const QuickChoiceChips({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.activeColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          final isSelected = selectedValue == item.value;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              label: Text(
                item.label,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              backgroundColor: isSelected ? activeColor : const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: activeColor.withValues(alpha: 0.3)),
              ),
              onPressed: () => onSelected(item.value),
            ),
          );
        }).toList(),
      ),
    );
  }
}
