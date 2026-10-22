import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../models/custom_routine.dart';
import '../../../shared/utils/home_timer_helper.dart';

class PresetListCard extends StatelessWidget {
  final CustomRoutine routine;
  final bool isPinned;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PresetListCard({
    super.key,
    required this.routine,
    required this.isPinned,
    required this.onTap,
    required this.onTogglePin,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDuration(int secs) {
    final mins = secs ~/ 60;
    final remSecs = secs % 60;
    if (mins == 0) return '${remSecs}s';
    return '${mins}m ${remSecs > 0 ? '${remSecs}s' : ''}'.trim();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = HomeTimerHelper.getCategoryColor(routine.category);
    final icon = HomeTimerHelper.getCategoryIcon(routine.category);

    return Dismissible(
      key: Key('tm_routine_${routine.id}'),
      direction: routine.isPreset
          ? DismissDirection.none
          : DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Category Badge, Standard/Custom Tag & Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon, color: color, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: color.withValues(alpha: 0.4),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  routine.category.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),
                            if (!routine.isPreset) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E676).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFF00E676).withValues(alpha: 0.4),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  l10n?.categoryCustom.toUpperCase() ?? 'CUSTOM',
                                  style: const TextStyle(
                                    color: Color(0xFF00E676),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Pin to Home
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            icon: Icon(
                              isPinned
                                  ? Icons.push_pin_rounded
                                  : Icons.push_pin_outlined,
                              color: isPinned ? color : Colors.white38,
                              size: 20,
                            ),
                            tooltip: isPinned
                                ? (l10n?.unpinFromHome ?? 'Unpin from Home')
                                : (l10n?.pinToHome ?? 'Pin to Home'),
                            visualDensity: VisualDensity.compact,
                            onPressed: onTogglePin,
                          ),

                          // Quick Edit
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.white60,
                              size: 20,
                            ),
                            tooltip: l10n?.edit ?? 'Edit',
                            visualDensity: VisualDensity.compact,
                            onPressed: onEdit,
                          ),

                          // Delete
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            icon: Icon(
                              routine.isPreset
                                  ? Icons.lock_outline_rounded
                                  : Icons.delete_outline,
                              color: routine.isPreset
                                  ? Colors.white24
                                  : const Color(0xFFFF5252),
                              size: routine.isPreset ? 18 : 20,
                            ),
                            tooltip: routine.isPreset
                                ? (l10n?.timerCannotBeDeleted ?? 'Built-in timer (Cannot be deleted)')
                                : (l10n?.delete ?? 'Delete'),
                            visualDensity: VisualDensity.compact,
                            onPressed: onDelete,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Routine Name
                  Text(
                    routine.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Summary Details
                  Text(
                    '${routine.rounds} Rounds • ${_formatDuration(routine.totalDurationSeconds)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // Description / Note (if any)
                  if (routine.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      routine.description.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        l10n?.openInTimer ?? 'Open in Timer',
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: color,
                        size: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
