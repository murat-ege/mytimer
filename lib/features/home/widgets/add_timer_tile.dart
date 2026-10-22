import 'package:flutter/material.dart';
import 'package:mytimer/l10n/generated/app_localizations.dart';

class AddTimerTile extends StatelessWidget {
  final VoidCallback onTap;

  const AddTimerTile({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardH = constraints.maxHeight;
        final isCompact = cardH < 130;
        final badgeSize = isCompact
            ? (cardH * 0.28).clamp(28.0, 34.0)
            : 38.0;
        final iconSize = isCompact ? (badgeSize * 0.55).clamp(16.0, 20.0) : 22.0;
        final fontSize = isCompact ? (cardH * 0.125).clamp(11.5, 13.5) : 14.5;
        final spacing = isCompact ? 5.0 : 8.0;
        final borderRadiusVal = isCompact ? 16.0 : 20.0;

        return SizedBox.expand(
          child: InkWell(
            borderRadius: BorderRadius.circular(borderRadiusVal),
            onTap: onTap,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(borderRadiusVal),
                border: Border.all(
                  color: const Color(0xFF00E676).withValues(alpha: 0.35),
                  style: BorderStyle.solid,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: badgeSize,
                    height: badgeSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(isCompact ? 10 : 12),
                      border: Border.all(
                        color: const Color(0xFF00E676).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: const Color(0xFF00E676),
                      size: iconSize,
                    ),
                  ),
                  SizedBox(height: spacing),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        l10n?.addTimer ?? 'Add Timer',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF00E676),
                          fontSize: fontSize,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
