import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.only(bottom: 24, top: 12, left: 24, right: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: onReset,
            icon: const Icon(Icons.refresh, color: Colors.white70, size: 36),
            tooltip: resetTooltip,
          ),
          IconButton(
            onPressed: onSkipPrevious,
            icon: const Icon(Icons.skip_previous, color: Colors.white70, size: 36),
            tooltip: skipTooltip,
          ),
          GestureDetector(
            onTap: onPlayPause,
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor,
                boxShadow: [
                  BoxShadow(color: primaryColor.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 2),
                ],
              ),
              child: Icon(
                isRunning ? Icons.pause : Icons.play_arrow,
                color: Colors.black,
                size: 46,
              ),
            ),
          ),
          IconButton(
            onPressed: onSkipNext,
            icon: const Icon(Icons.skip_next, color: Colors.white70, size: 36),
            tooltip: nextTooltip,
          ),
          IconButton(
            onPressed: onExit,
            icon: const Icon(Icons.stop_circle_outlined, color: Colors.white70, size: 36),
            tooltip: quitTooltip,
          ),
        ],
      ),
    );
  }
}
