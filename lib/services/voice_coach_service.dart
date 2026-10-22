import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';

class VoiceProfile {
  final String id;
  final String nameEn;
  final String nameTr;
  final bool isMale;
  final double pitch;
  final double rate;

  const VoiceProfile({
    required this.id,
    required this.nameEn,
    required this.nameTr,
    required this.isMale,
    required this.pitch,
    required this.rate,
  });
}

class VoiceCoachService {
  static final VoiceCoachService _instance = VoiceCoachService._internal();
  factory VoiceCoachService() => _instance;
  VoiceCoachService._internal();

  final FlutterTts _flutterTts = FlutterTts();

  bool voiceEnabled = true;
  String currentVoiceId = 'male_1';
  String languageCode = 'en'; // 'en' or 'tr'
  bool _isInitialized = false;

  static const List<VoiceProfile> availableProfiles = [
    VoiceProfile(
      id: 'male_1',
      nameEn: 'Coach Marcus (Male 1 - Deep & Commanding)',
      nameTr: 'Koç Demir (Erkek 1 - Tok & Güçlü)',
      isMale: true,
      pitch: 0.60,
      rate: 0.48,
    ),
    VoiceProfile(
      id: 'male_2',
      nameEn: 'Coach Jax (Male 2 - Ultra-Deep & Bassy)',
      nameTr: 'Koç Barış (Erkek 2 - Çok Kalın & Derin Tok)',
      isMale: true,
      pitch: 0.48,
      rate: 0.46,
    ),
    VoiceProfile(
      id: 'female_1',
      nameEn: 'Coach Sarah (Female 1 - High Energy Athletic)',
      nameTr: 'Koç Selin (Kadın 1 - Yüksek Enerji Atletik)',
      isMale: false,
      pitch: 1.12,
      rate: 0.52,
    ),
    VoiceProfile(
      id: 'female_2',
      nameEn: 'Coach Emma (Female 2 - Calm & Focused)',
      nameTr: 'Koç Ayşe (Kadın 2 - Sakin & Odaklı)',
      isMale: false,
      pitch: 0.95,
      rate: 0.48,
    ),
  ];

