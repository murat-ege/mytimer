import 'package:flutter/material.dart';
import '../models/custom_routine.dart';
import '../models/interval_step.dart';
import '../models/timer_phase.dart';

enum HyroxDivision {
  menOpen,
  womenOpen,
  menPro,
  womenPro,
  doublesMen,
  doublesWomen,
  doublesMixed,
  relay,
}

extension HyroxDivisionExtension on HyroxDivision {
  String get displayName {
    switch (this) {
      case HyroxDivision.menOpen:
        return 'Men Open';
      case HyroxDivision.womenOpen:
        return 'Women Open';
      case HyroxDivision.menPro:
        return 'Men Pro';
      case HyroxDivision.womenPro:
        return 'Women Pro';
      case HyroxDivision.doublesMen:
        return 'Men Doubles';
      case HyroxDivision.doublesWomen:
        return 'Women Doubles';
      case HyroxDivision.doublesMixed:
        return 'Mixed Doubles';
      case HyroxDivision.relay:
        return 'Relay (Team of 4)';
    }
  }

  String get shortName {
    switch (this) {
      case HyroxDivision.menOpen:
        return 'M OPEN';
      case HyroxDivision.womenOpen:
        return 'W OPEN';
      case HyroxDivision.menPro:
        return 'M PRO';
      case HyroxDivision.womenPro:
        return 'W PRO';
      case HyroxDivision.doublesMen:
        return 'M DOUBLES';
      case HyroxDivision.doublesWomen:
        return 'W DOUBLES';
      case HyroxDivision.doublesMixed:
        return 'MIXED DBL';
      case HyroxDivision.relay:
        return 'RELAY';
    }
  }
}

class HyroxStationInfo {
  final int index;
  final String id;
  final String name;
  final String distanceOrReps;
  final IconData icon;
  final Map<HyroxDivision, String> weights;
  final String proPace;
  final String openPace;
  final String rookiePace;

  const HyroxStationInfo({
    required this.index,
    required this.id,
    required this.name,
    required this.distanceOrReps,
    required this.icon,
    required this.weights,
    required this.proPace,
    required this.openPace,
    required this.rookiePace,
  });

  String getWeightFor(HyroxDivision division) {
    return weights[division] ?? '-';
  }
}

class HyroxData {
  static const Color hyroxYellow = Color(0xFFFFE600);
  static const Color hyroxDark = Color(0xFF141414);
  static const Color hyroxCardBg = Color(0xFF1E1E1E);

