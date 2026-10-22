import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/crossfit_wods.dart';
import '../../data/hyrox_data.dart';
import '../../data/timer_presets_data.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/custom_routine.dart';
import '../../features/hyrox/hyrox_home_screen.dart';
import '../../features/stopwatch/stopwatch_screen.dart';
import '../../features/timer_manager/timer_manager_screen.dart';
import '../../features/timer_runner/timer_runner_screen.dart';
import '../../repositories/local_timer_repository.dart';

/// Data payload for Drag & Drop reordering of items inside folders
class FolderItemDragData {
  final String folderId;
  final String itemId;

  const FolderItemDragData({
    required this.folderId,
    required this.itemId,
  });
}

/// Resolved visual & operational representation of an icon item inside a folder
class HomeFolderItem {
  final String id;
  final String folderId;
  final String Function(AppLocalizations?) getTitle;
  final String Function(AppLocalizations?) getSubtitle;
  final IconData icon;
  final Color color;
  final Color gradientSecondColor;
  final bool isPrimary;
  final bool isPreset;
  final String? routineId;
  final Widget Function() buildScreen;

  const HomeFolderItem({
    required this.id,
    required this.folderId,
    required this.getTitle,
    required this.getSubtitle,
    required this.icon,
    required this.color,
    required this.gradientSecondColor,
    this.isPrimary = false,
    this.isPreset = false,
    this.routineId,
    required this.buildScreen,
  });
}

/// Definition of a Home Folder
class HomeFolderMeta {
  final String id;
  final String Function(AppLocalizations?) getTitle;
  final String Function(AppLocalizations?) getSubtitle;
  final String Function(AppLocalizations?) getBadge;
  final Color color;
  final Color gradientSecondColor;
  final IconData icon;
  final String categoryFilter;

  const HomeFolderMeta({
    required this.id,
    required this.getTitle,
    required this.getSubtitle,
    required this.getBadge,
    required this.color,
    required this.gradientSecondColor,
    required this.icon,
    required this.categoryFilter,
  });
}

class HomeTimerHelper {
  static const String orderPrefKey = 'home_timer_order_v1';
  static const String folderOrderPrefKey = 'home_folder_order_v3';
  static const String folderItemsPrefix = 'home_folder_items_v3_';
  static const String presetPrefix = 'preset:';

  /// Legacy list kept for backward compatibility
  static const List<String> defaultOrder = [
    'tabata',
    'emom',
    'amrap',
    'for_time',
    'crossfit',
    'hyrox',
    'rounds',
    'stopwatch',
    'countdown',
    'workout_log',
  ];

  /// 6 Standard Main Folders shown on initial setup and layout reset
  static const List<String> defaultFolderOrder = [
    'tabata',
    'emom',
    'amrap',
    'for_time',
    'crossfit',
    'hyrox',
  ];

