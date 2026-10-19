import 'package:flutter/material.dart';
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
  List<CustomRoutine> _routines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoutines();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'ÖZEL TİMERLAR',
          style: TextStyle(
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
                // Cloud Sync Notice Banner
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_done_outlined, color: Color(0xFF00E5FF), size: 22),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Timer verileriniz lokal cihazınızda güvendedir. Gelecekteki hesap senkronizasyonu için hazırlandı.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

                // Routines List
                Expanded(
                  child: _routines.isEmpty
                      ? Center(
                          child: Text(
                            'Kayıtlı timer bulunamadı. Yeni bir tane ekleyin!',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _routines.length,
                          itemBuilder: (context, index) {
                            final routine = _routines[index];
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
        label: const Text(
          'YENİ TİMER',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _buildRoutineCard(CustomRoutine routine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        routine.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.white60, size: 20),
                      onPressed: () => _openBuilder(routine),
                      tooltip: 'Düzenle',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: () => _deleteRoutine(routine),
                      tooltip: 'Sil',
                    ),
                  ],
                ),
                if (routine.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    routine.description,
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
