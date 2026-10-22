import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../data/timer_presets_data.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/custom_routine.dart';
import '../../repositories/local_timer_repository.dart';
import '../../shared/utils/home_timer_helper.dart';
import 'widgets/edit_preset_sheet.dart';
import 'widgets/preset_list_card.dart';
import 'widgets/select_preset_type_sheet.dart';

class TimerManagerScreen extends StatefulWidget {
  final String? initialCategory;

  const TimerManagerScreen({super.key, this.initialCategory});

  @override
  State<TimerManagerScreen> createState() => _TimerManagerScreenState();
}

class _TimerManagerScreenState extends State<TimerManagerScreen> {
  final LocalTimerRepository _repository = LocalTimerRepository();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _chipScrollController = ScrollController();

  List<CustomRoutine> _routines = [];
  Set<String> _pinnedIds = {};
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'ALL';

  final List<String> _categories = [
    'ALL',
    'standart',
    'crossfit',
    'hyrox',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      final initial = widget.initialCategory!.toLowerCase().trim().replaceAll(' ', '').replaceAll('_', '');
      if (initial.contains('crossfit') ||
          initial.contains('hero') ||
          initial.contains('girl') ||
          initial.contains('bench')) {
        _selectedCategory = 'crossfit';
      } else if (initial.contains('hyrox')) {
        _selectedCategory = 'hyrox';
      } else if (initial.contains('tabata') ||
          initial.contains('round') ||
          initial.contains('emom') ||
          initial.contains('amrap') ||
          initial.contains('fortime') ||
          initial.contains('countdown') ||
          initial.contains('standart')) {
        _selectedCategory = 'standart';
      } else {
        _selectedCategory = 'ALL';
      }
    } else {
      _selectedCategory = 'ALL';
    }

    _loadRoutines();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _chipScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRoutines() async {
    setState(() => _isLoading = true);
    final all = await _repository.getRoutines();
    final pinned = <String>{};
    for (final r in all) {
      if (await HomeTimerHelper.isPinned(r.id, category: r.category)) {
        pinned.add(r.id);
      }
    }
    if (mounted) {
      setState(() {
        _routines = all;
        _pinnedIds = pinned;
        _isLoading = false;
      });
    }
  }

  String _getCategoryDisplayName(String cat, AppLocalizations? l10n) {
    final lower = cat.toLowerCase().trim().replaceAll(' ', '').replaceAll('_', '');
    if (lower == 'all') return l10n?.allCategories ?? 'ALL';
    if (lower == 'standart' || lower == 'standard') return 'STANDART';
    if (lower == 'crossfit') return 'CROSSFIT';
    if (lower.contains('hyrox')) return 'HYROX';
    return cat.toUpperCase();
  }

  String? get _initialStandardSubtype {
    if (widget.initialCategory == null) return null;
    final initial = widget.initialCategory!.toLowerCase().trim().replaceAll(' ', '').replaceAll('_', '');
    if (initial.contains('tabata')) return 'tabata';
    if (initial.contains('round')) return 'round';
    if (initial.contains('emom')) return 'emom';
    if (initial.contains('amrap')) return 'amrap';
    if (initial.contains('fortime')) return 'fortime';
    if (initial.contains('countdown')) return 'countdown';
    return null;
  }

  bool _matchesCategory(String rCat, String selCat) {
    if (selCat == 'all') return true;

    if (selCat == 'standart' || selCat == 'standard') {
      final subtype = _initialStandardSubtype;
      if (subtype != null) {
        return rCat.contains(subtype);
      }
      return rCat.contains('standart') ||
          rCat.contains('standard') ||
          rCat.contains('tabata') ||
          rCat.contains('round') ||
          rCat.contains('emom') ||
          rCat.contains('amrap') ||
          rCat.contains('fortime') ||
          rCat.contains('countdown');
    }

    if (selCat == 'crossfit') {
      return rCat.contains('hero') ||
          rCat.contains('girl') ||
          rCat.contains('benchmark') ||
          rCat.contains('bench') ||
          rCat.contains('crossfit');
    }

    if (selCat == 'hyrox') {
      return rCat.contains('hyrox');
    }

    return rCat.contains(selCat);
  }

  List<CustomRoutine> get _filteredRoutines {
    final list = _routines.where((r) {
      final query = _searchQuery.toLowerCase().trim();
      final matchesSearch = query.isEmpty ||
          r.name.toLowerCase().contains(query) ||
          r.description.toLowerCase().contains(query) ||
          r.category.toLowerCase().contains(query);

      final rCat = r.category.toLowerCase().trim().replaceAll(' ', '').replaceAll('_', '');
      final selCat = _selectedCategory.toLowerCase().trim().replaceAll(' ', '').replaceAll('_', '');

      final matchesCategory = _matchesCategory(rCat, selCat);

      return matchesSearch && matchesCategory;
    }).toList();

    list.sort(_compareRoutines);
    return list;
  }