  static final Map<String, HomeFolderMeta> folderDefinitions = {
    'tabata': HomeFolderMeta(
      id: 'tabata',
      getTitle: (l10n) => l10n?.tabata ?? 'TABATA',
      getSubtitle: (l10n) => l10n?.tabataAcronym ?? '20s Work / 10s Rest',
      getBadge: (_) => 'HIIT • 20/10',
      color: const Color(0xFF00E676),
      gradientSecondColor: const Color(0xFF00BFA5),
      icon: Icons.flash_on_rounded,
      categoryFilter: 'tabata',
    ),
    'rounds': HomeFolderMeta(
      id: 'rounds',
      getTitle: (l10n) => l10n?.rounds ?? 'ROUNDS',
      getSubtitle: (l10n) => l10n?.roundsAcronym ?? 'Interval Training',
      getBadge: (_) => 'INTERVAL',
      color: const Color(0xFF2979FF),
      gradientSecondColor: const Color(0xFF00B0FF),
      icon: Icons.repeat_rounded,
      categoryFilter: 'rounds',
    ),
    'emom': HomeFolderMeta(
      id: 'emom',
      getTitle: (l10n) => l10n?.emomTitle ?? 'EMOM',
      getSubtitle: (l10n) => l10n?.emomAcronym ?? 'Every Minute On the Minute',
      getBadge: (_) => 'EVERY MINUTE',
      color: const Color(0xFFFFD600),
      gradientSecondColor: const Color(0xFFFF9100),
      icon: Icons.timer_outlined,
      categoryFilter: 'emom',
    ),
    'amrap': HomeFolderMeta(
      id: 'amrap',
      getTitle: (l10n) => l10n?.amrapTitle ?? 'AMRAP',
      getSubtitle: (_) => 'As Many Rounds As Possible',
      getBadge: (_) => 'MAX REPS',
      color: const Color(0xFFFF5722),
      gradientSecondColor: const Color(0xFFFF1744),
      icon: Icons.all_inclusive_rounded,
      categoryFilter: 'amrap',
    ),
    'for_time': HomeFolderMeta(
      id: 'for_time',
      getTitle: (l10n) => l10n?.forTimeTitle ?? 'FOR TIME',
      getSubtitle: (l10n) => l10n?.forTimeAcronym ?? 'Race Against The Clock',
      getBadge: (_) => 'TIME CAP',
      color: const Color(0xFF7C4DFF),
      gradientSecondColor: const Color(0xFF651FFF),
      icon: Icons.speed_rounded,
      categoryFilter: 'fortime',
    ),
    'crossfit': HomeFolderMeta(
      id: 'crossfit',
      getTitle: (_) => 'CROSSFIT',
      getSubtitle: (_) => 'Crossfit WODs',
      getBadge: (_) => 'HERO & WODS',
      color: const Color(0xFFFF3D00),
      gradientSecondColor: const Color(0xFFFF9100),
      icon: Icons.fitness_center_rounded,
      categoryFilter: 'crossfit',
    ),
    'hyrox': HomeFolderMeta(
      id: 'hyrox',
      getTitle: (l10n) => l10n?.hyrox ?? 'HYROX',
      getSubtitle: (l10n) => l10n?.hyroxSubtitle ?? 'Race Simulator & Tests',
      getBadge: (_) => 'RACE & PFT',
      color: const Color(0xFFFFE600),
      gradientSecondColor: const Color(0xFFFF9100),
      icon: Icons.directions_run_rounded,
      categoryFilter: 'hyrox',
    ),
    'stopwatch': HomeFolderMeta(
      id: 'stopwatch',
      getTitle: (l10n) => l10n?.stopwatch ?? 'STOPWATCH',
      getSubtitle: (l10n) => l10n?.stopwatchAcronym ?? 'Count-Up Timer with Splits',
      getBadge: (_) => 'CHRONO',
      color: const Color(0xFF00E5FF),
      gradientSecondColor: const Color(0xFF0091EA),
      icon: CupertinoIcons.stopwatch_fill,
      categoryFilter: 'stopwatch',
    ),
    'countdown': HomeFolderMeta(
      id: 'countdown',
      getTitle: (l10n) => l10n?.countdown ?? 'COUNTDOWN',
      getSubtitle: (l10n) => l10n?.countdownAcronym ?? 'Universal Timer',
      getBadge: (_) => 'TIMER',
      color: const Color(0xFFFF4081),
      gradientSecondColor: const Color(0xFFF50057),
      icon: Icons.hourglass_bottom_rounded,
      categoryFilter: 'countdown',
    ),
  };

  /// Strictly determines which folder a category belongs to.
  /// No other folder is allowed!
  static String getFolderIdForCategory(String category) {
    final cat = category.toLowerCase().trim().replaceAll(' ', '').replaceAll('_', '');
    if (cat.contains('tabata')) return 'tabata';
    if (cat.contains('round')) return 'rounds';
    if (cat.contains('emom')) return 'emom';
    if (cat.contains('amrap')) return 'amrap';
    if (cat.contains('fortime')) return 'for_time';
    if (cat.contains('crossfit') ||
        cat.contains('hero') ||
        cat.contains('girl') ||
        cat.contains('bench')) {
      return 'crossfit';
    }
    if (cat.contains('hyrox')) return 'hyrox';
    if (cat.contains('stopwatch')) return 'stopwatch';
    if (cat.contains('countdown')) return 'countdown';
    return 'tabata';
  }

  static bool isPresetId(String id) => id.startsWith(presetPrefix);

  static String getPresetId(String routineId) => '$presetPrefix$routineId';

