import 'dart:io';
import 'package:flutter/material.dart';
import '../../../models/workout_log.dart';
import '../../../services/system_date_formatter.dart';

class WorkoutLogCard extends StatelessWidget {
  final WorkoutLog log;
  final Color typeColor;
  final VoidCallback onPhotoOptions;
  final VoidCallback onEditNote;
  final VoidCallback onExport;
  final VoidCallback onDelete;
  final void Function(String path, String title) onShowFullImage;

  const WorkoutLogCard({
    super.key,
    required this.log,
    required this.typeColor,
    required this.onPhotoOptions,
    required this.onEditNote,
    required this.onExport,
    required this.onDelete,
    required this.onShowFullImage,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = log.imagePath != null && log.imagePath!.isNotEmpty && File(log.imagePath!).existsSync();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: typeColor.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Timer Type Badge, Date/Time, Menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: typeColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    log.timerType.toUpperCase(),
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      SystemDateFormatter.formatDateTime(log.completedAt),
                      style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
                  color: const Color(0xFF262626),
                  onSelected: (val) {
                    if (val == 'photo') onPhotoOptions();
                    if (val == 'note') onEditNote();
                    if (val == 'export') onExport();
                    if (val == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'photo',
                      child: Row(
                        children: [
                          Icon(hasImage ? Icons.image : Icons.add_a_photo_outlined, color: typeColor, size: 18),
                          const SizedBox(width: 8),
                          Text(hasImage ? 'Change Photo' : 'Attach Photo', style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'note',
                      child: Row(
                        children: [
                          Icon(Icons.edit_note, color: Colors.white70, size: 18),
                          SizedBox(width: 8),
                          Text('Edit Note', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(Icons.share_outlined, color: Colors.white70, size: 18),
                          SizedBox(width: 8),
                          Text('Export CSV', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Workout Title
            Text(
              log.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),

            if (log.defaultDefinition.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                log.defaultDefinition,
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
              ),
            ],

            const SizedBox(height: 10),

            // Middle: Duration & Stats Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, color: Color(0xFF00E676), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Total: ${log.formattedDuration}',
                        style: const TextStyle(color: Color(0xFF00E676), fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                if (log.completedRounds != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Rounds: ${log.completedRounds}${log.totalRounds != null ? "/${log.totalRounds}" : ""}',
                      style: const TextStyle(color: Color(0xFFFFB300), fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ],
            ),

            // User Note if available
            if (log.userNote.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notes, color: Colors.white54, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        log.userNote,
                        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Attached Photo thumbnail if present
            if (hasImage) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => onShowFullImage(log.imagePath!, log.title),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(log.imagePath!),
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox(),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.fullscreen, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: onPhotoOptions,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, color: typeColor.withValues(alpha: 0.7), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Attach whiteboard / workout photo',
                        style: TextStyle(color: typeColor.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
