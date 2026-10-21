import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/custom_routine.dart';
import '../../models/interval_step.dart';
import '../../models/timer_phase.dart';
import '../../repositories/local_timer_repository.dart';
import '../../shared/widgets/active_preset_banner.dart';
import '../../shared/widgets/number_stepper_tile.dart';
// import '../../shared/widgets/quick_choice_chips.dart';
import '../../shared/widgets/stat_item.dart';
import '../../shared/widgets/sticky_start_button.dart';
import '../../shared/widgets/timer_preset_sheet.dart';
import '../timer_runner/timer_runner_screen.dart';

class ForTimeScreen extends StatefulWidget {
  const ForTimeScreen({super.key});

  @override
  State<ForTimeScreen> createState() => _ForTimeScreenState();
}

class _ForTimeScreenState extends State<ForTimeScreen> {
  final LocalTimerRepository _repository = LocalTimerRepository();

  int _prepSeconds = 10;
  int _forTimeCapMinutes = 20;
  int _intervalSignalMinutes = 0;
  String _presetNote = '';
  String? _activePresetName;

  static const Color _themeColor = Color(0xFF7C4DFF);

  @override
  void initState() {
    super.initState();
    _loadLastPreset();
  }

  Future<void> _loadLastPreset() async {
    final last = await _repository.getLastLoadedRoutine('fortime');
    if (last != null && mounted) {
      _applyPreset(last, saveToStorage: false);
    }
  }

  void _restoreDefaults() {
    setState(() {
      _prepSeconds = 10;
      _forTimeCapMinutes = 20;
      _intervalSignalMinutes = 0;
      _presetNote = '';
      _activePresetName = null;
    });
    _repository.clearLastLoadedRoutine('fortime');
  }

  void _applyPreset(CustomRoutine routine, {bool saveToStorage = true}) {
    setState(() {
      _prepSeconds = routine.prepSeconds;
      _forTimeCapMinutes = (routine.totalDurationSeconds ~/ 60).clamp(1, 180);
      _intervalSignalMinutes = routine.intervalSignalSeconds ~/ 60;
      _presetNote = routine.description;
      _activePresetName = routine.name;
    });
    if (saveToStorage) {
      _repository.saveLastLoadedRoutine('fortime', routine);
    }
  }

