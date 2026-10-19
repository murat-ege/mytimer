import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  AudioPlayer? _player;
  bool soundEnabled = true;
  bool vibrationEnabled = true;

  AudioPlayer get _audioPlayer {
    _player ??= AudioPlayer();
    return _player!;
  }

  Future<void> init() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    } catch (_) {}
  }

  Future<void> _safePlay(String assetPath) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(assetPath), volume: 1.0);
    } catch (_) {
      // Audio playback failed (e.g. test environment or device error), silently continue
    }
  }

  Future<void> playCountdownBeep() async {
    if (vibrationEnabled) {
      try {
        HapticFeedback.mediumImpact();
      } catch (_) {}
    }
    if (!soundEnabled) return;
    await _safePlay('sounds/beep_countdown.wav');
  }

  Future<void> playWorkBeep() async {
    if (vibrationEnabled) {
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
    }
    if (!soundEnabled) return;
    await _safePlay('sounds/beep_work.wav');
  }

  Future<void> playRestBeep() async {
    if (vibrationEnabled) {
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
    }
    if (!soundEnabled) return;
    await _safePlay('sounds/beep_rest.wav');
  }

  Future<void> playCompleteFanfare() async {
    if (vibrationEnabled) {
      try {
        HapticFeedback.vibrate();
      } catch (_) {}
    }
    if (!soundEnabled) return;
    await _safePlay('sounds/beep_complete.wav');
  }

  void dispose() {
    _player?.dispose();
  }
}
