import '../models/custom_routine.dart';
import '../models/interval_step.dart';
import '../models/timer_phase.dart';
import 'hyrox_data.dart';

class CrossFitWodsData {
  static List<CustomRoutine> getAllWods() {
    final now = DateTime(2026, 1, 1);

    return [
      // ==================== THE GIRLS ====================
      CustomRoutine(
        id: 'wod_fran',
        name: 'Fran',
        category: 'The Girls',
        description: '21-15-9 Reps: Thruster (95/65 lb) and Pull-up. Fast and explosive!',
        prepSeconds: 10,
        rounds: 3,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'fran_step', name: 'FRAN WORK', durationSeconds: 180, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_cindy',
        name: 'Cindy',
        category: 'The Girls',
        description: '20 Min AMRAP: 5 Pull-ups, 10 Push-ups, 15 Air Squats. Continuous pace!',
        prepSeconds: 10,
        rounds: 1,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'cindy_step', name: 'AMRAP 20 MIN', durationSeconds: 1200, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_grace',
        name: 'Grace',
        category: 'The Girls',
        description: '30 Clean & Jerks (135/95 lb) For Time. Max power & barbell speed.',
        prepSeconds: 10,
        rounds: 1,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'grace_step', name: 'GRACE (CAP 6 MIN)', durationSeconds: 360, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_helen',
        name: 'Helen',
        category: 'The Girls',
        description: '3 Rounds: 400m Run, 21 Kettlebell Swings (24/16 kg), 12 Pull-ups.',
        prepSeconds: 10,
        rounds: 3,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'helen_step', name: 'HELEN ROUND', durationSeconds: 240, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_annie',
        name: 'Annie',
        category: 'The Girls',
        description: '50-40-30-20-10 Reps: Double Unders and Sit-ups For Time.',
        prepSeconds: 10,
        rounds: 5,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'annie_step', name: 'ANNIE ROUND', durationSeconds: 150, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_diane',
        name: 'Diane',
        category: 'The Girls',
        description: '21-15-9 Reps: Deadlift (225/155 lb) and Handstand Push-up (HSPU).',
        prepSeconds: 10,
        rounds: 3,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'diane_step', name: 'DIANE WORK', durationSeconds: 180, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_karen',
        name: 'Karen',
        category: 'The Girls',
        description: '150 Wall Ball Shots (20/14 lb) For Time. Leg and shoulder endurance.',
        prepSeconds: 10,
        rounds: 1,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'karen_step', name: 'KAREN (CAP 10 MIN)', durationSeconds: 600, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_chelsea',
        name: 'Chelsea',
        category: 'The Girls',
        description: 'EMOM 30 Min: Every minute 5 Pull-ups, 10 Push-ups, 15 Air Squats.',
        prepSeconds: 10,
        rounds: 30,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'chelsea_w', name: 'WORK', durationSeconds: 45, phase: TimerPhase.work),
          IntervalStep(id: 'chelsea_r', name: 'REST', durationSeconds: 15, phase: TimerPhase.rest),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_angie',
        name: 'Angie',
        category: 'The Girls',
        description: 'For Time: 100 Pull-ups, 100 Push-ups, 100 Sit-ups, 100 Squats.',
        prepSeconds: 10,
        rounds: 4,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'angie_step', name: '100 REPS SEGMENT', durationSeconds: 360, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_nancy',
        name: 'Nancy',
        category: 'The Girls',
        description: '5 Rounds: 400m Run, 15 Overhead Squats (95/65 lb).',
        prepSeconds: 10,
        rounds: 5,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'nancy_step', name: 'NANCY ROUND', durationSeconds: 210, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_kelly',
        name: 'Kelly',
        category: 'The Girls',
        description: '5 Rounds: 400m Run, 30 Box Jumps (24/20 in), 30 Wall Balls.',
        prepSeconds: 10,
        rounds: 5,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'kelly_step', name: 'KELLY ROUND', durationSeconds: 300, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_isabel',
        name: 'Isabel',
        category: 'The Girls',
        description: '30 Snatches (135/95 lb) For Time. Sprint Olympic lifting WOD.',
        prepSeconds: 10,
        rounds: 1,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'isabel_step', name: 'ISABEL (CAP 6 MIN)', durationSeconds: 360, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_jackie',
        name: 'Jackie',
        category: 'The Girls',
        description: 'For Time: 1000m Row, 50 Thrusters (45 lb bar), 30 Pull-ups.',
        prepSeconds: 10,
        rounds: 1,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'jackie_row', name: '1000M ROW', durationSeconds: 270, phase: TimerPhase.work),
          IntervalStep(id: 'jackie_thr', name: '50 THRUSTERS', durationSeconds: 150, phase: TimerPhase.work),
          IntervalStep(id: 'jackie_pull', name: '30 PULL-UPS', durationSeconds: 120, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_eva',
        name: 'Eva',
        category: 'The Girls',
        description: '5 Rounds: 800m Run, 30 KB Swings (32/24 kg), 30 Pull-ups.',
        prepSeconds: 10,
        rounds: 5,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'eva_step', name: 'EVA ROUND', durationSeconds: 360, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_mary',
        name: 'Mary',
        category: 'The Girls',
        description: '20 Min AMRAP: 5 HSPU, 10 Pistol Squats, 15 Pull-ups.',
        prepSeconds: 10,
        rounds: 1,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'mary_step', name: 'AMRAP 20 MIN', durationSeconds: 1200, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // ==================== HERO WODS ====================
      CustomRoutine(
        id: 'wod_murph',
        name: 'Murph',
        category: 'Hero WOD',
        description: 'For Time (with 20/14 lb vest): 1 Mile Run, 100 Pull-ups, 200 Push-ups, 300 Squats, 1 Mile Run.',
        prepSeconds: 10,
        rounds: 1,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'murph_run1', name: '1 MILE RUN', durationSeconds: 540, phase: TimerPhase.work),
          IntervalStep(id: 'murph_pull', name: '100 PULL-UPS', durationSeconds: 600, phase: TimerPhase.work),
          IntervalStep(id: 'murph_push', name: '200 PUSH-UPS', durationSeconds: 720, phase: TimerPhase.work),
          IntervalStep(id: 'murph_sq', name: '300 AIR SQUATS', durationSeconds: 600, phase: TimerPhase.work),
          IntervalStep(id: 'murph_run2', name: '1 MILE RUN', durationSeconds: 540, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_dt',
        name: 'DT',
        category: 'Hero WOD',
        description: '5 Rounds: 12 Deadlifts, 9 Hang Power Cleans, 6 Push Jerks (155/105 lb).',
        prepSeconds: 10,
        rounds: 5,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'dt_step', name: 'DT ROUND', durationSeconds: 150, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_nate',
        name: 'Nate',
        category: 'Hero WOD',
        description: '20 Min AMRAP: 2 Muscle-ups, 4 HSPU, 8 KB Swings (32/24 kg).',
        prepSeconds: 10,
        rounds: 1,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'nate_step', name: 'NATE AMRAP 20 MIN', durationSeconds: 1200, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_badger',
        name: 'Badger',
        category: 'Hero WOD',
        description: '3 Rounds: 30 Squat Cleans (95/65 lb), 30 Pull-ups, 800m Run.',
        prepSeconds: 10,
        rounds: 3,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'badger_step', name: 'BADGER ROUND', durationSeconds: 420, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_kalsu',
        name: 'Kalsu',
        category: 'Hero WOD',
        description: '100 Thrusters (135/95 lb) For Time. At the top of every minute: 5 Burpees.',
        prepSeconds: 10,
        rounds: 20,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'kalsu_b', name: '5 BURPEES', durationSeconds: 20, phase: TimerPhase.work),
          IntervalStep(id: 'kalsu_t', name: 'THRUSTERS', durationSeconds: 40, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // ==================== BENCHMARK & INTERVAL ====================
      CustomRoutine(
        id: 'wod_fight_gone_bad',
        name: 'Fight Gone Bad',
        category: 'Benchmark',
        description: '3 Rounds: 1 min Wall Balls, 1 min SDHP, 1 min Box Jumps, 1 min Push Press, 1 min Row, 1 min Rest.',
        prepSeconds: 10,
        rounds: 3,
        restBetweenRoundsSeconds: 60,
        intervals: const [
          IntervalStep(id: 'fgb_1', name: 'Wall Balls', durationSeconds: 60, phase: TimerPhase.work),
          IntervalStep(id: 'fgb_2', name: 'Sumo Deadlift High Pull', durationSeconds: 60, phase: TimerPhase.work),
          IntervalStep(id: 'fgb_3', name: 'Box Jumps', durationSeconds: 60, phase: TimerPhase.work),
          IntervalStep(id: 'fgb_4', name: 'Push Press', durationSeconds: 60, phase: TimerPhase.work),
          IntervalStep(id: 'fgb_5', name: 'Row (Calories)', durationSeconds: 60, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_tabata_something_else',
        name: 'Tabata Something Else',
        category: 'Benchmark',
        description: '4 movements x 8 Tabata rounds (Pull-up, Push-up, Sit-up, Squat). 32 rounds total.',
        prepSeconds: 10,
        rounds: 32,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'tse_w', name: 'TABATA WORK', durationSeconds: 20, phase: TimerPhase.work),
          IntervalStep(id: 'tse_r', name: 'REST', durationSeconds: 10, phase: TimerPhase.rest),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_row_repeats',
        name: 'Rowing 500m Repeats',
        category: 'Benchmark',
        description: '5 Rounds: 1:45 Max Effort Row Sprint, 2:00 Complete Rest.',
        prepSeconds: 10,
        rounds: 5,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'row_w', name: 'ROW (500M SPRINT)', durationSeconds: 105, phase: TimerPhase.work),
          IntervalStep(id: 'row_r', name: 'REST', durationSeconds: 120, phase: TimerPhase.rest),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_strength_5x5',
        name: 'CrossFit 5x5 Strength',
        category: 'Benchmark',
        description: '5 Rounds: 3 min Heavy Work Set, 2 min Rest Between Sets.',
        prepSeconds: 10,
        rounds: 5,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'str_w', name: 'HEAVY WORK SET', durationSeconds: 180, phase: TimerPhase.work),
          IntervalStep(id: 'str_r', name: 'REST BETWEEN SETS', durationSeconds: 120, phase: TimerPhase.rest),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_hiit_30_30',
        name: 'HIIT 30s / 30s',
        category: 'Benchmark',
        description: '10 Rounds: 30s Sprint / Max Effort, 30s Rest.',
        prepSeconds: 10,
        rounds: 10,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'hiit_w', name: 'SPRINT / MAX EFFORT', durationSeconds: 30, phase: TimerPhase.work),
          IntervalStep(id: 'hiit_r', name: 'REST', durationSeconds: 30, phase: TimerPhase.rest),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // ==================== HYROX ====================
      ...HyroxData.getHyroxPresets(),
    ];
  }
}
