class TimerSettings {
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool wakelockEnabled;
  final String languageCode; // 'en' or 'tr'
  final bool voiceCoachEnabled;
  final String voiceCoachId; // 'male_1', 'male_2', 'female_1', 'female_2'
  final String audioThemeId; // one of the 10 audio themes
  final bool confirmTimerExit;
  final bool autoStartTimer;

  const TimerSettings({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.wakelockEnabled = true,
    this.languageCode = 'en',
    this.voiceCoachEnabled = true,
    this.voiceCoachId = 'male_1',
    this.audioThemeId = 'classic_beeps',
    this.confirmTimerExit = false,
    this.autoStartTimer = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'wakelockEnabled': wakelockEnabled,
      'languageCode': languageCode,
      'voiceCoachEnabled': voiceCoachEnabled,
      'voiceCoachId': voiceCoachId,
      'audioThemeId': audioThemeId,
      'confirmTimerExit': confirmTimerExit,
      'autoStartTimer': autoStartTimer,
    };
  }

  factory TimerSettings.fromJson(Map<String, dynamic> json) {
    return TimerSettings(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      wakelockEnabled: json['wakelockEnabled'] as bool? ?? true,
      languageCode: json['languageCode'] as String? ?? 'en',
      voiceCoachEnabled: json['voiceCoachEnabled'] as bool? ?? true,
      voiceCoachId: json['voiceCoachId'] as String? ?? 'male_1',
      audioThemeId: json['audioThemeId'] as String? ?? 'classic_beeps',
      confirmTimerExit: json['confirmTimerExit'] as bool? ?? false,
      autoStartTimer: json['autoStartTimer'] as bool? ?? false,
    );
  }

  TimerSettings copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? wakelockEnabled,
    String? languageCode,
    bool? voiceCoachEnabled,
    String? voiceCoachId,
    String? audioThemeId,
    bool? confirmTimerExit,
    bool? autoStartTimer,
  }) {
    return TimerSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      wakelockEnabled: wakelockEnabled ?? this.wakelockEnabled,
      languageCode: languageCode ?? this.languageCode,
      voiceCoachEnabled: voiceCoachEnabled ?? this.voiceCoachEnabled,
      voiceCoachId: voiceCoachId ?? this.voiceCoachId,
      audioThemeId: audioThemeId ?? this.audioThemeId,
      confirmTimerExit: confirmTimerExit ?? this.confirmTimerExit,
      autoStartTimer: autoStartTimer ?? this.autoStartTimer,
    );
  }
}
