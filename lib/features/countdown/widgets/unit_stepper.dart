import 'package:flutter/material.dart';

class UnitStepper extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onDec;
  final VoidCallback onInc;
  final String? offText;

  const UnitStepper({
    super.key,
    required this.label,
    required this.value,
    required this.onDec,
    required this.onInc,
    this.offText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onDec,
                icon: const Icon(Icons.remove_circle_outline, color: Colors.white70, size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 4),
              Text(
                value == 0 && offText != null ? offText! : value.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: value == 0 ? Colors.white38 : Colors.white,
                  fontSize: value == 0 && offText != null ? 18 : 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: onInc,
                icon: const Icon(Icons.add_circle_outline, color: Colors.white70, size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
