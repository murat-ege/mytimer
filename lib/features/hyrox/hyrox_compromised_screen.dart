import 'package:flutter/material.dart';
import '../../data/hyrox_data.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/custom_routine.dart';
import '../../models/interval_step.dart';
import '../../models/timer_phase.dart';
import '../../repositories/local_timer_repository.dart';
import '../timer_runner/timer_runner_screen.dart';

class HyroxCompromisedScreen extends StatefulWidget {
  const HyroxCompromisedScreen({super.key});

  @override
  State<HyroxCompromisedScreen> createState() => _HyroxCompromisedScreenState();
}

class _HyroxCompromisedScreenState extends State<HyroxCompromisedScreen> {
  final LocalTimerRepository _repository = LocalTimerRepository();

  int _rounds = 4; // 2, 4, 6, 8
  int _runMinutes = 4; // 1km run target pace ~ 4:00 - 5:00
  int _stationMinutes = 3; // Station work interval
  int _restSeconds = 60; // Rest between rounds
  final int _prepSeconds = 0;
  bool _cycleAllStations = true; // Rotate through official stations

  static const Color _themeColor = Color(0xFFFFE600);

  int get _totalWorkoutMinutes {
    final roundSecs = (_runMinutes * 60) + (_stationMinutes * 60) + _restSeconds;
    return (roundSecs * _rounds) ~/ 60;
  }

  CustomRoutine _buildRoutine() {
    final now = DateTime.now();
    final List<IntervalStep> intervals = [];

    for (int r = 0; r < _rounds; r++) {
      final station = HyroxData.stations[r % HyroxData.stations.length];
      final stationName = _cycleAllStations ? station.name.toUpperCase() : 'HYROX STATION';

      intervals.add(
        IntervalStep(
          id: 'step_run_$r',
          name: 'RUN 1000M (ROUND ${r + 1})',
          durationSeconds: _runMinutes * 60,
          phase: TimerPhase.work,
        ),
      );

      intervals.add(
        IntervalStep(
          id: 'step_station_$r',
          name: '$stationName (${station.distanceOrReps})',
          durationSeconds: _stationMinutes * 60,
          phase: TimerPhase.work,
        ),
      );

      if (_restSeconds > 0 && r < _rounds - 1) {
        intervals.add(
          IntervalStep(
            id: 'step_rest_$r',
            name: 'RECOVERY REST',
            durationSeconds: _restSeconds,
            phase: TimerPhase.rest,
          ),
        );
      }
    }

    return CustomRoutine(
      id: 'hyrox_comp_${now.millisecondsSinceEpoch}',
      name: 'HYROX COMPROMISED RUN ($_rounds ROUNDS)',
      description: 'Alternating 1km Run + Functional Station with heavy legs.',
      category: 'HYROX',
      prepSeconds: _prepSeconds,
      rounds: 1, // Already expanded intervals
      intervals: intervals,
      createdAt: now,
      updatedAt: now,
    );
  }

  void _startWorkout() {
    final routine = _buildRoutine();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TimerRunnerScreen(routine: routine)),
    );
  }

  Future<void> _saveAsPreset() async {
    final l10n = AppLocalizations.of(context);
    final routine = _buildRoutine();
    await _repository.saveRoutine(routine);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.presetSaved ?? 'Saved to Custom Timers!'),
          backgroundColor: const Color(0xFF00E676),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _themeColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'HYROX',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n?.hyroxCompromisedRun ?? 'Compromised Running',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined, color: _themeColor),
            tooltip: 'Save as Preset',
            onPressed: _saveAsPreset,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            // Intro Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF262626), Color(0xFF161616)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _themeColor.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.directions_run_rounded, color: _themeColor, size: 28),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'COMPROMISED RUNNING',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The hallmark of HYROX training. Run at target race pace immediately into functional stations with high lactic build up.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _themeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'ESTIMATED DURATION: ~$_totalWorkoutMinutes MINUTES',
                      style: const TextStyle(color: _themeColor, fontSize: 12, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Number of Rounds
            _buildSectionTitle('ROUNDS (RUN + STATION BLOCKS)'),
            const SizedBox(height: 10),
            Row(
              children: [2, 4, 6, 8].map((r) {
                final isSelected = _rounds == r;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Center(
                        child: Text(
                          '$r Rounds',
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white70,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: _themeColor,
                      backgroundColor: const Color(0xFF1E1E1E),
                      side: BorderSide(color: isSelected ? _themeColor : Colors.white12),
                      onSelected: (val) {
                        if (val) setState(() => _rounds = r);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Run Interval Duration
            _buildSectionTitle('RUN INTERVAL DURATION (TARGET CAP)'),
            const SizedBox(height: 10),
            Row(
              children: [3, 4, 5, 6].map((m) {
                final isSelected = _runMinutes == m;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Center(
                        child: Text(
                          '$m:00 Min',
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white70,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: _themeColor,
                      backgroundColor: const Color(0xFF1E1E1E),
                      side: BorderSide(color: isSelected ? _themeColor : Colors.white12),
                      onSelected: (val) {
                        if (val) setState(() => _runMinutes = m);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Station Interval Duration
            _buildSectionTitle('STATION WORK DURATION (TARGET CAP)'),
            const SizedBox(height: 10),
            Row(
              children: [2, 3, 4, 5].map((m) {
                final isSelected = _stationMinutes == m;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Center(
                        child: Text(
                          '$m:00 Min',
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white70,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: _themeColor,
                      backgroundColor: const Color(0xFF1E1E1E),
                      side: BorderSide(color: isSelected ? _themeColor : Colors.white12),
                      onSelected: (val) {
                        if (val) setState(() => _stationMinutes = m);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Rest Between Rounds
            _buildSectionTitle('RECOVERY REST BETWEEN BLOCKS'),
            const SizedBox(height: 10),
            Row(
              children: [0, 45, 60, 90].map((s) {
                final isSelected = _restSeconds == s;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Center(
                        child: Text(
                          s == 0 ? 'No Rest' : '${s}s Rest',
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white70,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: _themeColor,
                      backgroundColor: const Color(0xFF1E1E1E),
                      side: BorderSide(color: isSelected ? _themeColor : Colors.white12),
                      onSelected: (val) {
                        if (val) setState(() => _restSeconds = s);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Station Cycle Switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sync_rounded, color: _themeColor, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cycle Through 8 HYROX Stations',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Rotate: SkiErg -> Sled Push -> Sled Pull -> Burpees...',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _cycleAllStations,
                    activeThumbColor: _themeColor,
                    activeTrackColor: _themeColor.withValues(alpha: 0.3),
                    onChanged: (val) => setState(() => _cycleAllStations = val),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF121212),
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _themeColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                shadowColor: _themeColor.withValues(alpha: 0.5),
              ),
              onPressed: _startWorkout,
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, color: Colors.black, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'START COMPROMISED RUN',
                      style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2),
    );
  }
}
