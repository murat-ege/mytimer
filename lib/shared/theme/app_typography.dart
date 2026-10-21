import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized athletic & dynamic sports typography for MyTimer.
/// Uses Barlow for body/UI and Barlow Semi Condensed / Condensed for timers and titles.
class AppTypography {
  const AppTypography._();

  /// The primary font family name for Barlow.
  static String get fontFamily => GoogleFonts.barlow().fontFamily ?? 'Barlow';

  /// Athletic title / header style with condensed energy.
  static TextStyle athleticHeader({
    Color? color,
    double fontSize = 22,
    FontWeight fontWeight = FontWeight.w900,
    double letterSpacing = 2.0,
    List<Shadow>? shadows,
  }) {
    return GoogleFonts.barlowSemiCondensed(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      shadows: shadows,
    );
  }

  /// High-impact athletic digits for active timers, countdowns, and splits.
  /// Preconfigured with tabular figures so numbers don't jump during workouts.
  static TextStyle timerDigits({
    Color? color,
    double fontSize = 110,
    FontWeight fontWeight = FontWeight.w900,
    double letterSpacing = -1.5,
    List<Shadow>? shadows,
  }) {
    return GoogleFonts.barlowCondensed(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      fontFeatures: const [FontFeature.tabularFigures()],
      shadows: shadows,
    );
  }

  /// General body and UI text style.
  static TextStyle body({
    Color? color,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w600,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.barlow(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Builds a dark-mode optimized athletic text theme for MaterialApp.
  static TextTheme createTextTheme([TextTheme? base]) {
    final original = base ?? ThemeData.dark().textTheme;
    final barlowTheme = GoogleFonts.barlowTextTheme(original);

    return barlowTheme.copyWith(
      displayLarge: GoogleFonts.barlowCondensed(
        textStyle: barlowTheme.displayLarge,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.0,
      ),
      displayMedium: GoogleFonts.barlowCondensed(
        textStyle: barlowTheme.displayMedium,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.barlowCondensed(
        textStyle: barlowTheme.displaySmall,
        fontWeight: FontWeight.w800,
      ),
      headlineLarge: GoogleFonts.barlowSemiCondensed(
        textStyle: barlowTheme.headlineLarge,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
      headlineMedium: GoogleFonts.barlowSemiCondensed(
        textStyle: barlowTheme.headlineMedium,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
      ),
      headlineSmall: GoogleFonts.barlowSemiCondensed(
        textStyle: barlowTheme.headlineSmall,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      titleLarge: GoogleFonts.barlowSemiCondensed(
        textStyle: barlowTheme.titleLarge,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
      ),
      titleMedium: GoogleFonts.barlow(
        textStyle: barlowTheme.titleMedium,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: GoogleFonts.barlow(
        textStyle: barlowTheme.titleSmall,
        fontWeight: FontWeight.w600,
      ),
      labelLarge: GoogleFonts.barlowSemiCondensed(
        textStyle: barlowTheme.labelLarge,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }
}
