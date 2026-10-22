import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'audio_theme_generator.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  bool soundEnabled = true;
  bool vibrationEnabled = true;
  String currentThemeId = 'classic_beeps';

  static final AudioContext _audioContext = AudioContext(
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: {
        AVAudioSessionOptions.mixWithOthers,
      },
    ),
    android: AudioContextAndroid(
      isSpeakerphoneOn: false,
      stayAwake: true,
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.assistanceSonification,
      audioFocus: AndroidAudioFocus.none,
    ),
  );

  static const int _poolSize = 3;
  final List<AudioPlayer> _playerPool = [];
  int _poolIndex = 0;

  AudioPlayer _getPlayer() {
    if (_playerPool.length < _poolSize) {
      final p = AudioPlayer();
      // ignore: invalid_use_of_visible_for_testing_member
      p.creatingCompleter.future.catchError((_) {});
      p.setAudioContext(_audioContext).catchError((_) {});
      p.setReleaseMode(ReleaseMode.stop).catchError((_) {});
      p.setPlayerMode(PlayerMode.lowLatency).catchError((_) {});
      _playerPool.add(p);
      return p;
    }
    final player = _playerPool[_poolIndex % _poolSize];
    _poolIndex++;
    return player;
  }

  final Map<String, String> _soundFileCache = {};
  String? _cachedTempDirPath;

  Future<void> init() async {
    try {
      await AudioPlayer.global.setAudioContext(_audioContext);
      for (int i = 0; i < _poolSize; i++) {
        _getPlayer();
      }
      unawaited(_prewarmSounds());
    } catch (_) {}
  }

  Future<void> _prewarmSounds() async {
    for (final type in SoundType.values) {
      await _getSoundFilePath(currentThemeId, type);
    }
  }

  Future<String?> _getSoundFilePath(String themeId, SoundType type) async {
    final key = '${themeId}_${type.name}';
    final cached = _soundFileCache[key];
    if (cached != null) {
      return cached;
    }
    try {
      _cachedTempDirPath ??= (await getTemporaryDirectory()).path;
      final soundDir = Directory('$_cachedTempDirPath/sound_cache_v8');
      if (!await soundDir.exists()) {
        await soundDir.create(recursive: true);
      }
      final file = File('${soundDir.path}/$key.wav');
      if (!await file.exists()) {
        final bytes = AudioThemeGenerator.getSoundBytes(themeId, type);
        await file.writeAsBytes(bytes, flush: true);
      }
      _soundFileCache[key] = file.path;
      return file.path;
    } catch (_) {
      return null;
    }
  }

  Future<void> _playSound(String themeId, SoundType type) async {
    try {
      final player = _getPlayer();
      final path = await _getSoundFilePath(themeId, type);
      if (path != null) {
        await player.play(
          DeviceFileSource(path, mimeType: 'audio/wav'),
          mode: PlayerMode.lowLatency,
          volume: 0.75,
        );
      } else {
        final bytes = AudioThemeGenerator.getSoundBytes(themeId, type);
        await player.play(
          BytesSource(bytes, mimeType: 'audio/wav'),
          mode: PlayerMode.lowLatency,
          volume: 0.75,
        );
      }
    } catch (_) {
      // Audio playback failed (e.g. headless test environment), continue
    }
  }

  Future<void> playCountdownBeep([String? overrideThemeId]) async {
    if (vibrationEnabled) {
      try {
        HapticFeedback.mediumImpact();
      } catch (_) {}
    }
    if (!soundEnabled) return;
    final theme = overrideThemeId ?? currentThemeId;
    await _playSound(theme, SoundType.countdown);
  }

  Future<void> playWorkBeep([String? overrideThemeId]) async {
    if (vibrationEnabled) {
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
    }
    if (!soundEnabled) return;
    final theme = overrideThemeId ?? currentThemeId;
    await _playSound(theme, SoundType.work);
  }

  Future<void> playRestBeep([String? overrideThemeId]) async {
    if (vibrationEnabled) {
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
    }
    if (!soundEnabled) return;
    final theme = overrideThemeId ?? currentThemeId;
    await _playSound(theme, SoundType.rest);
  }

  Future<void> playCompleteFanfare([String? overrideThemeId]) async {
    if (vibrationEnabled) {
      try {
        HapticFeedback.vibrate();
      } catch (_) {}
    }
    if (!soundEnabled) return;
    final theme = overrideThemeId ?? currentThemeId;
    await _playSound(theme, SoundType.complete);
  }

  int _previewToken = 0;
  final ValueNotifier<bool> isPlayingPreviewNotifier = ValueNotifier<bool>(false);

  void stopPreview() {
    _previewToken++;
    isPlayingPreviewNotifier.value = false;
  }

  /// Preview a theme with a full 4-second sequence: 3, 2, 1 countdown followed by GO.
  Future<void> previewTheme(String themeId) async {
    final token = ++_previewToken;
    isPlayingPreviewNotifier.value = true;

    try {
      // 0.0s: "3"
      if (vibrationEnabled) {
        try {
          HapticFeedback.mediumImpact();
        } catch (_) {}
      }
      await _playSound(themeId, SoundType.countdown);
      await Future.delayed(const Duration(milliseconds: 1000));
      if (token != _previewToken) return;

      // 1.0s: "2"
      if (vibrationEnabled) {
        try {
          HapticFeedback.mediumImpact();
        } catch (_) {}
      }
      await _playSound(themeId, SoundType.countdown);
      await Future.delayed(const Duration(milliseconds: 1000));
      if (token != _previewToken) return;

      // 2.0s: "1"
      if (vibrationEnabled) {
        try {
          HapticFeedback.mediumImpact();
        } catch (_) {}
      }
      await _playSound(themeId, SoundType.countdown);
      await Future.delayed(const Duration(milliseconds: 1000));
      if (token != _previewToken) return;

      // 3.0s: "GO"
      if (vibrationEnabled) {
        try {
          HapticFeedback.heavyImpact();
        } catch (_) {}
      }
      await _playSound(themeId, SoundType.work);
      await Future.delayed(const Duration(milliseconds: 1000));
    } finally {
      if (token == _previewToken) {
        isPlayingPreviewNotifier.value = false;
      }
    }
  }

  AudioPlayer? _silentPlayer;

  Future<void> startBackgroundKeepAlive() async {
    try {
      if (_silentPlayer == null) {
        _silentPlayer = AudioPlayer();
        // ignore: invalid_use_of_visible_for_testing_member
        _silentPlayer!.creatingCompleter.future.catchError((_) {});
        await _silentPlayer!.setAudioContext(_audioContext).catchError((_) {});
        await _silentPlayer!.setReleaseMode(ReleaseMode.loop).catchError((_) {});
      }
      if (_silentPlayer!.state != PlayerState.playing) {
        await _silentPlayer!.play(AssetSource('sounds/silent.wav'), volume: 0.01).catchError((_) {});
      }
    } catch (_) {}
  }

  Future<void> stopBackgroundKeepAlive() async {
    try {
      await _silentPlayer?.stop();
    } catch (_) {}
  }

  void dispose() {
    stopPreview();
    isPlayingPreviewNotifier.dispose();
    for (final p in _playerPool) {
      p.dispose();
    }
    _playerPool.clear();
    _silentPlayer?.dispose();
  }
}
