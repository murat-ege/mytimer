import 'package:flutter/material.dart';
import 'package:mytimer/l10n/generated/app_localizations.dart';
import '../../../models/custom_routine.dart';
import 'home_timer_card.dart';

class AddTimerBottomSheet extends StatefulWidget {
  final Map<String, TimerCatalogItem> baseCatalog;
  final List<String> currentTimerOrder;
  final List<CustomRoutine>? allRoutines;
  final void Function(String id) onAdd;
  final void Function(String id)? onRemove;
  final VoidCallback onResetToDefault;

  const AddTimerBottomSheet({
    super.key,
    required this.baseCatalog,
    required this.currentTimerOrder,
    this.allRoutines,
    required this.onAdd,
    this.onRemove,
    required this.onResetToDefault,
  });

  static Future<void> show(
    BuildContext context, {
    required Map<String, TimerCatalogItem> baseCatalog,
    required List<String> currentTimerOrder,
    List<CustomRoutine>? allRoutines,
    required void Function(String id) onAdd,
    void Function(String id)? onRemove,
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
        baseCatalog: baseCatalog,
        currentTimerOrder: currentTimerOrder,
        allRoutines: allRoutines,
        onAdd: onAdd,
        onRemove: onRemove,
        onResetToDefault: onResetToDefault,
      ),
    );
  }

  @override
  State<AddTimerBottomSheet> createState() => _AddTimerBottomSheetState();
}

class _AddTimerBottomSheetState extends State<AddTimerBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentHidden = widget.baseCatalog.keys
        .where((k) => !widget.currentTimerOrder.contains(k))
        .toList();

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
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

              // Title & Reset
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n?.addTimer ?? 'Add Timer',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onResetToDefault();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      l10n?.resetLayout ?? 'Reset Layout',
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

              // Timers List
              Flexible(
                child: _buildStandardTimersList(context, l10n, currentHidden),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandardTimersList(
    BuildContext context,
    AppLocalizations? l10n,
    List<String> currentHidden,
  ) {
    if (currentHidden.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 36.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: Color(0xFF00E676),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              l10n?.allTimersAdded ?? 'All timers are on the home screen',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: currentHidden.length,
      separatorBuilder: (_, _) => const Divider(color: Colors.white12, height: 1),
      itemBuilder: (ctx, i) {
        final item = widget.baseCatalog[currentHidden[i]]!;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.color, size: 24),
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
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          trailing: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: item.color.withValues(alpha: 0.2),
              foregroundColor: item.color,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: item.color.withValues(alpha: 0.5)),
              ),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              l10n?.addInterval ?? 'Ekle',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            onPressed: () {
              widget.onAdd(item.id);
              setState(() {});
            },
          ),
        );
      },
    );
  }
}