  int _compareRoutines(CustomRoutine a, CustomRoutine b) {
    final catRankA = _getMainCategoryRank(a);
    final catRankB = _getMainCategoryRank(b);

    if (catRankA != catRankB) {
      return catRankA.compareTo(catRankB);
    }

    if (catRankA == 1) {
      final subA = _getStandardSubcategoryRank(a);
      final subB = _getStandardSubcategoryRank(b);
      if (subA != subB) {
        return subA.compareTo(subB);
      }
      return a.name.compareTo(b.name);
    } else if (catRankA == 2) {
      final subA = _getCrossfitSubcategoryRank(a);
      final subB = _getCrossfitSubcategoryRank(b);
      if (subA != subB) {
        return subA.compareTo(subB);
      }
      return a.name.compareTo(b.name);
    } else if (catRankA == 3) {
      return a.name.compareTo(b.name);
    } else {
      final catCmp = a.category.compareTo(b.category);
      if (catCmp != 0) return catCmp;
      return a.name.compareTo(b.name);
    }
  }

  int _getMainCategoryRank(CustomRoutine r) {
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

  int _getStandardSubcategoryRank(CustomRoutine r) {
    final cat = r.category.toLowerCase().trim().replaceAll(' ', '').replaceAll('_', '');
    if (cat.contains('tabata')) return 1;
    if (cat.contains('round')) return 2;
    if (cat.contains('emom')) return 3;
    if (cat.contains('amrap')) return 4;
    if (cat.contains('fortime')) return 5;
    if (cat.contains('countdown')) return 6;
    return 7;
  }

  int _getCrossfitSubcategoryRank(CustomRoutine r) {
    final cat = r.category.toLowerCase().trim().replaceAll(' ', '').replaceAll('_', '');
    if (cat.contains('hero')) return 1;
    if (cat.contains('girl')) return 2;
    if (cat.contains('benchmark') || cat.contains('bench')) return 3;
    return 4;
  }

  Future<void> _editPresetDetails(CustomRoutine routine, {bool isNew = false}) async {
    final l10n = AppLocalizations.of(context);

    await EditPresetSheet.show(
      context: context,
      routine: routine,
      onOpenInTimer: (previewRoutine) {
        _openPresetInTimer(previewRoutine);
      },
      onSaved: (updated) async {
        await _repository.saveRoutine(updated);
        final bool shouldPin = isNew || routine.isPreset;
        if (shouldPin) {
          await HomeTimerHelper.pin(updated.id, category: updated.category);
        }
        await _loadRoutines();
        HapticFeedback.mediumImpact();
        if (mounted) {
          final message = shouldPin
              ? '${updated.name} ${l10n?.pinnedToHome.toLowerCase() ?? 'ana ekrana eklendi'}'
              : (l10n?.timerUpdated ?? 'Timer updated successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  String? _resolveTargetTimerType() {
    final currentNorm = _selectedCategory.toLowerCase().trim().replaceAll(' ', '').replaceAll('_', '');
    final initialNorm = widget.initialCategory?.toLowerCase().trim().replaceAll(' ', '').replaceAll('_', '') ?? '';

    for (final norm in [currentNorm, initialNorm]) {
      if (norm.isEmpty || norm == 'all') continue;
      if (norm.contains('tabata')) return 'tabata';
      if (norm.contains('round')) return 'rounds';
      if (norm.contains('emom')) return 'emom';
      if (norm.contains('amrap')) return 'amrap';
      if (norm.contains('fortime')) return 'fortime';
      if (norm.contains('countdown')) return 'countdown';
    }
    return null;
  }

  Future<void> _createPresetForType(String cat) async {
    final defaultPreset = TimerPresetsData.getDefaultTimerPresets()
        .firstWhere((p) => p.category.toLowerCase().replaceAll(' ', '').replaceAll('_', '').contains(cat));

    final newCustom = defaultPreset.copyWith(
      id: const Uuid().v4(),
      name: '${defaultPreset.name} (Custom)',
      isPreset: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _editPresetDetails(newCustom, isNew: true);
  }

  Future<void> _createNewPreset() async {
    final directType = _resolveTargetTimerType();
    if (directType != null) {
      await _createPresetForType(directType);
      return;
    }

    final cat = await SelectPresetTypeSheet.show(context);
    if (cat != null && mounted) {
      await _createPresetForType(cat);
    }
  }

  Future<void> _deletePreset(CustomRoutine routine) async {
    final l10n = AppLocalizations.of(context);
    if (routine.isPreset) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.builtInPresetsProtected ??
                  'Built-in standard timers are protected and cannot be deleted. You can unpin them from the home screen.',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n?.deleteTimerTitle ?? 'Delete Timer?',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n?.deleteTimerConfirm ??
              'Are you sure you want to delete this timer? It will also be removed from the home screen.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n?.cancel ?? 'CANCEL',
              style: const TextStyle(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n?.delete ?? 'DELETE',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.deleteRoutine(routine.id);
      await _loadRoutines();
      HapticFeedback.mediumImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${routine.name} silindi'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _openPresetInTimer(CustomRoutine routine) async {
    final screen = HomeTimerHelper.buildScreenForRoutine(routine);
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
    if (mounted) {
      _loadRoutines();
    }
  }

  int _countForCategory(String cat) {
    final selCat = cat.toLowerCase().trim().replaceAll(' ', '').replaceAll('_', '');
    if (selCat == 'all') return _routines.length;
    return _routines.where((r) {
      final rCat = r.category.toLowerCase().trim().replaceAll(' ', '').replaceAll('_', '');
      return _matchesCategory(rCat, selCat);
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filtered = _filteredRoutines;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n?.timerManager.toUpperCase() ?? 'TIMER MANAGER',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)))
          : Column(
              children: [
                // 1. Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: l10n?.searchTimersHint ?? 'Search timers...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF00E676)),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white60),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. Category Filter Chips
                SizedBox(
                  height: 46,
                  child: ListView.builder(
                    controller: _chipScrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: _categories.length,
                    itemBuilder: (context, idx) {
                      final cat = _categories[idx];
                      final isSelected = _selectedCategory == cat;
                      final displayName = _getCategoryDisplayName(cat, l10n);
                      final count = _countForCategory(cat);

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(
                            '$displayName ($count)'.replaceAll(' ', '\u00A0'),
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white70,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                          backgroundColor: const Color(0xFF1E1E1E),
                          selectedColor: const Color(0xFF00E676),
                          checkmarkColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF00E676) : Colors.white12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 3. Status Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filtered.length} ${l10n?.savedTimers ?? 'timers'}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_searchQuery.isNotEmpty || _selectedCategory != 'ALL')
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _selectedCategory = 'ALL';
                            });
                          },
                          child: Text(
                            l10n?.clearFilters ?? 'Clear Filters',
                            style: const TextStyle(
                              color: Color(0xFF00E676),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // 4. Presets List
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.bookmark_outline_rounded,
                                  color: Colors.white24,
                                  size: 56,
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  l10n?.noTimersAvailable ?? 'No saved timers found yet.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final routine = filtered[index];
                            final isPinned = _pinnedIds.contains(routine.id);

                            return PresetListCard(
                              routine: routine,
                              isPinned: isPinned,
                              onTap: () => _openPresetInTimer(routine),
                              onTogglePin: () async {
                                final pinned = await HomeTimerHelper.togglePin(routine.id);
                                setState(() {
                                  if (pinned) {
                                    _pinnedIds.add(routine.id);
                                  } else {
                                    _pinnedIds.remove(routine.id);
                                  }
                                });
                                HapticFeedback.lightImpact();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        pinned
                                            ? (l10n?.pinnedToHome ?? 'Added to Home Screen')
                                            : (l10n?.unpinnedFromHome ?? 'Removed from Home Screen'),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              onEdit: () => _editPresetDetails(routine),
                              onDelete: () => _deletePreset(routine),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: Builder(
        builder: (ctx) {
          final directType = _resolveTargetTimerType();
          final fabColor = directType != null
              ? HomeTimerHelper.getCategoryColor(directType)
              : const Color(0xFF00E676);
          final fabTextColor = fabColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

          return FloatingActionButton.extended(
            backgroundColor: fabColor,
            foregroundColor: fabTextColor,
            icon: const Icon(Icons.add_rounded, size: 22),
            label: Text(
              directType != null
                  ? (l10n?.addCategoryTimer(_getCategoryDisplayName(directType, l10n)) ??
                      'Add ${_getCategoryDisplayName(directType, l10n)}')
                  : (l10n?.newTimer ?? 'New Timer'),
              style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
            onPressed: _createNewPreset,
          );
        },
      ),
    );
  }
}
