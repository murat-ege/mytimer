import 'interval_step.dart';
import 'timer_phase.dart';

class CustomRoutine {
  final String id;
  final String name;
  final String description;
  final String category;
  final bool isPreset;
  final int prepSeconds;
  final List<IntervalStep> intervals;
  final int rounds;
  final int restBetweenRoundsSeconds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomRoutine({
    required this.id,
    required this.name,
    this.description = '',
    this.category = 'CrossFit WOD',
    this.isPreset = false,
    this.prepSeconds = 10,
    required this.intervals,
    this.rounds = 1,
    this.restBetweenRoundsSeconds = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  int get totalDurationSeconds {
    final intervalsSum = intervals.fold<int>(0, (sum, i) => sum + i.durationSeconds);
    final roundsTime = intervalsSum * rounds;
    final roundRestsTime = (rounds > 1) ? restBetweenRoundsSeconds * (rounds - 1) : 0;
    return prepSeconds + roundsTime + roundRestsTime;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'isPreset': isPreset,
      'prepSeconds': prepSeconds,
      'intervals': intervals.map((i) => i.toJson()).toList(),
      'rounds': rounds,
      'restBetweenRoundsSeconds': restBetweenRoundsSeconds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CustomRoutine.fromJson(Map<String, dynamic> json) {
    return CustomRoutine(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'CrossFit WOD',
      isPreset: json['isPreset'] as bool? ?? false,
      prepSeconds: json['prepSeconds'] as int? ?? 10,
      intervals: (json['intervals'] as List<dynamic>)
          .map((i) => IntervalStep.fromJson(i as Map<String, dynamic>))
          .toList(),
      rounds: json['rounds'] as int? ?? 1,
      restBetweenRoundsSeconds: json['restBetweenRoundsSeconds'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  CustomRoutine copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    bool? isPreset,
    int? prepSeconds,
    List<IntervalStep>? intervals,
    int? rounds,
    int? restBetweenRoundsSeconds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomRoutine(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      isPreset: isPreset ?? this.isPreset,
      prepSeconds: prepSeconds ?? this.prepSeconds,
      intervals: intervals ?? this.intervals,
      rounds: rounds ?? this.rounds,
      restBetweenRoundsSeconds: restBetweenRoundsSeconds ?? this.restBetweenRoundsSeconds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Preset factory for standard Tabata
  factory CustomRoutine.tabata({
    int workSeconds = 20,
    int restSeconds = 10,
    int rounds = 8,
    int prepSeconds = 10,
  }) {
    final now = DateTime.now();
    return CustomRoutine(
      id: 'tabata_standard',
      name: 'TABATA',
      description: '20s Work / 10s Rest x 8 Rounds',
      prepSeconds: prepSeconds,
      intervals: [
        IntervalStep(
          id: 'step_work',
          name: 'WORK',
          durationSeconds: workSeconds,
          phase: TimerPhase.work,
        ),
        IntervalStep(
          id: 'step_rest',
          name: 'REST',
          durationSeconds: restSeconds,
          phase: TimerPhase.rest,
        ),
      ],
      rounds: rounds,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Preset factory for Rounds / Intervals
  factory CustomRoutine.roundsPreset({
    required String name,
    int workSeconds = 60,
    int restSeconds = 30,
    int rounds = 5,
    int prepSeconds = 10,
  }) {
    final now = DateTime.now();
    return CustomRoutine(
      id: 'rounds_${now.millisecondsSinceEpoch}',
      name: name,
      prepSeconds: prepSeconds,
      intervals: [
        IntervalStep(
          id: 'step_round_work',
          name: 'WORK',
          durationSeconds: workSeconds,
          phase: TimerPhase.work,
        ),
        if (restSeconds > 0)
          IntervalStep(
            id: 'step_round_rest',
            name: 'REST',
            durationSeconds: restSeconds,
            phase: TimerPhase.rest,
          ),
      ],
      rounds: rounds,
      createdAt: now,
      updatedAt: now,
    );
  }
}
