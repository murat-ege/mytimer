import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/workout_log.dart';
import '../../repositories/workout_log_repository.dart';
import '../../services/system_date_formatter.dart';
import '../../services/workout_log_exporter.dart';
import 'widgets/workout_log_card.dart';

class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key});

  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  final WorkoutLogRepository _repository = WorkoutLogRepository();
  final ImagePicker _imagePicker = ImagePicker();

  List<WorkoutLog> _logs = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    final list = await _repository.getLogs();
    if (mounted) {
      setState(() {
        _logs = list;
        _isLoading = false;
      });
    }
  }

  List<WorkoutLog> get _filteredLogs {
    if (_searchQuery.trim().isEmpty) return _logs;
    final q = _searchQuery.toLowerCase();
    return _logs.where((log) {
      return log.title.toLowerCase().contains(q) ||
          log.defaultDefinition.toLowerCase().contains(q) ||
          log.userNote.toLowerCase().contains(q);
    }).toList();
  }

  Color _getTimerColor(String timerType) {
    switch (timerType.toLowerCase()) {
      case 'tabata':
        return const Color(0xFF00E676);
      case 'rounds':
        return const Color(0xFF2979FF);
      case 'emom':
        return const Color(0xFFFFD600);
      case 'amrap':
        return const Color(0xFFFF5722);
      case 'fortime':
        return const Color(0xFF7C4DFF);
      case 'stopwatch':
        return const Color(0xFF00E5FF);
      case 'countdown':
        return const Color(0xFFFF4081);
      case 'custom':
        return const Color(0xFF00BFA5);
      default:
        return const Color(0xFF00BFA5);
    }
  }

  Future<void> _pickImage(WorkoutLog log, ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked != null) {
        final updated = log.copyWith(imagePath: picked.path);
        await _repository.saveLog(updated);
        _loadLogs();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo attached to workout!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to attach photo: $e')),
        );
      }
    }
  }

  void _showImageOptions(WorkoutLog log) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                log.imagePath != null ? (l10n?.changePhoto ?? 'Change Photo') : (l10n?.attachPhoto ?? 'Attach Photo (Whiteboard / Score)'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF00E676)),
                title: const Text('Take Photo (Camera)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(log, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF00E5FF)),
                title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(log, ImageSource.gallery);
                },
              ),
              if (log.imagePath != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  title: Text(l10n?.removePhoto ?? 'Remove Photo', style: const TextStyle(color: Colors.redAccent)),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    final updated = log.copyWith(imagePath: '');
                    await _repository.saveLog(updated);
                    _loadLogs();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullImage(String path, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(path),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Container(
                  padding: const EdgeInsets.all(32),
                  color: const Color(0xFF1E1E1E),
                  child: const Text('Image file no longer available on device', style: TextStyle(color: Colors.white54)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editNote(WorkoutLog log) {
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: log.userNote);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(l10n?.workoutNote ?? 'Edit Workout Note', style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: l10n?.workoutNoteHint ?? 'Enter score, weights, scaling or notes',
            hintStyle: const TextStyle(color: Colors.white30),
            filled: true,
            fillColor: const Color(0xFF262626),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n?.cancel ?? 'CANCEL', style: const TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final updated = log.copyWith(userNote: ctrl.text.trim());
              await _repository.saveLog(updated);
              _loadLogs();
            },
            child: Text(l10n?.save ?? 'SAVE'),
          ),
        ],
      ),
    );
  }

  void _deleteSingleLog(WorkoutLog log) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete Log Entry?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete ${log.title} (${SystemDateFormatter.formatDateTime(log.completedAt)})?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n?.cancel ?? 'CANCEL', style: const TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n?.delete ?? 'DELETE', style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.deleteLog(log.id);
      _loadLogs();
    }
  }

  void _clearAllLogs() async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(l10n?.clearAllLogs ?? 'Clear All Logs', style: const TextStyle(color: Colors.white)),
        content: Text(
          l10n?.clearLogsConfirm ?? 'Are you sure you want to permanently delete all workout logs? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n?.cancel ?? 'CANCEL', style: const TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n?.delete ?? 'DELETE ALL'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.clearAllLogs();
      _loadLogs();
    }
  }

  void _exportSingleCsv(WorkoutLog log) async {
    final shared = await WorkoutLogExporter.exportLogs([log], title: 'Workout - ${log.title}');
    if (!shared && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV copied to clipboard!')),
      );
    }
  }

  void _exportAllCsv() async {
    if (_logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No workout logs to export!')),
      );
      return;
    }
    final shared = await WorkoutLogExporter.exportLogs(_logs, title: 'All_MyTimer_Workout_Logs');
    if (!shared && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV copied to clipboard!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final logs = _filteredLogs;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n?.workoutLogs ?? 'WORKOUT LOG',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_logs.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.file_download_outlined, color: Color(0xFF00E676)),
              tooltip: l10n?.exportAllCsv ?? 'Export All (CSV)',
              onPressed: _exportAllCsv,
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
              tooltip: l10n?.clearAllLogs ?? 'Clear All Logs',
              onPressed: _clearAllLogs,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)))
          : Column(
              children: [
                // Search bar if logs exist
                if (_logs.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: TextField(
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search logs, definitions or notes...',
                          hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF00E676), size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),

                Expanded(
                  child: logs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history_toggle_off_rounded, size: 64, color: Colors.white.withValues(alpha: 0.3)),
                              const SizedBox(height: 16),
                              Text(
                                l10n?.noLogsYet ?? 'No workout logs recorded yet.\nComplete any timer workout to see your history here!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 15, height: 1.4),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: logs.length,
                          itemBuilder: (context, idx) {
                            final log = logs[idx];
                            return WorkoutLogCard(
                              log: log,
                              typeColor: _getTimerColor(log.timerType),
                              onPhotoOptions: () => _showImageOptions(log),
                              onEditNote: () => _editNote(log),
                              onExport: () => _exportSingleCsv(log),
                              onDelete: () => _deleteSingleLog(log),
                              onShowFullImage: _showFullImage,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
