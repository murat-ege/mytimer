import '../models/custom_routine.dart';
import '../models/interval_step.dart';
import '../models/timer_phase.dart';

class CrossFitWodsData {
  static List<CustomRoutine> getAllWods() {
    final now = DateTime(2026, 1, 1);

    return [
      // ==================== THE GIRLS ====================
      CustomRoutine(
        id: 'wod_fran',
        name: 'Fran',
        category: 'The Girls',
        description: '21-15-9 Tekrar: Thruster (43/30 kg) ve Pull-up. Hızlı ve patlayıcı güç!',
        prepSeconds: 10,
        rounds: 3,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'fran_step', name: 'FRAN ÇALIŞMA', durationSeconds: 180, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_cindy',
        name: 'Cindy',
        category: 'The Girls',
        description: '20 Dk AMRAP: 5 Pull-up, 10 Push-up, 15 Air Squat. Kesintisiz tempo!',
        prepSeconds: 10,
        rounds: 1,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'cindy_step', name: 'AMRAP 20 DK', durationSeconds: 1200, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_grace',
        name: 'Grace',
        category: 'The Girls',
        description: '30 Clean & Jerk (61/43 kg) For Time. Maksimum güç ve teknik dayanıklılık.',
        prepSeconds: 10,
        rounds: 1,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'grace_step', name: 'GRACE (CAP 6 DK)', durationSeconds: 360, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_helen',
        name: 'Helen',
        category: 'The Girls',
        description: '3 Tur: 400m Koşu, 21 Kettlebell Swing (24/16 kg), 12 Pull-up.',
        prepSeconds: 10,
        rounds: 3,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'helen_step', name: 'HELEN TURU', durationSeconds: 240, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_annie',
        name: 'Annie',
        category: 'The Girls',
        description: '50-40-30-20-10 Tekrar: Double Under ve Sit-up For Time.',
        prepSeconds: 10,
        rounds: 5,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'annie_step', name: 'ANNIE SERİSİ', durationSeconds: 150, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_diane',
        name: 'Diane',
        category: 'The Girls',
        description: '21-15-9 Tekrar: Deadlift (102/70 kg) ve Handstand Push-up (HSPU).',
        prepSeconds: 10,
        rounds: 3,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'diane_step', name: 'DIANE ÇALIŞMA', durationSeconds: 180, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_karen',
        name: 'Karen',
        category: 'The Girls',
        description: '150 Wall Ball Shot (9/6 kg) For Time. Bacak ve omuz testi!',
        prepSeconds: 10,
        rounds: 1,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'karen_step', name: 'KAREN (CAP 10 DK)', durationSeconds: 600, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_chelsea',
        name: 'Chelsea',
        category: 'The Girls',
        description: 'EMOM 30 Dk: Her dakika 5 Pull-up, 10 Push-up, 15 Squat.',
        prepSeconds: 10,
        rounds: 30,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'chelsea_w', name: 'EMOM ÇALIŞ', durationSeconds: 45, phase: TimerPhase.work),
          IntervalStep(id: 'chelsea_r', name: 'DİNLEN', durationSeconds: 15, phase: TimerPhase.rest),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_angie',
        name: 'Angie',
        category: 'The Girls',
        description: 'For Time: 100 Pull-up, 100 Push-up, 100 Sit-up, 100 Squat.',
        prepSeconds: 10,
        rounds: 4,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'angie_step', name: '100 TEKRAR BÖLÜMÜ', durationSeconds: 360, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_nancy',
        name: 'Nancy',
        category: 'The Girls',
        description: '5 Tur: 400m Koşu, 15 Overhead Squat (43/30 kg).',
        prepSeconds: 10,
        rounds: 5,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'nancy_step', name: 'NANCY TURU', durationSeconds: 210, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_kelly',
        name: 'Kelly',
        category: 'The Girls',
        description: '5 Tur: 400m Koşu, 30 Box Jump (60/50 cm), 30 Wall Ball.',
        prepSeconds: 10,
        rounds: 5,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'kelly_step', name: 'KELLY TURU', durationSeconds: 300, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_isabel',
        name: 'Isabel',
        category: 'The Girls',
        description: '30 Snatch (61/43 kg) For Time. Patlayıcı olimpik halter WOD.',
        prepSeconds: 10,
        rounds: 1,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'isabel_step', name: 'ISABEL (CAP 6 DK)', durationSeconds: 360, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_jackie',
        name: 'Jackie',
        category: 'The Girls',
        description: 'For Time: 1000m Row, 50 Thruster (20 kg bar), 30 Pull-up.',
        prepSeconds: 10,
        rounds: 3,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'jackie_row', name: '1000M ROW', durationSeconds: 270, phase: TimerPhase.work),
          IntervalStep(id: 'jackie_thr', name: '50 THRUSTER', durationSeconds: 150, phase: TimerPhase.work),
          IntervalStep(id: 'jackie_pull', name: '30 PULL-UP', durationSeconds: 120, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_eva',
        name: 'Eva',
        category: 'The Girls',
        description: '5 Tur: 800m Koşu, 30 KB Swing (32/24 kg), 30 Pull-up. Zorlu dayanıklılık testi.',
        prepSeconds: 10,
        rounds: 5,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'eva_step', name: 'EVA TURU', durationSeconds: 360, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_mary',
        name: 'Mary',
        category: 'The Girls',
        description: '20 Dk AMRAP: 5 HSPU, 10 Tek Bacak Squat (Pistol), 15 Pull-up.',
        prepSeconds: 10,
        rounds: 1,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'mary_step', name: 'AMRAP 20 DK', durationSeconds: 1200, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // ==================== HERO WODS ====================
      CustomRoutine(
        id: 'wod_murph',
        name: 'Murph',
        category: 'Hero WOD',
        description: 'For Time (Yelekli): 1 Mil Koşu, 100 Pull-up, 200 Push-up, 300 Squat, 1 Mil Koşu.',
        prepSeconds: 15,
        rounds: 5,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'murph_run1', name: '1 MİL KOŞU', durationSeconds: 540, phase: TimerPhase.work),
          IntervalStep(id: 'murph_pull', name: '100 PULL-UP', durationSeconds: 600, phase: TimerPhase.work),
          IntervalStep(id: 'murph_push', name: '200 PUSH-UP', durationSeconds: 720, phase: TimerPhase.work),
          IntervalStep(id: 'murph_sq', name: '300 AIR SQUAT', durationSeconds: 600, phase: TimerPhase.work),
          IntervalStep(id: 'murph_run2', name: '1 MİL KOŞU BİTİRİŞ', durationSeconds: 540, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_dt',
        name: 'DT',
        category: 'Hero WOD',
        description: '5 Tur: 12 Deadlift, 9 Hang Power Clean, 6 Push Jerk (70/47 kg).',
        prepSeconds: 10,
        rounds: 5,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'dt_step', name: 'DT TURU', durationSeconds: 150, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_nate',
        name: 'Nate',
        category: 'Hero WOD',
        description: '20 Dk AMRAP: 2 Muscle-up, 4 Handstand Push-up, 8 KB Swing (32/24 kg).',
        prepSeconds: 10,
        rounds: 1,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'nate_step', name: 'NATE AMRAP 20 DK', durationSeconds: 1200, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_badger',
        name: 'Badger',
        category: 'Hero WOD',
        description: '3 Tur: 30 Squat Clean (43/30 kg), 30 Pull-up, 800m Koşu.',
        prepSeconds: 10,
        rounds: 3,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'badger_step', name: 'BADGER TURU', durationSeconds: 420, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_kalsu',
        name: 'Kalsu',
        category: 'Hero WOD',
        description: '100 Thruster (61/43 kg) For Time. Her dakikanın başında 5 Burpee EMOM!',
        prepSeconds: 10,
        rounds: 20,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'kalsu_b', name: '5 BURPEE!', durationSeconds: 20, phase: TimerPhase.work),
          IntervalStep(id: 'kalsu_t', name: 'THRUSTER YAP', durationSeconds: 40, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // ==================== BENCHMARK & INTERVAL ====================
      CustomRoutine(
        id: 'wod_fight_gone_bad',
        name: 'Fight Gone Bad',
        category: 'Benchmark',
        description: '3 Tur: 1 dk Wall Ball, 1 dk SDHP, 1 dk Box Jump, 1 dk Push Press, 1 dk Row, 1 dk Dinlenme.',
        prepSeconds: 10,
        rounds: 3,
        restBetweenRoundsSeconds: 60,
        intervals: const [
          IntervalStep(id: 'fgb_1', name: 'Wall Ball', durationSeconds: 60, phase: TimerPhase.work),
          IntervalStep(id: 'fgb_2', name: 'Sumo Deadlift High Pull', durationSeconds: 60, phase: TimerPhase.work),
          IntervalStep(id: 'fgb_3', name: 'Box Jump', durationSeconds: 60, phase: TimerPhase.work),
          IntervalStep(id: 'fgb_4', name: 'Push Press', durationSeconds: 60, phase: TimerPhase.work),
          IntervalStep(id: 'fgb_5', name: 'Row (Kalori)', durationSeconds: 60, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_tabata_something_else',
        name: 'Tabata Something Else',
        category: 'Benchmark',
        description: '4 Bölüm x 8 Tabata turu (Pull-up, Push-up, Sit-up, Squat). Toplam 32 tur.',
        prepSeconds: 10,
        rounds: 32,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'tse_w', name: 'TABATA ÇALIŞMA', durationSeconds: 20, phase: TimerPhase.work),
          IntervalStep(id: 'tse_r', name: 'DİNLENME', durationSeconds: 10, phase: TimerPhase.rest),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_row_repeats',
        name: 'Rowing 500m Repeats',
        category: 'Benchmark',
        description: '5 Tur: 1:45 Maksimum efor Row, 2:00 Tam dinlenme.',
        prepSeconds: 10,
        rounds: 5,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'row_w', name: 'ROW (500M SPRINT)', durationSeconds: 105, phase: TimerPhase.work),
          IntervalStep(id: 'row_r', name: 'DİNLENME', durationSeconds: 120, phase: TimerPhase.rest),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_strength_5x5',
        name: 'CrossFit 5x5 Strength',
        category: 'Benchmark',
        description: '5 Tur: 3 dakika ağır set çalışması, 2 dakika dinlenme.',
        prepSeconds: 10,
        rounds: 5,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'str_w', name: 'AĞIR SET ÇALIŞMASI', durationSeconds: 180, phase: TimerPhase.work),
          IntervalStep(id: 'str_r', name: 'SET ARASI DİNLENME', durationSeconds: 120, phase: TimerPhase.rest),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      CustomRoutine(
        id: 'wod_hiit_30_30',
        name: 'HIIT 30s / 30s',
        category: 'Benchmark',
        description: '10 Tur: 30 saniye maksimum nabız, 30 saniye dinlenme.',
        prepSeconds: 10,
        rounds: 10,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'hiit_w', name: 'SPRINT / MAKSİMUM GÜÇ', durationSeconds: 30, phase: TimerPhase.work),
          IntervalStep(id: 'hiit_r', name: 'DİNLENME', durationSeconds: 30, phase: TimerPhase.rest),
        ],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
