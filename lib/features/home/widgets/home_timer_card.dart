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

  const TimerCatalogItem({
    required this.id,
    required this.getTitle,
    required this.getSubtitle,
    required this.color,
    this.gradientSecondColor,
    required this.icon,
    required this.buildScreen,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = item.getTitle(l10n);
    final subtitle = _cleanSubtitle(item.getSubtitle(l10n));
    final secondColor = item.gradientSecondColor ?? item.color;

    return LayoutBuilder(
      builder: (context, cardConstraints) {
        final contentWidth =
            (cardConstraints.maxWidth - 28).clamp(1.0, double.infinity);

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
                  borderRadius: BorderRadius.circular(20),
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
                    borderRadius: BorderRadius.circular(20),
                    onTap: onTap,
                    onLongPress: onLongPress,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 13.0,
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
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      item.color.withValues(alpha: 0.32),
                                      secondColor.withValues(alpha: 0.18),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: item.color.withValues(alpha: 0.50),
                                    width: 1.0,
                                  ),
                                ),
                                child: Icon(item.icon, color: item.color, size: 20),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 11,
                                color: item.color.withValues(alpha: 0.60),
                              ),
                            ],
                          ),

                          // Bottom: Title & Subtitle (both fit completely into the card without ellipsis)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: contentWidth,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    title,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 3),
                              SizedBox(
                                width: contentWidth,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: SizedBox(
                                    width: contentWidth,
                                    child: Text(
                                      subtitle,
                                      maxLines: 2,
                                      softWrap: true,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                  top: -6,
                  left: -6,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 28,
                      height: 28,
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
                      child: const Icon(
                        Icons.remove,
                        color: Colors.white,
                        size: 18,
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
