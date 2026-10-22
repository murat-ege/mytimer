import '../models/custom_routine.dart';
import '../models/interval_step.dart';
import '../models/timer_phase.dart';

class TimerPresetsData {
  static List<CustomRoutine> getDefaultTimerPresets() {
    final now = DateTime(2026, 1, 1);

    return [
      // ==================== TABATA ====================
      CustomRoutine(
        id: 'preset_tabata_standard',
        name: 'Tabata 20/10',
        description: '8 Rounds • 20s Work / 10s Rest • Classic High-Intensity',
        category: 'Standard - Tabata',
        isPreset: true,
        prepSeconds: 10,
        rounds: 8,
        intervals: const [
          IntervalStep(id: 'tabata_step_work', name: 'WORK', durationSeconds: 20, phase: TimerPhase.work),
          IntervalStep(id: 'tabata_step_rest', name: 'REST', durationSeconds: 10, phase: TimerPhase.rest),
        ],
        createdAt: now,
        updatedAt: now,
      ),
      CustomRoutine(
        id: 'preset_tabata_sprint',
        name: 'Tabata Sprint 30/30',
        description: '4 Rounds • 30s Max Sprint / 30s Rest',
        category: 'Standard - Tabata',
        isPreset: true,
        prepSeconds: 10,
        rounds: 4,
        intervals: const [
          IntervalStep(id: 'sprint_step_work', name: 'SPRINT', durationSeconds: 30, phase: TimerPhase.work),
          IntervalStep(id: 'sprint_step_rest', name: 'REST', durationSeconds: 30, phase: TimerPhase.rest),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // ==================== ROUNDS ====================
      CustomRoutine(
        id: 'preset_rounds_boxing',
        name: 'Boxing Rounds 3x3m',
        description: '3 Rounds • 3 Min Work / 1 Min Rest • Boxing & MMA pace',
        category: 'Standard - Rounds',
        isPreset: true,
        prepSeconds: 10,
        rounds: 3,
        restBetweenRoundsSeconds: 60,
        intervals: const [
          IntervalStep(id: 'rounds_step_work', name: 'ROUND', durationSeconds: 180, phase: TimerPhase.work),
          IntervalStep(id: 'rounds_step_rest', name: 'REST', durationSeconds: 60, phase: TimerPhase.rest),
        ],
        createdAt: now,
        updatedAt: now,
      ),
      CustomRoutine(
        id: 'preset_rounds_5x5',
        name: '5x5 Heavy Intervals',
        description: '5 Rounds • 5 Min Work / 2 Min Rest',
        category: 'Standard - Rounds',
        isPreset: true,
        prepSeconds: 10,
        rounds: 5,
        restBetweenRoundsSeconds: 120,
        intervals: const [
          IntervalStep(id: '5x5_step_work', name: 'INTERVAL', durationSeconds: 300, phase: TimerPhase.work),
          IntervalStep(id: '5x5_step_rest', name: 'REST', durationSeconds: 120, phase: TimerPhase.rest),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // ==================== EMOM ====================
      CustomRoutine(
        id: 'preset_emom_10m',
        name: 'EMOM 10 Min',
        description: '10 Rounds • 1 Min Interval • Every Minute on the Minute',
        category: 'Standard - EMOM',
        isPreset: true,
        prepSeconds: 10,
        rounds: 10,
        intervals: const [
          IntervalStep(id: 'emom_step_work', name: 'EMOM INTERVAL', durationSeconds: 60, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),
      CustomRoutine(
        id: 'preset_emom_20m',
        name: 'EMOM 20 Min',
        description: '20 Rounds • 1 Min Interval • Endurance & Consistency',
        category: 'Standard - EMOM',
        isPreset: true,
        prepSeconds: 10,
        rounds: 20,
        intervals: const [
          IntervalStep(id: 'emom20_step_work', name: 'EMOM INTERVAL', durationSeconds: 60, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // ==================== AMRAP ====================
      CustomRoutine(
        id: 'preset_amrap_12m',
        name: 'AMRAP 12 Min',
        description: '12 Min Time Cap • As Many Rounds/Reps As Possible',
        category: 'Standard - AMRAP',
        isPreset: true,
        prepSeconds: 10,
        rounds: 1,
        intervals: const [
          IntervalStep(id: 'amrap12_step_work', name: 'AMRAP 12', durationSeconds: 720, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),
      CustomRoutine(
        id: 'preset_amrap_20m',
        name: 'AMRAP 20 Min',
        description: '20 Min Time Cap • Continuous High-Volume Work',
        category: 'Standard - AMRAP',
        isPreset: true,
        prepSeconds: 10,
        rounds: 1,
        intervals: const [
          IntervalStep(id: 'amrap20_step_work', name: 'AMRAP 20', durationSeconds: 1200, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // ==================== FOR TIME ====================
      CustomRoutine(
        id: 'preset_fortime_15m',
        name: 'For Time 15 Min Cap',
        description: '15 Min Cap • Complete Workout As Fast As Possible',
        category: 'Standard - For Time',
        isPreset: true,
        prepSeconds: 10,
        rounds: 1,
        intervals: const [
          IntervalStep(id: 'fortime15_step_work', name: 'FOR TIME', durationSeconds: 900, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // ==================== COUNTDOWN ====================
      CustomRoutine(
        id: 'preset_countdown_5m',
        name: 'Countdown 5 Min',
        description: '5 Min Standard Countdown Timer',
        category: 'Standard - Countdown',
        isPreset: true,
        prepSeconds: 0,
        rounds: 1,
        intervals: const [
          IntervalStep(id: 'countdown5_step', name: 'COUNTDOWN', durationSeconds: 300, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),
      CustomRoutine(
        id: 'preset_countdown_10m',
        name: 'Countdown 10 Min',
        description: '10 Min Standard Countdown Timer',
        category: 'Standard - Countdown',
        isPreset: true,
        prepSeconds: 0,
        rounds: 1,
        intervals: const [
          IntervalStep(id: 'countdown10_step', name: 'COUNTDOWN', durationSeconds: 600, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
