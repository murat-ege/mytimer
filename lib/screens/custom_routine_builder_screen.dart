import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/custom_routine.dart';
import '../models/interval_step.dart';
import '../models/timer_phase.dart';
import '../repositories/local_timer_repository.dart';

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
          name: 'ÇALIŞMA',
          durationSeconds: 40,
          phase: TimerPhase.work,
        ),
        const IntervalStep(
          id: 'step_2',
          name: 'DİNLENME',
          durationSeconds: 20,
          phase: TimerPhase.rest,
        ),
      ];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _addInterval() {
    showDialog(
      context: context,
      builder: (ctx) {
        String name = 'ÇALIŞMA';
        int duration = 30;
        TimerPhase phase = TimerPhase.work;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text('Yeni Aralık Ekle', style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Aralık Adı',
                        labelStyle: TextStyle(color: Colors.white70),
                        hintText: 'Örn: Kettlebell Swing, Dinlenme',
                        hintStyle: TextStyle(color: Colors.white30),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) => name = val.trim(),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TimerPhase>(
                      initialValue: phase,
                      dropdownColor: const Color(0xFF262626),
                      decoration: const InputDecoration(
                        labelText: 'Tip',
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                      items: const [
                        DropdownMenuItem(value: TimerPhase.work, child: Text('ÇALIŞMA (Work)', style: TextStyle(color: Color(0xFF00E676)))),
                        DropdownMenuItem(value: TimerPhase.rest, child: Text('DİNLENME (Rest)', style: TextStyle(color: Color(0xFFFF3D00)))),
                        DropdownMenuItem(value: TimerPhase.cooldown, child: Text('SOĞUMA (Cooldown)', style: TextStyle(color: Color(0xFF00E5FF)))),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            phase = val;
                            if (phase == TimerPhase.rest) name = 'DİNLENME';
                            if (phase == TimerPhase.work) name = 'ÇALIŞMA';
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Süre (sn):', style: TextStyle(color: Colors.white70)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.white70),
                              onPressed: () {
                                if (duration > 5) setDialogState(() => duration -= 5);
                              },
                            ),
                            Text('$duration sn', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.add, color: Color(0xFF00E676)),
                              onPressed: () => setDialogState(() => duration += 5),
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
                  child: const Text('İPTAL', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676), foregroundColor: Colors.black),
                  onPressed: () {
                    setState(() {
                      _intervals.add(
                        IntervalStep(
                          id: const Uuid().v4(),
                          name: name.isEmpty ? 'Aralık' : name,
                          durationSeconds: duration,
                          phase: phase,
                        ),
                      );
                    });
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('EKLE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate()) return;
    if (_intervals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir aralık ekleyin!')),
      );
      return;
    }

    final now = DateTime.now();
    final routine = CustomRoutine(
      id: widget.initialRoutine?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      prepSeconds: _prepSeconds,
      rounds: _rounds,
      restBetweenRoundsSeconds: _restBetweenRoundsSeconds,
      intervals: _intervals,
      createdAt: widget.initialRoutine?.createdAt ?? now,
      updatedAt: now,
    );

    await _repository.saveRoutine(routine);

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.initialRoutine == null ? 'YENİ TİMER OLUŞTUR' : 'TİMER DÜZENLE',
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
                  labelText: 'Timer Adı *',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'Örn: Barbell Complex, HIIT 45/15',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Lütfen bir ad girin' : null,
              ),

              const SizedBox(height: 14),

              // Routine Description Field
              TextFormField(
                controller: _descController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Açıklama (İsteğe bağlı)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'Hedeflenen hareketler, ağırlık veya notlar',
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
                      'TOPLAM TUR',
                      '$_rounds',
                      () { if (_rounds > 1) setState(() => _rounds--); },
                      () => setState(() => _rounds++),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSmallStepper(
                      'HAZIRLIK',
                      '$_prepSeconds s',
                      () { if (_prepSeconds > 0) setState(() => _prepSeconds -= 5); },
                      () => setState(() => _prepSeconds += 5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSmallStepper(
                      'TUR ARASI',
                      '$_restBetweenRoundsSeconds s',
                      () { if (_restBetweenRoundsSeconds > 0) setState(() => _restBetweenRoundsSeconds -= 5); },
                      () => setState(() => _restBetweenRoundsSeconds += 5),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Intervals Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ARALIK SIRALAMASI',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                  ),
                  TextButton.icon(
                    onPressed: _addInterval,
                    icon: const Icon(Icons.add, color: Color(0xFF00E676)),
                    label: const Text('ARALIK EKLE', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
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
                        Icon(Icons.drag_indicator, color: Colors.white38),
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
                                step.name,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                '${step.phase.displayName} • ${step.durationSeconds} sn',
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
                  child: const Text(
                    'TİMER''I KAYDET',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5),
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
                  child: const Icon(Icons.add, size: 16, color: Color(0xFF00E676)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
