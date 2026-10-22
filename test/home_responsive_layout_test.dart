import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mytimer/l10n/generated/app_localizations.dart';
import 'package:mytimer/features/home/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildHomeScreen() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomeScreen(
        currentLocale: const Locale('tr'),
        onLocaleChanged: (_) {},
      ),
    );
  }

  testWidgets('HomeScreen renders 2 columns on phone portrait', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildHomeScreen());
    await tester.pumpAndSettle();

    final gridFinder = find.byType(GridView);
    expect(gridFinder, findsOneWidget);

    final gridView = tester.widget<GridView>(gridFinder);
    final delegate =
        gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

    expect(delegate.crossAxisCount, equals(2));
    expect(delegate.childAspectRatio, greaterThan(1.0));
  });

  testWidgets('HomeScreen increases columns to 4 on modern phone landscape',
      (tester) async {
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildHomeScreen());
    await tester.pumpAndSettle();

    final gridFinder = find.byType(GridView);
    expect(gridFinder, findsOneWidget);

    final gridView = tester.widget<GridView>(gridFinder);
    final delegate =
        gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

    expect(delegate.crossAxisCount, equals(4));
    expect(delegate.childAspectRatio, greaterThanOrEqualTo(1.4));
  });

  testWidgets('HomeScreen sets 3 columns on compact landscape', (tester) async {
    tester.view.physicalSize = const Size(600, 350);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildHomeScreen());
    await tester.pumpAndSettle();

    final gridFinder = find.byType(GridView);
    expect(gridFinder, findsOneWidget);

    final gridView = tester.widget<GridView>(gridFinder);
    final delegate =
        gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

    expect(delegate.crossAxisCount, equals(3));
  });

  testWidgets('HomeScreen adapts to tablet portrait and landscape',
      (tester) async {
    // Tablet portrait
    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildHomeScreen());
    await tester.pumpAndSettle();

    GridView gridView = tester.widget<GridView>(find.byType(GridView));
    SliverGridDelegateWithFixedCrossAxisCount delegate =
        gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, equals(3));

    // Rotate to tablet landscape
    tester.view.physicalSize = const Size(1024, 768);
    await tester.pumpAndSettle();

    gridView = tester.widget<GridView>(find.byType(GridView));
    delegate =
        gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, equals(4));
  });
}
