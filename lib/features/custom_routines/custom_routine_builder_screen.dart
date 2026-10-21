import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/custom_routine.dart';
import '../../models/interval_step.dart';
import '../../models/timer_phase.dart';
import '../../repositories/local_timer_repository.dart';

class CustomRoutineBuilderScreen extends StatefulWidget {
  final CustomRoutine? initialRoutine;

  const CustomRoutineBuilderScreen({super.key, this.initialRoutine});

  @override
  State<CustomRoutineBuilderScreen> createState() =>
      _CustomRoutineBuilderScreenState();
}

class _CustomRoutineBuilderScreenState
    extends State<CustomRoutineBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = LocalTimerRepository();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  int _prepSeconds = 10;
  int _rounds = 3;
  int _restBetweenRoundsSeconds = 30;
  bool _initializedLocalizedName = false;

  List<IntervalStep> _intervals = [];

  @override
  void initState() {
    super.initState();
    final init = widget.initialRoutine;
    _nameController = TextEditingController(text: init?.name ?? '');
    _descController = TextEditingController(text: init?.description ?? '');
    _prepSeconds = init?.prepSeconds ?? 10;
    _rounds = init?.rounds ?? 3;
    _restBetweenRoundsSeconds = init?.restBetweenRoundsSeconds ?? 30;

    if (init != null) {
      _intervals = List.from(init.intervals);
    } else {
      // Default initial intervals
      _intervals = [
        const IntervalStep(
          id: 'step_1',
          name: 'WORK',
          durationSeconds: 40,
          phase: TimerPhase.work,
        ),
        const IntervalStep(
          id: 'step_2',
          name: 'REST',
          durationSeconds: 20,
          phase: TimerPhase.rest,
        ),
      ];
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedLocalizedName) {
      _initializedLocalizedName = true;
      final init = widget.initialRoutine;
      if (init != null && init.isPreset) {
        final l10n = AppLocalizations.of(context);
        final suffix = l10n?.customSuffix ?? ' (Custom)';
        _nameController.text = '${init.name}$suffix';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _addInterval() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) {
        String name = l10n?.work ?? 'WORK';
        int duration = 30;
        TimerPhase phase = TimerPhase.work;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: Text(l10n?.addNewInterval ?? 'Add New Interval', style: const TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: l10n?.intervalName ?? 'Interval Name',
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText: l10n?.routineNameHint ?? 'e.g., Kettlebell Swing, Rest',
                        hintStyle: const TextStyle(color: Colors.white30),
                        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) => name = val.trim(),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TimerPhase>(
                      initialValue: phase,
                      dropdownColor: const Color(0xFF262626),
                      decoration: InputDecoration(
                        labelText: l10n?.intervalPhaseLabel ?? 'Phase',
                        labelStyle: const TextStyle(color: Colors.white70),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: TimerPhase.work,
                          child: Text(l10n?.work ?? 'WORK', style: const TextStyle(color: Color(0xFF00E676))),
                        ),
                        DropdownMenuItem(
                          value: TimerPhase.rest,
                          child: Text(l10n?.rest ?? 'REST', style: const TextStyle(color: Color(0xFFFF3D00))),
                        ),
                        DropdownMenuItem(
                          value: TimerPhase.cooldown,
                          child: Text(l10n?.cooldown ?? 'COOLDOWN', style: const TextStyle(color: Color(0xFF00E5FF))),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            phase = val;
                            if (phase == TimerPhase.rest) name = l10n?.rest ?? 'REST';
                            if (phase == TimerPhase.work) name = l10n?.work ?? 'WORK';
                            if (phase == TimerPhase.cooldown) name = l10n?.cooldown ?? 'COOLDOWN';
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n?.durationSec ?? 'Duration (s):', style: const TextStyle(color: Colors.white70)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.white70),
                              onPressed: () {
                                if (duration > 0) setDialogState(() => duration -= 1);
                              },
                            ),
                            Text(
                              duration == 0 ? (l10n?.off ?? 'OFF') : '$duration ${l10n?.seconds ?? "s"}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.white70),
                              onPressed: () => setDialogState(() => duration += 1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(l10n?.cancel ?? 'CANCEL', style: const TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676), foregroundColor: Colors.black),
                  onPressed: () {
                    setState(() {
                      _intervals.add(
                        IntervalStep(
                          id: const Uuid().v4(),
                          name: name.isEmpty ? (l10n?.work ?? 'WORK') : name,
                          durationSeconds: duration,
                          phase: phase,
                        ),
                      );
                    });
                    Navigator.of(ctx).pop();
                  },
                  child: Text(l10n?.add ?? 'ADD'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveRoutine() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_intervals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.addAtLeastOneInterval ?? 'Please add at least one interval!')),
      );
      return;
    }

    final now = DateTime.now();
    final isEditingPreset = widget.initialRoutine?.isPreset ?? false;
    final routineId = (widget.initialRoutine == null || isEditingPreset)
        ? const Uuid().v4()
        : widget.initialRoutine!.id;

    final routine = CustomRoutine(
      id: routineId,
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      category: 'Custom',
      isPreset: false, // User modified or created routines are always custom
      prepSeconds: _prepSeconds,
      rounds: _rounds,
      restBetweenRoundsSeconds: _restBetweenRoundsSeconds,
      intervals: _intervals,
      createdAt: isEditingPreset ? now : (widget.initialRoutine?.createdAt ?? now),
      updatedAt: now,
    );

    await _repository.saveRoutine(routine);

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  String _getStepDisplayName(String name, TimerPhase phase, AppLocalizations? l10n) {
    if (name == 'ÇALIŞMA' || name == 'WORK') return l10n?.work ?? 'WORK';
    if (name == 'DİNLENME' || name == 'REST') return l10n?.rest ?? 'REST';
    if (name == 'SOĞUMA' || name == 'COOLDOWN') return l10n?.cooldown ?? 'COOLDOWN';
    if (name == 'HAZIRLIK' || name == 'PREP') return l10n?.prep ?? 'PREP';
    return name;
  }

  String _getPhaseDisplayName(TimerPhase phase, AppLocalizations? l10n) {
    switch (phase) {
      case TimerPhase.prep:
        return l10n?.prep ?? 'PREP';
      case TimerPhase.work:
        return l10n?.work ?? 'WORK';
      case TimerPhase.rest:
      case TimerPhase.restBetweenSets:
        return l10n?.rest ?? 'REST';
      case TimerPhase.cooldown:
        return l10n?.cooldown ?? 'COOLDOWN';
      case TimerPhase.finished:
        return l10n?.finished ?? 'FINISHED';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditingPreset = widget.initialRoutine?.isPreset ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.initialRoutine == null
              ? (l10n?.createRoutine ?? 'CREATE TIMER')
              : (isEditingPreset ? (l10n?.customizeWod ?? 'CUSTOMIZE WOD') : (l10n?.editTimer ?? 'EDIT TIMER')),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFF00E676), size: 28),
            onPressed: _saveRoutine,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Routine Name Field
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: '${l10n?.routineName ?? "Timer Name"} *',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: l10n?.routineNameHint ?? 'e.g., Barbell Complex, HIIT 45/15',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? (l10n?.routineNameRequired ?? 'Please enter a name') : null,
              ),

              const SizedBox(height: 14),

              // Routine Description Field
              TextFormField(
                controller: _descController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: l10n?.descriptionLabel ?? 'Description (Optional)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: l10n?.descriptionHint ?? 'Target movements, weights or notes',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 20),

              // Controls Grid (Rounds, Prep, Rest between rounds)
              Row(
                children: [
                  Expanded(
                    child: _buildSmallStepper(
                      l10n?.totalRounds ?? 'TOTAL ROUNDS',
                      _rounds == 0 ? (l10n?.off ?? 'OFF') : '$_rounds',
                      () { if (_rounds > 1) setState(() => _rounds--); },
                      () => setState(() => _rounds++),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSmallStepper(
                      l10n?.prepTime ?? 'PREP TIME',
                      _prepSeconds == 0 ? (l10n?.off ?? 'OFF') : '$_prepSeconds ${l10n?.seconds ?? "s"}',
                      () { if (_prepSeconds > 0) setState(() => _prepSeconds -= 1); },
                      () => setState(() => _prepSeconds += 1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSmallStepper(
                      l10n?.restBetweenSets ?? 'REST BETWEEN ROUNDS',
                      _restBetweenRoundsSeconds == 0 ? (l10n?.off ?? 'OFF') : '$_restBetweenRoundsSeconds ${l10n?.seconds ?? "s"}',
                      () { if (_restBetweenRoundsSeconds > 0) setState(() => _restBetweenRoundsSeconds -= 1); },
                      () => setState(() => _restBetweenRoundsSeconds += 1),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Intervals Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      l10n?.intervalSequence ?? 'INTERVAL SEQUENCE',
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _addInterval,
                    icon: const Icon(Icons.add, color: Color(0xFF00E676)),
                    label: Text(l10n?.addInterval ?? 'ADD INTERVAL', style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Reorderable Interval List
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _intervals.length,
                onReorderItem: (oldIndex, newIndex) {
                  setState(() {
                    final item = _intervals.removeAt(oldIndex);
                    _intervals.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final step = _intervals[index];
                  final color = step.phase.primaryColor;
                  final stepDisplayName = _getStepDisplayName(step.name, step.phase, l10n);
                  final phaseName = _getPhaseDisplayName(step.phase, l10n);

                  return Container(
                    key: ValueKey(step.id),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.drag_indicator, color: Colors.white38),
                        const SizedBox(width: 10),
                        Container(
                          width: 10,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stepDisplayName,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                '$phaseName • ${step.durationSeconds} ${l10n?.seconds ?? "s"}',
                                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () {
                            setState(() {
                              _intervals.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveRoutine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 26),
                      const SizedBox(width: 8),
                      Text(
                        l10n?.saveTimer ?? 'SAVE TIMER',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallStepper(String title, String val, VoidCallback onDec, VoidCallback onInc) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(val, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onDec,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
                  child: const Icon(Icons.remove, size: 16, color: Colors.white70),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onInc,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
                  child: const Icon(Icons.add, size: 16, color: Colors.white70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
