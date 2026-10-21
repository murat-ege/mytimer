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
import '../../shared/widgets/sticky_start_button.dart';
import '../../shared/widgets/timer_preset_sheet.dart';
import '../timer_runner/timer_runner_screen.dart';
import '../../shared/theme/app_typography.dart';
import 'widgets/unit_stepper.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  final LocalTimerRepository _repository = LocalTimerRepository();

  int _hours = 0;
  int _minutes = 5;
  int _seconds = 0;
  int _prepSeconds = 0;
  String _presetNote = '';
  String? _activePresetName;

  static const Color _themeColor = Color(0xFFFF4081);

  @override
  void initState() {
    super.initState();
    _loadLastPreset();
  }

  Future<void> _loadLastPreset() async {
    final last = await _repository.getLastLoadedRoutine('countdown');
    if (last != null && mounted) {
      _applyPreset(last, saveToStorage: false);
    }
  }

  int get _totalSeconds => (_hours * 3600) + (_minutes * 60) + _seconds;

  // void _applyQuickPreset(int minutes) {
  //   setState(() {
  //     _hours = minutes ~/ 60;
  //     _minutes = minutes % 60;
  //     _seconds = 0;
  //   });
  // }

  void _restoreDefaults() {
    setState(() {
      _hours = 0;
      _minutes = 5;
      _seconds = 0;
      _prepSeconds = 0;
      _presetNote = '';
      _activePresetName = null;
    });
    _repository.clearLastLoadedRoutine('countdown');
  }

  void _applyPreset(CustomRoutine routine, {bool saveToStorage = true}) {
    setState(() {
      _prepSeconds = routine.prepSeconds;
      final totalSec = routine.totalDurationSeconds;
      _hours = totalSec ~/ 3600;
      _minutes = (totalSec % 3600) ~/ 60;
      _seconds = totalSec % 60;
      _presetNote = routine.description;
      _activePresetName = routine.name;
    });
    if (saveToStorage) {
      _repository.saveLastLoadedRoutine('countdown', routine);
    }
  }

  Future<void> _saveCurrentPreset(String name, String note) async {
    final now = DateTime.now();
    final routine = CustomRoutine(
      id: const Uuid().v4(),
      name: name,
      description: note,
      category: 'countdown',
      isPreset: false,
      prepSeconds: _prepSeconds,
      rounds: 1,
      intervals: [
        IntervalStep(
          id: 'step_cd',
          name: name.toUpperCase(),
          durationSeconds: _totalSeconds,
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
    await _repository.saveLastLoadedRoutine('countdown', routine);
  }

  void _startCountdown() {
    if (_totalSeconds <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set a duration greater than 0 seconds!'),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final title = _hours > 0
        ? 'COUNTDOWN ($_hours h $_minutes m)'
        : 'COUNTDOWN ($_minutes:${_seconds.toString().padLeft(2, '0')})';

    final routine = CustomRoutine(
      id: 'countdown_${now.millisecondsSinceEpoch}',
      name: title,
      description: _presetNote,
      category: 'countdown',
      prepSeconds: _prepSeconds,
      rounds: 1,
      intervals: [
        IntervalStep(
          id: 'step_countdown',
          name: 'COUNTDOWN',
          durationSeconds: _totalSeconds,
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
      title: 'COUNTDOWN',
      primaryColor: _themeColor,
      onSave: _saveCurrentPreset,
    );
  }

  void _openPresets() {
    final l10n = AppLocalizations.of(context);
    TimerPresetSheet.show(
      context: context,
      timerType: 'countdown',
      title: 'COUNTDOWN',
      primaryColor: _themeColor,
      defaultName: l10n?.defaultPreset ?? '5 Minute Countdown (Default)',
      defaultSummary: '5m 00s • OFF Prep',
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
    // final minUnit = l10n?.minutes ?? 'min';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n?.countdown ?? 'COUNTDOWN',
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

            // Time Selector Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1E1E), Color(0xFF262626)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _themeColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _totalSeconds == 0
                          ? (l10n?.off ?? 'OFF')
                          : '${_hours.toString().padLeft(2, '0')}:${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}',
                      maxLines: 1,
                      style: AppTypography.timerDigits(
                        color: Colors.white,
                        fontSize: 54,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: UnitStepper(
                          label: l10n?.hours ?? 'Hours',
                          value: _hours,
                          offText: l10n?.off ?? 'OFF',
                          onDec: () {
                            if (_hours > 0) setState(() => _hours--);
                          },
                          onInc: () {
                            if (_hours < 23) setState(() => _hours++);
                          },
                        ),
                      ),
                      Expanded(
                        child: UnitStepper(
                          label: l10n?.minutes ?? 'Minutes',
                          value: _minutes,
                          offText: l10n?.off ?? 'OFF',
                          onDec: () {
                            if (_minutes > 0) setState(() => _minutes--);
                          },
                          onInc: () {
                            if (_minutes < 59) setState(() => _minutes++);
                          },
                        ),
                      ),
                      Expanded(
                        child: UnitStepper(
                          label: l10n?.seconds ?? 'Seconds',
                          value: _seconds,
                          offText: l10n?.off ?? 'OFF',
                          onDec: () {
                            if (_seconds > 0) setState(() => _seconds -= 1);
                          },
                          onInc: () {
                            if (_seconds < 59) setState(() => _seconds += 1);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // // Quick Presets Row
            // QuickChoiceChips<int>(
            //   items: [1, 2, 3, 5, 10, 15, 20, 30, 45, 60]
            //       .map((m) => QuickChoiceChipItem<int>(value: m, label: '$m $minUnit'))
            //       .toList(),
            //   selectedValue: _minutes,
            //   activeColor: _themeColor,
            //   onSelected: (mins) => _applyQuickPreset(mins),
            // ),

            // const SizedBox(height: 16),

            // Prep Time Stepper
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

            const SizedBox(height: 12),
          ],
        ),
      ),
      bottomNavigationBar: StickyStartButton(
        title: l10n?.start ?? 'START COUNTDOWN',
        color: _themeColor,
        onPressed: _startCountdown,
      ),
    );
  }
}
