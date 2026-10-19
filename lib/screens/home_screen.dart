import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import 'custom_routines_screen.dart';
import 'rounds_screen.dart';
import 'settings_screen.dart';
import 'stopwatch_screen.dart';
import 'tabata_screen.dart';

class HomeScreen extends StatefulWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;

  const HomeScreen({
    super.key,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _initScreens();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLocale != widget.currentLocale) {
      _initScreens();
    }
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          currentLocale: widget.currentLocale,
          onLocaleChanged: widget.onLocaleChanged,
        ),
      ),
    );
  }

  void _initScreens() {
    _screens = [
      TabataScreen(
        key: ValueKey('tabata_${widget.currentLocale.languageCode}'),
        onOpenSettings: _openSettings,
      ),
      RoundsScreen(
        key: ValueKey('rounds_${widget.currentLocale.languageCode}'),
        onOpenSettings: _openSettings,
      ),
      StopwatchScreen(
        key: ValueKey('stopwatch_${widget.currentLocale.languageCode}'),
        onOpenSettings: _openSettings,
      ),
      CustomRoutinesScreen(
        key: ValueKey('custom_${widget.currentLocale.languageCode}'),
        onOpenSettings: _openSettings,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF181818),
          border: Border(top: BorderSide(color: Colors.white12, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF00E676),
          unselectedItemColor: Colors.white38,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.flash_on),
              label: l10n?.tabata ?? 'Tabata',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.fitness_center),
              label: l10n?.rounds ?? 'Rounds',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.timer),
              label: l10n?.stopwatch ?? 'Stopwatch',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.tune),
              label: l10n?.custom ?? 'Custom',
            ),
          ],
        ),
      ),
    );
  }
}
