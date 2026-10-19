import 'package:flutter/material.dart';
import '../models/custom_routine.dart';
import 'timer_runner_screen.dart';

class TabataScreen extends StatefulWidget {
  const TabataScreen({super.key});

  @override
  State<TabataScreen> createState() => _TabataScreenState();
}

class _TabataScreenState extends State<TabataScreen> {
  int _workSeconds = 20;
  int _restSeconds = 10;
  int _rounds = 8;
  int _prepSeconds = 10;

  int get _totalWorkoutSeconds {
    return _prepSeconds + (_workSeconds + _restSeconds) * _rounds;
  }

  String get _formattedTotalTime {
    final mins = _totalWorkoutSeconds ~/ 60;
    final secs = _totalWorkoutSeconds % 60;
    return '${mins}d ${secs.toString().padLeft(2, '0')}s';
  }

  void _startWorkout() {
    final routine = CustomRoutine.tabata(
      workSeconds: _workSeconds,
      restSeconds: _restSeconds,
      rounds: _rounds,
      prepSeconds: _prepSeconds,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TimerRunnerScreen(routine: routine),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'TABATA TIMER',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          children: [
            // Top Overview Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1E1E), Color(0xFF262626)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('TOPLAM SÜRE', _formattedTotalTime, const Color(0xFF00E676)),
                  Container(width: 1, height: 40, color: Colors.white12),
                  _buildStatItem('TUR SAYISI', '$_rounds TUR', const Color(0xFFFFB300)),
                  Container(width: 1, height: 40, color: Colors.white12),
                  _buildStatItem('ÇALIŞMA/DİNLENME', '${_workSeconds}s / ${_restSeconds}s', const Color(0xFFFF3D00)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Work Duration Control
            _buildNumberStepper(
              title: 'ÇALIŞMA SÜRESİ',
              valueText: '$_workSeconds sn',
              color: const Color(0xFF00E676),
              icon: Icons.fitness_center,
              onDecrement: () {
                if (_workSeconds > 5) setState(() => _workSeconds -= 5);
              },
              onIncrement: () {
                setState(() => _workSeconds += 5);
              },
            ),

            const SizedBox(height: 16),

            // Rest Duration Control
            _buildNumberStepper(
              title: 'DİNLENME SÜRESİ',
              valueText: '$_restSeconds sn',
              color: const Color(0xFFFF3D00),
              icon: Icons.pause_circle_outline,
              onDecrement: () {
                if (_restSeconds > 0) setState(() => _restSeconds -= 5);
              },
              onIncrement: () {
                setState(() => _restSeconds += 5);
              },
            ),

            const SizedBox(height: 16),

            // Rounds Control
            _buildNumberStepper(
              title: 'TOPLAM TUR',
              valueText: '$_rounds Tur',
              color: const Color(0xFFFFB300),
              icon: Icons.repeat,
              onDecrement: () {
                if (_rounds > 1) setState(() => _rounds -= 1);
              },
              onIncrement: () {
                setState(() => _rounds += 1);
              },
            ),

            const SizedBox(height: 16),

            // Prep Time Control
            _buildNumberStepper(
              title: 'HAZIRLIK GERİ SAYIM',
              valueText: '$_prepSeconds sn',
              color: const Color(0xFF00E5FF),
              icon: Icons.hourglass_top,
              onDecrement: () {
                if (_prepSeconds > 0) setState(() => _prepSeconds -= 5);
              },
              onIncrement: () {
                setState(() => _prepSeconds += 5);
              },
            ),

            const SizedBox(height: 32),

            // Start Button
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _startWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: const Color(0xFF00E676).withValues(alpha: 0.5),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, size: 36),
                    SizedBox(width: 8),
                    Text(
                      'TABATA BAŞLAT',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberStepper({
    required String title,
    required String valueText,
    required Color color,
    required IconData icon,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valueText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDecrement,
            icon: const Icon(Icons.remove_circle_outline, color: Colors.white70, size: 30),
          ),
          IconButton(
            onPressed: onIncrement,
            icon: Icon(Icons.add_circle, color: color, size: 30),
          ),
        ],
      ),
    );
  }
}