  Future<void> _saveCurrentPreset(String name, String note) async {
    final now = DateTime.now();
    final routine = CustomRoutine(
      id: const Uuid().v4(),
      name: name,
      description: note,
      category: 'fortime',
      isPreset: false,
      prepSeconds: _prepSeconds,
      rounds: 1,
      intervalSignalSeconds: _intervalSignalMinutes * 60,
      intervals: [
        IntervalStep(
          id: 'step_fortime',
          name: 'FOR TIME',
          durationSeconds: _forTimeCapMinutes * 60,
          phase: TimerPhase.work,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );
    await _repository.saveRoutine(routine);
    setState(() {
      _activePresetName = name;
    });
    await _repository.saveLastLoadedRoutine('fortime', routine);
  }

  void _startWorkout() {
    final now = DateTime.now();
    final routine = CustomRoutine(
      id: 'fortime_${now.millisecondsSinceEpoch}',
      name: 'FOR TIME (CAP $_forTimeCapMinutes MIN)',
      description: _presetNote,
      category: 'fortime',
      prepSeconds: _prepSeconds,
      rounds: 1,
      intervalSignalSeconds: _intervalSignalMinutes * 60,
      intervals: [
        IntervalStep(
          id: 'step_fortime',
          name: 'FOR TIME',
          durationSeconds: _forTimeCapMinutes * 60,
          phase: TimerPhase.work,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TimerRunnerScreen(routine: routine)),
    );
  }

  void _openSaveDialog() {
    TimerPresetSheet.showSaveDialog(
      context: context,
      title: 'FOR TIME',
      primaryColor: _themeColor,
      onSave: _saveCurrentPreset,
    );
  }

  void _openPresets() {
    final l10n = AppLocalizations.of(context);
    TimerPresetSheet.show(
      context: context,
      timerType: 'fortime',
      title: 'FOR TIME',
      primaryColor: _themeColor,
      defaultName: l10n?.defaultPreset ?? '20 Min Cap (Default)',
      defaultSummary: '20m 00s Time Cap • 10s Prep',
      onSelectDefault: _restoreDefaults,
      onSelectPreset: _applyPreset,
      onPresetDeleted: (_, name) {
        if (_activePresetName == name) {
          _restoreDefaults();
        }
      },
      onSaveCurrent: _saveCurrentPreset,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final secUnit = l10n?.seconds ?? 's';
    final minUnit = l10n?.minutes ?? 'min';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n?.forTimeTitle ?? 'FOR TIME',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined, color: _themeColor),
            tooltip: l10n?.savePreset ?? 'Save Preset',
            onPressed: _openSaveDialog,
          ),
          IconButton(
            icon: const Icon(Icons.bookmarks_outlined, color: Colors.white70),
            tooltip: l10n?.presets ?? 'Presets & Saved Timers',
            onPressed: _openPresets,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          children: [
            if (_activePresetName != null && _activePresetName!.isNotEmpty)
              ActivePresetBanner(
                presetName: _activePresetName!,
                themeColor: _themeColor,
                onClear: _restoreDefaults,
              ),

            // Top Overview Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1E1E), Color(0xFF262626)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _themeColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: StatItem(
                      label: l10n?.timeCap ?? 'TIME CAP',
                      value: _forTimeCapMinutes == 0
                          ? (l10n?.off ?? 'OFF')
                          : '$_forTimeCapMinutes:00',
                      color: _themeColor,
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.white12),
                  Expanded(
                    child: StatItem(
                      label: l10n?.prepTime ?? 'PREP',
                      value: _prepSeconds == 0
                          ? (l10n?.off ?? 'OFF')
                          : '$_prepSeconds $secUnit',
                      color: const Color(0xFF00E5FF),
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.white12),
                  Expanded(
                    child: StatItem(
                      label: l10n?.intervalSignal ?? 'INTERVAL SIGNAL',
                      value: _intervalSignalMinutes == 0
                          ? (l10n?.off ?? 'OFF')
                          : '$_intervalSignalMinutes $minUnit',
                      color: const Color(0xFFFFB300),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 1. Prep Control
            NumberStepperTile(
              title: l10n?.prepTime ?? 'PREP TIME',
              valueText: _prepSeconds == 0
                  ? (l10n?.off ?? 'OFF')
                  : '$_prepSeconds $secUnit',
              color: const Color(0xFF00E5FF),
              icon: Icons.hourglass_top_rounded,
              onDec: () {
                if (_prepSeconds > 0) setState(() => _prepSeconds -= 1);
              },
              onInc: () => setState(() => _prepSeconds += 1),
            ),

            const SizedBox(height: 14),

            // 2. Time Cap Stepper
            NumberStepperTile(
              title: l10n?.timeCap ?? 'TIME CAP (MAX DURATION)',
              valueText: _forTimeCapMinutes == 0
                  ? (l10n?.off ?? 'OFF')
                  : '$_forTimeCapMinutes $minUnit',
              color: _themeColor,
              icon: Icons.timer_outlined,
              onDec: () {
                if (_forTimeCapMinutes > 0) {
                  setState(() => _forTimeCapMinutes -= 1);
                }
              },
              onInc: () => setState(() => _forTimeCapMinutes += 1),
            ),

            const SizedBox(height: 14),

            // Quick Time Cap Chips
            // QuickChoiceChips<int>(
            //   items: [5, 10, 12, 15, 20, 25, 30, 45, 60]
            //       .map(
            //         (m) => QuickChoiceChipItem<int>(
            //           value: m,
            //           label: '$m $minUnit',
            //         ),
            //       )
            //       .toList(),
            //   selectedValue: _forTimeCapMinutes,
            //   activeColor: _themeColor,
            //   onSelected: (mins) => setState(() => _forTimeCapMinutes = mins),
            // ),

            // const SizedBox(height: 14),

            // 3. Interval Signal Stepper
            NumberStepperTile(
              title: l10n?.intervalSignal ?? 'INTERVAL SIGNAL',
              valueText: _intervalSignalMinutes == 0
                  ? (l10n?.off ?? 'OFF')
                  : (l10n?.everyMinute(_intervalSignalMinutes) ??
                        'Every $_intervalSignalMinutes $minUnit'),
              color: const Color(0xFFFFB300),
              icon: Icons.notifications_active_outlined,
              onDec: () {
                if (_intervalSignalMinutes > 0) {
                  setState(() => _intervalSignalMinutes -= 1);
                }
              },
              onInc: () {
                if (_intervalSignalMinutes < _forTimeCapMinutes) {
                  setState(() => _intervalSignalMinutes += 1);
                }
              },
            ),

            const SizedBox(height: 10),

            // // Quick Interval Signal Chips
            // QuickChoiceChips<int>(
            //   items: [0, 1, 2, 3, 5]
            //       .map(
            //         (m) => QuickChoiceChipItem<int>(
            //           value: m,
            //           label: m == 0 ? (l10n?.off ?? 'OFF') : '$m $minUnit',
            //         ),
            //       )
            //       .toList(),
            //   selectedValue: _intervalSignalMinutes,
            //   activeColor: const Color(0xFFFFB300),
            //   onSelected: (mins) =>
            //       setState(() => _intervalSignalMinutes = mins),
            // ),

            // const SizedBox(height: 12),
          ],
        ),
      ),
      bottomNavigationBar: StickyStartButton(
        title: l10n?.start ?? 'START FOR TIME',
        color: _themeColor,
        onPressed: _startWorkout,
      ),
    );
  }
}
