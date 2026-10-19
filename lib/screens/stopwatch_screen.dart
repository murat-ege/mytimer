import 'package:flutter/material.dart';
import '../controllers/stopwatch_controller.dart';
import '../l10n/generated/app_localizations.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final StopwatchController _controller = StopwatchController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onUpdate);
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final laps = _controller.laps;
    final fastest = _controller.fastestLapMs;
    final slowest = _controller.slowestLapMs;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n?.stopwatch ?? 'KRONOMETRE',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Big Digital Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  StopwatchController.formatMs(_controller.elapsedMs),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 76,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ),

          // Control Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Reset / Lap Button
                _buildCircularButton(
                  label: _controller.isRunning ? (l10n?.lap ?? 'TUR') : (l10n?.reset ?? 'SIFIRLA'),
                  color: Colors.white24,
                  textColor: Colors.white,
                  onTap: () {
                    if (_controller.isRunning) {
                      _controller.recordLap();
                    } else {
                      _controller.reset();
                    }
                  },
                ),

                // Start / Stop Button
                _buildCircularButton(
                  label: _controller.isRunning ? (l10n?.pause ?? 'DURDUR') : (l10n?.start ?? 'BAŞLAT'),
                  color: _controller.isRunning
                      ? const Color(0xFFFF3D00)
                      : const Color(0xFF00E676),
                  textColor: Colors.black,
                  onTap: () {
                    if (_controller.isRunning) {
                      _controller.pause();
                    } else {
                      _controller.start();
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(color: Colors.white12, height: 1),

          // Laps Header
          if (laps.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n?.round ?? 'TUR', style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(l10n?.roundTime ?? 'TUR SÜRESİ', style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(l10n?.totalTime ?? 'TOPLAM', style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),

          // Laps List
          Expanded(
            child: laps.isEmpty
                ? Center(
                    child: Text(
                      'Henüz tur kaydedilmedi',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    itemCount: laps.length,
                    separatorBuilder: (_, _) => const Divider(color: Colors.white10, height: 1),
                    itemBuilder: (context, index) {
                      final lap = laps[index];
                      Color lapColor = Colors.white;

                      if (fastest != null && lap.lapTimeMs == fastest) {
                        lapColor = const Color(0xFF00E676);
                      } else if (slowest != null && lap.lapTimeMs == slowest) {
                        lapColor = const Color(0xFFFF3D00);
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tur ${lap.lapNumber.toString().padLeft(2, '0')}',
                              style: TextStyle(color: lapColor, fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            Text(
                              StopwatchController.formatMs(lap.lapTimeMs),
                              style: TextStyle(
                                color: lapColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                            Text(
                              StopwatchController.formatMs(lap.splitTimeMs, showMs: false),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 15,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