  VoiceProfile get currentProfile {
    return availableProfiles.firstWhere(
      (p) => p.id == currentVoiceId,
      orElse: () => availableProfiles.first,
    );
  }

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.awaitSpeakCompletion(false);
      if (Platform.isIOS) {
        try {
          await _flutterTts.setSharedInstance(true);
          await _flutterTts.autoStopSharedSession(false);
          await _flutterTts.setIosAudioCategory(
            IosTextToSpeechAudioCategory.playback,
            [
              IosTextToSpeechAudioCategoryOptions.mixWithOthers,
              IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
            ],
          );
        } catch (_) {}
      }
      await _applySettings();
      _isInitialized = true;
    } catch (_) {}
  }

  Future<void> _applySettings() async {
    try {
      final profile = currentProfile;
      final langTag = (languageCode == 'tr') ? 'tr-TR' : 'en-US';
      await _flutterTts.setLanguage(langTag);

      if (Platform.isIOS) {
        try {
          await _flutterTts.setSharedInstance(true);
          await _flutterTts.autoStopSharedSession(false);
          await _flutterTts.setIosAudioCategory(
            IosTextToSpeechAudioCategory.playback,
            [
              IosTextToSpeechAudioCategoryOptions.mixWithOthers,
              IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
            ],
          );
        } catch (_) {}
      }

      // Select real system male or female voice
      try {
        final voices = await _flutterTts.getVoices;
        if (voices is List) {
          final langPrefix = (languageCode == 'tr') ? 'tr' : 'en';
          final langVoices = voices.where((v) {
            if (v is Map) {
              final locale = (v['locale'] ?? '').toString().toLowerCase();
              return locale.startsWith(langPrefix);
            }
            return false;
          }).toList();

          Map? matchedVoice;
          if (profile.isMale) {
            matchedVoice = langVoices.firstWhere((v) {
              final m = v as Map;
              final gender = (m['gender'] ?? '').toString().toLowerCase();
              final name = (m['name'] ?? '').toString().toLowerCase();
              final features = (m['features'] ?? '').toString().toLowerCase();
              return gender == 'male' ||
                  name.contains('male') ||
                  features.contains('male') ||
                  name.contains('cem') ||
                  name.contains('ahmet') ||
                  name.contains('alex') ||
                  name.contains('daniel') ||
                  name.contains('aaron') ||
                  name.contains('arthur') ||
                  name.contains('gordon') ||
                  name.contains('fred') ||
                  name.contains('oliver');
            }, orElse: () => null);
          } else {
            matchedVoice = langVoices.firstWhere((v) {
              final m = v as Map;
              final gender = (m['gender'] ?? '').toString().toLowerCase();
              final name = (m['name'] ?? '').toString().toLowerCase();
              final features = (m['features'] ?? '').toString().toLowerCase();
              return gender == 'female' ||
                  name.contains('female') ||
                  features.contains('female') ||
                  name.contains('yelda') ||
                  name.contains('samantha') ||
                  name.contains('karen') ||
                  name.contains('moira') ||
                  name.contains('tessa') ||
                  name.contains('victoria');
            }, orElse: () => null);
          }

          if (matchedVoice != null) {
            final voiceName = matchedVoice['name']?.toString() ?? '';
            final voiceLocale = matchedVoice['locale']?.toString() ?? '';
            if (voiceName.isNotEmpty && voiceLocale.isNotEmpty) {
              await _flutterTts.setVoice({
                'name': voiceName,
                'locale': voiceLocale,
              });
            }
          }
        }
      } catch (_) {}

      await _flutterTts.setPitch(profile.pitch);
      await _flutterTts.setSpeechRate(profile.rate);
      await _flutterTts.setVolume(1.0);
    } catch (_) {}
  }

  Future<void> updateConfig({
    required bool enabled,
    required String voiceId,
    required String lang,
  }) async {
    voiceEnabled = enabled;
    currentVoiceId = voiceId;
    languageCode = lang;
    await _applySettings();
  }

  String? _lastSpokenText;
  DateTime? _lastSpokenTime;

  Future<void> speak(String text) async {
    if (!voiceEnabled) return;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final now = DateTime.now();
    if (_lastSpokenText == trimmed &&
        _lastSpokenTime != null &&
        now.difference(_lastSpokenTime!).inMilliseconds < 250) {
      return;
    }
    _lastSpokenText = trimmed;
    _lastSpokenTime = now;

    try {
      await _flutterTts.speak(trimmed);
    } catch (_) {}
  }

  // --- WOD Coaching Announcements ---

  Future<void> speakCountdown(int number) async {
    if (!voiceEnabled || number <= 0) return;
    await speak('$number');
  }

  Future<void> speakWork({int? roundIndex, int? totalRounds}) async {
    if (!voiceEnabled) return;
    if (roundIndex == null || roundIndex <= 1) {
      if (totalRounds != null && totalRounds > 1) {
        await speak('Lets Go!');
      } else {
        await speak('Lets Go!');
      }
    } else {
      await speak('Round $roundIndex');
    }
  }

  Future<void> speakRest() async {
    if (!voiceEnabled) return;
    if (languageCode == 'tr') {
      await speak('Dinlen!');
    } else {
      await speak('Rest!');
    }
  }

  Future<void> speakCooldown() async {
    if (!voiceEnabled) return;
    if (languageCode == 'tr') {
      await speak('Soğuma!');
    } else {
      await speak('Cooldown!');
    }
  }

  Future<void> speakIntervalSignal(int minutes) async {
    // Minute interval announcements are currently disabled
    return;
  }

  Future<void> speakRound(int roundNumber, int totalRounds) async {
    if (!voiceEnabled) return;
    await speak('Round $roundNumber');
  }

  Future<void> speakHalfway() async {
    // Halfway announcement is currently disabled
    return;
  }

  Future<void> speakComplete() async {
    if (!voiceEnabled) return;
    if (languageCode == 'tr') {
      await speak('Antrenman tamamlandı!');
    } else {
      await speak('Workout complete!');
    }
  }

  Future<void> testVoice() async {
    await _applySettings();
    await speak('Go! Round 1');
  }

  void stop() {
    try {
      _flutterTts.stop().catchError((_) => null);
    } catch (_) {}
  }
}
