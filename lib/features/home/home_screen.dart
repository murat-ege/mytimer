import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mytimer/l10n/generated/app_localizations.dart';
import 'package:mytimer/features/tabata/tabata_screen.dart';
import 'package:mytimer/features/rounds/rounds_screen.dart';
import 'package:mytimer/features/emom/emom_screen.dart';
import 'package:mytimer/features/amrap/amrap_screen.dart';
import 'package:mytimer/features/for_time/for_time_screen.dart';
import 'package:mytimer/features/hyrox/hyrox_home_screen.dart';
import 'package:mytimer/features/stopwatch/stopwatch_screen.dart';
import 'package:mytimer/features/countdown/countdown_screen.dart';
import 'package:mytimer/features/custom_routines/custom_routines_screen.dart';
import 'package:mytimer/features/workout_log/workout_log_screen.dart';
import 'package:mytimer/features/settings/settings_screen.dart';

import 'widgets/home_timer_card.dart';
import 'widgets/add_timer_tile.dart';
import 'widgets/add_timer_bottom_sheet.dart';

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
  static const String _prefKey = 'home_timer_order_v1';

  static const List<String> _defaultOrder = [
    'tabata',
    'rounds',
    'emom',
    'amrap',
    'for_time',
    'hyrox',
    'stopwatch',
    'countdown',
    'custom',
    'workout_log',
  ];

  List<String> _timerOrder = List.from(_defaultOrder);
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
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_prefKey);
      if (saved != null && saved.isNotEmpty) {
        final valid = saved.where((id) => _catalog.containsKey(id)).toList();
        if (!valid.contains('hyrox') && _catalog.containsKey('hyrox')) {
          final customIdx = valid.indexOf('custom');
          if (customIdx >= 0) {
            valid.insert(customIdx, 'hyrox');
          } else {
            valid.add('hyrox');
          }
        }
        if (valid.isNotEmpty) {
          setState(() {
            _timerOrder = valid;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _saveOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefKey, _timerOrder);
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
      _saveOrder();
    }
  }

  void _removeTimer(String id) {
    setState(() {
      _timerOrder.remove(id);
    });
    _saveOrder();
    HapticFeedback.mediumImpact();
  }

  void _addTimer(String id) {
    if (!_timerOrder.contains(id)) {
      setState(() {
        _timerOrder.add(id);
      });
      _saveOrder();
      HapticFeedback.lightImpact();
    }
  }

  void _resetToDefault() {
    setState(() {
      _timerOrder = List.from(_defaultOrder);
    });
    _saveOrder();
    HapticFeedback.heavyImpact();
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          currentLocale: widget.currentLocale ?? Localizations.localeOf(context),
          onLocaleChanged: widget.onLocaleChanged,
        ),
      ),
    );
  }

  void _openLog(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const WorkoutLogScreen()));
  }

  Map<String, TimerCatalogItem> get _catalog => {
    'tabata': TimerCatalogItem(
      id: 'tabata',
      getTitle: (l10n) => l10n?.tabata ?? 'TABATA',
      getSubtitle: (l10n) => l10n?.tabataAcronym ?? '20s Work / 10s Rest',
      color: const Color(0xFF00E676),
      gradientSecondColor: const Color(0xFF00BFA5),
      icon: Icons.flash_on_rounded,
      buildScreen: () => const TabataScreen(),
    ),
    'rounds': TimerCatalogItem(
      id: 'rounds',
      getTitle: (l10n) => l10n?.rounds ?? 'ROUNDS',
      getSubtitle: (l10n) => l10n?.roundsAcronym ?? 'Interval Training',
      color: const Color(0xFF2979FF),
      gradientSecondColor: const Color(0xFF00B0FF),
      icon: Icons.repeat_rounded,
      buildScreen: () => const RoundsScreen(),
    ),
    'emom': TimerCatalogItem(
      id: 'emom',
      getTitle: (l10n) => l10n?.emomTitle ?? 'EMOM',
      getSubtitle: (l10n) => l10n?.emomAcronym ?? 'Every Minute On the Minute',
      color: const Color(0xFFFFD600),
      gradientSecondColor: const Color(0xFFFF9100),
      icon: Icons.timer_outlined,
      buildScreen: () => const EmomScreen(),
    ),
    'amrap': TimerCatalogItem(
      id: 'amrap',
      getTitle: (l10n) => l10n?.amrapTitle ?? 'AMRAP',
      getSubtitle: (l10n) => l10n?.amrapAcronym ?? 'As Many Rounds / Reps As Possible',
      color: const Color(0xFFFF5722),
      gradientSecondColor: const Color(0xFFFF1744),
      icon: Icons.all_inclusive_rounded,
      buildScreen: () => const AmrapScreen(),
    ),
    'for_time': TimerCatalogItem(
      id: 'for_time',
      getTitle: (l10n) => l10n?.forTimeTitle ?? 'FOR TIME',
      getSubtitle: (l10n) =>
          l10n?.forTimeAcronym ?? 'Race Against The Clock',
      color: const Color(0xFF7C4DFF),
      gradientSecondColor: const Color(0xFF651FFF),
      icon: Icons.speed_rounded,
      buildScreen: () => const ForTimeScreen(),
    ),
    'hyrox': TimerCatalogItem(
      id: 'hyrox',
      getTitle: (l10n) => l10n?.hyrox ?? 'HYROX',
      getSubtitle: (l10n) =>
          l10n?.hyroxSubtitle ?? 'Race Simulator, Intervals & Tests',
      color: const Color(0xFFFFE600),
      gradientSecondColor: const Color(0xFFFF9100),
      icon: Icons.directions_run_rounded,
      buildScreen: () => const HyroxHomeScreen(),
    ),
    'stopwatch': TimerCatalogItem(
      id: 'stopwatch',
      getTitle: (l10n) => l10n?.stopwatch ?? 'STOPWATCH',
      getSubtitle: (l10n) =>
          l10n?.stopwatchAcronym ?? 'Count-Up Timer with Splits',
      color: const Color(0xFF00E5FF),
      gradientSecondColor: const Color(0xFF0091EA),
      icon: CupertinoIcons.stopwatch_fill,
      buildScreen: () => const StopwatchScreen(),
    ),
    'countdown': TimerCatalogItem(
      id: 'countdown',
      getTitle: (l10n) => l10n?.countdown ?? 'COUNTDOWN',
      getSubtitle: (l10n) => l10n?.countdownAcronym ?? 'Universal Timer',
      color: const Color(0xFFFF4081),
      gradientSecondColor: const Color(0xFFF50057),
      icon: Icons.hourglass_bottom_rounded,
      buildScreen: () => const CountdownScreen(),
    ),
    'custom': TimerCatalogItem(
      id: 'custom',
      getTitle: (l10n) => l10n?.custom ?? 'CUSTOM & WODS',
      getSubtitle: (l10n) =>
          l10n?.customSubtitle ?? 'Hero WODs & Custom Routines',
      color: const Color(0xFF00BFA5),
      gradientSecondColor: const Color(0xFF1DE9B6),
      icon: Icons.fitness_center_rounded,
      buildScreen: () => const CustomRoutinesScreen(),
    ),
    'workout_log': TimerCatalogItem(
      id: 'workout_log',
      getTitle: (l10n) => l10n?.workoutLogs ?? 'WORKOUT LOG',
      getSubtitle: (l10n) =>
          l10n?.workoutLogSubtitle ?? 'History, Whiteboard & CSV',
      color: const Color(0xFFFF5252),
      gradientSecondColor: const Color(0xFFFF1744),
      icon: Icons.history_edu_rounded,
      buildScreen: () => const WorkoutLogScreen(),
    ),
  };

  void _showAddTimerBottomSheet() {
    AddTimerBottomSheet.show(
      context,
      catalog: _catalog,
      currentTimerOrder: _timerOrder,
      onAdd: _addTimer,
      onResetToDefault: _resetToDefault,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalog = _catalog;
    final activeItems = _timerOrder
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
                  tooltip: l10n?.addTimer ?? 'Zamanlayıcı Ekle',
                  onPressed: _showAddTimerBottomSheet,
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
                  l10n?.editHomeScreen ?? 'DÜZENLE',
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
                    l10n?.done ?? 'Bitti',
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
                    tooltip: l10n?.editHomeScreen ?? 'Ana Ekranı Düzenle',
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
              const crossAxisCount = 2;
              const spacing = 12.0;
              const horizontalPadding = 18.0;
              const childAspectRatio = 1.125;

              final itemWidth =
                  (constraints.maxWidth -
                      (horizontalPadding * 2) -
                      (spacing * (crossAxisCount - 1))) /
                  crossAxisCount;
              final itemHeight = itemWidth / childAspectRatio;

              final totalTiles =
                  activeItems.length + (_isEditing && hasHidden ? 1 : 0);

              return GridView.builder(
                padding: const EdgeInsets.only(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  top: 12.0,
                  bottom: 24.0,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: totalTiles,
                itemBuilder: (ctx, index) {
                  if (index >= activeItems.length) {
                    return AddTimerTile(onTap: _showAddTimerBottomSheet);
                  }

                  final item = activeItems[index];

                  return DragTarget<String>(
                    onWillAcceptWithDetails: (details) =>
                        details.data != item.id,
                    onAcceptWithDetails: (details) {
                      final fromIndex = _timerOrder.indexOf(details.data);
                      final toIndex = _timerOrder.indexOf(item.id);
                      if (fromIndex != -1 &&
                          toIndex != -1 &&
                          fromIndex != toIndex) {
                        setState(() {
                          final moved = _timerOrder.removeAt(fromIndex);
                          _timerOrder.insert(toIndex, moved);
                        });
                        _saveOrder();
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
                                        onRemove: () => _removeTimer(item.id),
                                      ),
                                    )
                                  : HomeTimerCard(
                                      item: item,
                                      isEditing: false,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => item.buildScreen(),
                                          ),
                                        );
                                      },
                                      onLongPress: () => _toggleEditing(true),
                                      onRemove: () => _removeTimer(item.id),
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
