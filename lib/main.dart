import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'l10n/generated/app_localizations.dart';
import 'repositories/local_timer_repository.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/sound_service.dart';

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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
      ],
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
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: HomeScreen(
        currentLocale: _locale,
        onLocaleChanged: _setLocale,
      ),
    );
  }
}
