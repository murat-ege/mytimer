import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimerRunnerControls extends StatelessWidget {
  final bool isRunning;
  final Color primaryColor;
  final VoidCallback onPlayPause;
  final VoidCallback onReset;
  final VoidCallback onSkipPrevious;
  final VoidCallback onSkipNext;
  final VoidCallback onExit;
  final String resetTooltip;
  final String skipTooltip;
  final String nextTooltip;
  final String quitTooltip;

  const TimerRunnerControls({
    super.key,
    required this.isRunning,
    required this.primaryColor,
    required this.onPlayPause,
    required this.onReset,
    required this.onSkipPrevious,
    required this.onSkipNext,
    required this.onExit,
    this.resetTooltip = 'RESET',
    this.skipTooltip = 'PREVIOUS',
    this.nextTooltip = 'NEXT',
    this.quitTooltip = 'QUIT',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 24, top: 10, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              onReset();
            },
            icon: const Icon(Icons.replay_rounded, color: Colors.white70, size: 32),
            tooltip: resetTooltip,
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              onSkipPrevious();
            },
            icon: const Icon(Icons.skip_previous_rounded, color: Colors.white70, size: 34),
            tooltip: skipTooltip,
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              onPlayPause();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: isRunning ? 0.60 : 0.35),
                    blurRadius: isRunning ? 26 : 16,
                    spreadRadius: isRunning ? 3 : 1,
                  ),
                ],
              ),
              child: Icon(
                isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.black,
                size: 50,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              onSkipNext();
            },
            icon: const Icon(Icons.skip_next_rounded, color: Colors.white70, size: 34),
            tooltip: nextTooltip,
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              onExit();
            },
            icon: const Icon(Icons.stop_circle_rounded, color: Colors.white70, size: 34),
            tooltip: quitTooltip,
          ),
        ],
      ),
    );
  }
}
