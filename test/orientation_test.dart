import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mytimer/l10n/generated/app_localizations.dart';
import 'package:mytimer/models/custom_routine.dart';
import 'package:mytimer/features/timer_runner/timer_runner_screen.dart';

void main() {
  testWidgets('TimerRunnerScreen orientation toggle test', (tester) async {
    final routine = CustomRoutine.tabata(
      workSeconds: 20,
      restSeconds: 10,
      rounds: 8,
      prepSeconds: 5,
    );

    // Set initial size to mobile portrait
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TimerRunnerScreen(routine: routine),
      ),
    );

    await tester.pumpAndSettle();

    // In portrait, find the lock portrait button
    final orientationBtn = find.byIcon(Icons.screen_lock_portrait);
    expect(orientationBtn, findsOneWidget);

    // Tap to toggle to landscape
    await tester.tap(orientationBtn);
    await tester.pump();

    // Set physical size to landscape dimensions (800x360)
    tester.view.physicalSize = const Size(800, 360);
    await tester.pumpAndSettle();

    // In landscape, verify lock landscape icon is present and no overflow
    final landscapeBtn = find.byIcon(Icons.screen_lock_landscape);
    expect(landscapeBtn, findsOneWidget);

    // Tap to toggle back to portrait
    await tester.tap(landscapeBtn);
    await tester.pump();

    tester.view.physicalSize = const Size(360, 800);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.screen_lock_portrait), findsOneWidget);
  });
}
