import 'dart:math';
import 'dart:typed_data';

enum SoundType {
  countdown,
  work,
  rest,
  complete,
}

class AudioThemeInfo {
  final String id;
  final String nameEn;
  final String nameTr;
  final String descriptionEn;
  final String descriptionTr;

  const AudioThemeInfo({
    required this.id,
    required this.nameEn,
    required this.nameTr,
    required this.descriptionEn,
    required this.descriptionTr,
  });
}

class AudioThemeGenerator {
  static const int sampleRate = 44100;

  static const List<AudioThemeInfo> allThemes = [
    AudioThemeInfo(
      id: 'beep_and_go',
      nameEn: 'Original Beep & Go',
      nameTr: 'Orijinal Bip & Go',
      descriptionEn: 'Pure 436Hz 3-2-1 countdown beeps and 1032Hz high GO start tone',
      descriptionTr: '436Hz 3-2-1 geri sayım bip tonu ve 1032Hz tiz GO başlama sinyali',
    ),
    AudioThemeInfo(
      id: 'classic_beeps',
      nameEn: 'Rogue Pro Box Buzzer',
      nameTr: 'Rogue Pro Box Bip & Buzzer',
      descriptionEn: 'Deep CrossFit wall-timer buzzer and low-frequency interval horn',
      descriptionTr: 'CrossFit box duvar saati buzzerı ve tok aralık sireni',
    ),
    AudioThemeInfo(
      id: 'arena_horn',
      nameEn: 'Arena Stadium Air Horn',
      nameTr: 'Arena Stadyum Havalı Sireni',
      descriptionEn: 'Thunderous multi-harmonic brass blast used in arena sports',
      descriptionTr: 'Hokey ve stadyumlarda kullanılan gür ve tok stadyum kornası',
    ),
    AudioThemeInfo(
      id: 'boxing_bell',
      nameEn: 'Heavy Boxing Ring Bell',
      nameTr: 'Ağır Boks Ring Çanı',
      descriptionEn: 'Authentic 10-inch brass fight bell with metallic strike and rich decay',
      descriptionTr: 'Otantik pirinç boks ring gongu, metalik vuruş ve uzun yankı',
    ),
    AudioThemeInfo(
      id: 'drill_whistle',
      nameEn: 'Fox 40 Referee Whistle',
      nameTr: 'Fox 40 Hakem Düdüğü',
      descriptionEn: 'High-intensity dual-tone pea-less whistle with acoustic air flutter',
      descriptionTr: 'Çift frekanslı hava titreşimli gerçek atletik hakem düdüğü',
    ),
    AudioThemeInfo(
      id: 'heavy_synth',
      nameEn: 'Barbell Drop & Heavy Bass',
      nameTr: 'Halter Vuruşu & Derin Sub-Bass',
      descriptionEn: 'Sub-bass athletic impact layered with Olympic barbell iron clank',
      descriptionTr: 'Olimpik halter demir vuruşu ve göğsü titreten subwoofer darbesi',
    ),
    AudioThemeInfo(
      id: 'woodblock_click',
      nameEn: 'Boxing Corner Clapper',
      nameTr: 'Boks Köşe Tahtası (10sn Uyarısı)',
      descriptionEn: 'Dry acoustic hardwood clappers used for 10-second round warnings',
      descriptionTr: 'Boks rauntlarında 10 saniye kala vurulan kuru sert ahşap takoz sesi',
    ),
    AudioThemeInfo(
      id: 'arcade_8bit',
      nameEn: 'Gymboss Pro Interval Timer',
      nameTr: 'Gymboss Pro Dijital Zamanlayıcı',
      descriptionEn: 'Crisp acoustic sine-wave digital interval beeps that cut through music',
      descriptionTr: 'Müzik sesini bastıran, pürüzsüz net dijital antrenman aralık sinyali',
    ),
    AudioThemeInfo(
      id: 'cyber_laser',
      nameEn: 'Industrial Shot-Clock Buzzer',
      nameTr: 'Endüstriyel Şut Saati Kornası',
      descriptionEn: 'Low-frequency 320Hz rasping buzzer like NBA and Olympic shot-clocks',
      descriptionTr: 'NBA ve basketbol salonlarındaki 320Hz kalın raspalı süre sonu kornası',
    ),
    AudioThemeInfo(
      id: 'drum_kick',
      nameEn: 'HIIT Cadence Bass Drum',
      nameTr: 'HIIT Ritim Bas Davulu',
      descriptionEn: 'Deep 24-inch acoustic marching bass drum with heavy punch',
      descriptionTr: 'Derin gövdeli akustik bas davul vuruşu ve ritmik bas darbesi',
    ),
    AudioThemeInfo(
      id: 'zen_singing_bowl',
      nameEn: 'Tibetan Temple Meditation Gong',
      nameTr: 'Tibet Meditasyon & Yoga Gongu',
      descriptionEn: 'Deep 216Hz bronze temple gong with long acoustic shimmer for mobility',
      descriptionTr: 'Yoga ve esneme için 216Hz derin bronz tapınak çanı ve uzun tınlama',
    ),
  ];