  static String extractRoutineId(String presetId) {
    if (presetId.startsWith(presetPrefix)) {
      return presetId.substring(presetPrefix.length);
    }
    return presetId;
  }

  static const Set<String> _removedBaseTimerIds = {
    'tabata',
    'rounds',
    'emom',
    'amrap',
    'for_time',
    'countdown',
    'custom',
  };

  /// Default icon items for each folder (Hyrox & Stopwatch keep their main launcher)
  static List<String> getDefaultItemsForFolder(String folderId) {
    switch (folderId) {
      case 'tabata':
        return [
          'preset:preset_tabata_standard',
          'preset:preset_tabata_sprint',
        ];
      case 'rounds':
        return [
          'preset:preset_rounds_boxing',
          'preset:preset_rounds_5x5',
        ];
      case 'emom':
        return [
          'preset:preset_emom_10m',
          'preset:preset_emom_20m',
        ];
      case 'amrap':
        return [
          'preset:preset_amrap_12m',
          'preset:preset_amrap_20m',
        ];
      case 'for_time':
        return [
          'preset:preset_fortime_15m',
        ];
      case 'crossfit':
        return [
          'preset:wod_fran',
          'preset:wod_cindy',
          'preset:wod_grace',
          'preset:wod_helen',
          'preset:wod_murph',
        ];
      case 'hyrox':
        return [
          'hyrox',
          'preset:hyrox_half_sim',
          'preset:hyrox_compromised_4x1k',
          'preset:hyrox_station_pemom',
          'preset:hyrox_wallball_test',
        ];
      case 'stopwatch':
        return ['stopwatch'];
      case 'countdown':
        return [
          'preset:preset_countdown_5m',
          'preset:preset_countdown_10m',
        ];
      case 'custom':
        return [
          'timer_manager',
        ];
      default:
        return [];
    }
  }

