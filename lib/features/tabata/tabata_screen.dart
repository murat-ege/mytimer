import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:mytimer/l10n/generated/app_localizations.dart';
import 'package:mytimer/models/custom_routine.dart';
import 'package:mytimer/models/interval_step.dart';
import 'package:mytimer/models/timer_phase.dart';
import 'package:mytimer/repositories/local_timer_repository.dart';
import 'package:mytimer/shared/widgets/active_preset_banner.dart';
import 'package:mytimer/shared/widgets/timer_preset_sheet.dart';
import 'package:mytimer/shared/widgets/stat_item.dart';
import 'package:mytimer/shared/widgets/number_stepper_tile.dart';
import 'package:mytimer/shared/widgets/sticky_start_button.dart';
import 'package:mytimer/features/timer_runner/timer_runner_screen.dart';

class TabataScreen extends StatefulWidget {
  const TabataScreen({super.key});

  @override
  State<TabataScreen> createState() => _TabataScreenState();
}

class _TabataScreenState extends State<TabataScreen> {
  final LocalTimerRepository _repository = LocalTimerRepository();

  int _workSeconds = 20;
  int _restSeconds = 10;
  int _rounds = 8;
  int _prepSeconds = 10;
  int _cooldownSeconds = 0;
  String _presetNote = '';
  String? _activePresetName;

  static const Color _themeColor = Color(0xFF00E676);

  @override
  void initState() {
    super.initState();
    _loadLastPreset();
  }

  Future<void> _loadLastPreset() async {
    final last = await _repository.getLastLoadedRoutine('tabata');
    if (last != null && mounted) {
      _applyPreset(last, saveToStorage: false);
    }
  }

  int get _totalWorkoutSeconds {
    return ((_workSeconds + _restSeconds) * _rounds) + _cooldownSeconds;
  }

  String _formattedTotalTime(String minUnit, String secUnit) {
    final mins = _totalWorkoutSeconds ~/ 60;
    final secs = _totalWorkoutSeconds % 60;
    return '$mins$minUnit ${secs.toString().padLeft(2, '0')}$secUnit';
  }

  void _restoreDefaults() {
    setState(() {
      _workSeconds = 20;
      _restSeconds = 10;
      _rounds = 8;
      _prepSeconds = 10;
      _cooldownSeconds = 0;
      _presetNote = '';
      _activePresetName = null;
    });
    _repository.clearLastLoadedRoutine('tabata');
  }

  void _applyPreset(CustomRoutine routine, {bool saveToStorage = true}) {
    setState(() {
      _prepSeconds = routine.prepSeconds;
      _cooldownSeconds = routine.cooldownSeconds;
      _rounds = routine.rounds;
      if (routine.intervals.isNotEmpty) {
        _workSeconds = routine.intervals.first.durationSeconds;
      }
      if (routine.intervals.length > 1) {
        _restSeconds = routine.intervals[1].durationSeconds;
      }
      _presetNote = routine.description;
      _activePresetName = routine.name;
    });
    if (saveToStorage) {
      _repository.saveLastLoadedRoutine('tabata', routine);
    }
  }

