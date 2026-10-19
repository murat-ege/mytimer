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
        return const Color(0xFF00E676); // High Voltage Green
      case TimerPhase.rest:
      case TimerPhase.restBetweenSets:
        return const Color(0xFFFF3D00); // Vivid Deep Orange/Red
      case TimerPhase.cooldown:
        return const Color(0xFF00E5FF); // Bright Cyan
      case TimerPhase.finished:
        return const Color(0xFF7C4DFF); // Deep Purple / Gold
    }
  }

  Color get backgroundColor {
    switch (this) {
      case TimerPhase.prep:
        return const Color(0xFF1E1700);
      case TimerPhase.work:
        return const Color(0xFF021B0E);
      case TimerPhase.rest:
      case TimerPhase.restBetweenSets:
        return const Color(0xFF240700);
      case TimerPhase.cooldown:
        return const Color(0xFF001920);
      case TimerPhase.finished:
        return const Color(0xFF150A2E);
    }
  }
}
