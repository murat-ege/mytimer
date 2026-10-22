import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../models/custom_routine.dart';
import '../../../models/interval_step.dart';
import '../../../models/timer_phase.dart';
import '../../../shared/utils/home_timer_helper.dart';

class EditPresetSheet extends StatefulWidget {
  final CustomRoutine routine;
  final ValueChanged<CustomRoutine> onSaved;
  final ValueChanged<CustomRoutine> onOpenInTimer;

  const EditPresetSheet({
    super.key,
    required this.routine,
    required this.onSaved,
    required this.onOpenInTimer,
  });

  static Future<void> show({
    required BuildContext context,
    required CustomRoutine routine,
    required ValueChanged<CustomRoutine> onSaved,
    required ValueChanged<CustomRoutine> onOpenInTimer,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => EditPresetSheet(
        routine: routine,
        onSaved: onSaved,
        onOpenInTimer: onOpenInTimer,
      ),
    );
  }

  @override
  State<EditPresetSheet> createState() => _EditPresetSheetState();
}

class _EditPresetSheetState extends State<EditPresetSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _noteCtrl;

  late int _rounds;
  late int _prepSeconds;
  late int _cooldownSeconds;
  late int _workSeconds;
  late int _restSeconds;

  /// Rounds and HYROX interval timers use a single work step plus rest
  /// between rounds (no rest after the last round), mirroring the
  /// Compromised Run structure.
  late final bool _usesRoundRest;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.routine.name);
    _noteCtrl = TextEditingController(text: widget.routine.description);

    final cat = widget.routine.category.toLowerCase();
    final isRoundsType = cat.contains('round');
    _usesRoundRest = isRoundsType ||
        (cat.contains('hyrox') && widget.routine.intervals.length <= 1);

    _rounds = widget.routine.rounds;
    _prepSeconds = widget.routine.prepSeconds;
    _cooldownSeconds = widget.routine.cooldownSeconds;
    _workSeconds = widget.routine.intervals.isNotEmpty
        ? widget.routine.intervals.first.durationSeconds
        : 20;
    if (_usesRoundRest) {
      // Legacy Rounds timers may still carry a REST step instead.
      _restSeconds = widget.routine.restBetweenRoundsSeconds > 0
          ? widget.routine.restBetweenRoundsSeconds
          : (widget.routine.intervals.length > 1
              ? widget.routine.intervals[1].durationSeconds
              : 0);
    } else {
      _restSeconds = widget.routine.intervals.length > 1
          ? widget.routine.intervals[1].durationSeconds
          : widget.routine.restBetweenRoundsSeconds;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String _formatSecs(int totalSecs) {
    final m = totalSecs ~/ 60;
    final s = totalSecs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  CustomRoutine _buildUpdatedRoutine({required bool hasRest}) {
    final name = _nameCtrl.text.trim().isNotEmpty
        ? _nameCtrl.text.trim()
        : widget.routine.name;
    final note = _noteCtrl.text.trim();

    final intervals = <IntervalStep>[
      IntervalStep(
        id: widget.routine.intervals.isNotEmpty
            ? widget.routine.intervals.first.id
            : 'step_work',
        name: widget.routine.intervals.isNotEmpty
            ? widget.routine.intervals.first.name
            : 'WORK',
        durationSeconds: _workSeconds,
        phase: TimerPhase.work,
      ),
    ];

    final addRestStep = !_usesRoundRest && hasRest && _restSeconds > 0;
    if (addRestStep) {
      intervals.add(
        IntervalStep(
          id: widget.routine.intervals.length > 1
              ? widget.routine.intervals[1].id
              : 'step_rest',
          name: widget.routine.intervals.length > 1
              ? widget.routine.intervals[1].name
              : 'REST',
          durationSeconds: _restSeconds,
          phase: TimerPhase.rest,
        ),
      );
    }

    return widget.routine.copyWith(
      name: name,
      description: note,
      rounds: _rounds,
      prepSeconds: _prepSeconds,
      cooldownSeconds: _cooldownSeconds,
      // Rest lives either in a REST step or between rounds — never both.
      restBetweenRoundsSeconds: _usesRoundRest
          ? _restSeconds
          : (addRestStep ? 0 : widget.routine.restBetweenRoundsSeconds),
      intervals: intervals,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final routine = widget.routine;

    final cat = routine.category.toLowerCase().trim().replaceAll(' ', '').replaceAll('_', '');
    final color = HomeTimerHelper.getCategoryColor(routine.category);
    final icon = HomeTimerHelper.getCategoryIcon(routine.category);

    final isTabata = cat.contains('tabata');
    final isRounds = cat.contains('round');
    final isAmrap = cat.contains('amrap');
    final isForTime = cat.contains('fortime');
    final isCountdown = cat.contains('countdown');

    final hasRest = isTabata || isRounds || _usesRoundRest || _restSeconds > 0;
    final hasRounds = !isAmrap && !isForTime && !isCountdown;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 14,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.editTimer ?? 'Edit Timer',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        routine.isPreset
                            ? (l10n?.willBeSavedAsCustomCopy ?? 'Will be saved as a custom copy')
                            : (l10n?.customTimerWillBeUpdated ?? 'Custom timer will be updated'),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 12),

            // Scrollable Fields
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  // 1. Routine Name
                  TextField(
                    controller: _nameCtrl,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: l10n?.routineName ?? 'Routine Name',
                      labelStyle: TextStyle(color: color),
                      filled: true,
                      fillColor: const Color(0xFF141414),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2. Note
                  TextField(
                    controller: _noteCtrl,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: l10n?.workoutNote ?? 'Notes / Description',
                      labelStyle: const TextStyle(color: Colors.white60),
                      filled: true,
                      fillColor: const Color(0xFF141414),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // PARAMETERS SECTION HEADER
                  Row(
                    children: [
                      Icon(Icons.tune_rounded, size: 16, color: color),
                      const SizedBox(width: 6),
                      Text(
                        l10n?.timerParameters ?? 'TIMER PARAMETERS',
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 1. Prep Seconds
                  _buildParamRow(
                    icon: Icons.hourglass_top_rounded,
                    label: l10n?.prepDuration ?? 'Prep Duration',
                    valueText: '${_prepSeconds}s',
                    color: const Color(0xFFFF9100),
                    onMinus: () {
                      if (_prepSeconds >= 5) {
                        setState(() => _prepSeconds -= 5);
                        HapticFeedback.lightImpact();
                      }
                    },
                    onPlus: () {
                      if (_prepSeconds <= 55) {
                        setState(() => _prepSeconds += 5);
                        HapticFeedback.lightImpact();
                      }
                    },
                  ),

                  // 2. Rounds
                  if (hasRounds)
                    _buildParamRow(
                      icon: Icons.repeat_rounded,
                      label: l10n?.roundsCount ?? 'Rounds',
                      valueText: '$_rounds ${l10n?.roundsShort ?? 'Rnds'}',
                      color: const Color(0xFF00E676),
                      onMinus: () {
                        if (_rounds > 1) {
                          setState(() => _rounds--);
                          HapticFeedback.lightImpact();
                        }
                      },
                      onPlus: () {
                        if (_rounds < 99) {
                          setState(() => _rounds++);
                          HapticFeedback.lightImpact();
                        }
                      },
                    ),

                  // 3. Work / Interval Duration
                  _buildParamRow(
                    icon: Icons.timer_outlined,
                    label: (isAmrap || isForTime || isCountdown)
                        ? (l10n?.durationOrCap ?? 'Duration / Cap')
                        : (l10n?.workDuration ?? 'Work Duration'),
                    valueText: _formatSecs(_workSeconds),
                    color: color,
                    onMinus: () {
                      final step = (isAmrap || isForTime)
                          ? 60
                          : (_usesRoundRest && _workSeconds > 60)
                              ? 30
                              : (_workSeconds > 60 ? 15 : 5);
                      if (_workSeconds > step) {
                        setState(() => _workSeconds -= step);
                        HapticFeedback.lightImpact();
                      }
                    },
                    onPlus: () {
                      final step = (isAmrap || isForTime)
                          ? 60
                          : (_usesRoundRest && _workSeconds >= 60)
                              ? 30
                              : (_workSeconds >= 60 ? 15 : 5);
                      setState(() => _workSeconds += step);
                      HapticFeedback.lightImpact();
                    },
                  ),

                  // 4. Rest Duration
                  if (hasRest)
                    _buildParamRow(
                      icon: Icons.pause_circle_outline,
                      label: l10n?.restDuration ?? 'Rest Duration',
                      valueText: _formatSecs(_restSeconds),
                      color: const Color(0xFF2979FF),
                      onMinus: () {
                        final step = _restSeconds > 60 ? 15 : 5;
                        if (_restSeconds >= step) {
                          setState(() => _restSeconds -= step);
                          HapticFeedback.lightImpact();
                        }
                      },
                      onPlus: () {
                        final step = _restSeconds >= 60 ? 15 : 5;
                        setState(() => _restSeconds += step);
                        HapticFeedback.lightImpact();
                      },
                    ),

                  // 5. Cooldown
                  _buildParamRow(
                    icon: Icons.ac_unit_rounded,
                    label: l10n?.cooldownDuration ?? 'Cooldown',
                    valueText: '${_cooldownSeconds}s',
                    color: const Color(0xFF00E5FF),
                    onMinus: () {
                      if (_cooldownSeconds >= 10) {
                        setState(() => _cooldownSeconds -= 10);
                        HapticFeedback.lightImpact();
                      }
                    },
                    onPlus: () {
                      if (_cooldownSeconds <= 300) {
                        setState(() => _cooldownSeconds += 10);
                        HapticFeedback.lightImpact();
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Actions Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.play_circle_outline, size: 20),
                    label: Text(l10n?.openInTimer ?? 'Open in Timer'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      final updated = _buildUpdatedRoutine(hasRest: hasRest);
                      widget.onOpenInTimer(updated);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.save_rounded, size: 20),
                    label: Text(
                      l10n?.save ?? 'SAVE',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      final updated = _buildUpdatedRoutine(hasRest: hasRest);
                      widget.onSaved(updated);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildParamRow({
    required IconData icon,
    required String label,
    required String valueText,
    required Color color,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onMinus,
                icon: const Icon(Icons.remove_circle_outline, color: Colors.white70, size: 22),
                visualDensity: VisualDensity.compact,
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 60),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  valueText,
                  style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900),
                ),
              ),
              IconButton(
                onPressed: onPlus,
                icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 22),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
