import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mytimer/models/custom_routine.dart';
import 'package:mytimer/models/interval_step.dart';
import 'package:mytimer/models/timer_phase.dart';
import 'package:mytimer/shared/utils/home_timer_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Home Folder Setup & Reset Layout Tests', () {
    test('Default setup order is Tabata, EMOM, AMRAP, For Time, CrossFit, Hyrox', () {
      expect(
        HomeTimerHelper.defaultFolderOrder,
        equals(['tabata', 'emom', 'amrap', 'for_time', 'crossfit', 'hyrox']),
      );
    });

    test('CrossFit default folder contains top 5 popular WODs', () {
      final crossfitItems = HomeTimerHelper.getDefaultItemsForFolder('crossfit');
      expect(crossfitItems.length, equals(5));
      expect(
        crossfitItems,
        equals([
          'preset:wod_fran',
          'preset:wod_cindy',
          'preset:wod_grace',
          'preset:wod_helen',
          'preset:wod_murph',
        ]),
      );
    });

    test('Hyrox default folder contains all Hyrox presets and hub launcher', () {
      final hyroxItems = HomeTimerHelper.getDefaultItemsForFolder('hyrox');
      expect(hyroxItems.length, equals(5));
      expect(
        hyroxItems,
        equals([
          'hyrox',
          'preset:hyrox_half_sim',
          'preset:hyrox_compromised_4x1k',
          'preset:hyrox_station_pemom',
          'preset:hyrox_wallball_test',
        ]),
      );
    });

    test('getFolderOrder returns default 6 folders on initial setup', () async {
      final order = await HomeTimerHelper.getFolderOrder();
      expect(
        order,
        equals(['tabata', 'emom', 'amrap', 'for_time', 'crossfit', 'hyrox']),
      );
    });

    test('resetToDefaultLayout restores default order and includes custom timers', () async {
      // Modify order first
      await HomeTimerHelper.saveFolderOrder(['rounds', 'stopwatch']);

      final customRoutines = [
        CustomRoutine(
          id: 'custom_crossfit_wod_1',
          name: 'Custom Fight Gone Bad',
          category: 'CrossFit WOD',
          isPreset: false,
          intervals: const [
            IntervalStep(id: 's1', name: 'Work', durationSeconds: 60, phase: TimerPhase.work),
          ],
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
        CustomRoutine(
          id: 'custom_tabata_core',
          name: 'Custom Core Tabata',
          category: 'Tabata',
          isPreset: false,
          intervals: const [
            IntervalStep(id: 's2', name: 'Work', durationSeconds: 20, phase: TimerPhase.work),
          ],
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ];

      final restoredOrder = await HomeTimerHelper.resetToDefaultLayout(routines: customRoutines);

      expect(
        restoredOrder,
        equals(['tabata', 'emom', 'amrap', 'for_time', 'crossfit', 'hyrox']),
      );

      // Verify crossfit folder has 5 default WODs + the custom WOD
      final crossfitFolderItems = await HomeTimerHelper.getFolderItems('crossfit', routines: customRoutines);
      expect(crossfitFolderItems.contains('preset:wod_fran'), isTrue);
      expect(crossfitFolderItems.contains('preset:wod_cindy'), isTrue);
      expect(crossfitFolderItems.contains('preset:wod_grace'), isTrue);
      expect(crossfitFolderItems.contains('preset:wod_helen'), isTrue);
      expect(crossfitFolderItems.contains('preset:wod_murph'), isTrue);
      expect(crossfitFolderItems.contains('preset:custom_crossfit_wod_1'), isTrue);

      // Verify tabata folder has its default presets + the custom tabata
      final tabataFolderItems = await HomeTimerHelper.getFolderItems('tabata', routines: customRoutines);
      expect(tabataFolderItems.contains('preset:preset_tabata_standard'), isTrue);
      expect(tabataFolderItems.contains('preset:preset_tabata_sprint'), isTrue);
      expect(tabataFolderItems.contains('preset:custom_tabata_core'), isTrue);
    });
  });
}
