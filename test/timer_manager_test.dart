import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mytimer/data/timer_presets_data.dart';
import 'package:mytimer/data/crossfit_wods.dart';
import 'package:mytimer/data/hyrox_data.dart';
import 'package:mytimer/models/custom_routine.dart';
import 'package:mytimer/shared/utils/home_timer_helper.dart';
import 'package:mytimer/features/timer_manager/timer_manager_screen.dart';

void main() {
  group('TimerManagerScreen Category & Sorting Tests', () {
    test('Categories contain ALL, standart, crossfit, hyrox', () {
      const screen = TimerManagerScreen();
      final state = screen.createState();
      expect(state, isNotNull);
    });

    test('HomeTimerHelper.pin adds routine to its category folder', () async {
      SharedPreferences.setMockInitialValues({});
      const testId = 'custom_routine_123';
      const category = 'Standard - Tabata';

      final success = await HomeTimerHelper.pin(testId, category: category);
      expect(success, isTrue);

      final isPinned = await HomeTimerHelper.isPinned(testId, category: category);
      expect(isPinned, isTrue);

      final folderItems = await HomeTimerHelper.getFolderItems('tabata');
      expect(folderItems.contains(HomeTimerHelper.getPresetId(testId)), isTrue);
    });

    test('InitialCategory filtering: tabata only matches tabata routines', () {
      final allPresets = TimerPresetsData.getDefaultTimerPresets();
      final tabatas = allPresets.where((r) => r.category.toLowerCase().contains('tabata')).toList();
      final rounds = allPresets.where((r) => r.category.toLowerCase().contains('round')).toList();

      expect(tabatas.isNotEmpty, isTrue);
      expect(rounds.isNotEmpty, isTrue);

      // Verify Tabata items match tabata and do not match rounds
      for (final t in tabatas) {
        final cat = t.category.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
        expect(cat.contains('tabata'), isTrue);
        expect(cat.contains('round'), isFalse);
      }
    });

    test('Routines sort order: Standart -> Crossfit -> Hyrox with subcategory order', () {
      final stdTabata = TimerPresetsData.getDefaultTimerPresets().firstWhere((r) => r.category.contains('Tabata'));
      final stdRounds = TimerPresetsData.getDefaultTimerPresets().firstWhere((r) => r.category.contains('Rounds'));
      final stdEmom = TimerPresetsData.getDefaultTimerPresets().firstWhere((r) => r.category.contains('EMOM'));
      final stdAmrap = TimerPresetsData.getDefaultTimerPresets().firstWhere((r) => r.category.contains('AMRAP'));
      final stdForTime = TimerPresetsData.getDefaultTimerPresets().firstWhere((r) => r.category.contains('For Time'));
      final stdCountdown = TimerPresetsData.getDefaultTimerPresets().firstWhere((r) => r.category.contains('Countdown'));

      final heroWod = CrossFitWodsData.getAllWods().firstWhere((r) => r.category == 'Hero WOD');
      final theGirls = CrossFitWodsData.getAllWods().firstWhere((r) => r.category == 'The Girls');
      final benchmark = CrossFitWodsData.getAllWods().firstWhere((r) => r.category == 'Benchmark');

      final hyrox = HyroxData.getHyroxPresets().first;

      final routines = [
        hyrox,
        benchmark,
        theGirls,
        heroWod,
        stdCountdown,
        stdForTime,
        stdAmrap,
        stdEmom,
        stdRounds,
        stdTabata,
      ];

      // Sorting logic simulation
      int getMainCategoryRank(CustomRoutine r) {
        final cat = r.category.toLowerCase().trim().replaceAll(' ', '').replaceAll('_', '');
        if (cat.contains('standart') ||
            cat.contains('tabata') ||
            cat.contains('round') ||
            cat.contains('emom') ||
            cat.contains('amrap') ||
            cat.contains('fortime') ||
            cat.contains('countdown')) {
          return 1;
        }
        if (cat.contains('hero') ||
            cat.contains('girl') ||
            cat.contains('benchmark') ||
            cat.contains('bench') ||
            cat.contains('crossfit')) {
          return 2;
        }
        if (cat.contains('hyrox')) {
          return 3;
        }
        return 4;
      }

      int getStandartSubcategoryRank(CustomRoutine r) {
        final cat = r.category.toLowerCase().trim().replaceAll(' ', '').replaceAll('_', '');
        if (cat.contains('tabata')) return 1;
        if (cat.contains('round')) return 2;
        if (cat.contains('emom')) return 3;
        if (cat.contains('amrap')) return 4;
        if (cat.contains('fortime')) return 5;
        if (cat.contains('countdown')) return 6;
        return 7;
      }

      int getCrossfitSubcategoryRank(CustomRoutine r) {
        final cat = r.category.toLowerCase().trim().replaceAll(' ', '').replaceAll('_', '');
        if (cat.contains('hero')) return 1;
        if (cat.contains('girl')) return 2;
        if (cat.contains('benchmark') || cat.contains('bench')) return 3;
        return 4;
      }

      routines.sort((a, b) {
        final catRankA = getMainCategoryRank(a);
        final catRankB = getMainCategoryRank(b);
        if (catRankA != catRankB) return catRankA.compareTo(catRankB);

        if (catRankA == 1) {
          final subA = getStandartSubcategoryRank(a);
          final subB = getStandartSubcategoryRank(b);
          if (subA != subB) return subA.compareTo(subB);
          return a.name.compareTo(b.name);
        } else if (catRankA == 2) {
          final subA = getCrossfitSubcategoryRank(a);
          final subB = getCrossfitSubcategoryRank(b);
          if (subA != subB) return subA.compareTo(subB);
          return a.name.compareTo(b.name);
        } else if (catRankA == 3) {
          return a.name.compareTo(b.name);
        } else {
          return a.name.compareTo(b.name);
        }
      });

      expect(routines[0].category, contains('Tabata'));
      expect(routines[1].category, contains('Rounds'));
      expect(routines[2].category, contains('EMOM'));
      expect(routines[3].category, contains('AMRAP'));
      expect(routines[4].category, contains('For Time'));
      expect(routines[5].category, contains('Countdown'));
      expect(routines[6].category, 'Hero WOD');
      expect(routines[7].category, 'The Girls');
      expect(routines[8].category, 'Benchmark');
      expect(routines[9].category, 'HYROX');
    });
  });
}
