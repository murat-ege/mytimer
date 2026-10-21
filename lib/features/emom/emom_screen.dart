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

class EmomScreen extends StatefulWidget {
  const EmomScreen({super.key});

  @override
  State<EmomScreen> createState() => _EmomScreenState();
}

class _EmomScreenState extends State<EmomScreen> {
  final LocalTimerRepository _repository = LocalTimerRepository();

  int _prepSeconds = 10;
  int _emomMinutes = 10;
  int _intervalSeconds = 60; // Standard 1 min, or E2MOM (120s), etc.
  String _presetNote = '';
  String? _activePresetName;

  static const Color _themeColor = Color(0xFFFFD600);

  @override
  void initState() {
    super.initState();
    _loadLastPreset();
  }

  Future<void> _loadLastPreset() async {
    final last = await _repository.getLastLoadedRoutine('emom');
    if (last != null && mounted) {
      _applyPreset(last, saveToStorage: false);
    }
  }

  void _restoreDefaults() {
    setState(() {
      _prepSeconds = 10;
      _emomMinutes = 10;
      _intervalSeconds = 60;
      _presetNote = '';
      _activePresetName = null;
    });
    _repository.clearLastLoadedRoutine('emom');
  }

  void _applyPreset(CustomRoutine routine, {bool saveToStorage = true}) {
    setState(() {
      _prepSeconds = routine.prepSeconds;
      _emomMinutes = routine.rounds;
      if (routine.intervals.isNotEmpty) {
        _intervalSeconds = routine.intervals.first.durationSeconds;
      }
      _presetNote = routine.description;
      _activePresetName = routine.name;
    });
    if (saveToStorage) {
      _repository.saveLastLoadedRoutine('emom', routine);
    }
  }

  Future<void> _saveCurrentPreset(String name, String note) async {
    final now = DateTime.now();
    final routine = CustomRoutine(
      id: const Uuid().v4(),
      name: name,
      description: note,
      category: 'emom',
      isPreset: false,
      prepSeconds: _prepSeconds,
      rounds: _emomMinutes,
      intervals: [
        IntervalStep(
          id: 'step_emom',
          name: 'EMOM',
          durationSeconds: _intervalSeconds,
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
    await _repository.saveLastLoadedRoutine('emom', routine);
  }

  void _startWorkout() {
    final now = DateTime.now();
    final routine = CustomRoutine(
      id: 'emom_${now.millisecondsSinceEpoch}',
      name: 'EMOM $_emomMinutes MIN',
      description: _presetNote,
      category: 'emom',
      prepSeconds: _prepSeconds,
      rounds: _emomMinutes,
      intervals: [
        IntervalStep(
          id: 'step_emom_work',
          name: 'EMOM',
          durationSeconds: _intervalSeconds,
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
      title: 'EMOM',
      primaryColor: _themeColor,
      onSave: _saveCurrentPreset,
    );
  }

  void _openPresets() {
    final l10n = AppLocalizations.of(context);
    TimerPresetSheet.show(
      context: context,
      timerType: 'emom',
      title: 'EMOM',
      primaryColor: _themeColor,
      defaultName: l10n?.defaultPreset ?? '10 Min EMOM (Default)',
      defaultSummary: '10 Rounds • 1:00 per minute • 10s Prep',
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
          l10n?.emomTitle ?? 'EMOM',
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
                      value: _emomMinutes == 0
                          ? (l10n?.off ?? 'OFF')
                          : '$_emomMinutes $minUnit',
                      color: _themeColor,
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.white12),
                  Expanded(
                    child: StatItem(
                      label: l10n?.totalRoundsStat ?? 'TOTAL ROUNDS',
                      value: _emomMinutes == 0
                          ? (l10n?.off ?? 'OFF')
                          : '$_emomMinutes',
                      color: const Color(0xFF00E676),
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.white12),
                  Expanded(
                    child: StatItem(
                      label: 'INTERVAL',
                      value: _intervalSeconds == 0
                          ? (l10n?.off ?? 'OFF')
                          : '$_intervalSeconds $secUnit',
                      color: const Color(0xFF00E5FF),
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

            // 2. Total Minutes / Rounds
            NumberStepperTile(
              title: l10n?.totalTime ?? 'TOTAL MINUTES (ROUNDS)',
              valueText: _emomMinutes == 0
                  ? (l10n?.off ?? 'OFF')
                  : '$_emomMinutes $minUnit',
              color: _themeColor,
              icon: Icons.repeat_rounded,
              onDec: () {
                if (_emomMinutes > 1) setState(() => _emomMinutes -= 1);
              },
              onInc: () => setState(() => _emomMinutes += 1),
            ),

            const SizedBox(height: 14),

            // 3. Interval Length (E1MOM / E2MOM etc.)
            NumberStepperTile(
              title: 'INTERVAL CADENCE',
              valueText: _intervalSeconds == 0
                  ? (l10n?.off ?? 'OFF')
                  : '$_intervalSeconds $secUnit (${_intervalSeconds ~/ 60}m)',
              color: const Color(0xFF00E676),
              icon: Icons.timer_outlined,
              onDec: () {
                if (_intervalSeconds > 30) {
                  setState(() => _intervalSeconds -= 30);
                }
              },
              onInc: () => setState(() => _intervalSeconds += 30),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
      bottomNavigationBar: StickyStartButton(
        title: l10n?.start ?? 'START EMOM',
        color: _themeColor,
        onPressed: _startWorkout,
      ),
    );
  }
}