  static final Map<String, Uint8List> _cache = {};

  static Uint8List getSoundBytes(String themeId, SoundType type) {
    final key = '${themeId}_${type.name}';
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }
    final bytes = _generateWave(themeId, type);
    _cache[key] = bytes;
    return bytes;
  }

  static Uint8List _generateWave(String themeId, SoundType type) {
    switch (themeId) {
      case 'beep_and_go':
        return _generateBeepAndGo(type);
      case 'arena_horn':
        return _generateArenaHorn(type);
      case 'boxing_bell':
        return _generateBoxingBell(type);
      case 'heavy_synth':
        return _generateBarbellDrop(type);
      case 'drill_whistle':
        return _generateWhistle(type);
      case 'woodblock_click':
        return _generateCornerClapper(type);
      case 'arcade_8bit':
        return _generateGymbossTimer(type);
      case 'cyber_laser':
        return _generateShotClockBuzzer(type);
      case 'drum_kick':
        return _generateCadenceDrum(type);
      case 'zen_singing_bowl':
        return _generateZenGong(type);
      case 'classic_beeps':
      default:
        return _generateBoxBuzzer(type);
    }
  }

  // --- Theme: Original Beep & Go ---
  static Uint8List _generateBeepAndGo(SoundType type) {
    switch (type) {
      case SoundType.countdown:
        return _synthPureBeep(freq: 436, durationSec: 0.22, volume: 0.90);
      case SoundType.work:
        return _synthHarmonicWorkBeep(durationSec: 0.60, volume: 0.95);
      case SoundType.rest:
        return _synthPureBeep(freq: 654, durationSec: 0.40, volume: 0.85);
      case SoundType.complete:
        return _synthSequence([
          _Tone(freq: 436, dur: 0.18, wave: 'sine', volume: 0.85),
          _Tone(freq: 654, dur: 0.18, wave: 'sine', volume: 0.85),
          _Tone(freq: 872, dur: 0.18, wave: 'sine', volume: 0.85),
          _Tone(freq: 1032, dur: 0.65, wave: 'sine', volume: 0.95),
        ]);
    }
  }

  // --- Theme 1: Rogue Pro Box Buzzer ---
  static Uint8List _generateBoxBuzzer(SoundType type) {
    switch (type) {
      case SoundType.countdown:
        return _synthGymBuzzer(freq: 460, durationSec: 0.16, volume: 0.85);
      case SoundType.work:
        return _synthSequence([
          _Tone(freq: 580, dur: 0.12, wave: 'buzzer', volume: 0.9),
          _Tone(freq: 580, dur: 0.45, wave: 'buzzer', volume: 0.95),
        ]);
      case SoundType.rest:
        return _synthGymBuzzer(freq: 330, durationSec: 0.35, volume: 0.8);
      case SoundType.complete:
        return _synthSequence([
          _Tone(freq: 440, dur: 0.15, wave: 'buzzer', volume: 0.85),
          _Tone(freq: 440, dur: 0.15, wave: 'buzzer', volume: 0.85),
          _Tone(freq: 440, dur: 0.55, wave: 'buzzer', volume: 0.95),
        ]);
    }
  }

  // --- Theme 2: Arena Stadium Air Horn ---
  static Uint8List _generateArenaHorn(SoundType type) {
    switch (type) {
      case SoundType.countdown:
        return _synthArenaHorn(freq: 196, durationSec: 0.18, volume: 0.8);
      case SoundType.work:
        return _synthArenaHorn(freq: 246, durationSec: 0.70, volume: 0.95);
      case SoundType.rest:
        return _synthArenaHorn(freq: 155, durationSec: 0.40, volume: 0.8);
      case SoundType.complete:
        return _synthSequence([
          _Tone(freq: 185, dur: 0.2, wave: 'horn', volume: 0.85),
          _Tone(freq: 185, dur: 0.2, wave: 'horn', volume: 0.85),
          _Tone(freq: 185, dur: 0.65, wave: 'horn', volume: 0.95),
        ]);
    }
  }

  // --- Theme 3: Heavy Boxing Ring Bell ---
  static Uint8List _generateBoxingBell(SoundType type) {
    switch (type) {
      case SoundType.countdown:
        return _synthFightBell(freq: 780, durationSec: 0.25, decay: 6.0, volume: 0.8);
      case SoundType.work:
        return _synthSequence([
          _Tone(freq: 880, dur: 0.28, wave: 'bell', volume: 0.9),
          _Tone(freq: 880, dur: 1.10, wave: 'bell', volume: 0.95),
        ]);
      case SoundType.rest:
        return _synthFightBell(freq: 620, durationSec: 0.80, decay: 3.5, volume: 0.85);
      case SoundType.complete:
        return _synthSequence([
          _Tone(freq: 740, dur: 0.25, wave: 'bell', volume: 0.85),
          _Tone(freq: 740, dur: 0.25, wave: 'bell', volume: 0.85),
          _Tone(freq: 740, dur: 1.20, wave: 'bell', volume: 0.95),
        ]);
    }
  }

  // --- Theme 4: Fox 40 Referee Whistle ---
  static Uint8List _generateWhistle(SoundType type) {
    switch (type) {
      case SoundType.countdown:
        return _synthFox40Whistle(freq: 2850, durationSec: 0.12, volume: 0.8);
      case SoundType.work:
        return _synthFox40Whistle(freq: 2950, durationSec: 0.65, volume: 0.95);
      case SoundType.rest:
        return _synthFox40Whistle(freq: 2650, durationSec: 0.35, volume: 0.85);
      case SoundType.complete:
        return _synthSequence([
          _Tone(freq: 2900, dur: 0.15, wave: 'whistle', volume: 0.85),
          _Tone(freq: 2900, dur: 0.15, wave: 'whistle', volume: 0.85),
          _Tone(freq: 3100, dur: 0.60, wave: 'whistle', volume: 0.95),
        ]);
    }
  }

  // --- Theme 5: Barbell Drop & Heavy Bass ---
  static Uint8List _generateBarbellDrop(SoundType type) {
    switch (type) {
      case SoundType.countdown:
        return _synthBarbellDrop(durationSec: 0.16, startFreq: 130, endFreq: 60, volume: 0.85);
      case SoundType.work:
        return _synthBarbellDrop(durationSec: 0.65, startFreq: 110, endFreq: 40, volume: 0.95);
      case SoundType.rest:
        return _synthBarbellDrop(durationSec: 0.35, startFreq: 90, endFreq: 45, volume: 0.8);
      case SoundType.complete:
        return _synthSequence([
          _Tone(freq: 120, dur: 0.2, wave: 'drop', volume: 0.85),
          _Tone(freq: 120, dur: 0.2, wave: 'drop', volume: 0.85),
          _Tone(freq: 100, dur: 0.65, wave: 'drop', volume: 0.95),
        ]);
    }
  }

  // --- Theme 6: Boxing Corner Clapper ---
  static Uint8List _generateCornerClapper(SoundType type) {
    switch (type) {
      case SoundType.countdown:
        return _synthCornerClapper(freq: 940, durationSec: 0.08, volume: 0.9);
      case SoundType.work:
        return _synthSequence([
          _Tone(freq: 960, dur: 0.10, wave: 'clapper', volume: 0.9),
          _Tone(freq: 1020, dur: 0.25, wave: 'clapper', volume: 0.95),
        ]);
      case SoundType.rest:
        return _synthCornerClapper(freq: 720, durationSec: 0.12, volume: 0.85);
      case SoundType.complete:
        return _synthSequence([
          _Tone(freq: 960, dur: 0.1, wave: 'clapper', volume: 0.85),
          _Tone(freq: 960, dur: 0.1, wave: 'clapper', volume: 0.85),
          _Tone(freq: 1050, dur: 0.25, wave: 'clapper', volume: 0.95),
        ]);
    }
  }

  // --- Theme 7: Gymboss Pro Interval Timer ---
  static Uint8List _generateGymbossTimer(SoundType type) {
    switch (type) {
      case SoundType.countdown:
        return _synthGymbossTimer(freq: 1600, durationSec: 0.12, volume: 0.85);
      case SoundType.work:
        return _synthSequence([
          _Tone(freq: 2000, dur: 0.12, wave: 'gymboss', volume: 0.85),
          _Tone(freq: 2400, dur: 0.40, wave: 'gymboss', volume: 0.95),
        ]);
      case SoundType.rest:
        return _synthSequence([
          _Tone(freq: 1800, dur: 0.12, wave: 'gymboss', volume: 0.85),
          _Tone(freq: 1200, dur: 0.30, wave: 'gymboss', volume: 0.85),
        ]);
      case SoundType.complete:
        return _synthSequence([
          _Tone(freq: 1600, dur: 0.12, wave: 'gymboss', volume: 0.85),
          _Tone(freq: 2000, dur: 0.12, wave: 'gymboss', volume: 0.85),
          _Tone(freq: 2400, dur: 0.50, wave: 'gymboss', volume: 0.95),
        ]);
    }
  }

  // --- Theme 8: Industrial Shot-Clock Buzzer ---
  static Uint8List _generateShotClockBuzzer(SoundType type) {
    switch (type) {
      case SoundType.countdown:
        return _synthShotClockBuzzer(freq: 340, durationSec: 0.15, volume: 0.85);
      case SoundType.work:
        return _synthShotClockBuzzer(freq: 310, durationSec: 0.65, volume: 0.95);
      case SoundType.rest:
        return _synthShotClockBuzzer(freq: 270, durationSec: 0.35, volume: 0.8);
      case SoundType.complete:
        return _synthSequence([
          _Tone(freq: 310, dur: 0.18, wave: 'shotclock', volume: 0.85),
          _Tone(freq: 310, dur: 0.18, wave: 'shotclock', volume: 0.85),
          _Tone(freq: 310, dur: 0.60, wave: 'shotclock', volume: 0.95),
        ]);
    }
  }

  // --- Theme 9: HIIT Cadence Bass Drum ---
  static Uint8List _generateCadenceDrum(SoundType type) {
    switch (type) {
      case SoundType.countdown:
        return _synthCadenceDrum(durationSec: 0.14, startFreq: 140, endFreq: 55, volume: 0.85);
      case SoundType.work:
        return _synthSequence([
          _Tone(freq: 150, dur: 0.18, wave: 'drum', volume: 0.85),
          _Tone(freq: 120, dur: 0.50, wave: 'drum', volume: 0.95),
        ]);
      case SoundType.rest:
        return _synthCadenceDrum(durationSec: 0.35, startFreq: 110, endFreq: 45, volume: 0.8);
      case SoundType.complete:
        return _synthSequence([
          _Tone(freq: 140, dur: 0.15, wave: 'drum', volume: 0.85),
          _Tone(freq: 140, dur: 0.15, wave: 'drum', volume: 0.85),
          _Tone(freq: 110, dur: 0.65, wave: 'drum', volume: 0.95),
        ]);
    }
  }

  // --- Theme 10: Tibetan Temple Meditation Gong ---
  static Uint8List _generateZenGong(SoundType type) {
    switch (type) {
      case SoundType.countdown:
        return _synthTibetanGong(freq: 260, durationSec: 0.35, decay: 4.5, volume: 0.8);
      case SoundType.work:
        return _synthTibetanGong(freq: 216, durationSec: 1.20, decay: 2.2, volume: 0.95);
      case SoundType.rest:
        return _synthTibetanGong(freq: 174, durationSec: 0.90, decay: 2.8, volume: 0.85);
      case SoundType.complete:
        return _synthSequence([
          _Tone(freq: 216, dur: 0.3, wave: 'gong', volume: 0.8),
          _Tone(freq: 270, dur: 0.3, wave: 'gong', volume: 0.8),
          _Tone(freq: 324, dur: 1.4, wave: 'gong', volume: 0.95),
        ]);
    }
  }

  // ===================== WAVE SYNTHESIZER UTILITIES =====================

  static Uint8List _synthPureBeep({
    required double freq,
    required double durationSec,
    double volume = 0.90,
  }) {
    final numSamples = (durationSec * sampleRate).toInt();
    final samples = Int16List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final progress = i / numSamples;
      double env = 1.0;
      if (progress < 0.03) env = progress / 0.03; // ~15ms attack
      if (progress > 0.85) env = (1.0 - progress) / 0.15; // smooth release

      final val = sin(2 * pi * freq * t);
      samples[i] = (val * volume * env * 32767).toInt().clamp(-32768, 32767);
    }
    return _createWav(samples);
  }

  static Uint8List _synthHarmonicWorkBeep({
    double durationSec = 0.60,
    double volume = 0.95,
  }) {
    final numSamples = (durationSec * sampleRate).toInt();
    final samples = Int16List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final progress = i / numSamples;
      double env = 1.0;
      if (progress < 0.02) env = progress / 0.02; // crisp 15ms attack
      if (progress > 0.80) env = (1.0 - progress) / 0.20; // smooth decay

      // High, crisp, athletic GO tone: 1308 Hz fundamental (3x countdown 436 Hz)
      // + 2616 Hz upper shimmer + 1744 Hz bright harmonic fullness
      final f1 = sin(2 * pi * 1308 * t);
      final f2 = 0.25 * sin(2 * pi * 2616 * t);
      final f3 = 0.15 * sin(2 * pi * 1744 * t);
      final val = (f1 + f2 + f3) / 1.40;

      samples[i] = (val * volume * env * 32767).toInt().clamp(-32768, 32767);
    }
    return _createWav(samples);
  }

  static Uint8List _synthGymBuzzer({
    required double freq,
    required double durationSec,
    double volume = 0.9,
  }) {
    final numSamples = (durationSec * sampleRate).toInt();
    final samples = Int16List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final progress = i / numSamples;
      double env = 1.0;
      if (progress < 0.03) env = progress / 0.03;
      if (progress > 0.88) env = (1.0 - progress) / 0.12;

      // Authentic gym wall clock buzzer: Rich odd & even harmonics with rasp
      final f1 = sin(2 * pi * freq * t);
      final f2 = 0.7 * sin(2 * pi * (freq * 2) * t);
      final f3 = 0.45 * sin(2 * pi * (freq * 3) * t);
      final f4 = 0.25 * sin(2 * pi * (freq * 4) * t);
      final raw = (f1 + f2 + f3 + f4) / 2.4;

      final saturated = (raw * 1.5).clamp(-0.9, 0.9);
      samples[i] = (saturated * volume * env * 32767).toInt().clamp(-32768, 32767);
    }
    return _createWav(samples);
  }

  static Uint8List _synthArenaHorn({
    required double freq,
    required double durationSec,
    double volume = 0.9,
  }) {
    final numSamples = (durationSec * sampleRate).toInt();
    final samples = Int16List(numSamples);

    final f1 = freq;
    final f2 = freq * 1.2599; // major third
    final f3 = freq * 1.4983; // fifth

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final progress = i / numSamples;
      double env = 1.0;
      if (progress < 0.06) env = progress / 0.06;
      if (progress > 0.85) env = (1.0 - progress) / 0.15;

      final s1 = sin(2 * pi * f1 * t) + 0.4 * sin(2 * pi * (f1 * 2) * t);
      final s2 = 0.85 * sin(2 * pi * f2 * t);
      final s3 = 0.75 * sin(2 * pi * f3 * t);
      final raw = (s1 + s2 + s3) / 3.0;

      final brass = (raw * 1.4).clamp(-0.85, 0.85);
      samples[i] = (brass * volume * env * 32767).toInt().clamp(-32768, 32767);
    }
    return _createWav(samples);
  }

  static Uint8List _synthFightBell({
    required double freq,
    required double durationSec,
    required double decay,
    double volume = 0.9,
  }) {
    final numSamples = (durationSec * sampleRate).toInt();
    final samples = Int16List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final env = exp(-decay * t);

      final clickEnv = exp(-400 * t);
      final click = sin(2 * pi * 2400 * t) * clickEnv * 0.35;

      final s1 = sin(2 * pi * freq * t);
      final s2 = 0.5 * sin(2 * pi * (freq * 1.98) * t) * exp(-decay * 1.2 * t);
      final s3 = 0.3 * sin(2 * pi * (freq * 3.12) * t) * exp(-decay * 1.8 * t);
      final s4 = 0.15 * sin(2 * pi * (freq * 4.75) * t) * exp(-decay * 2.5 * t);

      final val = ((s1 + s2 + s3 + s4) / 1.95) * env + click;
      samples[i] = (val * volume * 32767).toInt().clamp(-32768, 32767);
    }
    return _createWav(samples);
  }

  static Uint8List _synthFox40Whistle({
    required double freq,
    required double durationSec,
    double volume = 0.9,
  }) {
    final numSamples = (durationSec * sampleRate).toInt();
    final samples = Int16List(numSamples);

    final f1 = freq;
    final f2 = freq * 1.095;

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final progress = i / numSamples;
      double env = 1.0;
      if (progress < 0.08) env = progress / 0.08;
      if (progress > 0.85) env = (1.0 - progress) / 0.15;

      final tremolo = 0.8 + 0.2 * sin(2 * pi * 28 * t);
      final s1 = sin(2 * pi * f1 * t);
      final s2 = 0.85 * sin(2 * pi * f2 * t);
      final airNoise = (sin(2 * pi * 97 * t) * sin(2 * pi * 233 * t)) * 0.05;

      final val = (((s1 + s2) / 1.85) * tremolo + airNoise) * env;
      samples[i] = (val * volume * 32767).toInt().clamp(-32768, 32767);
    }
    return _createWav(samples);
  }

  static Uint8List _synthBarbellDrop({
    required double durationSec,
    required double startFreq,
    required double endFreq,
    double volume = 0.95,
  }) {
    final numSamples = (durationSec * sampleRate).toInt();
    final samples = Int16List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final pitchEnv = exp(-14 * t);
      final curFreq = endFreq + (startFreq - endFreq) * pitchEnv;
      final subEnv = exp(-8 * t);
      final subBass = sin(2 * pi * curFreq * t) * subEnv;

      final ironEnv = exp(-40 * t);
      final iron = (sin(2 * pi * 720 * t) + 0.6 * sin(2 * pi * 1350 * t) + 0.3 * sin(2 * pi * 2100 * t)) / 1.9 * ironEnv * 0.45;

      final val = (subBass * 0.8 + iron).clamp(-0.95, 0.95);
      samples[i] = (val * volume * 32767).toInt().clamp(-32768, 32767);
    }
    return _createWav(samples);
  }

  static Uint8List _synthCornerClapper({
    required double freq,
    required double durationSec,
    double volume = 0.95,
  }) {
    final numSamples = (durationSec * sampleRate).toInt();
    final samples = Int16List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final env = exp(-50 * t);
      final clap2 = (t > 0.006) ? exp(-60 * (t - 0.006)) * sin(2 * pi * (freq * 1.15) * (t - 0.006)) * 0.7 : 0.0;
      final wood1 = sin(2 * pi * freq * t) * env;
      final val = (wood1 + clap2).clamp(-0.95, 0.95);
      samples[i] = (val * volume * 32767).toInt().clamp(-32768, 32767);
    }
    return _createWav(samples);
  }

  static Uint8List _synthGymbossTimer({
    required double freq,
    required double durationSec,
    double volume = 0.9,
  }) {
    final numSamples = (durationSec * sampleRate).toInt();
    final samples = Int16List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final progress = i / numSamples;
      double env = 1.0;
      if (progress < 0.04) env = progress / 0.04;
      if (progress > 0.80) env = (1.0 - progress) / 0.20;

      final val = (sin(2 * pi * freq * t) + 0.15 * sin(2 * pi * (freq * 2) * t)) / 1.15;
      samples[i] = (val * volume * env * 32767).toInt().clamp(-32768, 32767);
    }
    return _createWav(samples);
  }

  static Uint8List _synthShotClockBuzzer({
    required double freq,
    required double durationSec,
    double volume = 0.95,
  }) {
    final numSamples = (durationSec * sampleRate).toInt();
    final samples = Int16List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final progress = i / numSamples;
      double env = 1.0;
      if (progress < 0.04) env = progress / 0.04;
      if (progress > 0.88) env = (1.0 - progress) / 0.12;

      final saw = 2.0 * (t * freq - (t * freq).floor()) - 1.0;
      final sub = sin(2 * pi * (freq * 0.5) * t) * 0.4;
      final high = sin(2 * pi * (freq * 2) * t) * 0.3;
      final val = ((saw + sub + high) / 1.7).clamp(-0.85, 0.85);

      samples[i] = (val * volume * env * 32767).toInt().clamp(-32768, 32767);
    }
    return _createWav(samples);
  }

  static Uint8List _synthCadenceDrum({
    required double durationSec,
    required double startFreq,
    required double endFreq,
    double volume = 0.95,
  }) {
    final numSamples = (durationSec * sampleRate).toInt();
    final samples = Int16List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final pitchEnv = exp(-18 * t);
      final curFreq = endFreq + (startFreq - endFreq) * pitchEnv;
      final ampEnv = exp(-9 * t);
      final sub = sin(2 * pi * curFreq * t);
      final val = (sub * ampEnv * 1.4).clamp(-0.95, 0.95);
      samples[i] = (val * volume * 32767).toInt().clamp(-32768, 32767);
    }
    return _createWav(samples);
  }

  static Uint8List _synthTibetanGong({
    required double freq,
    required double durationSec,
    required double decay,
    double volume = 0.9,
  }) {
    final numSamples = (durationSec * sampleRate).toInt();
    final samples = Int16List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final env = exp(-decay * t);
      final shimmer = 0.85 + 0.15 * sin(2 * pi * 3.5 * t);
      final s1 = sin(2 * pi * freq * t);
      final s2 = 0.4 * sin(2 * pi * (freq * 1.5) * t);
      final s3 = 0.2 * sin(2 * pi * (freq * 2.25) * t);
      final val = ((s1 + s2 + s3) / 1.6) * shimmer * env;
      samples[i] = (val * volume * 32767).toInt().clamp(-32768, 32767);
    }
    return _createWav(samples);
  }

  static Uint8List _synthSequence(List<_Tone> sequence) {
    int totalSamples = 0;
    for (final tone in sequence) {
      totalSamples += (tone.dur * sampleRate).toInt();
    }
    final samples = Int16List(totalSamples);
    int offset = 0;

    for (final tone in sequence) {
      final toneSamples = (tone.dur * sampleRate).toInt();
      for (int i = 0; i < toneSamples; i++) {
        final t = i / sampleRate;
        final progress = i / toneSamples;
        final env = (progress > 0.88) ? (1.0 - progress) / 0.12 : 1.0;

        double val = 0.0;
        if (tone.wave == 'buzzer') {
          final f1 = sin(2 * pi * tone.freq * t);
          final f2 = 0.7 * sin(2 * pi * (tone.freq * 2) * t);
          val = ((f1 + f2) / 1.7 * 1.4).clamp(-0.9, 0.9);
        } else if (tone.wave == 'horn') {
          val = (sin(2 * pi * tone.freq * t) + 0.8 * sin(2 * pi * (tone.freq * 1.26) * t)) / 1.8;
        } else if (tone.wave == 'bell') {
          final bellEnv = exp(-3.8 * t);
          val = (sin(2 * pi * tone.freq * t) + 0.45 * sin(2 * pi * (tone.freq * 1.98) * t)) / 1.45 * bellEnv;
        } else if (tone.wave == 'whistle') {
          val = (sin(2 * pi * tone.freq * t) + 0.8 * sin(2 * pi * (tone.freq * 1.09) * t)) / 1.8;
        } else if (tone.wave == 'drop') {
          final pEnv = exp(-14 * t);
          final cFreq = 40 + (tone.freq - 40) * pEnv;
          val = sin(2 * pi * cFreq * t) * exp(-9 * t);
        } else if (tone.wave == 'clapper') {
          val = sin(2 * pi * tone.freq * t) * exp(-45 * t);
        } else if (tone.wave == 'gymboss') {
          val = (sin(2 * pi * tone.freq * t) + 0.15 * sin(2 * pi * (tone.freq * 2) * t)) / 1.15;
        } else if (tone.wave == 'shotclock') {
          val = 2.0 * (t * tone.freq - (t * tone.freq).floor()) - 1.0;
        } else if (tone.wave == 'drum') {
          val = sin(2 * pi * tone.freq * t) * exp(-10 * t);
        } else if (tone.wave == 'gong') {
          val = sin(2 * pi * tone.freq * t) * exp(-2.5 * t);
        } else {
          val = sin(2 * pi * tone.freq * t);
        }

        samples[offset + i] = (val * tone.volume * env * 32767).toInt().clamp(-32768, 32767);
      }
      offset += toneSamples;
    }

    return _createWav(samples);
  }

  static Uint8List _createWav(Int16List rawSamples, {bool applyReverb = true}) {
    final samples = (applyReverb && rawSamples.isNotEmpty)
        ? _applyArenaReverb(rawSamples)
        : rawSamples;

    final byteCount = samples.length * 2;
    final buffer = ByteData(44 + byteCount);

    // RIFF Chunk
    _writeString(buffer, 0, 'RIFF');
    buffer.setUint32(4, 36 + byteCount, Endian.little);
    _writeString(buffer, 8, 'WAVE');

    // fmt Chunk
    _writeString(buffer, 12, 'fmt ');
    buffer.setUint32(16, 16, Endian.little); // Chunk size
    buffer.setUint16(20, 1, Endian.little);  // PCM format
    buffer.setUint16(22, 1, Endian.little);  // Mono (1 channel)
    buffer.setUint32(24, sampleRate, Endian.little);
    buffer.setUint32(28, sampleRate * 2, Endian.little); // Byte rate
    buffer.setUint16(32, 2, Endian.little);  // Block align
    buffer.setUint16(34, 16, Endian.little); // Bits per sample

    // data Chunk
    _writeString(buffer, 36, 'data');
    buffer.setUint32(40, byteCount, Endian.little);

    int byteOffset = 44;
    for (int i = 0; i < samples.length; i++) {
      buffer.setInt16(byteOffset, samples[i], Endian.little);
      byteOffset += 2;
    }

    return buffer.buffer.asUint8List();
  }

  static Int16List _applyArenaReverb(Int16List dry) {
    // Multi-tap gym & arena wall reflections (42ms, 85ms, 135ms, 210ms)
    final d1 = (sampleRate * 0.042).round();
    final d2 = (sampleRate * 0.085).round();
    final d3 = (sampleRate * 0.135).round();
    final d4 = (sampleRate * 0.210).round();

    final extraTail = (sampleRate * 0.25).round();
    final totalLen = dry.length + extraTail;
    final out = Float64List(totalLen);

    // Direct dry signal
    for (int i = 0; i < dry.length; i++) {
      out[i] += dry[i] * 0.75;
    }

    final delays = [d1, d2, d3, d4];
    final gains = [0.32, 0.22, 0.16, 0.10];

    for (int tap = 0; tap < delays.length; tap++) {
      final d = delays[tap];
      final g = gains[tap];
      for (int i = 0; i < dry.length; i++) {
        if (i + d < totalLen) {
          out[i + d] += dry[i] * g;
        }
      }
      final dSec = d * 2;
      final gSec = g * 0.38;
      for (int i = 0; i < dry.length; i++) {
        if (i + dSec < totalLen) {
          out[i + dSec] += dry[i] * gSec;
        }
      }
    }

    // Dynamic peak normalization to avoid digital clipping
    double peak = 0.0;
    for (int i = 0; i < totalLen; i++) {
      final a = out[i].abs();
      if (a > peak) peak = a;
    }

    final scale = peak > 0 ? (29000.0 / peak) : 1.0;
    final result = Int16List(totalLen);
    for (int i = 0; i < totalLen; i++) {
      result[i] = (out[i] * scale).round().clamp(-32768, 32767);
    }

    return result;
  }

  static void _writeString(ByteData data, int offset, String str) {
    for (int i = 0; i < str.length; i++) {
      data.setUint8(offset + i, str.codeUnitAt(i));
    }
  }
}

class _Tone {
  final double freq;
  final double dur;
  final String wave;
  final double volume;

  _Tone({required this.freq, required this.dur, required this.wave, this.volume = 0.5});
}
