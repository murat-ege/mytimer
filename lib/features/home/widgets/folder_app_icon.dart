import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/home_timer_helper.dart';

class FolderAppIcon extends StatelessWidget {
  final HomeFolderItem item;
  final Color folderColor;
  final bool isEditing;
  final bool isFeedback;
  final Animation<double>? jiggleAnimation;
  final int itemIndex;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onRemove;

  const FolderAppIcon({
    super.key,
    required this.item,
    required this.folderColor,
    this.isEditing = false,
    this.isFeedback = false,
    this.jiggleAnimation,
    this.itemIndex = 0,
    this.onTap,
    this.onLongPress,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = item.getTitle(l10n);

    Widget iconContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // App Icon Squircle
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    item.color,
                    item.gradientSecondColor,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Icon(
                  item.icon,
                  size: 28,
                  color: _getContrastColor(item.color),
                ),
              ),
            ),

            // Delete / Remove Badge in Edit Mode
            if (isEditing && onRemove != null)
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onRemove?.call();
                  },
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.remove_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),

        // App Label
        SizedBox(
          width: 76,
          child: Text(
            title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              height: 1.15,
            ),
          ),
        ),
      ],
    );

    // Apply iOS jiggle animation in edit mode
    if (isEditing && jiggleAnimation != null && !isFeedback) {
      iconContent = AnimatedBuilder(
        animation: jiggleAnimation!,
        builder: (context, child) {
          final factor = (itemIndex % 2 == 0) ? 1.0 : -1.0;
          return Transform.rotate(
            angle: jiggleAnimation!.value * factor * (math.pi / 180),
            child: child,
          );
        },
        child: iconContent,
      );
    }

    if (isFeedback) {
      return Material(
        color: Colors.transparent,
        child: iconContent,
      );
    }

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: iconContent,
    );
  }

  /// Ensures glyph readability on bright neon vs darker colors
  Color _getContrastColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.45 ? Colors.black.withValues(alpha: 0.88) : Colors.white;
  }
}
