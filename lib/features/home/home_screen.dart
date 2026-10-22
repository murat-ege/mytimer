import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mytimer/l10n/generated/app_localizations.dart';
import 'package:mytimer/models/custom_routine.dart';
import 'package:mytimer/repositories/local_timer_repository.dart';
import 'package:mytimer/shared/utils/home_timer_helper.dart';
import 'package:mytimer/features/timer_manager/timer_manager_screen.dart';
import 'package:mytimer/features/workout_log/workout_log_screen.dart';
import 'package:mytimer/features/settings/settings_screen.dart';

import 'widgets/home_timer_card.dart';
import 'widgets/add_timer_tile.dart';
import 'widgets/add_timer_bottom_sheet.dart';
import 'widgets/folder_modal.dart';

export 'widgets/home_timer_card.dart' show TimerCatalogItem, HomeTimerCard;

class HomeScreen extends StatefulWidget {
  final Locale? currentLocale;
  final void Function(Locale) onLocaleChanged;

  const HomeScreen({
    super.key,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final LocalTimerRepository _repository = LocalTimerRepository();

  List<CustomRoutine> _routines = [];
  List<String> _folderOrder = List.from(HomeTimerHelper.defaultFolderOrder);
  bool _isEditing = false;

  late AnimationController _jiggleController;
  late Animation<double> _jiggleAnimation;

  @override
  void initState() {
    super.initState();
    _jiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _jiggleAnimation = Tween<double>(begin: -0.024, end: 0.024).animate(
      CurvedAnimation(parent: _jiggleController, curve: Curves.easeInOutSine),
    );

    _loadSavedOrder();
  }

  @override
  void dispose() {
    _jiggleController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedOrder() async {
    try {
      final routines = await _repository.getRoutines();
      final savedOrder = await HomeTimerHelper.getFolderOrder();

      if (mounted) {
        setState(() {
          _routines = routines;
          _folderOrder = savedOrder;
        });
      }
    } catch (_) {}
  }

  Future<void> _saveFolderOrder() async {
    try {
      await HomeTimerHelper.saveFolderOrder(_folderOrder);
    } catch (_) {}
  }

  void _toggleEditing(bool enable) {
    if (_isEditing == enable) return;
    setState(() {
      _isEditing = enable;
    });

    if (enable) {
      _jiggleController.repeat(reverse: true);
      HapticFeedback.mediumImpact();
    } else {
      _jiggleController.stop();
      _jiggleController.reset();
      HapticFeedback.lightImpact();
      _saveFolderOrder();
    }
  }

  void _removeFolder(String id) {
    setState(() {
      _folderOrder.remove(id);
    });
    _saveFolderOrder();
    HapticFeedback.mediumImpact();
  }

  void _addFolder(String id) {
    if (!_folderOrder.contains(id)) {
      setState(() {
        _folderOrder.add(id);
      });
      _saveFolderOrder();
      HapticFeedback.lightImpact();
    }
  }

  void _resetToDefault() {
    setState(() {
      _folderOrder = List.from(HomeTimerHelper.defaultFolderOrder);
    });
    _saveFolderOrder();
    HapticFeedback.heavyImpact();
  }

  void _openSettings(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          currentLocale: widget.currentLocale ?? Localizations.localeOf(context),
          onLocaleChanged: widget.onLocaleChanged,
        ),
      ),
    );
    if (mounted) {
      _loadSavedOrder();
    }
  }

