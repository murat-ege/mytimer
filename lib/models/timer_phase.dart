import 'package:flutter/material.dart';

enum TimerPhase {
  prep,
  work,
  rest,
  restBetweenSets,
  cooldown,
  finished,
}

extension TimerPhaseExtension on TimerPhase {
  String get displayName {
    switch (this) {
      case TimerPhase.prep:
        return 'PREP';
      case TimerPhase.work:
        return 'WORK';
      case TimerPhase.rest:
        return 'REST';
      case TimerPhase.restBetweenSets:
        return 'SET REST';
      case TimerPhase.cooldown:
        return 'COOLDOWN';
      case TimerPhase.finished:
        return 'FINISHED';
    }
  }

  Color get primaryColor {
    switch (this) {
      case TimerPhase.prep:
        return const Color(0xFFFFB300); // Vivid Amber
      case TimerPhase.work:
        return const Color(0xFF00E676); // High Voltage Athletic Green
      case TimerPhase.rest:
      case TimerPhase.restBetweenSets:
        return const Color(0xFFFF2A42); // Vivid High-Impact Athletic Red
      case TimerPhase.cooldown:
        return const Color(0xFF00E5FF); // Bright Cyan
      case TimerPhase.finished:
        return const Color(0xFF9D65FF); // Victory Purple
    }
  }

  Color get backgroundColor {
    switch (this) {
      case TimerPhase.prep:
        return const Color(0xFF281900); // Recognizable Dark Amber
      case TimerPhase.work:
        return const Color(0xFF052B16); // Recognizable Athletic Emerald Green
      case TimerPhase.rest:
      case TimerPhase.restBetweenSets:
        return const Color(0xFF33080C); // Recognizable Athletic Crimson Red
      case TimerPhase.cooldown:
        return const Color(0xFF00222B); // Dark Cyan
      case TimerPhase.finished:
        return const Color(0xFF1A0A33); // Dark Violet
    }
  }
}
