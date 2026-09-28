import 'package:flutter/material.dart';

/// StudySprout palette.
/// Canonical visual preset name: 'WARM_EARTHY' (accents overridden for the brief).
class AppColors {
  const AppColors._();

  /// Canonical preset identifier — must stay one of the ten canonical presets.
  static const String name = 'WARM_EARTHY';

  static const Color bgTop = Color(0xFFF7FBF2);
  static const Color bgBottom = Color(0xFFEDF6E3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF2F8EA);
  static const Color border = Color(0xFFDCE9C9);

  static const Color primary = Color(0xFF7BAE4F);
  static const Color primaryDark = Color(0xFF5C8C3A);
  static const Color accent = Color(0xFFD9ED92);
  static const Color secondary = Color(0xFFF4A261);
  static const Color secondaryDark = Color(0xFFE08A44);

  static const Color textPrimary = Color(0xFF264653);
  static const Color textSecondary = Color(0xFF5C7A6B);
  static const Color textMuted = Color(0xFF8AA096);

  static const Color loaderTop = Color(0xFF17321F);
  static const Color loaderBottom = Color(0xFF0C1A12);
  static const Color loaderTitle = Color(0xFFF3F8E7);
  static const Color loaderSubtitle = Color(0xFF9BB88A);
  static const Color loaderStatus = Color(0xFF7D9470);

  static const Color danger = Color(0xFFD9534F);

  static const List<Color> ctaGradient = <Color>[primary, primaryDark];

  /// Shorthand for an alpha-adjusted copy of [color].
  static Color fade(Color color, double opacity) =>
      color.withValues(alpha: opacity);
}

class AppTheme {
  const AppTheme._();

  static ThemeData build() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.bgTop,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bgTop,
      splashColor: AppColors.fade(AppColors.accent, 0.28),
      highlightColor: Colors.transparent,
      textTheme: const TextTheme(
        // Menu hero wordmark.
        displayLarge: TextStyle(
          fontSize: 46,
          fontWeight: FontWeight.w800,
          height: 0.98,
          letterSpacing: -0.5,
          color: AppColors.textPrimary,
        ),
        // Loader wordmark.
        displayMedium: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.0,
          color: AppColors.loaderTitle,
        ),
        // Result headline.
        headlineMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
          color: AppColors.textPrimary,
        ),
        // Stat numbers, sheet titles.
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        // Button labels — lineHeight locked to the 24px icon box.
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          height: 24 / 16,
          letterSpacing: 1.2,
          color: AppColors.surface,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.3,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
