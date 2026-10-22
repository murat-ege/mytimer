import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../services/sound_service.dart';
import '../../../services/voice_coach_service.dart';

class TimerUtilityControls extends StatefulWidget {
  final Color primaryColor;
  final bool isLandscape;
  final VoidCallback onToggleOrientation;

  const TimerUtilityControls({
    super.key,
    required this.primaryColor,
    this.isLandscape = false,
    required this.onToggleOrientation,
  });

  @override
  State<TimerUtilityControls> createState() => _TimerUtilityControlsState();
}

class _TimerUtilityControlsState extends State<TimerUtilityControls> {
  final SoundService _soundService = SoundService();
  final VoiceCoachService _voiceCoach = VoiceCoachService();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primaryColor = widget.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Audio beeps toggle
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                setState(() {
                  _soundService.soundEnabled = !_soundService.soundEnabled;
                });
                HapticFeedback.lightImpact();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: _soundService.soundEnabled
                      ? primaryColor.withValues(alpha: 0.20)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _soundService.soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                      color: _soundService.soundEnabled ? primaryColor : Colors.white38,
                      size: 19,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n?.audioCapsule ?? 'AUDIO',
                      style: TextStyle(
                        color: _soundService.soundEnabled ? primaryColor : Colors.white38,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 2),
          // Voice coach toggle
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                setState(() {
                  _voiceCoach.voiceEnabled = !_voiceCoach.voiceEnabled;
                });
                HapticFeedback.lightImpact();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: _voiceCoach.voiceEnabled
                      ? primaryColor.withValues(alpha: 0.20)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _voiceCoach.voiceEnabled ? Icons.record_voice_over_rounded : Icons.voice_over_off_rounded,
                      color: _voiceCoach.voiceEnabled ? primaryColor : Colors.white38,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n?.coachCapsule ?? 'COACH',
                      style: TextStyle(
                        color: _voiceCoach.voiceEnabled ? primaryColor : Colors.white38,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 2),
          // Screen orientation toggle
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                widget.onToggleOrientation();
                HapticFeedback.lightImpact();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Icon(
                  widget.isLandscape ? Icons.screen_lock_landscape_rounded : Icons.screen_lock_portrait_rounded,
                  color: Colors.white70,
                  size: 19,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
