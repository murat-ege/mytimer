import 'package:flutter_test/flutter_test.dart';
import 'package:mytimer/controllers/stopwatch_controller.dart';
import 'package:mytimer/controllers/workout_controller.dart';
import 'package:mytimer/models/custom_routine.dart';
import 'package:mytimer/models/timer_phase.dart';
import 'package:mytimer/services/sound_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkoutController Tests', () {
    test('Tabata workout calculates segments accurately', () {
      final tabata = CustomRoutine.tabata(
        workSeconds: 20,
        restSeconds: 10,
        rounds: 8,
        prepSeconds: 10,
      );

      final controller = WorkoutController(routine: tabata);

      // Prep (10s) + 8 * (20s + 10s) = 10 + 240 = 250s
      expect(controller.totalWorkoutSeconds, 250);
      expect(controller.totalRounds, 8);
      expect(controller.currentPhase, TimerPhase.prep);
      expect(controller.secondsRemaining, 10);
    });

    test('Skip next transitions to next interval', () {
      final tabata = CustomRoutine.tabata(
        workSeconds: 20,
        restSeconds: 10,
        rounds: 2,
        prepSeconds: 5,
      );

      final controller = WorkoutController(routine: tabata);
      expect(controller.currentPhase, TimerPhase.prep);

      controller.skipNext(); // Jump to round 1 work
      expect(controller.currentPhase, TimerPhase.work);
      expect(controller.secondsRemaining, 20);

      controller.skipNext(); // Jump to round 1 rest
      expect(controller.currentPhase, TimerPhase.rest);
      expect(controller.secondsRemaining, 10);
    });
  });

  group('StopwatchController Tests', () {
    test('Records lap splits correctly', () {
      final stopwatch = StopwatchController();
      expect(stopwatch.laps.isEmpty, true);

      stopwatch.start();
      stopwatch.recordLap();
      expect(stopwatch.laps.length, 1);
      expect(stopwatch.laps.first.lapNumber, 1);

      stopwatch.reset();
      expect(stopwatch.laps.isEmpty, true);
      expect(stopwatch.isRunning, false);
    });

    test('Formats ms accurately', () {
      expect(StopwatchController.formatMs(65120), '01:05.12');
      expect(StopwatchController.formatMs(65120, showMs: false), '01:05');
    });
  });

  group('SoundService & Splash Tests', () {
    test('SoundService initializes with ducking AudioContext', () async {
      final soundService = SoundService();
      await soundService.init();
      expect(soundService.soundEnabled, true);
    });
  });
}
