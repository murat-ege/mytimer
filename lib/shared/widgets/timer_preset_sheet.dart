import 'package:flutter/material.dart';
import 'package:mytimer/l10n/generated/app_localizations.dart';
import 'package:mytimer/models/custom_routine.dart';
import 'package:mytimer/repositories/local_timer_repository.dart';

class TimerPresetSheet extends StatefulWidget {
  final String timerType;
  final String title;
  final Color primaryColor;
  final String defaultName;
  final String defaultSummary;
  final VoidCallback onSelectDefault;
  final void Function(CustomRoutine routine) onSelectPreset;
  final void Function(String id, String name)? onPresetDeleted;
  final Future<void> Function(String name, String note)? onSaveCurrent;

  const TimerPresetSheet({
    super.key,
    required this.timerType,
    required this.title,
    required this.primaryColor,
    required this.defaultName,
    required this.defaultSummary,
    required this.onSelectDefault,
    required this.onSelectPreset,
    this.onPresetDeleted,
    this.onSaveCurrent,
  });

  static Future<void> show({
    required BuildContext context,
    required String timerType,
    required String title,
    required Color primaryColor,
    required String defaultName,
    required String defaultSummary,
    required VoidCallback onSelectDefault,
    required void Function(CustomRoutine routine) onSelectPreset,
    void Function(String id, String name)? onPresetDeleted,
    Future<void> Function(String name, String note)? onSaveCurrent,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TimerPresetSheet(
        timerType: timerType,
        title: title,
        primaryColor: primaryColor,
        defaultName: defaultName,
        defaultSummary: defaultSummary,
        onSelectDefault: onSelectDefault,
        onSelectPreset: onSelectPreset,
        onPresetDeleted: onPresetDeleted,
        onSaveCurrent: onSaveCurrent,
      ),
    );
  }

  static Future<void> showSaveDialog({
    required BuildContext context,
    required String title,
    required Color primaryColor,
    required Future<void> Function(String name, String note) onSave,
  }) {
    final l10n = AppLocalizations.of(context);
    final nameCtrl = TextEditingController(text: '$title Custom');
    final noteCtrl = TextEditingController();

    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n?.savePreset ?? 'Save As Custom Preset',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: l10n?.routineName ?? 'WOD / Timer Name',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: l10n?.presetNameHint ?? 'e.g. My Heavy WOD',
                hintStyle: const TextStyle(color: Colors.white30),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n?.workoutNote ?? 'Workout Notes (Optional)',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText:
                    l10n?.workoutNoteHint ?? 'Target weights, scaling, reps',
                hintStyle: const TextStyle(color: Colors.white30),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              l10n?.cancel ?? 'CANCEL',
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(ctx).pop();
                await onSave(name, noteCtrl.text.trim());
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n?.presetSaved ?? 'Preset saved successfully',
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(
              l10n?.save ?? 'SAVE',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  State<TimerPresetSheet> createState() => _TimerPresetSheetState();
}

class _TimerPresetSheetState extends State<TimerPresetSheet> {
  final LocalTimerRepository _repository = LocalTimerRepository();
  List<CustomRoutine> _presets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    final all = await _repository.getRoutines();
    if (mounted) {
      setState(() {
        _presets = all
            .where(
              (r) => r.category.toLowerCase() == widget.timerType.toLowerCase(),
            )
            .toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF181818),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Colors.white24, width: 0.5)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title.toUpperCase(),
                        style: TextStyle(
                          color: widget.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        l10n?.presets ?? 'Saved Presets & Custom Timers',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: l10n?.cancel ?? 'Close',
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 1),

          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: widget.primaryColor,
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    children: [
                      // 1. DEFAULT BASE PRESET (FIRST OPTION)
                      _buildPresetCard(
                        title: widget.defaultName,
                        summary: widget.defaultSummary,
                        note:
                            l10n?.restoreDefault ??
                            'Reset timer to original default parameters',
                        isDefault: true,
                        onTap: () {
                          widget.onSelectDefault();
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${widget.defaultName} applied!'),
                            ),
                          );
                        },
                      ),

                      if (_presets.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 4.0,
                            bottom: 6.0,
                          ),
                          child: Text(
                            l10n?.customRoutines.toUpperCase() ??
                                'CUSTOM SAVED WODS',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],

                      // 2. USER SAVED PRESETS
                      ..._presets.map(
                        (preset) => Dismissible(
                          key: Key('preset_${preset.id}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                          onDismissed: (_) async {
                            final deletedName = preset.name;
                            final deletedId = preset.id;
                            await _repository.deleteRoutine(preset.id);
                            widget.onPresetDeleted?.call(
                              deletedId,
                              deletedName,
                            );
                            await _loadPresets();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$deletedName silindi'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          child: _buildPresetCard(
                            title: preset.name,
                            summary:
                                '${preset.rounds} Rounds • ${_formatDuration(preset.totalDurationSeconds)}',
                            note: preset.description,
                            isDefault: false,
                            onTap: () {
                              widget.onSelectPreset(preset);
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${preset.name} applied!'),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int secs) {
    final mins = secs ~/ 60;
    final remSecs = secs % 60;
    if (mins == 0) return '${remSecs}s';
    return '${mins}m ${remSecs > 0 ? '${remSecs}s' : ''}'.trim();
  }

  Widget _buildPresetCard({
    required String title,
    required String summary,
    required String note,
    required bool isDefault,
    required VoidCallback onTap,
    VoidCallback? onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDefault
              ? widget.primaryColor.withValues(alpha: 0.5)
              : Colors.white12,
          width: isDefault ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDefault
                        ? widget.primaryColor.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDefault
                        ? Icons.restart_alt_rounded
                        : Icons.fitness_center_rounded,
                    color: isDefault ? widget.primaryColor : Colors.white70,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: isDefault
                                    ? widget.primaryColor
                                    : Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          // if (isDefault)
                          //   Container(
                          //     padding: const EdgeInsets.symmetric(
                          //       horizontal: 8,
                          //       vertical: 2,
                          //     ),
                          //     decoration: BoxDecoration(
                          //       color: widget.primaryColor.withValues(
                          //         alpha: 0.15,
                          //       ),
                          //       borderRadius: BorderRadius.circular(6),
                          //       border: Border.all(
                          //         color: widget.primaryColor,
                          //         width: 0.8,
                          //       ),
                          //     ),
                          //     child: const Text(
                          //       'ORIGINAL',
                          //       style: TextStyle(
                          //         color: Color(0xFF00E676),
                          //         fontSize: 9,
                          //         fontWeight: FontWeight.w900,
                          //         letterSpacing: 1,
                          //       ),
                          //     ),
                          //   ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        summary,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (note.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          note,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isDefault && onDelete != null)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.white38,
                      size: 20,
                    ),
                    onPressed: onDelete,
                  )
                else
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white38,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
