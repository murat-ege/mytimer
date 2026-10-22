import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'l10n/generated/app_localizations.dart';
import 'repositories/local_timer_repository.dart';
import 'features/home/home_screen.dart';
import 'features/splash/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/sound_service.dart';
import 'services/voice_coach_service.dart';
import 'shared/theme/app_typography.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive CE
  await Hive.initFlutter();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF181818),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize core services
  await SoundService().init();
  await NotificationService().init();

  // Load saved settings
  final repository = LocalTimerRepository();
  final settings = await repository.getSettings();

  // Apply sound and voice settings
  SoundService().soundEnabled = settings.soundEnabled;
  SoundService().vibrationEnabled = settings.vibrationEnabled;
  SoundService().currentThemeId = settings.audioThemeId;

  await VoiceCoachService().init();
  await VoiceCoachService().updateConfig(
    enabled: settings.voiceCoachEnabled,
    voiceId: settings.voiceCoachId,
    lang: settings.languageCode,
  );

  runApp(MyTimerApp(initialLocale: Locale(settings.languageCode)));
}

class MyTimerApp extends StatefulWidget {
  final Locale initialLocale;

  const MyTimerApp({super.key, required this.initialLocale});

  @override
  State<MyTimerApp> createState() => _MyTimerAppState();
}

class _MyTimerAppState extends State<MyTimerApp> {
  late Locale _locale;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  void _setLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyTimer',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          secondary: Color(0xFFFFB300),
          surface: Color(0xFF1E1E1E),
          error: Color(0xFFFF3D00),
        ),
        textTheme: AppTypography.createTextTheme(),
        actionIconTheme: ActionIconThemeData(
          backButtonIconBuilder: (BuildContext context) => const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF121212),
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          titleTextStyle: AppTypography.athleticHeader(
            color: Colors.white,
            fontSize: 20,
            letterSpacing: 1.5,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _showSplash
            ? SplashScreen(
                key: const ValueKey('splash'),
                onFinish: () {
                  setState(() {
                    _showSplash = false;
                  });
                },
              )
            : HomeScreen(
                key: ValueKey('home_${_locale.languageCode}'),
                currentLocale: _locale,
                onLocaleChanged: _setLocale,
              ),
      ),
    );
  }
}
