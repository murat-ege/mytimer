import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/custom_routine.dart';
import '../models/interval_step.dart';
import '../models/timer_phase.dart';
import 'timer_runner_screen.dart';

class RoundsScreen extends StatefulWidget {
  final VoidCallback? onOpenSettings;

  const RoundsScreen({super.key, this.onOpenSettings});

  @override
  State<RoundsScreen> createState() => _RoundsScreenState();
}

class _RoundsScreenState extends State<RoundsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Preparation state
  int _prepSeconds = 10;

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
      name: '$_roundsCount ROUNDS',
      prepSeconds: _prepSeconds,
      rounds: _roundsCount,
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

    _navigateToRunner(routine);
  }

  void _startEmomWorkout() {
    final now = DateTime.now();
    final routine = CustomRoutine(
      id: 'emom_${now.millisecondsSinceEpoch}',
      name: 'EMOM $_emomMinutes MIN',
      prepSeconds: _prepSeconds,
      rounds: _emomMinutes,
      intervals: const [
        IntervalStep(
          id: 'step_emom_work',
          name: 'EMOM',
          durationSeconds: 60,
          phase: TimerPhase.work,
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
      name: 'AMRAP $_amrapMinutes MIN',
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

    _navigateToRunner(routine);
  }

  void _startForTimeWorkout() {
    final now = DateTime.now();
    final routine = CustomRoutine(
      id: 'fortime_${now.millisecondsSinceEpoch}',
      name: 'FOR TIME (CAP $_forTimeCapMinutes MIN)',
      prepSeconds: _prepSeconds,
      rounds: 1,
      intervals: [
        IntervalStep(
          id: 'step_fortime',
          name: 'FOR TIME',
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
      MaterialPageRoute(builder: (_) => TimerRunnerScreen(routine: routine)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n?.rounds ?? 'TUR & CROSSFIT',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          if (widget.onOpenSettings != null)
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white70),
              tooltip: l10n?.settings ?? 'Settings',
              onPressed: widget.onOpenSettings,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00E676),
          indicatorWeight: 3,
          labelColor: const Color(0xFF00E676),
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
          tabs: [
            Tab(text: l10n?.round ?? 'TUR'),
            Tab(text: l10n?.emomTitle ?? 'EMOM'),
            Tab(text: l10n?.amrapTitle ?? 'AMRAP'),
            Tab(text: l10n?.forTimeTitle ?? 'FOR TIME'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. ROUNDS TAB
          _buildRoundsTab(l10n),
          // 2. EMOM TAB
          _buildEmomTab(l10n),
          // 3. AMRAP TAB
          _buildAmrapTab(l10n),
          // 4. FOR TIME TAB
          _buildForTimeTab(l10n),
        ],
      ),
    );
  }

  Widget _buildRoundsTab(AppLocalizations? l10n) {
    final secUnit = l10n?.seconds ?? 'sn';
    final minUnit = l10n?.minutes ?? 'dk';
    final roundUnit = l10n?.round ?? 'Tur';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // 1. Hazırlanma Control (FIRST ACTION)
          _buildStepperCard(
            title: l10n?.prepTime ?? 'HAZIRLANMA SÜRESİ',
            valueText: '$_prepSeconds $secUnit',
            color: const Color(0xFF00E5FF),
            onDec: () => setState(() {
              if (_prepSeconds > 0) _prepSeconds -= 1;
            }),
            onInc: () => setState(() => _prepSeconds += 1),
          ),
          const SizedBox(height: 14),
          // 2. Tur Çalışma Süresi
          _buildStepperCard(
            title: l10n?.workTime ?? 'TUR ÇALIŞMA SÜRESİ',
            valueText: '$_roundWorkMinutes $minUnit',
            color: const Color(0xFF00E676),
            onDec: () => setState(() {
              if (_roundWorkMinutes > 1) _roundWorkMinutes--;
            }),
            onInc: () => setState(() => _roundWorkMinutes++),
          ),
          const SizedBox(height: 14),
          // 3. Tur Dinlenme Süresi
          _buildStepperCard(
            title: l10n?.restTime ?? 'TUR DİNLENME SÜRESİ',
            valueText: '$_roundRestMinutes $minUnit',
            color: const Color(0xFFFF3D00),
            onDec: () => setState(() {
              if (_roundRestMinutes > 0) _roundRestMinutes--;
            }),
            onInc: () => setState(() => _roundRestMinutes++),
          ),
          const SizedBox(height: 14),
          // 4. Toplam Tur Sayısı
          _buildStepperCard(
            title: l10n?.totalRounds ?? 'TOPLAM TUR SAYISI',
            valueText: '$_roundsCount $roundUnit',
            color: const Color(0xFFFFB300),
            onDec: () => setState(() {
              if (_roundsCount > 1) _roundsCount--;
            }),
            onInc: () => setState(() => _roundsCount++),
          ),
          const SizedBox(height: 30),
          _buildStartButton(
            l10n?.start ?? "BAŞLAT",
            _startRoundsWorkout,
            const Color(0xFF00E676),
          ),
        ],
      ),
    );
  }

  Widget _buildEmomTab(AppLocalizations? l10n) {
    final secUnit = l10n?.seconds ?? 'sn';
    final minUnit = l10n?.minutes ?? 'dk';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // 1. Hazırlanma Control (FIRST ACTION)
          _buildStepperCard(
            title: l10n?.prepTime ?? 'HAZIRLANMA SÜRESİ',
            valueText: '$_prepSeconds $secUnit',
            color: const Color(0xFF00E5FF),
            onDec: () => setState(() {
              if (_prepSeconds > 0) _prepSeconds -= 1;
            }),
            onInc: () => setState(() => _prepSeconds += 1),
          ),
          const SizedBox(height: 14),
          // 2. Toplam Dakika
          _buildStepperCard(
            title: l10n?.totalTime ?? 'TOPLAM DAKİKA',
            valueText: '$_emomMinutes $minUnit',
            color: const Color(0xFFFFD600),
            onDec: () => setState(() {
              if (_emomMinutes > 1) _emomMinutes--;
            }),
            onInc: () => setState(() => _emomMinutes++),
          ),
          const SizedBox(height: 30),
          _buildStartButton(
            l10n?.start ?? "BAŞLAT",
            _startEmomWorkout,
            const Color(0xFFFFD600),
          ),
        ],
      ),
    );
  }

  Widget _buildAmrapTab(AppLocalizations? l10n) {
    final secUnit = l10n?.seconds ?? 'sn';
    final minUnit = l10n?.minutes ?? 'dk';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // 1. Hazırlanma Control (FIRST ACTION)
          _buildStepperCard(
            title: l10n?.prepTime ?? 'HAZIRLANMA SÜRESİ',
            valueText: '$_prepSeconds $secUnit',
            color: const Color(0xFF00E5FF),
            onDec: () => setState(() {
              if (_prepSeconds > 0) _prepSeconds -= 1;
            }),
            onInc: () => setState(() => _prepSeconds += 1),
          ),
          const SizedBox(height: 14),
          // 2. AMRAP Süresi
          _buildStepperCard(
            title: 'AMRAP (${l10n?.timeCap ?? "SÜRE"})',
            valueText: '$_amrapMinutes $minUnit',
            color: const Color(0xFFFF9100),
            onDec: () => setState(() {
              if (_amrapMinutes > 1) _amrapMinutes--;
            }),
            onInc: () => setState(() => _amrapMinutes++),
          ),
          const SizedBox(height: 30),
          _buildStartButton(
            l10n?.start ?? "BAŞLAT",
            _startAmrapWorkout,
            const Color(0xFFFF9100),
          ),
        ],
      ),
    );
  }

  Widget _buildForTimeTab(AppLocalizations? l10n) {
    final secUnit = l10n?.seconds ?? 'sn';
    final minUnit = l10n?.minutes ?? 'dk';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // 1. Hazırlanma Control (FIRST ACTION)
          _buildStepperCard(
            title: l10n?.prepTime ?? 'HAZIRLANMA SÜRESİ',
            valueText: '$_prepSeconds $secUnit',
            color: const Color(0xFF00E5FF),
            onDec: () => setState(() {
              if (_prepSeconds > 0) _prepSeconds -= 1;
            }),
            onInc: () => setState(() => _prepSeconds += 1),
          ),
          const SizedBox(height: 14),
          // 2. Time Cap
          _buildStepperCard(
            title: l10n?.timeCap ?? 'TIME CAP',
            valueText: '$_forTimeCapMinutes $minUnit',
            color: const Color(0xFF7C4DFF),
            onDec: () => setState(() {
              if (_forTimeCapMinutes > 1) _forTimeCapMinutes--;
            }),
            onInc: () => setState(() => _forTimeCapMinutes++),
          ),
          const SizedBox(height: 30),
          _buildStartButton(
            l10n?.start ?? "BAŞLAT",
            _startForTimeWorkout,
            const Color(0xFF7C4DFF),
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
            icon: const Icon(
              Icons.remove_circle_outline,
              color: Colors.white70,
              size: 30,
            ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: color.withValues(alpha: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, size: 36),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