  Future<void> _saveCurrentPreset(String name, String note) async {
    final now = DateTime.now();
    final routine = CustomRoutine(
      id: const Uuid().v4(),
      name: name,
      description: note,
      category: 'tabata',
      isPreset: false,
      prepSeconds: _prepSeconds,
      cooldownSeconds: _cooldownSeconds,
      rounds: _rounds,
      intervals: [
        IntervalStep(
          id: 'step_work',
          name: 'WORK',
          durationSeconds: _workSeconds,
          phase: TimerPhase.work,
        ),
        IntervalStep(
          id: 'step_rest',
          name: 'REST',
          durationSeconds: _restSeconds,
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
    await _repository.saveLastLoadedRoutine('tabata', routine);
  }

  void _startWorkout() {
    final now = DateTime.now();
    final routine = CustomRoutine(
      id: 'tabata_${now.millisecondsSinceEpoch}',
      name: 'TABATA',
      description: _presetNote,
      category: 'tabata',
      prepSeconds: _prepSeconds,
      cooldownSeconds: _cooldownSeconds,
      rounds: _rounds,
      intervals: [
        IntervalStep(
          id: 'step_work',
          name: 'WORK',
          durationSeconds: _workSeconds,
          phase: TimerPhase.work,
        ),
        IntervalStep(
          id: 'step_rest',
          name: 'REST',
          durationSeconds: _restSeconds,
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
      title: 'TABATA',
      primaryColor: _themeColor,
      onSave: _saveCurrentPreset,
    );
  }

  void _openPresets() {
    final l10n = AppLocalizations.of(context);
    TimerPresetSheet.show(
      context: context,
      timerType: 'tabata',
      title: 'TABATA',
      primaryColor: _themeColor,
      defaultName: l10n?.defaultPreset ?? 'Standard Tabata (Default)',
      defaultSummary: '8 Rounds • 20s Work / 10s Rest',
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

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n?.tabata ?? 'TABATA',
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
                      value: _formattedTotalTime(minUnit, secUnit),
                      color: _themeColor,
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.white12),
                  Expanded(
                    child: StatItem(
                      label: l10n?.totalRoundsStat ?? 'TOTAL ROUNDS',
                      value: '$_rounds $roundUnit',
                      color: const Color(0xFFFFB300),
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.white12),
                  Expanded(
                    child: StatItem(
                      label: l10n?.workRestStat ?? 'WORK / REST',
                      value: '$_workSeconds$secUnit / $_restSeconds$secUnit',
                      color: const Color(0xFFFF3D00),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 1. Prep Stepper
            NumberStepperTile(
              title: l10n?.prepTime ?? 'PREP TIME',
              valueText: _prepSeconds == 0
                  ? (l10n?.off ?? 'OFF')
                  : '$_prepSeconds $secUnit',
              color: const Color(0xFF00E5FF),
              icon: Icons.hourglass_top_rounded,
              onDecrement: () {
                if (_prepSeconds > 0) setState(() => _prepSeconds -= 1);
              },
              onIncrement: () {
                setState(() => _prepSeconds += 1);
              },
            ),

            const SizedBox(height: 14),

            // 2. Work Duration Control
            NumberStepperTile(
              title: l10n?.workTime ?? 'WORK TIME',
              valueText: _workSeconds == 0
                  ? (l10n?.off ?? 'OFF')
                  : '$_workSeconds $secUnit',
              color: _themeColor,
              icon: Icons.fitness_center_rounded,
              onDecrement: () {
                if (_workSeconds > 1) setState(() => _workSeconds -= 1);
              },
              onIncrement: () {
                setState(() => _workSeconds += 1);
              },
            ),

            const SizedBox(height: 14),

            // 3. Rest Duration Control
            NumberStepperTile(
              title: l10n?.restTime ?? 'REST TIME',
              valueText: _restSeconds == 0
                  ? (l10n?.off ?? 'OFF')
                  : '$_restSeconds $secUnit',
              color: const Color(0xFFFF3D00),
              icon: Icons.pause_circle_outline_rounded,
              onDecrement: () {
                if (_restSeconds > 0) setState(() => _restSeconds -= 1);
              },
              onIncrement: () {
                setState(() => _restSeconds += 1);
              },
            ),

            const SizedBox(height: 14),

            // 4. Rounds Control
            NumberStepperTile(
              title: l10n?.totalRounds ?? 'TOTAL ROUNDS',
              valueText: _rounds == 0
                  ? (l10n?.off ?? 'OFF')
                  : '$_rounds $roundUnit',
              color: const Color(0xFFFFB300),
              icon: Icons.repeat_rounded,
              onDecrement: () {
                if (_rounds > 1) setState(() => _rounds -= 1);
              },
              onIncrement: () {
                setState(() => _rounds += 1);
              },
            ),

            const SizedBox(height: 14),

            // 5. Cooldown Control
            NumberStepperTile(
              title: l10n?.cooldownTime ?? 'COOLDOWN TIME',
              valueText: _cooldownSeconds == 0
                  ? (l10n?.off ?? 'OFF')
                  : '$_cooldownSeconds $secUnit',
              color: const Color(0xFF00E5FF),
              icon: Icons.ac_unit_rounded,
              onDecrement: () {
                if (_cooldownSeconds > 0) {
                  setState(
                    () =>
                        _cooldownSeconds = (_cooldownSeconds - 5).clamp(0, 600),
                  );
                }
              },
              onIncrement: () {
                setState(
                  () => _cooldownSeconds = (_cooldownSeconds + 5).clamp(0, 600),
                );
              },
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
      bottomNavigationBar: StickyStartButton(
        label: l10n?.start ?? 'START TABATA',
        themeColor: _themeColor,
        onPressed: _startWorkout,
      ),
    );
  }
}