  /// Returns the saved or default folder order
  static Future<List<String>> getFolderOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(folderOrderPrefKey);
      if (list != null) {
        final valid = list.where((id) => folderDefinitions.containsKey(id)).toList();
        return valid;
      }
    } catch (_) {}
    return List<String>.from(defaultFolderOrder);
  }

  /// Saves the reordered list of folders
  static Future<void> saveFolderOrder(List<String> order) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(folderOrderPrefKey, order);
    } catch (_) {}
  }

  /// Returns the items order for a specific folder
  static Future<List<String>> getFolderItems(String folderId, {List<CustomRoutine>? routines}) async {
    if (folderId == 'stopwatch') {
      return ['stopwatch'];
    }
    List<String> items;
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('$folderItemsPrefix$folderId');
      if (list != null) {
        items = list.where((id) => !_removedBaseTimerIds.contains(id)).toList();
      } else {
        items = List<String>.from(getDefaultItemsForFolder(folderId));
      }
    } catch (_) {
      items = List<String>.from(getDefaultItemsForFolder(folderId));
    }

    // Ensure custom routines created for this category are included in the folder
    try {
      final allRoutines = routines ?? await LocalTimerRepository().getRoutines();
      final customForFolder = allRoutines.where(
        (r) => !r.isPreset && getFolderIdForCategory(r.category) == folderId,
      );
      for (final r in customForFolder) {
        final key = getPresetId(r.id);
        if (!items.contains(key) && !items.contains(r.id)) {
          items.add(key);
        }
      }
    } catch (_) {}

    return items;
  }

  /// Saves the items order for a specific folder
  static Future<void> saveFolderItems(String folderId, List<String> items) async {
    if (folderId == 'stopwatch') return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('$folderItemsPrefix$folderId', items);
    } catch (_) {}
  }

  /// Resets the home folder order and folder contents to the default setup:
  /// 1. Home screen shows [tabata, emom, amrap, for_time, crossfit, hyrox] in order.
  /// 2. Folders contain their default presets (CrossFit has top 5 WODs: Fran, Cindy, Grace, Helen, Murph).
  /// 3. Any custom timers belonging to a category are placed inside their respective folder.
  static Future<List<String>> resetToDefaultLayout({List<CustomRoutine>? routines}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Reset folder order
      final newFolderOrder = List<String>.from(defaultFolderOrder);
      await prefs.setStringList(folderOrderPrefKey, newFolderOrder);
      await prefs.setStringList(orderPrefKey, newFolderOrder);

      // Fetch custom routines
      final allRoutines = routines ?? await LocalTimerRepository().getRoutines();
      final nonPresets = allRoutines.where((r) => !r.isPreset).toList();

      // 2. Reset each folder's items to its default presets + custom routines
      for (final folderId in folderDefinitions.keys) {
        if (folderId == 'stopwatch') {
          await prefs.setStringList('$folderItemsPrefix$folderId', ['stopwatch']);
          continue;
        }

        final items = List<String>.from(getDefaultItemsForFolder(folderId));

        // Add any custom routines belonging to this folder
        for (final r in nonPresets) {
          if (getFolderIdForCategory(r.category) == folderId) {
            final key = getPresetId(r.id);
            if (!items.contains(key) && !items.contains(r.id)) {
              items.add(key);
            }
          }
        }

        await prefs.setStringList('$folderItemsPrefix$folderId', items);
      }

      return newFolderOrder;
    } catch (_) {
      return List<String>.from(defaultFolderOrder);
    }
  }

  /// Legacy getOrder method supporting legacy consumers while reflecting folder items
  static Future<List<String>> getOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(orderPrefKey);
      if (list != null && list.isNotEmpty) {
        return List<String>.from(list);
      }
    } catch (_) {}
    return List<String>.from(defaultOrder);
  }

  static Future<void> saveOrder(List<String> order) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(orderPrefKey, order);
    } catch (_) {}
  }

  /// Checks if a routine is pinned on the home screen
  static Future<bool> isPinned(String routineId, {String? category}) async {
    try {
      final presetKey = getPresetId(routineId);
      final rawKey = routineId;

      final order = await getOrder();
      if (order.contains(presetKey) || order.contains(rawKey)) {
        return true;
      }

      if (category != null && category.isNotEmpty) {
        final folderId = getFolderIdForCategory(category);
        final items = await getFolderItems(folderId);
        return items.contains(presetKey) || items.contains(rawKey);
      }

      for (final folderId in defaultFolderOrder) {
        final items = await getFolderItems(folderId);
        if (items.contains(presetKey) || items.contains(rawKey)) {
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  /// Strictly pins/unpins a routine into its category's folder.
  /// No other folder destination is permitted!
  static Future<bool> togglePin(String routineId, {String? category}) async {
    try {
      String targetCategory = category ?? '';
      if (targetCategory.isEmpty) {
        final routines = await LocalTimerRepository().getRoutines();
        final match = routines.where((r) => r.id == routineId).firstOrNull;
        if (match != null) {
          targetCategory = match.category;
        }
      }

      final folderId = getFolderIdForCategory(targetCategory);
      final items = await getFolderItems(folderId);
      final presetKey = getPresetId(routineId);

      final isAlreadyPinned = items.contains(presetKey) || items.contains(routineId);
      final willPin = !isAlreadyPinned;

      if (willPin) {
        if (!items.contains(presetKey)) {
          items.add(presetKey);
        }
      } else {
        items.remove(presetKey);
        items.remove(routineId);
      }

      await saveFolderItems(folderId, items);

      // Keep legacy list updated in SharedPreferences
      final legacyList = await getOrder();
      if (willPin) {
        if (!legacyList.contains(presetKey)) legacyList.add(presetKey);
      } else {
        legacyList.remove(presetKey);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(orderPrefKey, legacyList);

      return willPin;
    } catch (_) {
      return false;
    }
  }

  /// Explicitly pins a routine into its category's folder on the home screen
  static Future<bool> pin(String routineId, {String? category}) async {
    try {
      String targetCategory = category ?? '';
      if (targetCategory.isEmpty) {
        final routines = await LocalTimerRepository().getRoutines();
        final match = routines.where((r) => r.id == routineId).firstOrNull;
        if (match != null) {
          targetCategory = match.category;
        }
      }

      final folderId = getFolderIdForCategory(targetCategory);
      final items = await getFolderItems(folderId);
      final presetKey = getPresetId(routineId);

      if (!items.contains(presetKey) && !items.contains(routineId)) {
        items.add(presetKey);
        await saveFolderItems(folderId, items);
      }

      final legacyList = await getOrder();
      if (!legacyList.contains(presetKey)) {
        legacyList.add(presetKey);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(orderPrefKey, legacyList);
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Unpins a routine from whichever folder it belongs to
  static Future<void> unpin(String routineId) async {
    try {
      final presetKey = getPresetId(routineId);
      for (final folderId in defaultFolderOrder) {
        final items = await getFolderItems(folderId);
        if (items.contains(presetKey) || items.contains(routineId)) {
          items.remove(presetKey);
          items.remove(routineId);
          await saveFolderItems(folderId, items);
        }
      }
      final legacyList = await getOrder();
      legacyList.remove(presetKey);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(orderPrefKey, legacyList);
    } catch (_) {}
  }

  /// Resolves an item ID to a fully configured HomeFolderItem
  static HomeFolderItem? resolveFolderItem({
    required String folderId,
    required String itemId,
    required List<CustomRoutine> routines,
  }) {
    // 1. Check primary/base timers
    switch (itemId) {
      case 'hyrox':
        return HomeFolderItem(
          id: 'hyrox',
          folderId: 'hyrox',
          getTitle: (l10n) => l10n?.hyrox ?? 'HYROX',
          getSubtitle: (l10n) => l10n?.hyroxSubtitle ?? 'Race Simulator & Tests',
          icon: Icons.directions_run_rounded,
          color: const Color(0xFFFFE600),
          gradientSecondColor: const Color(0xFFFF9100),
          isPrimary: true,
          buildScreen: () => const HyroxHomeScreen(),
        );
      case 'stopwatch':
        return HomeFolderItem(
          id: 'stopwatch',
          folderId: 'stopwatch',
          getTitle: (l10n) => l10n?.stopwatch ?? 'STOPWATCH',
          getSubtitle: (l10n) => l10n?.stopwatchAcronym ?? 'Count-Up Timer with Splits',
          icon: CupertinoIcons.stopwatch_fill,
          color: const Color(0xFF00E5FF),
          gradientSecondColor: const Color(0xFF0091EA),
          isPrimary: true,
          buildScreen: () => const StopwatchScreen(),
        );
      case 'tabata':
      case 'rounds':
      case 'emom':
      case 'amrap':
      case 'for_time':
      case 'countdown':
        return HomeFolderItem(
          id: itemId,
          folderId: folderId,
          getTitle: (l10n) => _timerManagerTitle(l10n),
          getSubtitle: (l10n) => _timerManagerSubtitle(l10n),
          icon: Icons.tune_rounded,
          color: getCategoryColor(itemId),
          gradientSecondColor: getCategoryColor(itemId).withValues(alpha: 0.75),
          isPrimary: true,
          buildScreen: () => TimerManagerScreen(initialCategory: itemId),
        );
      case 'custom':
        return HomeFolderItem(
          id: 'custom',
          folderId: 'custom',
          getTitle: (l10n) => l10n?.custom ?? 'CUSTOM & WODS',
          getSubtitle: (l10n) => l10n?.customSubtitle ?? 'Hero WODs & Custom Routines',
          icon: Icons.fitness_center_rounded,
          color: const Color(0xFF00BFA5),
          gradientSecondColor: const Color(0xFF1DE9B6),
          isPrimary: true,
          buildScreen: () => const TimerManagerScreen(initialCategory: 'crossfit'),
        );
      case 'preset_manager':
      case 'timer_manager':
        return const HomeFolderItem(
          id: 'timer_manager',
          folderId: 'custom',
          getTitle: _timerManagerTitle,
          getSubtitle: _timerManagerSubtitle,
          icon: Icons.library_books_rounded,
          color: Color(0xFF26A69A),
          gradientSecondColor: Color(0xFF00897B),
          isPrimary: false,
          buildScreen: _buildTimerManagerScreen,
        );
    }

    // 2. Check presets and routines
    final routineId = extractRoutineId(itemId);
    CustomRoutine? routine = routines.where((r) => r.id == routineId).firstOrNull;

    // Fallbacks if routine not yet loaded into memory
    if (routine == null) {
      final allPresets = [
        ...TimerPresetsData.getDefaultTimerPresets(),
        ...CrossFitWodsData.getAllWods(),
        ...HyroxData.getHyroxPresets(),
      ];
      routine = allPresets.where((p) => p.id == routineId).firstOrNull;
    }

    if (routine != null) {
      final color = getCategoryColor(routine.category);
      final icon = getCategoryIcon(routine.category);
      final r = routine;

      return HomeFolderItem(
        id: itemId,
        folderId: folderId,
        getTitle: (_) => r.name,
        getSubtitle: (_) {
          if (r.description.trim().isNotEmpty) {
            return r.description.trim();
          }
          final mins = r.totalDurationSeconds ~/ 60;
          final secs = r.totalDurationSeconds % 60;
          final timeStr = mins > 0
              ? '${mins}m ${secs > 0 ? '${secs}s' : ''}'
              : '${secs}s';
          return '${r.rounds} Rnds • $timeStr';
        },
        icon: icon,
        color: color,
        gradientSecondColor: color.withValues(alpha: 0.75),
        isPreset: true,
        routineId: r.id,
        buildScreen: () => buildScreenForRoutine(r),
      );
    }

    return null;
  }

  static String _timerManagerTitle(AppLocalizations? l10n) =>
      l10n?.timerManager ?? 'Timer Manager';
  static String _timerManagerSubtitle(AppLocalizations? l10n) =>
      l10n?.allTimersAndWod ?? 'All Timers & WOD';
  static Widget _buildTimerManagerScreen() => const TimerManagerScreen();

  /// Builds the appropriate screen for a preset routine (directly opens the countdown timer screen)
  static Widget buildScreenForRoutine(CustomRoutine routine) {
    return TimerRunnerScreen(routine: routine);
  }

  /// Category color mapping for custom presets
  static Color getCategoryColor(String category) {
    final cat = category.toLowerCase().trim().replaceAll(' ', '').replaceAll('_', '');
    if (cat.contains('tabata')) {
      return const Color(0xFF00E676);
    } else if (cat.contains('round')) {
      return const Color(0xFF2979FF);
    } else if (cat.contains('emom')) {
      return const Color(0xFFFFD600);
    } else if (cat.contains('amrap')) {
      return const Color(0xFFFF5722);
    } else if (cat.contains('fortime')) {
      return const Color(0xFF7C4DFF);
    } else if (cat.contains('countdown')) {
      return const Color(0xFFFF4081);
    } else if (cat.contains('hyrox')) {
      return const Color(0xFFFFE600);
    } else if (cat.contains('hero')) {
      return const Color(0xFFFF3D00);
    } else if (cat.contains('girl')) {
      return const Color(0xFFFF4081);
    } else if (cat.contains('bench')) {
      return const Color(0xFF00E5FF);
    } else if (cat.contains('crossfit')) {
      return const Color(0xFFFF9100);
    } else if (cat.contains('standart') || cat.contains('standard')) {
      return const Color(0xFF00E676);
    } else {
      return const Color(0xFF00BFA5);
    }
  }

  /// Category icon mapping for custom presets
  static IconData getCategoryIcon(String category) {
    final cat = category.toLowerCase().trim().replaceAll(' ', '').replaceAll('_', '');
    if (cat.contains('tabata')) {
      return Icons.flash_on_rounded;
    } else if (cat.contains('round')) {
      return Icons.repeat_rounded;
    } else if (cat.contains('emom')) {
      return Icons.timer_outlined;
    } else if (cat.contains('amrap')) {
      return Icons.all_inclusive_rounded;
    } else if (cat.contains('fortime')) {
      return Icons.speed_rounded;
    } else if (cat.contains('countdown')) {
      return Icons.hourglass_bottom_rounded;
    } else if (cat.contains('hyrox')) {
      return Icons.directions_run_rounded;
    } else if (cat.contains('hero')) {
      return Icons.military_tech_rounded;
    } else if (cat.contains('girl')) {
      return Icons.auto_awesome_rounded;
    } else if (cat.contains('bench')) {
      return Icons.emoji_events_rounded;
    } else if (cat.contains('crossfit')) {
      return Icons.fitness_center_rounded;
    } else if (cat.contains('standart') || cat.contains('standard')) {
      return Icons.tune_rounded;
    } else {
      return Icons.fitness_center_rounded;
    }
  }
}
