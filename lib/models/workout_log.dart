class WorkoutLog {
  final String id;
  final String timerType; // 'tabata', 'rounds', 'emom', 'amrap', 'fortime', 'stopwatch', 'countdown', 'custom'
  final String title;
  final String defaultDefinition;
  final String userNote;
  final int totalDurationSeconds;
  final DateTime completedAt;
  final String? imagePath;
  final int? completedRounds;
  final int? totalRounds;

  const WorkoutLog({
    required this.id,
    required this.timerType,
    required this.title,
    required this.defaultDefinition,
    this.userNote = '',
    required this.totalDurationSeconds,
    required this.completedAt,
    this.imagePath,
    this.completedRounds,
    this.totalRounds,
  });

  String get formattedDuration {
    final hours = totalDurationSeconds ~/ 3600;
    final mins = (totalDurationSeconds % 3600) ~/ 60;
    final secs = totalDurationSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timerType': timerType,
      'title': title,
      'defaultDefinition': defaultDefinition,
      'userNote': userNote,
      'totalDurationSeconds': totalDurationSeconds,
      'completedAt': completedAt.toIso8601String(),
      'imagePath': imagePath,
      'completedRounds': completedRounds,
      'totalRounds': totalRounds,
    };
  }

  factory WorkoutLog.fromJson(Map<String, dynamic> json) {
    return WorkoutLog(
      id: json['id'] as String,
      timerType: json['timerType'] as String? ?? 'workout',
      title: json['title'] as String? ?? 'Workout',
      defaultDefinition: json['defaultDefinition'] as String? ?? '',
      userNote: json['userNote'] as String? ?? '',
      totalDurationSeconds: json['totalDurationSeconds'] as int? ?? 0,
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? '') ?? DateTime.now(),
      imagePath: json['imagePath'] as String?,
      completedRounds: json['completedRounds'] as int?,
      totalRounds: json['totalRounds'] as int?,
    );
  }

  WorkoutLog copyWith({
    String? id,
    String? timerType,
    String? title,
    String? defaultDefinition,
    String? userNote,
    int? totalDurationSeconds,
    DateTime? completedAt,
    String? imagePath,
    int? completedRounds,
    int? totalRounds,
  }) {
    return WorkoutLog(
      id: id ?? this.id,
      timerType: timerType ?? this.timerType,
      title: title ?? this.title,
      defaultDefinition: defaultDefinition ?? this.defaultDefinition,
      userNote: userNote ?? this.userNote,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      completedAt: completedAt ?? this.completedAt,
      imagePath: imagePath ?? this.imagePath,
      completedRounds: completedRounds ?? this.completedRounds,
      totalRounds: totalRounds ?? this.totalRounds,
    );
  }
}
