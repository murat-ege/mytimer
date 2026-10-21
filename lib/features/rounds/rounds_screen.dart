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

class RoundsScreen extends StatefulWidget {
  const RoundsScreen({super.key});

  @override
  State<RoundsScreen> createState() => _RoundsScreenState();
}

class _RoundsScreenState extends State<RoundsScreen> {
  final LocalTimerRepository _repository = LocalTimerRepository();

  int _prepSeconds = 10;
  int _roundWorkMinutes = 3;
  int _roundRestMinutes = 1;
  int _roundsCount = 5;
  int _cooldownMinutes = 0;
  String _presetNote = '';
  String? _activePresetName;

  static const Color _themeColor = Color(0xFF2979FF);

  @override
  void initState() {
    super.initState();
    _loadLastPreset();
  }

  Future<void> _loadLastPreset() async {
    final last = await _repository.getLastLoadedRoutine('rounds');
    if (last != null && mounted) {
      _applyPreset(last, saveToStorage: false);
    }
  }

  int get _totalWorkoutSeconds {
    return (((_roundWorkMinutes + _roundRestMinutes) * 60) * _roundsCount) +
        (_cooldownMinutes * 60);
  }

  void _restoreDefaults() {
    setState(() {
      _prepSeconds = 10;
      _roundWorkMinutes = 3;
      _roundRestMinutes = 1;
      _roundsCount = 5;
      _cooldownMinutes = 0;
      _presetNote = '';
      _activePresetName = null;
    });
    _repository.clearLastLoadedRoutine('rounds');
  }

  void _applyPreset(CustomRoutine routine, {bool saveToStorage = true}) {
    setState(() {
      _prepSeconds = routine.prepSeconds;
      _roundsCount = routine.rounds;
      _cooldownMinutes = routine.cooldownSeconds ~/ 60;
      if (routine.intervals.isNotEmpty) {
        _roundWorkMinutes = (routine.intervals.first.durationSeconds ~/ 60)
            .clamp(1, 60);
      }
      if (routine.intervals.length > 1) {
        _roundRestMinutes = (routine.intervals[1].durationSeconds ~/ 60).clamp(
          0,
          30,
        );
      }
      _presetNote = routine.description;
      _activePresetName = routine.name;
    });
    if (saveToStorage) {
      _repository.saveLastLoadedRoutine('rounds', routine);
    }
  }

  Future<void> _saveCurrentPreset(String name, String note) async {
    final now = DateTime.now();
    final routine = CustomRoutine(
      id: const Uuid().v4(),
      name: name,
      description: note,
      category: 'rounds',
      isPreset: false,
      prepSeconds: _prepSeconds,
      rounds: _roundsCount,
      cooldownSeconds: _cooldownMinutes * 60,
      intervals: [
        IntervalStep(
          id: 'step_r_work',
          name: 'WORK',
          durationSeconds: _roundWorkMinutes * 60,
          phase: TimerPhase.work,
        ),
        if (_roundRestMinutes > 0)
          IntervalStep(
            id: 'step_r_rest',
            name: 'REST',
            durationSeconds: _roundRestMinutes * 60,
            phase: TimerPhase.rest,
          ),
      ],
      createdAt: now,
      updatedAt: now,
    );
    await _repository.saveRoutine(routine);
    setState(() {
      _activePresetName = name;
    });
    await _repository.saveLastLoadedRoutine('rounds', routine);
  }

