import 'timer_phase.dart';

class IntervalStep {
  final String id;
  final String name;
  final int durationSeconds;
  final TimerPhase phase;

  const IntervalStep({
    required this.id,
    required this.name,
    required this.durationSeconds,
    required this.phase,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'durationSeconds': durationSeconds,
      'phase': phase.name,
    };
  }

  factory IntervalStep.fromJson(Map<String, dynamic> json) {
    return IntervalStep(
      id: json['id'] as String,
      name: json['name'] as String,
      durationSeconds: json['durationSeconds'] as int,
      phase: TimerPhase.values.firstWhere(
        (e) => e.name == json['phase'],
        orElse: () => TimerPhase.work,
      ),
    );
  }

  IntervalStep copyWith({
    String? id,
    String? name,
    int? durationSeconds,
    TimerPhase? phase,
  }) {
    return IntervalStep(
      id: id ?? this.id,
      name: name ?? this.name,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      phase: phase ?? this.phase,
    );
  }
}