  static const List<HyroxStationInfo> stations = [
    HyroxStationInfo(
      index: 1,
      id: 'skierg',
      name: 'SkiErg',
      distanceOrReps: '1000m',
      icon: Icons.downhill_skiing_rounded,
      weights: {
        HyroxDivision.menOpen: 'Damper 6',
        HyroxDivision.womenOpen: 'Damper 5',
        HyroxDivision.menPro: 'Damper 6',
        HyroxDivision.womenPro: 'Damper 5',
        HyroxDivision.doublesMen: 'Damper 6',
        HyroxDivision.doublesWomen: 'Damper 5',
        HyroxDivision.doublesMixed: 'Damper 6/5',
        HyroxDivision.relay: 'Damper 6/5',
      },
      proPace: '3:30 - 3:50',
      openPace: '4:00 - 4:40',
      rookiePace: '4:50 - 5:30',
    ),
    HyroxStationInfo(
      index: 2,
      id: 'sled_push',
      name: 'Sled Push',
      distanceOrReps: '50m (4x12.5m)',
      icon: Icons.double_arrow_rounded,
      weights: {
        HyroxDivision.menOpen: '152 kg (incl. sled)',
        HyroxDivision.womenOpen: '102 kg (incl. sled)',
        HyroxDivision.menPro: '202 kg (incl. sled)',
        HyroxDivision.womenPro: '152 kg (incl. sled)',
        HyroxDivision.doublesMen: '152 kg (incl. sled)',
        HyroxDivision.doublesWomen: '102 kg (incl. sled)',
        HyroxDivision.doublesMixed: '152 kg (incl. sled)',
        HyroxDivision.relay: '152/102 kg',
      },
      proPace: '2:15 - 2:45',
      openPace: '2:45 - 3:45',
      rookiePace: '4:00 - 5:30',
    ),
    HyroxStationInfo(
      index: 3,
      id: 'sled_pull',
      name: 'Sled Pull',
      distanceOrReps: '50m (4x12.5m)',
      icon: Icons.replay_rounded,
      weights: {
        HyroxDivision.menOpen: '103 kg (incl. sled)',
        HyroxDivision.womenOpen: '78 kg (incl. sled)',
        HyroxDivision.menPro: '153 kg (incl. sled)',
        HyroxDivision.womenPro: '103 kg (incl. sled)',
        HyroxDivision.doublesMen: '103 kg (incl. sled)',
        HyroxDivision.doublesWomen: '78 kg (incl. sled)',
        HyroxDivision.doublesMixed: '103 kg (incl. sled)',
        HyroxDivision.relay: '103/78 kg',
      },
      proPace: '3:00 - 3:45',
      openPace: '3:50 - 4:45',
      rookiePace: '5:00 - 6:30',
    ),
    HyroxStationInfo(
      index: 4,
      id: 'burpee_broad_jumps',
      name: 'Burpee Broad Jumps',
      distanceOrReps: '80m',
      icon: Icons.accessibility_new_rounded,
      weights: {
        HyroxDivision.menOpen: 'Bodyweight',
        HyroxDivision.womenOpen: 'Bodyweight',
        HyroxDivision.menPro: 'Bodyweight',
        HyroxDivision.womenPro: 'Bodyweight',
        HyroxDivision.doublesMen: 'Bodyweight',
        HyroxDivision.doublesWomen: 'Bodyweight',
        HyroxDivision.doublesMixed: 'Bodyweight',
        HyroxDivision.relay: 'Bodyweight',
      },
      proPace: '2:45 - 3:30',
      openPace: '3:45 - 5:00',
      rookiePace: '5:30 - 7:00',
    ),
    HyroxStationInfo(
      index: 5,
      id: 'rowing',
      name: 'Rowing',
      distanceOrReps: '1000m',
      icon: Icons.rowing_rounded,
      weights: {
        HyroxDivision.menOpen: 'Damper 6',
        HyroxDivision.womenOpen: 'Damper 5',
        HyroxDivision.menPro: 'Damper 6',
        HyroxDivision.womenPro: 'Damper 5',
        HyroxDivision.doublesMen: 'Damper 6',
        HyroxDivision.doublesWomen: 'Damper 5',
        HyroxDivision.doublesMixed: 'Damper 6/5',
        HyroxDivision.relay: 'Damper 6/5',
      },
      proPace: '3:30 - 3:50',
      openPace: '4:00 - 4:45',
      rookiePace: '4:50 - 5:30',
    ),
    HyroxStationInfo(
      index: 6,
      id: 'farmers_carry',
      name: 'Farmers Carry',
      distanceOrReps: '200m',
      icon: Icons.fitness_center_rounded,
      weights: {
        HyroxDivision.menOpen: '2 x 24 kg',
        HyroxDivision.womenOpen: '2 x 16 kg',
        HyroxDivision.menPro: '2 x 32 kg',
        HyroxDivision.womenPro: '2 x 24 kg',
        HyroxDivision.doublesMen: '2 x 24 kg',
        HyroxDivision.doublesWomen: '2 x 16 kg',
        HyroxDivision.doublesMixed: '2 x 24 kg',
        HyroxDivision.relay: '2 x 24/16 kg',
      },
      proPace: '1:45 - 2:15',
      openPace: '2:20 - 3:15',
      rookiePace: '3:30 - 4:30',
    ),
    HyroxStationInfo(
      index: 7,
      id: 'sandbag_lunges',
      name: 'Sandbag Lunges',
      distanceOrReps: '100m',
      icon: Icons.directions_walk_rounded,
      weights: {
        HyroxDivision.menOpen: '20 kg',
        HyroxDivision.womenOpen: '10 kg',
        HyroxDivision.menPro: '30 kg',
        HyroxDivision.womenPro: '20 kg',
        HyroxDivision.doublesMen: '20 kg',
        HyroxDivision.doublesWomen: '10 kg',
        HyroxDivision.doublesMixed: '20 kg',
        HyroxDivision.relay: '20/10 kg',
      },
      proPace: '2:45 - 3:30',
      openPace: '3:45 - 5:00',
      rookiePace: '5:30 - 7:00',
    ),
    HyroxStationInfo(
      index: 8,
      id: 'wall_balls',
      name: 'Wall Balls',
      distanceOrReps: '75 / 100 Reps',
      icon: Icons.sports_volleyball_rounded,
      weights: {
        HyroxDivision.menOpen: '100 Reps • 6 kg (3.0m)',
        HyroxDivision.womenOpen: '75 Reps • 4 kg (2.7m)',
        HyroxDivision.menPro: '100 Reps • 9 kg (3.0m)',
        HyroxDivision.womenPro: '100 Reps • 6 kg (2.7m)',
        HyroxDivision.doublesMen: '100 Reps • 6 kg (3.0m)',
        HyroxDivision.doublesWomen: '75 Reps • 4 kg (2.7m)',
        HyroxDivision.doublesMixed: '100 Reps • 6 kg (3.0m/2.7m)',
        HyroxDivision.relay: '100/75 Reps',
      },
      proPace: '3:30 - 4:15',
      openPace: '4:30 - 6:00',
      rookiePace: '6:30 - 8:30',
    ),
  ];

