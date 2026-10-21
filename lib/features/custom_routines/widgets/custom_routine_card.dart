import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/custom_routine.dart';

class CustomRoutineCard extends StatelessWidget {
  final CustomRoutine routine;
  final Color categoryColor;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String formattedTotalDuration;

  const CustomRoutineCard({
    super.key,
    required this.routine,
    required this.categoryColor,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.formattedTotalDuration,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isPreset = routine.isPreset;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: categoryColor.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Category tag and Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: categoryColor.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        ((routine.category == 'Custom' || routine.category == 'Özel')
                                ? (l10n?.categoryCustom.toUpperCase() ?? 'CUSTOM')
                                : routine.category.toUpperCase())
                            .replaceAll(' ', '\u00A0'),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.white60, size: 20),
                          onPressed: onEdit,
                          tooltip: isPreset
                              ? (l10n?.customizeOrCopy ?? 'Customize / Save Copy')
                              : (l10n?.edit ?? 'Edit'),
                          visualDensity: VisualDensity.compact,
                        ),
                        if (!isPreset)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            onPressed: onDelete,
                            tooltip: l10n?.delete ?? 'Delete',
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Routine Name
                Text(
                  routine.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                if (routine.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    routine.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                  ),
                ],

                const SizedBox(height: 12),

                // Badges & Action Row
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildBadge(
                              Icons.repeat,
                              l10n?.roundsBadge(routine.rounds) ?? '${routine.rounds} Rounds',
                              const Color(0xFFFFB300),
                            ),
                            const SizedBox(width: 6),
                            _buildBadge(
                              Icons.list_alt,
                              l10n?.intervalsBadge(routine.intervals.length) ??
                                  '${routine.intervals.length} Intervals',
                              const Color(0xFF00E5FF),
                            ),
                            const SizedBox(width: 6),
                            _buildBadge(
                              Icons.timer_outlined,
                              formattedTotalDuration,
                              const Color(0xFF00E676),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BFA5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            l10n?.start ?? 'START',
                            maxLines: 1,
                            softWrap: false,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            text.replaceAll(' ', '\u00A0'),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
