import 'package:flutter/material.dart';
import 'package:mytimer/l10n/generated/app_localizations.dart';

class TimerCatalogItem {
  final String id;
  final String Function(AppLocalizations?) getTitle;
  final String Function(AppLocalizations?) getSubtitle;
  final Color color;
  final Color? gradientSecondColor;
  final IconData icon;
  final Widget Function() buildScreen;
  final bool isPreset;
  final String? badgeText;

  const TimerCatalogItem({
    required this.id,
    required this.getTitle,
    required this.getSubtitle,
    required this.color,
    this.gradientSecondColor,
    required this.icon,
    required this.buildScreen,
    this.isPreset = false,
    this.badgeText,
  });
}

class HomeTimerCard extends StatelessWidget {
  final TimerCatalogItem item;
  final bool isEditing;
  final bool isFeedback;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onRemove;

  const HomeTimerCard({
    super.key,
    required this.item,
    this.isEditing = false,
    this.isFeedback = false,
    required this.onTap,
    required this.onLongPress,
    required this.onRemove,
  });

  String _cleanSubtitle(String raw) {
    final trimmed = raw.trim();
    final regex = RegExp(r'^[^(]+\((.+)\)$');
    final match = regex.firstMatch(trimmed);
    if (match != null) {
      return match.group(1)!.trim();
    }
    return trimmed;
  }

  Widget _buildAutoShrinkText({
    required String text,
    required TextStyle baseStyle,
    required double maxWidth,
    int maxLines = 2,
    double minFontSize = 9.0,
  }) {
    double currentSize = baseStyle.fontSize ?? 14.0;
    while (currentSize > minFontSize) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: baseStyle.copyWith(fontSize: currentSize),
        ),
        textDirection: TextDirection.ltr,
        maxLines: maxLines,
      )..layout(maxWidth: maxWidth);

      if (!painter.didExceedMaxLines && painter.width <= maxWidth + 0.5) {
        break;
      }
      currentSize -= 0.5;
    }

    return SizedBox(
      width: maxWidth,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: maxWidth,
          child: Text(
            text,
            maxLines: maxLines,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: baseStyle.copyWith(fontSize: currentSize),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = item.getTitle(l10n);
    final subtitle = _cleanSubtitle(item.getSubtitle(l10n));
    final secondColor = item.gradientSecondColor ?? item.color;

    return LayoutBuilder(
      builder: (context, cardConstraints) {
        final cardW = cardConstraints.maxWidth;
        final cardH = cardConstraints.maxHeight;

        // Adaptive compact mode for landscape / small card sizes
        final isCompact = cardH < 130 || cardW < 150;

        final badgeSize = isCompact
            ? (cardH * 0.28).clamp(28.0, 34.0)
            : 38.0;
        final iconSize = isCompact
            ? (badgeSize * 0.52).clamp(15.0, 18.0)
            : 20.0;
        final paddingH = isCompact ? 11.0 : 14.0;
        final paddingV = isCompact ? 9.0 : 13.0;
        final titleFontSize = isCompact
            ? (cardH * 0.165).clamp(14.0, 16.5)
            : 18.0;
        final subtitleFontSize = isCompact
            ? (cardH * 0.11).clamp(10.0, 11.5)
            : 12.0;
        final borderRadiusVal = isCompact ? 16.0 : 20.0;
        final maxBottomHeight = (cardH - (paddingV * 2) - badgeSize - 4.0)
            .clamp(35.0, double.infinity);

        final contentWidth =
            (cardW - (paddingH * 2)).clamp(1.0, double.infinity);

        return SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      item.color.withValues(alpha: isFeedback ? 0.38 : 0.28),
                      secondColor.withValues(alpha: isFeedback ? 0.26 : 0.16),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(borderRadiusVal),
                  border: Border.all(
                    color: item.color.withValues(alpha: isFeedback ? 0.85 : 0.45),
                    width: isFeedback ? 2 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withValues(alpha: isFeedback ? 0.38 : 0.16),
                      blurRadius: isFeedback ? 18 : 12,
                      offset: Offset(0, isFeedback ? 6 : 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(borderRadiusVal),
                    onTap: onTap,
                    onLongPress: onLongPress,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: paddingH,
                        vertical: paddingV,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top Row: Squircle Icon Badge & subtle chevron
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: badgeSize,
                                height: badgeSize,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      item.color.withValues(alpha: 0.32),
                                      secondColor.withValues(alpha: 0.18),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(isCompact ? 10 : 12),
                                  border: Border.all(
                                    color: item.color.withValues(alpha: 0.50),
                                    width: 1.0,
                                  ),
                                ),
                                child: Icon(item.icon, color: item.color, size: iconSize),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (item.isPreset)
                                    Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isCompact ? 6 : 8,
                                        vertical: isCompact ? 2 : 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: item.color.withValues(alpha: 0.22),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: item.color.withValues(alpha: 0.65),
                                          width: 0.9,
                                        ),
                                      ),
                                      child: Text(
                                        item.badgeText ?? (l10n?.timerBadge ?? 'TIMER'),
                                        style: TextStyle(
                                          color: item.color,
                                          fontSize: isCompact ? 8.5 : 9.5,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: isCompact ? 10 : 11,
                                    color: item.color.withValues(alpha: 0.60),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Bottom: Title & Subtitle (both 2 lines, auto-shrink if overflowing)
                          ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: maxBottomHeight),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.bottomLeft,
                              child: SizedBox(
                                width: contentWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildAutoShrinkText(
                                      text: title,
                                      baseStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: titleFontSize,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.6,
                                        height: 1.15,
                                      ),
                                      maxWidth: contentWidth,
                                      maxLines: 2,
                                      minFontSize: 10.0,
                                    ),
                                    SizedBox(height: isCompact ? 2.0 : 3.0),
                                    _buildAutoShrinkText(
                                      text: subtitle,
                                      baseStyle: TextStyle(
                                        color: Colors.white70,
                                        fontSize: subtitleFontSize,
                                        fontWeight: FontWeight.w600,
                                        height: 1.15,
                                      ),
                                      maxWidth: contentWidth,
                                      maxLines: 2,
                                      minFontSize: 8.5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // iOS Delete Badge in top-left
              if (isEditing && !isFeedback)
                Positioned(
                  top: isCompact ? -4 : -6,
                  left: isCompact ? -4 : -6,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: isCompact ? 24 : 28,
                      height: isCompact ? 24 : 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53935),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.remove,
                        color: Colors.white,
                        size: isCompact ? 15 : 18,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