  /// Target Race times in seconds for pacing reference
  static const List<Map<String, dynamic>> targetRaceTimes = [
    {'title': 'Sub 60 (Elite Pro)', 'seconds': 3600, 'runPace': '3:45/km'},
    {'title': 'Sub 70 (Competitive)', 'seconds': 4200, 'runPace': '4:15/km'},
    {'title': 'Sub 75 (Top Age Group)', 'seconds': 4500, 'runPace': '4:30/km'},
    {'title': 'Sub 80 (Strong Finisher)', 'seconds': 4800, 'runPace': '4:50/km'},
    {'title': 'Sub 90 (Solid Finisher)', 'seconds': 5400, 'runPace': '5:20/km'},
    {'title': 'Sub 100 (First Timer Goal)', 'seconds': 6000, 'runPace': '6:00/km'},
  ];

  /// Built-in pre-configured HYROX workouts for Custom Routines
  static List<CustomRoutine> getHyroxPresets() {
    final now = DateTime(2026, 1, 1);
    return [
      CustomRoutine(
        id: 'hyrox_half_sim',
        name: 'HYROX Half Race Simulation',
        category: 'HYROX',
        description: '4 Rounds: 1000m Run followed by 4 Key HYROX Stations (SkiErg, Sled Push, Burpees, Wall Balls).',
        prepSeconds: 10,
        rounds: 4,
        restBetweenRoundsSeconds: 60,
        intervals: const [
          IntervalStep(id: 'h_sim_run', name: 'RUN 1000M', durationSeconds: 300, phase: TimerPhase.work),
          IntervalStep(id: 'h_sim_station', name: 'HYROX STATION', durationSeconds: 240, phase: TimerPhase.work),
          IntervalStep(id: 'h_sim_rest', name: 'TRANSITION / REST', durationSeconds: 60, phase: TimerPhase.rest),
        ],
        createdAt: now,
        updatedAt: now,
      ),
      CustomRoutine(
        id: 'hyrox_compromised_4x1k',
        name: 'HYROX Compromised Run (4x1km)',
        category: 'HYROX',
        description: 'Run 1km at race pace, immediately enter station work. Train running on heavy, lactic legs.',
        prepSeconds: 10,
        rounds: 4,
        restBetweenRoundsSeconds: 90,
        intervals: const [
          IntervalStep(id: 'h_comp_run', name: '1000M RUN (RACE PACE)', durationSeconds: 270, phase: TimerPhase.work),
          IntervalStep(id: 'h_comp_sled', name: 'STATION WORK (50M SLED / LUNGES)', durationSeconds: 180, phase: TimerPhase.work),
          IntervalStep(id: 'h_comp_rest', name: 'RECOVERY REST', durationSeconds: 90, phase: TimerPhase.rest),
        ],
        createdAt: now,
        updatedAt: now,
      ),
      CustomRoutine(
        id: 'hyrox_station_pemom',
        name: 'HYROX 16-Min Station P-EMOM',
        category: 'HYROX',
        description: 'Every 2 Minutes for 16 Mins: Rotate through all 8 HYROX stations (90s Work / 30s Rest).',
        prepSeconds: 10,
        rounds: 8,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'h_emom_w', name: 'STATION HIGH EFFORT', durationSeconds: 90, phase: TimerPhase.work),
          IntervalStep(id: 'h_emom_r', name: 'TRANSITION & REST', durationSeconds: 30, phase: TimerPhase.rest),
        ],
        createdAt: now,
        updatedAt: now,
      ),
      CustomRoutine(
        id: 'hyrox_wallball_test',
        name: 'HYROX 100 Wall Ball Test',
        category: 'HYROX',
        description: '100 Wall Balls For Time (6kg or 9kg). The legendary Station 8 finisher test.',
        prepSeconds: 10,
        rounds: 1,
        restBetweenRoundsSeconds: 0,
        intervals: const [
          IntervalStep(id: 'h_wb_work', name: '100 WALL BALLS FOR TIME', durationSeconds: 420, phase: TimerPhase.work),
        ],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
