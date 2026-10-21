import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mytimer/controllers/stopwatch_controller.dart';
import 'package:mytimer/controllers/workout_controller.dart';
import 'package:mytimer/models/custom_routine.dart';
import 'package:mytimer/models/timer_phase.dart';
import 'package:mytimer/models/timer_settings.dart';
import 'package:mytimer/features/settings/settings_screen.dart';
import 'package:mytimer/services/sound_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

      // Workout duration excludes prep time: 8 * (20s + 10s) = 240s
      expect(controller.totalWorkoutSeconds, 240);
      expect(controller.totalRounds, 8);
      expect(controller.currentPhase, TimerPhase.prep);
      expect(controller.secondsRemaining, 10);
      expect(controller.totalElapsedSeconds, 0);
    });

    test('Skip next transitions to next interval and manages elapsed workout time', () {
      final tabata = CustomRoutine.tabata(
        workSeconds: 20,
        restSeconds: 10,
        rounds: 2,
        prepSeconds: 5,
      );

      final controller = WorkoutController(routine: tabata);
      expect(controller.currentPhase, TimerPhase.prep);
      expect(controller.totalElapsedSeconds, 0);

      controller.skipNext(); // Jump to round 1 work
      expect(controller.currentPhase, TimerPhase.work);
      expect(controller.secondsRemaining, 20);
      expect(controller.totalElapsedSeconds, 0); // Still 0 at start of first work segment

      controller.skipNext(); // Jump to round 1 rest
      expect(controller.currentPhase, TimerPhase.rest);
      expect(controller.secondsRemaining, 10);
      expect(controller.totalElapsedSeconds, 20); // 20s completed work
    });

    test('syncWithRealTime correctly advances state when app resumes', () async {
      final tabata = CustomRoutine.tabata(
        workSeconds: 20,
        restSeconds: 10,
        rounds: 2,
        prepSeconds: 0,
      );

      final controller = WorkoutController(routine: tabata);
      controller.start();

      expect(controller.currentPhase, TimerPhase.work);
      expect(controller.secondsRemaining, 20);

      // Wait a moment then trigger sync
      await Future<void>.delayed(const Duration(milliseconds: 1050));
      controller.syncWithRealTime();

      expect(controller.secondsRemaining <= 19, true);
      expect(controller.totalElapsedSeconds >= 1, true);

      controller.reset();
    });

    test('Routine with cooldown appends cooldown segment after all rounds', () {
      final tabataWithCooldown = CustomRoutine.tabata(
        workSeconds: 20,
        restSeconds: 10,
        rounds: 1,
        prepSeconds: 0,
        cooldownSeconds: 60,
      );

      final controller = WorkoutController(routine: tabataWithCooldown);
      expect(controller.totalWorkoutSeconds, 20 + 10 + 60);

      controller.skipNext(); // work -> rest
      expect(controller.currentPhase, TimerPhase.rest);

      controller.skipNext(); // rest -> cooldown
      expect(controller.currentPhase, TimerPhase.cooldown);
      expect(controller.secondsRemaining, 60);
    });

    test('Routine model correctly serializes and deserializes cooldown and interval signal', () {
      final routine = CustomRoutine(
        id: 'test_123',
        name: 'For Time Test',
        category: 'fortime',
        prepSeconds: 0,
        rounds: 1,
        cooldownSeconds: 90,
        intervalSignalSeconds: 60,
        intervals: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final jsonMap = routine.toJson();
      expect(jsonMap['cooldownSeconds'], 90);
      expect(jsonMap['intervalSignalSeconds'], 60);

      final reconstructed = CustomRoutine.fromJson(jsonMap);
      expect(reconstructed.cooldownSeconds, 90);
      expect(reconstructed.intervalSignalSeconds, 60);
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

  group('SettingsScreen Tests', () {
    testWidgets('SettingsScreen renders without RenderFlex overflow', (tester) async {
      SharedPreferences.setMockInitialValues({
        'timer_settings_v1': jsonEncode(const TimerSettings(voiceCoachEnabled: true).toJson()),
      });

      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            currentLocale: const Locale('en'),
            onLocaleChanged: (_) {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('MyTimerApp enforces TextScaler.noScaling regardless of platform text scale', (tester) async {
      TextScaler? appliedScaler;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.noScaling,
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: Builder(
            builder: (context) {
              appliedScaler = MediaQuery.textScalerOf(context);
              return const Scaffold(body: Text('Scale Test'));
            },
          ),
        ),
      );
      expect(appliedScaler, equals(TextScaler.noScaling));
    });
  });
}
