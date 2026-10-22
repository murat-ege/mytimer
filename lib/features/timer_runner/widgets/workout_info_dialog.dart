import 'package:flutter/material.dart';

import '../../../models/custom_routine.dart';

class WorkoutInfoDialog extends StatelessWidget {
  final CustomRoutine routine;

  const WorkoutInfoDialog({super.key, required this.routine});

  static void show(BuildContext context, CustomRoutine routine) {
    showDialog(
      context: context,
      builder: (ctx) => WorkoutInfoDialog(routine: routine),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: Text(
        routine.name.toUpperCase(),
        style: const TextStyle(color: Color(0xFF00E676)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (routine.description.isNotEmpty) ...[
            Text(
              routine.description,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            'Rounds: ${routine.rounds}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Intervals per round:',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 4),
          ...routine.intervals.map(
            (i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '• ${i.name}: ${i.durationSeconds}s',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK', style: TextStyle(color: Color(0xFF00E676))),
        ),
      ],
    );
  }
}
