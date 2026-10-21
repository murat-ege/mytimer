import 'package:flutter/material.dart';
import 'package:mytimer/l10n/generated/app_localizations.dart';
import 'home_timer_card.dart';

class AddTimerBottomSheet extends StatelessWidget {
  final Map<String, TimerCatalogItem> catalog;
  final List<String> currentTimerOrder;
  final void Function(String id) onAdd;
  final VoidCallback onResetToDefault;

  const AddTimerBottomSheet({
    super.key,
    required this.catalog,
    required this.currentTimerOrder,
    required this.onAdd,
    required this.onResetToDefault,
  });

  static Future<void> show(
    BuildContext context, {
    required Map<String, TimerCatalogItem> catalog,
    required List<String> currentTimerOrder,
    required void Function(String id) onAdd,
    required VoidCallback onResetToDefault,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => AddTimerBottomSheet(
        catalog: catalog,
        currentTimerOrder: currentTimerOrder,
        onAdd: onAdd,
        onResetToDefault: onResetToDefault,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return StatefulBuilder(
      builder: (ctx, setSheetState) {
        final currentHidden = catalog.keys
            .where((k) => !currentTimerOrder.contains(k))
            .toList();

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle Bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n?.addTimer ?? 'Zamanlayıcı Ekle',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        onResetToDefault();
                        Navigator.of(ctx).pop();
                      },
                      child: Text(
                        l10n?.resetLayout ?? 'Varsayılan',
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (currentHidden.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: Color(0xFF00E676),
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n?.allTimersAdded ??
                              'Tüm zamanlayıcılar ana ekranda',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: currentHidden.length,
                      separatorBuilder: (_, _) =>
                          const Divider(color: Colors.white12, height: 1),
                      itemBuilder: (ctx, i) {
                        final item = catalog[currentHidden[i]]!;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.icon,
                              color: item.color,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            item.getTitle(l10n),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            item.getSubtitle(l10n),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          trailing: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: item.color.withValues(alpha: 0.2),
                              foregroundColor: item.color,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: item.color.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.add, size: 18),
                            label: Text(
                              l10n?.addInterval ?? 'Ekle',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            onPressed: () {
                              onAdd(item.id);
                              setSheetState(() {});
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
