import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/custom_routine.dart';
import '../../models/interval_step.dart';
import '../../models/timer_phase.dart';
import '../../repositories/local_timer_repository.dart';
import '../../shared/widgets/active_preset_banner.dart';
import '../../shared/widgets/number_stepper_tile.dart';
import '../../shared/widgets/stat_item.dart';
import '../../shared/widgets/sticky_start_button.dart';
import '../../shared/widgets/timer_preset_sheet.dart';
import '../timer_runner/timer_runner_screen.dart';

// import 'widgets/quick_duration_chips.dart';

class AmrapScreen extends StatefulWidget {
  const AmrapScreen({super.key});

  @override
  State<AmrapScreen> createState() => _AmrapScreenState();
}

class _AmrapScreenState extends State<AmrapScreen> {
  final LocalTimerRepository _repository = LocalTimerRepository();

  int _prepSeconds = 10;
  int _amrapMinutes = 15;
  String _presetNote = '';
  String? _activePresetName;

  static const Color _themeColor = Color(0xFFFF5722);

  @override
  void initState() {
    super.initState();
    _loadLastPreset();
  }

  Future<void> _loadLastPreset() async {
    final last = await _repository.getLastLoadedRoutine('amrap');
    if (last != null && mounted) {
      _applyPreset(last, saveToStorage: false);
    }
  }

  void _restoreDefaults() {
    setState(() {
      _prepSeconds = 10;
      _amrapMinutes = 15;
      _presetNote = '';
      _activePresetName = null;
    });
    _repository.clearLastLoadedRoutine('amrap');
  }

  void _applyPreset(CustomRoutine routine, {bool saveToStorage = true}) {
    setState(() {
      _prepSeconds = routine.prepSeconds;
      _amrapMinutes = (routine.totalDurationSeconds ~/ 60).clamp(1, 120);
      _presetNote = routine.description;
      _activePresetName = routine.name;
    });
    if (saveToStorage) {
      _repository.saveLastLoadedRoutine('amrap', routine);
    }
  }

  Future<void> _saveCurrentPreset(String name, String note) async {
    final now = DateTime.now();
    final routine = CustomRoutine(
      id: const Uuid().v4(),
      name: name,
      description: note,
      category: 'amrap',
      isPreset: false,
      prepSeconds: _prepSeconds,
      rounds: 1,
      intervals: [
        IntervalStep(
          id: 'step_amrap',
          name: 'AMRAP',
          durationSeconds: _amrapMinutes * 60,
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
    await _repository.saveLastLoadedRoutine('amrap', routine);
  }

  void _startWorkout() {
    final now = DateTime.now();
    final routine = CustomRoutine(
      id: 'amrap_${now.millisecondsSinceEpoch}',
      name: 'AMRAP $_amrapMinutes MIN',
      description: _presetNote,
      category: 'amrap',
      prepSeconds: _prepSeconds,
      rounds: 1,
      intervals: [
        IntervalStep(
          id: 'step_amrap',
          name: 'AMRAP',
          durationSeconds: _amrapMinutes * 60,
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
      title: 'AMRAP',
      primaryColor: _themeColor,
      onSave: _saveCurrentPreset,
    );
  }

  void _openPresets() {
    final l10n = AppLocalizations.of(context);
    TimerPresetSheet.show(
      context: context,
      timerType: 'amrap',
      title: 'AMRAP',
      primaryColor: _themeColor,
      defaultName: l10n?.defaultPreset ?? '15 Min AMRAP (Default)',
      defaultSummary: '15m 00s Cap • 10s Prep',
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
          l10n?.amrapTitle ?? 'AMRAP',
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
                      value: _amrapMinutes == 0
                          ? (l10n?.off ?? 'OFF')
                          : '$_amrapMinutes:00',
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
                    child: const StatItem(
                      label: 'GOAL',
                      value: 'MAX REPS',
                      color: Color(0xFF00E676),
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

            // 2. AMRAP Duration Stepper
            NumberStepperTile(
              title: 'AMRAP (${l10n?.timeCap ?? "DURATION"})',
              valueText: _amrapMinutes == 0
                  ? (l10n?.off ?? 'OFF')
                  : '$_amrapMinutes $minUnit',
              color: _themeColor,
              icon: Icons.timer_outlined,
              onDec: () {
                if (_amrapMinutes > 1) setState(() => _amrapMinutes -= 1);
              },
              onInc: () => setState(() => _amrapMinutes += 1),
            ),

            const SizedBox(height: 14),

            // // Quick Duration Chips
            // QuickDurationChips(
            //   durations: const [5, 7, 10, 12, 15, 20, 25, 30],
            //   selectedDuration: _amrapMinutes,
            //   unit: minUnit,
            //   themeColor: _themeColor,
            //   onSelected: (mins) => setState(() => _amrapMinutes = mins),
            // ),

            // const SizedBox(height: 12),
          ],
        ),
      ),
      bottomNavigationBar: StickyStartButton(
        title: l10n?.start ?? 'START AMRAP',
        color: _themeColor,
        onPressed: _startWorkout,
      ),
    );
  }
}