  void _openLog(BuildContext context) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const WorkoutLogScreen()));
    if (mounted) {
      _loadSavedOrder();
    }
  }

  void _openFolderModal(String folderId) async {
    final folder = HomeTimerHelper.folderDefinitions[folderId];
    if (folder == null) return;

    final itemIds = await HomeTimerHelper.getFolderItems(folderId);
    final resolvedItems = itemIds
        .map((id) => HomeTimerHelper.resolveFolderItem(
              folderId: folderId,
              itemId: id,
              routines: _routines,
            ))
        .whereType<HomeFolderItem>()
        .toList();

    if (!mounted) return;

    final result = await FolderModal.show(
      context: context,
      folder: folder,
      items: resolvedItems,
      isEditing: _isEditing,
      jiggleAnimation: _jiggleAnimation,
      onReorderIcons: (fId, fromId, toId) async {
        final currentList = await HomeTimerHelper.getFolderItems(fId);
        final fromIdx = currentList.indexOf(fromId);
        final toIdx = currentList.indexOf(toId);
        if (fromIdx != -1 && toIdx != -1 && fromIdx != toIdx) {
          final moved = currentList.removeAt(fromIdx);
          currentList.insert(toIdx, moved);
          await HomeTimerHelper.saveFolderItems(fId, currentList);
          if (mounted) {
            _loadSavedOrder();
          }
        }
      },
      onUnpinItem: (fId, itemId) async {
        final routineId = HomeTimerHelper.extractRoutineId(itemId);
        await HomeTimerHelper.unpin(routineId);
        if (mounted) {
          _loadSavedOrder();
        }
      },
      onToggleEditing: () => _toggleEditing(!_isEditing),
    );

    if (!mounted) return;

    if (result is HomeFolderItem) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => result.buildScreen()),
      );
      if (mounted) {
        _loadSavedOrder();
      }
    } else if (result is FolderAddPresetAction) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TimerManagerScreen(initialCategory: result.categoryFilter),
        ),
      );
      if (mounted) {
        _loadSavedOrder();
      }
    } else {
      _loadSavedOrder();
    }
  }

  Map<String, TimerCatalogItem> get _folderCatalog {
    final map = <String, TimerCatalogItem>{};
    for (final entry in HomeTimerHelper.folderDefinitions.entries) {
      final f = entry.value;
      map[f.id] = TimerCatalogItem(
        id: f.id,
        getTitle: (l10n) => f.getTitle(l10n),
        getSubtitle: (l10n) => f.getSubtitle(l10n),
        color: f.color,
        gradientSecondColor: f.gradientSecondColor,
        icon: f.icon,
        badgeText: f.getBadge(null),
        buildScreen: () => const SizedBox.shrink(),
      );
    }
    return map;
  }

  void _showAddFolderBottomSheet() {
    AddTimerBottomSheet.show(
      context,
      baseCatalog: _folderCatalog,
      currentTimerOrder: _folderOrder,
      onAdd: _addFolder,
      onResetToDefault: _resetToDefault,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalog = _folderCatalog;
    final activeItems = _folderOrder
        .where((id) => catalog.containsKey(id))
        .map((id) => catalog[id]!)
        .toList();

    final hasHidden = catalog.length > activeItems.length;

    return GestureDetector(
      onTap: () {
        if (_isEditing) _toggleEditing(false);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: _isEditing
              ? IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: Color(0xFF00E676),
                    size: 28,
                  ),
                  tooltip: l10n?.addTimer ?? 'Add Folder',
                  onPressed: _showAddFolderBottomSheet,
                )
              : Center(
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1C),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white12),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.history_rounded,
                        color: Colors.white70,
                        size: 22,
                      ),
                      tooltip: l10n?.workoutLogs ?? 'Workout Log',
                      onPressed: () => _openLog(context),
                    ),
                  ),
                ),
          title: _isEditing
              ? Text(
                  l10n?.editHomeScreen ?? 'EDIT',
                  style: const TextStyle(
                    color: Color(0xFF00E676),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 2.0,
                  ),
                )
              : RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'MY',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 21,
                          letterSpacing: 3.0,
                        ),
                      ),
                      TextSpan(
                        text: 'TIMER',
                        style: TextStyle(
                          color: Color(0xFF00E676),
                          fontWeight: FontWeight.w900,
                          fontSize: 21,
                          letterSpacing: 3.0,
                        ),
                      ),
                    ],
                  ),
                ),
          centerTitle: true,
          actions: [
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton.icon(
                  onPressed: () => _toggleEditing(false),
                  icon: const Icon(Icons.check_rounded, color: Color(0xFF00E676), size: 18),
                  label: Text(
                    l10n?.done ?? 'Done',
                    style: const TextStyle(
                      color: Color(0xFF00E676),
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
              )
            else ...[
              Center(
                child: Container(
                  width: 38,
                  height: 38,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1C),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white12),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.dashboard_customize_outlined,
                      color: Colors.white70,
                      size: 20,
                    ),
                    tooltip: l10n?.editHomeScreen ?? 'Edit Home Screen',
                    onPressed: () => _toggleEditing(true),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 38,
                  height: 38,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1C),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white12),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white70,
                      size: 20,
                    ),
                    tooltip: l10n?.settings ?? 'Settings',
                    onPressed: () => _openSettings(context),
                  ),
                ),
              ),
            ],
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final layout = _HomeGridLayout.compute(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
              );

              final itemWidth =
                  (constraints.maxWidth -
                      (layout.horizontalPadding * 2) -
                      (layout.spacing * (layout.crossAxisCount - 1))) /
                  layout.crossAxisCount;
              final itemHeight = itemWidth / layout.childAspectRatio;

              final totalTiles =
                  activeItems.length + (_isEditing && hasHidden ? 1 : 0);

              return GridView.builder(
                padding: EdgeInsets.only(
                  left: layout.horizontalPadding,
                  right: layout.horizontalPadding,
                  top: layout.topPadding,
                  bottom: layout.bottomPadding,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: layout.crossAxisCount,
                  mainAxisSpacing: layout.spacing,
                  crossAxisSpacing: layout.spacing,
                  childAspectRatio: layout.childAspectRatio,
                ),
                itemCount: totalTiles,
                itemBuilder: (ctx, index) {
                  if (index >= activeItems.length) {
                    return AddTimerTile(onTap: _showAddFolderBottomSheet);
                  }

                  final item = activeItems[index];

                  return DragTarget<String>(
                    onWillAcceptWithDetails: (details) =>
                        details.data != item.id,
                    onAcceptWithDetails: (details) {
                      final fromIndex = _folderOrder.indexOf(details.data);
                      final toIndex = _folderOrder.indexOf(item.id);
                      if (fromIndex != -1 &&
                          toIndex != -1 &&
                          fromIndex != toIndex) {
                        setState(() {
                          final moved = _folderOrder.removeAt(fromIndex);
                          _folderOrder.insert(toIndex, moved);
                        });
                        _saveFolderOrder();
                        HapticFeedback.lightImpact();
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      final isHovered = candidateData.isNotEmpty;

                      return SizedBox.expand(
                        child: LongPressDraggable<String>(
                          data: item.id,
                          delay: const Duration(milliseconds: 220),
                          onDragStarted: () {
                            if (!_isEditing) {
                              _toggleEditing(true);
                            }
                            HapticFeedback.selectionClick();
                          },
                          feedback: Material(
                            color: Colors.transparent,
                            child: Transform.scale(
                              scale: 1.05,
                              child: SizedBox(
                                width: itemWidth,
                                height: itemHeight,
                                child: HomeTimerCard(
                                  item: item,
                                  isEditing: _isEditing,
                                  isFeedback: true,
                                  onTap: () {},
                                  onLongPress: () {},
                                  onRemove: () {},
                                ),
                              ),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.25,
                            child: SizedBox(
                              width: itemWidth,
                              height: itemHeight,
                              child: HomeTimerCard(
                                item: item,
                                isEditing: _isEditing,
                                onTap: () {},
                                onLongPress: () {},
                                onRemove: () {},
                              ),
                            ),
                          ),
                          child: SizedBox.expand(
                            child: AnimatedScale(
                              scale: isHovered ? 1.04 : 1.0,
                              duration: const Duration(milliseconds: 160),
                              child: _isEditing
                                  ? AnimatedBuilder(
                                      animation: _jiggleAnimation,
                                      builder: (context, child) {
                                        final angle =
                                            (index % 2 == 0 ? 1 : -1) *
                                            _jiggleAnimation.value;
                                        return Transform.rotate(
                                          angle: angle,
                                          child: child,
                                        );
                                      },
                                      child: HomeTimerCard(
                                        item: item,
                                        isEditing: _isEditing,
                                        onTap: () {},
                                        onLongPress: () {},
                                        onRemove: () => _removeFolder(item.id),
                                      ),
                                    )
                                  : HomeTimerCard(
                                      item: item,
                                      isEditing: false,
                                      onTap: () => _openFolderModal(item.id),
                                      onLongPress: () => _toggleEditing(true),
                                      onRemove: () => _removeFolder(item.id),
                                    ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Responsive layout configuration for Home Screen timer grid
class _HomeGridLayout {
  final int crossAxisCount;
  final double childAspectRatio;
  final double spacing;
  final double horizontalPadding;
  final double topPadding;
  final double bottomPadding;

  const _HomeGridLayout({
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.spacing,
    required this.horizontalPadding,
    required this.topPadding,
    required this.bottomPadding,
  });

  factory _HomeGridLayout.compute({
    required double width,
    required double height,
  }) {
    final isLandscape = width > height;

    if (isLandscape) {
      if (height < 520) {
        final int columns;
        if (width < 640) {
          columns = 3;
        } else if (width < 880) {
          columns = 4;
        } else {
          columns = 5;
        }

        return _HomeGridLayout(
          crossAxisCount: columns,
          childAspectRatio: 1.42,
          spacing: 10.0,
          horizontalPadding: 16.0,
          topPadding: 8.0,
          bottomPadding: 16.0,
        );
      } else {
        final int columns;
        final double aspectRatio;
        if (width < 900) {
          columns = 3;
          aspectRatio = 1.30;
        } else if (width < 1180) {
          columns = 4;
          aspectRatio = 1.35;
        } else {
          columns = 5;
          aspectRatio = 1.40;
        }

        return _HomeGridLayout(
          crossAxisCount: columns,
          childAspectRatio: aspectRatio,
          spacing: 14.0,
          horizontalPadding: 24.0,
          topPadding: 12.0,
          bottomPadding: 24.0,
        );
      }
    } else {
      if (width >= 800) {
        return const _HomeGridLayout(
          crossAxisCount: 4,
          childAspectRatio: 1.25,
          spacing: 14.0,
          horizontalPadding: 24.0,
          topPadding: 16.0,
          bottomPadding: 28.0,
        );
      } else if (width >= 600) {
        return const _HomeGridLayout(
          crossAxisCount: 3,
          childAspectRatio: 1.20,
          spacing: 14.0,
          horizontalPadding: 20.0,
          topPadding: 14.0,
          bottomPadding: 24.0,
        );
      } else {
        if (width < 360) {
          return const _HomeGridLayout(
            crossAxisCount: 2,
            childAspectRatio: 1.08,
            spacing: 10.0,
            horizontalPadding: 12.0,
            topPadding: 10.0,
            bottomPadding: 20.0,
          );
        } else if (height < 640) {
          return const _HomeGridLayout(
            crossAxisCount: 2,
            childAspectRatio: 1.22,
            spacing: 10.0,
            horizontalPadding: 14.0,
            topPadding: 10.0,
            bottomPadding: 20.0,
          );
        } else {
          return const _HomeGridLayout(
            crossAxisCount: 2,
            childAspectRatio: 1.13,
            spacing: 12.0,
            horizontalPadding: 18.0,
            topPadding: 12.0,
            bottomPadding: 24.0,
          );
        }
      }
    }
  }
}
