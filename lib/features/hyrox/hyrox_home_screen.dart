import 'package:flutter/material.dart';
import '../../data/hyrox_data.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/custom_routine.dart';
import '../../models/interval_step.dart';
import '../../models/timer_phase.dart';
import '../timer_runner/timer_runner_screen.dart';
import 'hyrox_compromised_screen.dart';
import 'hyrox_doubles_timer_screen.dart';
import 'hyrox_race_screen.dart';
import 'hyrox_standards_sheet.dart';
import 'hyrox_station_test_screen.dart';
import 'widgets/hyrox_preset_card.dart';
import 'widgets/hyrox_race_hero_card.dart';
import 'widgets/hyrox_timer_tile.dart';

class HyroxHomeScreen extends StatelessWidget {
  const HyroxHomeScreen({super.key});

  static const Color hyroxYellow = Color(0xFFFFE600);

  void _startPemomIntervals(BuildContext context, {int workSecs = 90, int restSecs = 30, int rounds = 8}) {
    final now = DateTime.now();
    final List<IntervalStep> intervals = [];

    for (int i = 0; i < rounds; i++) {
      final station = HyroxData.stations[i % HyroxData.stations.length];
      intervals.add(
        IntervalStep(
          id: 'step_station_$i',
          name: '${station.name.toUpperCase()} (${station.distanceOrReps})',
          durationSeconds: workSecs,
          phase: TimerPhase.work,
        ),
      );
      if (restSecs > 0) {
        intervals.add(
          IntervalStep(
            id: 'step_rest_$i',
            name: 'STATION TRANSITION / REST',
            durationSeconds: restSecs,
            phase: TimerPhase.rest,
          ),
        );
      }
    }

    final routine = CustomRoutine(
      id: 'hyrox_pemom_${now.millisecondsSinceEpoch}',
      name: 'HYROX STATION P-EMOM ($rounds STATIONS)',
      description: '$workSecs sec work / $restSecs sec rest across official stations.',
      category: 'HYROX',
      prepSeconds: 15,
      rounds: 1,
      intervals: intervals,
      createdAt: now,
      updatedAt: now,
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TimerRunnerScreen(routine: routine)),
    );
  }

  void _showPemomOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: hyroxYellow.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.repeat_rounded, color: hyroxYellow, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'HYROX STATION P-EMOM',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Select your work / rest format across the 8 official stations:',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              _pemomTile(
                ctx,
                title: '90s Work / 30s Rest (Recommended)',
                subtitle: '8 Stations • 16 Mins Total • High Intensity Focus',
                onTap: () {
                  Navigator.of(ctx).pop();
                  _startPemomIntervals(context, workSecs: 90, restSecs: 30, rounds: 8);
                },
              ),
              const SizedBox(height: 10),
              _pemomTile(
                ctx,
                title: '60s Work / 30s Rest (Speed & Recovery)',
                subtitle: '8 Stations • 12 Mins Total • Fast transitions',
                onTap: () {
                  Navigator.of(ctx).pop();
                  _startPemomIntervals(context, workSecs: 60, restSecs: 30, rounds: 8);
                },
              ),
              const SizedBox(height: 10),
              _pemomTile(
                ctx,
                title: '2 Mins Work / 1 Min Rest (Endurance Volume)',
                subtitle: '8 Stations • 24 Mins Total • Heavy volume simulation',
                onTap: () {
                  Navigator.of(ctx).pop();
                  _startPemomIntervals(context, workSecs: 120, restSecs: 60, rounds: 8);
                },
              ),
              const SizedBox(height: 10),
              _pemomTile(
                ctx,
                title: 'Double Circuit (16 Stations • 90s/30s)',
                subtitle: '16 Stations • 32 Mins Total • Race simulation volume',
                onTap: () {
                  Navigator.of(ctx).pop();
                  _startPemomIntervals(context, workSecs: 90, restSecs: 30, rounds: 16);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pemomTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF282828),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: hyroxYellow,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'HYROX',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'TIMER SUITE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO RACE SIMULATOR CARD
            HyroxRaceHeroCard(
              hyroxYellow: hyroxYellow,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HyroxRaceScreen()),
                );
              },
            ),

            const SizedBox(height: 24),

            // Section: DEDICATED HYROX TRAINING TIMERS
            const Text(
              'SPECIALIZED TRAINING TIMERS',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            // 2x2 Grid for training timers
            Row(
              children: [
                Expanded(
                  child: HyroxTimerTile(
                    title: l10n?.hyroxCompromisedRun ?? 'Compromised Running',
                    subtitle: 'Run + Station Blocks',
                    icon: Icons.directions_run_rounded,
                    accentColor: const Color(0xFFFF9100),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HyroxCompromisedScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HyroxTimerTile(
                    title: l10n?.hyroxStationIntervals ?? 'Station P-EMOM',
                    subtitle: '8-Station Cadence',
                    icon: Icons.repeat_rounded,
                    accentColor: hyroxYellow,
                    onTap: () => _showPemomOptionsModal(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: HyroxTimerTile(
                    title: l10n?.hyroxDoublesTimer ?? 'Doubles (IGYG)',
                    subtitle: 'Partner Switch Timer',
                    icon: Icons.people_alt_rounded,
                    accentColor: const Color(0xFF00E5FF),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HyroxDoublesTimerScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HyroxTimerTile(
                    title: l10n?.hyroxBenchmarkTests ?? 'Benchmark Tests',
                    subtitle: 'Single Station PRs',
                    icon: Icons.flag_rounded,
                    accentColor: const Color(0xFF00E676),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HyroxStationTestScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Standards & Rules Quick Card
            _buildStandardsGuideCard(context, l10n),

            const SizedBox(height: 24),

            // Section: FEATURED PRESET WODS
            const Text(
              'PRE-CONFIGURED HYROX WORKOUTS',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            ...HyroxData.getHyroxPresets().map((preset) {
              return HyroxPresetCard(
                routine: preset,
                hyroxYellow: hyroxYellow,
              );
            }),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardsGuideCard(BuildContext context, AppLocalizations? l10n) {
    return InkWell(
      onTap: () => HyroxStandardsSheet.show(context),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF181818),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: hyroxYellow.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.fitness_center_rounded, color: hyroxYellow, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.hyroxStandardsGuide ?? 'Official Division Weights & Rules',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Men / Women Open, Pro & Doubles station weights',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
          ],
        ),
      ),
    );
  }
}
