import 'package:flutter/material.dart';

class NumberStepperTile extends StatelessWidget {
  final String title;
  final String valueText;
  final Color color;
  final IconData icon;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  NumberStepperTile({
    super.key,
    required this.title,
    required this.valueText,
    required this.color,
    required this.icon,
    VoidCallback? onDecrement,
    VoidCallback? onIncrement,
    VoidCallback? onDec,
    VoidCallback? onInc,
  }) : onDecrement = (onDecrement ?? onDec)!,
       onIncrement = (onIncrement ?? onInc)!;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valueText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDecrement,
            icon: const Icon(
              Icons.remove_circle_outline,
              color: Colors.white70,
              size: 28,
            ),
          ),
          IconButton(
            onPressed: onIncrement,
            icon: const Icon(
              Icons.add_circle_outline,
              color: Colors.white70,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
