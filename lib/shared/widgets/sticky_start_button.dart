import 'package:flutter/material.dart';
import '../theme/app_typography.dart';

class StickyStartButton extends StatelessWidget {
  final String label;
  final Color themeColor;
  final VoidCallback onPressed;

  StickyStartButton({
    super.key,
    String? label,
    String? title,
    Color? themeColor,
    Color? color,
    required this.onPressed,
  })  : label = (label ?? title)!,
        themeColor = (themeColor ?? color)!;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF121212),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: themeColor.withValues(alpha: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow_rounded, size: 36),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTypography.athleticHeader(
                    fontSize: 18,
                    letterSpacing: 2,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
