import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/workout_log.dart';
import 'system_date_formatter.dart';

class WorkoutLogExporter {
  static String _escapeCell(dynamic value) {
    final str = value?.toString() ?? '';
    if (str.contains(',') || str.contains('"') || str.contains('\n') || str.contains('\r')) {
      return '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }

  /// Generates RFC 4180 compliant CSV string from workout logs
  static String generateCsv(List<WorkoutLog> logs) {
    final List<List<dynamic>> rows = [
      [
        'ID',
        'Date & Time',
        'Timer Mode',
        'Workout Title',
        'Definition / Parameters',
        'Duration (Sec)',
        'Duration (Formatted)',
        'Rounds Completed',
        'Total Rounds',
        'Workout Notes',
        'Photo Attached',
      ],
      ...logs.map((log) => [
            log.id,
            SystemDateFormatter.formatDateTime(log.completedAt),
            log.timerType.toUpperCase(),
            log.title,
            log.defaultDefinition,
            log.totalDurationSeconds,
            log.formattedDuration,
            log.completedRounds ?? '',
            log.totalRounds ?? '',
            log.userNote,
            log.imagePath != null && log.imagePath!.isNotEmpty ? 'YES' : 'NO',
          ]),
    ];

    return rows.map((row) => row.map(_escapeCell).join(',')).join('\r\n');
  }

  static Future<bool> exportLogs(List<WorkoutLog> logs, {String? title}) async {
    final csvContent = generateCsv(logs);
    final subject = title ?? (logs.length == 1 ? 'MyTimer Workout - ${logs.first.title}' : 'MyTimer Workout Logs');

    try {
      await SharePlus.instance.share(ShareParams(text: csvContent, subject: subject));
      return true;
    } catch (_) {
      // Fallback: Copy to system clipboard
      await Clipboard.setData(ClipboardData(text: csvContent));
      return false;
    }
  }

  static Future<void> copyToClipboard(List<WorkoutLog> logs) async {
    final csvContent = generateCsv(logs);
    await Clipboard.setData(ClipboardData(text: csvContent));
  }
}
