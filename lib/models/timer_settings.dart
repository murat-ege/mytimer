class TimerSettings {
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool wakelockEnabled;
  final String languageCode; // 'tr' or 'en'

  const TimerSettings({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.wakelockEnabled = true,
    this.languageCode = 'tr',
  });

  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'wakelockEnabled': wakelockEnabled,
      'languageCode': languageCode,
    };
  }

  factory TimerSettings.fromJson(Map<String, dynamic> json) {
    return TimerSettings(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      wakelockEnabled: json['wakelockEnabled'] as bool? ?? true,
      languageCode: json['languageCode'] as String? ?? 'tr',
    );
  }

  TimerSettings copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? wakelockEnabled,
    String? languageCode,
  }) {
    return TimerSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      wakelockEnabled: wakelockEnabled ?? this.wakelockEnabled,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}
