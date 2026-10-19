import 'package:flutter/material.dart';
import '../models/custom_routine.dart';
import '../models/interval_step.dart';
import '../models/timer_phase.dart';
import 'timer_runner_screen.dart';

class RoundsScreen extends StatefulWidget {
  const RoundsScreen({super.key});

  @override
  State<RoundsScreen> createState() => _RoundsScreenState();
}

class _RoundsScreenState extends State<RoundsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Rounds Mode state
  int _roundWorkMinutes = 3;
  int _roundRestMinutes = 1;
  int _roundsCount = 5;

  // EMOM state
  int _emomMinutes = 10;

  // AMRAP state
  int _amrapMinutes = 15;

  // For Time state
  int _forTimeCapMinutes = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _startRoundsWorkout() {
    final now = DateTime.now();
    final routine = CustomRoutine(
      id: 'rounds_${now.millisecondsSinceEpoch}',
      name: '$_roundsCount TUR ANTRENMAN',
      prepSeconds: 10,
      rounds: _roundsCount,
      intervals: [
        IntervalStep(
          id: 'step_r_work',
          name: 'ÇALIŞMA',
          durationSeconds: _roundWorkMinutes * 60,
          phase: TimerPhase.work,
        ),
        if (_roundRestMinutes > 0)
          IntervalStep(
            id: 'step_r_rest',
            name: 'DİNLENME',
            durationSeconds: _roundRestMinutes * 60,
            phase: TimerPhase.rest,
          ),
      ],
      createdAt: now,
      updatedAt: now,
    );

    _navigateToRunner(routine);
  }

  void _startEmomWorkout() {
    final now = DateTime.now();
    final routine = CustomRoutine(
      id: 'emom_${now.millisecondsSinceEpoch}',
      name: 'EMOM $_emomMinutes DK',
      prepSeconds: 10,
      rounds: _emomMinutes,
      intervals: const [
        IntervalStep(
          id: 'step_emom_work',
          name: 'EMOM ÇALIŞ',
          durationSeconds: 50,
          phase: TimerPhase.work,
        ),
        IntervalStep(
          id: 'step_emom_rest',
          name: 'DİNLEN',
          durationSeconds: 10,
          phase: TimerPhase.rest,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );

    _navigateToRunner(routine);
  }

  void _startAmrapWorkout() {
    final now = DateTime.now();
    final routine = CustomRoutine(
      id: 'amrap_${now.millisecondsSinceEpoch}',
      name: 'AMRAP $_amrapMinutes DK',
      prepSeconds: 10,
      rounds: 1,
      intervals: [
        IntervalStep(
          id: 'step_amrap',
          name: 'AMRAP (MAKSİMUM TUR)',
          durationSeconds: _amrapMinutes * 60,
          phase: TimerPhase.work,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );

    _navigateToRunner(routine);
  }

  void _startForTimeWorkout() {
    final now = DateTime.now();
    final routine = CustomRoutine(
      id: 'fortime_${now.millisecondsSinceEpoch}',
      name: 'FOR TIME ($_forTimeCapMinutes DK CAP)',
      prepSeconds: 10,
      rounds: 1,
      intervals: [
        IntervalStep(
          id: 'step_fortime',
          name: 'FOR TIME BİTİR',
          durationSeconds: _forTimeCapMinutes * 60,
          phase: TimerPhase.work,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );

    _navigateToRunner(routine);
  }

  void _navigateToRunner(CustomRoutine routine) {
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
          'TUR & CROSSFIT',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00E676),
          indicatorWeight: 3,
          labelColor: const Color(0xFF00E676),
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: const [
            Tab(text: 'TUR'),
            Tab(text: 'EMOM'),
            Tab(text: 'AMRAP'),
            Tab(text: 'FOR TIME'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. ROUNDS TAB
          _buildRoundsTab(),
          // 2. EMOM TAB
          _buildEmomTab(),
          // 3. AMRAP TAB
          _buildAmrapTab(),
          // 4. FOR TIME TAB
          _buildForTimeTab(),
        ],
      ),
    );
  }

  Widget _buildRoundsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildInfoBanner('Her tur çalışma ve dinlenme sürelerini belirleyip serinizi tamamlayın.'),
          const SizedBox(height: 20),
          _buildStepperCard(
            title: 'TUR ÇALIŞMA SÜRESİ',
            valueText: '$_roundWorkMinutes Dakika',
            color: const Color(0xFF00E676),
            onDec: () => setState(() { if (_roundWorkMinutes > 1) _roundWorkMinutes--; }),
            onInc: () => setState(() => _roundWorkMinutes++),
          ),
          const SizedBox(height: 14),
          _buildStepperCard(
            title: 'TUR DİNLENME SÜRESİ',
            valueText: '$_roundRestMinutes Dakika',
            color: const Color(0xFFFF3D00),
            onDec: () => setState(() { if (_roundRestMinutes > 0) _roundRestMinutes--; }),
            onInc: () => setState(() => _roundRestMinutes++),
          ),
          const SizedBox(height: 14),
          _buildStepperCard(
            title: 'TOPLAM TUR SAYISI',
            valueText: '$_roundsCount Tur',
            color: const Color(0xFFFFB300),
            onDec: () => setState(() { if (_roundsCount > 1) _roundsCount--; }),
            onInc: () => setState(() => _roundsCount++),
          ),
          const SizedBox(height: 30),
          _buildStartButton('TUR ANTRENMANI BAŞLAT', _startRoundsWorkout, const Color(0xFF00E676)),
        ],
      ),
    );
  }

  Widget _buildEmomTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildInfoBanner('EMOM (Every Minute on the Minute): Her dakikanın başında belirlenen tekrarı yapın, kalan sürede dinlenin.'),
          const SizedBox(height: 20),
          _buildStepperCard(
            title: 'TOPLAM DAKİKA',
            valueText: '$_emomMinutes Dakika',
            color: const Color(0xFF00E5FF),
            onDec: () => setState(() { if (_emomMinutes > 1) _emomMinutes--; }),
            onInc: () => setState(() => _emomMinutes++),
          ),
          const SizedBox(height: 30),
          _buildStartButton('EMOM BAŞLAT', _startEmomWorkout, const Color(0xFF00E5FF)),
        ],
      ),
    );
  }

  Widget _buildAmrapTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildInfoBanner('AMRAP (As Many Rounds As Possible): Verilen süre boyunca mümkün olan en fazla tur veya tekrarı tamamlayın.'),
          const SizedBox(height: 20),
          _buildStepperCard(
            title: 'AMRAP SÜRESİ',
            valueText: '$_amrapMinutes Dakika',
            color: const Color(0xFFFF9100),
            onDec: () => setState(() { if (_amrapMinutes > 1) _amrapMinutes--; }),
            onInc: () => setState(() => _amrapMinutes++),
          ),
          const SizedBox(height: 30),
          _buildStartButton('AMRAP BAŞLAT', _startAmrapWorkout, const Color(0xFFFF9100)),
        ],
      ),
    );
  }

  Widget _buildForTimeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildInfoBanner('FOR TIME: Verilen egzersizleri zaman sınırından (Time Cap) önce en hızlı sürede tamamlayın.'),
          const SizedBox(height: 20),
          _buildStepperCard(
            title: 'TIME CAP (ZAMAN SINIRI)',
            valueText: '$_forTimeCapMinutes Dakika',
            color: const Color(0xFF7C4DFF),
            onDec: () => setState(() { if (_forTimeCapMinutes > 1) _forTimeCapMinutes--; }),
            onInc: () => setState(() => _forTimeCapMinutes++),
          ),
          const SizedBox(height: 30),
          _buildStartButton('FOR TIME BAŞLAT', _startForTimeWorkout, const Color(0xFF7C4DFF)),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white70, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperCard({
    required String title,
    required String valueText,
    required Color color,
    required VoidCallback onDec,
    required VoidCallback onInc,
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valueText,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDec,
            icon: const Icon(Icons.remove_circle_outline, color: Colors.white70, size: 30),
          ),
          IconButton(
            onPressed: onInc,
            icon: Icon(Icons.add_circle, color: color, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(String label, VoidCallback onPressed, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
