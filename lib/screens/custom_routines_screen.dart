import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/custom_routine.dart';
import '../repositories/local_timer_repository.dart';
import 'custom_routine_builder_screen.dart';
import 'timer_runner_screen.dart';

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
  String _selectedCategory = 'Hepsi';

  final List<String> _categories = [
    'Hepsi',
    'The Girls',
    'Hero WOD',
    'Benchmark',
    'Özel',
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
      final matchesSearch = query.isEmpty ||
          r.name.toLowerCase().contains(query) ||
          r.description.toLowerCase().contains(query);

      final matchesCategory = _selectedCategory == 'Hepsi' ||
          (_selectedCategory == 'Özel'
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
      MaterialPageRoute(
        builder: (_) => TimerRunnerScreen(routine: routine),
      ),
    );
  }

  void _deleteRoutine(CustomRoutine routine) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Timer Silinsin mi?', style: TextStyle(color: Colors.white)),
        content: Text(
          '${routine.name} silinecektir. Onaylıyor musunuz?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İPTAL', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('SİL', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.deleteRoutine(routine.id);
      _loadRoutines();
    }
  }

  String _formatTotalSeconds(int totalSecs) {
    final mins = totalSecs ~/ 60;
    final secs = totalSecs % 60;
    if (mins == 0) return '${secs}sn';
    return '${mins}dk ${secs > 0 ? '${secs}sn' : ''}';
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
        return const Color(0xFF00E676); // High Voltage Green
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
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)))
          : Column(
              children: [
                // 1. Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
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
                        hintText: l10n?.searchWods ?? 'WOD ara (Örn: Fran, Murph, Thruster, Pull-up)...',
                        hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF00E676), size: 22),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white54, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),

                // 2. Category Filter Chips (Horizontal Scroll)
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: _categories.length,
                    itemBuilder: (context, idx) {
                      final cat = _categories[idx];
                      final isSelected = _selectedCategory == cat;
                      final displayCat = cat == 'Hepsi' ? (l10n?.allCategories ?? 'TÜMÜ') : cat;
                      final count = cat == 'Hepsi'
                          ? _routines.length
                          : _routines.where((r) => cat == 'Özel' ? (r.category == 'Custom' || r.category == 'Özel') : r.category == cat).length;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(
                            '$displayCat ($count)',
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white70,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          },
                          backgroundColor: const Color(0xFF1E1E1E),
                          selectedColor: const Color(0xFF00E676),
                          checkmarkColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF00E676) : Colors.white12,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 4),

                // 3. Results Count Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filtered.length} antrenman listeleniyor',
                        style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      if (_searchQuery.isNotEmpty || _selectedCategory != 'Hepsi')
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _selectedCategory = 'Hepsi';
                            });
                          },
                          child: const Text(
                            'Filtreleri Temizle',
                            style: TextStyle(color: Color(0xFF00E676), fontSize: 12, fontWeight: FontWeight.bold),
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
                              Icon(Icons.search_off, size: 54, color: Colors.white.withValues(alpha: 0.3)),
                              const SizedBox(height: 12),
                              Text(
                                '"$_searchQuery" için antrenman bulunamadı',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 15),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                    _selectedCategory = 'Hepsi';
                                  });
                                },
                                child: const Text('Tüm WOD''ları Göster', style: TextStyle(color: Color(0xFF00E676))),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final routine = filtered[index];
                            return _buildRoutineCard(routine);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openBuilder(),
        backgroundColor: const Color(0xFF00E676),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add, size: 24),
        label: Text(
          l10n?.createNewRoutine ?? 'YENİ TİMER',
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _buildRoutineCard(CustomRoutine routine) {
    final catColor = _getCategoryColor(routine.category);
    final isPreset = routine.isPreset;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: catColor.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _startRoutine(routine),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Category tag and Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: catColor.withValues(alpha: 0.4), width: 1),
                      ),
                      child: Text(
                        routine.category.toUpperCase(),
                        style: TextStyle(
                          color: catColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.white60, size: 20),
                          onPressed: () => _openBuilder(routine),
                          tooltip: isPreset ? 'Özelleştir / Yeni İsimle Kaydet' : 'Düzenle',
                          visualDensity: VisualDensity.compact,
                        ),
                        if (!isPreset)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            onPressed: () => _deleteRoutine(routine),
                            tooltip: 'Sil',
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Routine Name
                Text(
                  routine.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                if (routine.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    routine.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                  ),
                ],

                const SizedBox(height: 12),

                // Badges Row
                Row(
                  children: [
                    _buildBadge(
                      Icons.repeat,
                      '${routine.rounds} Tur',
                      const Color(0xFFFFB300),
                    ),
                    const SizedBox(width: 8),
                    _buildBadge(
                      Icons.list_alt,
                      '${routine.intervals.length} Aralık',
                      const Color(0xFF00E5FF),
                    ),
                    const SizedBox(width: 8),
                    _buildBadge(
                      Icons.timer_outlined,
                      _formatTotalSeconds(routine.totalDurationSeconds),
                      const Color(0xFF00E676),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.play_arrow, color: Colors.black, size: 16),
                          SizedBox(width: 2),
                          Text(
                            'BAŞLAT',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