  void _startWorkout() {
    final now = DateTime.now();
    final routine = CustomRoutine(
      id: 'rounds_${now.millisecondsSinceEpoch}',
      name: '$_roundsCount ROUNDS',
      description: _presetNote,
      category: 'rounds',
      prepSeconds: _prepSeconds,
      rounds: _roundsCount,
      cooldownSeconds: _cooldownMinutes * 60,
      intervals: [
        IntervalStep(
          id: 'step_r_work',
          name: 'WORK',
          durationSeconds: _roundWorkMinutes * 60,
          phase: TimerPhase.work,
        ),
        if (_roundRestMinutes > 0)
          IntervalStep(
            id: 'step_r_rest',
            name: 'REST',
            durationSeconds: _roundRestMinutes * 60,
            phase: TimerPhase.rest,
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
      title: 'ROUNDS',
      primaryColor: _themeColor,
      onSave: _saveCurrentPreset,
    );
  }

  void _openPresets() {
    final l10n = AppLocalizations.of(context);
    TimerPresetSheet.show(
      context: context,
      timerType: 'rounds',
      title: 'ROUNDS',
      primaryColor: _themeColor,
      defaultName: l10n?.defaultPreset ?? '5 Rounds (3m Work / 1m Rest)',
      defaultSummary: '5 Rounds • 3m Work / 1m Rest',
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
    final roundUnit = l10n?.round ?? 'ROUND';

    final totalMins = _totalWorkoutSeconds ~/ 60;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n?.rounds ?? 'ROUNDS',
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
                      label: l10n?.totalTime ?? 'TOTAL TIME',
                      value: '$totalMins $minUnit',
                      color: const Color(0xFF00E676),
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.white12),
                  Expanded(
                    child: StatItem(
                      label: l10n?.totalRoundsStat ?? 'TOTAL ROUNDS',
                      value: '$_roundsCount $roundUnit',
                      color: _themeColor,
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.white12),
                  Expanded(
                    child: StatItem(
                      label: l10n?.workRestStat ?? 'WORK / REST',
                      value:
                          '$_roundWorkMinutes$minUnit / $_roundRestMinutes$minUnit',
                      color: const Color(0xFFFF3D00),
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

            // 2. Round Work Time
            NumberStepperTile(
              title: l10n?.workTime ?? 'ROUND WORK TIME',
              valueText: _roundWorkMinutes == 0
                  ? (l10n?.off ?? 'OFF')
                  : '$_roundWorkMinutes $minUnit',
              color: const Color(0xFF00E676),
              icon: Icons.fitness_center_rounded,
              onDec: () {
                if (_roundWorkMinutes > 1) setState(() => _roundWorkMinutes--);
              },
              onInc: () => setState(() => _roundWorkMinutes++),
            ),

            const SizedBox(height: 14),

            // 3. Round Rest Time
            NumberStepperTile(
              title: l10n?.restTime ?? 'ROUND REST TIME',
              valueText: _roundRestMinutes == 0
                  ? (l10n?.off ?? 'OFF')
                  : '$_roundRestMinutes $minUnit',
              color: const Color(0xFFFF3D00),
              icon: Icons.pause_circle_outline_rounded,
              onDec: () {
                if (_roundRestMinutes > 0) setState(() => _roundRestMinutes--);
              },
              onInc: () => setState(() => _roundRestMinutes++),
            ),

            const SizedBox(height: 14),

            // 4. Total Rounds
            NumberStepperTile(
              title: l10n?.totalRounds ?? 'TOTAL ROUNDS',
              valueText: _roundsCount == 0
                  ? (l10n?.off ?? 'OFF')
                  : '$_roundsCount $roundUnit',
              color: _themeColor,
              icon: Icons.repeat_rounded,
              onDec: () {
                if (_roundsCount > 1) setState(() => _roundsCount--);
              },
              onInc: () => setState(() => _roundsCount++),
            ),

            const SizedBox(height: 14),

            // 5. Cooldown Control
            NumberStepperTile(
              title: l10n?.cooldownTime ?? 'COOLDOWN TIME',
              valueText: _cooldownMinutes == 0
                  ? (l10n?.off ?? 'OFF')
                  : '$_cooldownMinutes $minUnit',
              color: const Color(0xFF00E5FF),
              icon: Icons.ac_unit_rounded,
              onDec: () {
                if (_cooldownMinutes > 0) setState(() => _cooldownMinutes--);
              },
              onInc: () => setState(() => _cooldownMinutes++),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
      bottomNavigationBar: StickyStartButton(
        title: l10n?.start ?? 'START ROUNDS',
        color: _themeColor,
        onPressed: _startWorkout,
      ),
    );
  }
}
