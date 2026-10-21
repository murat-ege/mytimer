import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/custom_routine.dart';
import '../../repositories/local_timer_repository.dart';
import '../timer_runner/timer_runner_screen.dart';
import 'custom_routine_builder_screen.dart';
import 'widgets/custom_routine_card.dart';

class CustomRoutinesScreen extends StatefulWidget {
  const CustomRoutinesScreen({super.key});

  @override
  State<CustomRoutinesScreen> createState() => _CustomRoutinesScreenState();
}

class _CustomRoutinesScreenState extends State<CustomRoutinesScreen> {
  final LocalTimerRepository _repository = LocalTimerRepository();
  final TextEditingController _searchController = TextEditingController();

  List<CustomRoutine> _routines = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'ALL';

  final List<String> _categories = [
    'ALL',
    'HYROX',
    'The Girls',
    'Hero WOD',
    'Benchmark',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    _loadRoutines();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRoutines() async {
    setState(() => _isLoading = true);
    final list = await _repository.getRoutines();
    if (mounted) {
      setState(() {
        _routines = list;
        _isLoading = false;
      });
    }
  }

  List<CustomRoutine> get _filteredRoutines {
    return _routines.where((r) {
      final query = _searchQuery.toLowerCase().trim();
      final matchesSearch =
          query.isEmpty ||
          r.name.toLowerCase().contains(query) ||
          r.description.toLowerCase().contains(query);

      final matchesCategory =
          _selectedCategory == 'ALL' ||
          (_selectedCategory == 'Custom'
              ? (r.category == 'Custom' || r.category == 'Özel')
              : r.category == _selectedCategory);

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _openBuilder([CustomRoutine? routine]) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CustomRoutineBuilderScreen(initialRoutine: routine),
      ),
    );
    if (result == true) {
      _loadRoutines();
    }
  }

  void _startRoutine(CustomRoutine routine) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TimerRunnerScreen(routine: routine)),
    );
  }

  void _deleteRoutine(CustomRoutine routine) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          l10n?.deleteTimerTitle ?? 'Delete Timer?',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n?.deleteTimerConfirm(routine.name) ??
              '${routine.name} will be deleted. Are you sure?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n?.cancel ?? 'CANCEL',
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n?.delete ?? 'DELETE',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.deleteRoutine(routine.id);
      _loadRoutines();
    }
  }

  String _formatTotalSeconds(int totalSecs, AppLocalizations? l10n) {
    final mins = totalSecs ~/ 60;
    final secs = totalSecs % 60;
    final sUnit = l10n?.seconds ?? 's';
    final mUnit = l10n?.minutes ?? 'min';
    if (mins == 0) return '$secs$sUnit';
    return '$mins$mUnit ${secs > 0 ? '$secs$sUnit' : ''}'.trim();
  }

  String _getCategoryDisplayName(String cat, AppLocalizations? l10n) {
    if (cat == 'ALL') return l10n?.allCategories ?? 'ALL';
    if (cat == 'Custom' || cat == 'Özel') {
      return l10n?.categoryCustom ?? 'Custom';
    }
    return cat;
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'The Girls':
        return const Color(0xFFFF4081); // Vibrant Pink
      case 'Hero WOD':
        return const Color(0xFFFF3D00); // Fiery Red/Orange
      case 'Benchmark':
        return const Color(0xFF00E5FF); // Electric Cyan
      case 'Özel':
      case 'Custom':
        return const Color(0xFF00BFA5); // Vivid Teal
      default:
        return const Color(0xFFFFB300); // Amber
    }
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
          l10n?.custom ?? 'WOD & ÖZEL TİMERLAR',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00BFA5)),
            )
          : Column(
              children: [
                // 1. Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 6.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText:
                            l10n?.searchWods ??
                            'WOD ara (Örn: Fran, Murph, Thruster, Pull-up)...',
                        hintStyle: const TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF00BFA5),
                          size: 22,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.white54,
                                  size: 20,
                                ),
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

                // 2. Category Filter Chips (Horizontal Scroll)
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (context, idx) {
                      final cat = _categories[idx];
                      final isSelected = _selectedCategory == cat;
                      final displayCat = _getCategoryDisplayName(cat, l10n);
                      final count = cat == 'ALL'
                          ? _routines.length
                          : _routines
                                .where(
                                  (r) => cat == 'Custom'
                                      ? (r.category == 'Custom' ||
                                            r.category == 'Özel')
                                      : r.category == cat,
                                )
                                .length;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(
                            '$displayCat ($count)'.replaceAll(' ', '\u00A0'),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white70,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          },
                          backgroundColor: const Color(0xFF1E1E1E),
                          selectedColor: const Color(0xFF00BFA5),
                          checkmarkColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF00BFA5)
                                  : Colors.white12,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 4),

                // 3. Results Count Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 4.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n?.workoutsListed(filtered.length) ??
                            '${filtered.length} workouts listed',
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

                // 4. Routines List
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 54,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n?.noWorkoutsFound(_searchQuery) ??
                                    'No workouts found for "$_searchQuery"',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                    _selectedCategory = 'ALL';
                                  });
                                },
                                child: Text(
                                  l10n?.showAllWods ?? 'Show All WODs',
                                  style: const TextStyle(
                                    color: Color(0xFF00E676),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final routine = filtered[index];
                            final card = CustomRoutineCard(
                              routine: routine,
                              categoryColor: _getCategoryColor(routine.category),
                              onTap: () => _startRoutine(routine),
                              onEdit: () => _openBuilder(routine),
                              onDelete: () => _deleteRoutine(routine),
                              formattedTotalDuration: _formatTotalSeconds(
                                routine.totalDurationSeconds,
                                l10n,
                              ),
                            );

                            if (routine.isPreset) {
                              return card;
                            }
                            return Dismissible(
                              key: Key('routine_${routine.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE53935),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                              onDismissed: (_) => _deleteRoutine(routine),
                              child: card,
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openBuilder(),
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add, size: 24),
        label: Text(
          l10n?.createRoutine ?? 'CREATE TIMER',
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ),
    );
  }
}
