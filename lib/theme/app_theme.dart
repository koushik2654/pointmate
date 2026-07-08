import 'package:flutter/material.dart';

/// Central color palette + [ThemeData] for PointMate.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFFFAF8FC);
  static const Color primary = Color(0xFF6D4AA6);
  static const Color primaryDark = Color(0xFF5A3B8C);
  static const Color primaryLight = Color(0xFF9B7BC7);

  static const List<Color> primaryGradient = [
    Color(0xFF8763B8),
    Color(0xFF5A3B8C),
  ];

  static const Color cardMuted = Color(0xFFF1EEF6);
  static const Color searchFill = Color(0xFFF1EEF6);
  static const Color textPrimary = Color(0xFF1F1B24);
  static const Color textSecondary = Color(0xFF6B6572);
  static const Color textMuted = Color(0xFF8E8896);

  static const Color inputBorder = Color(0xFFDDD7E6);
  static const Color negative = Color(0xFFE0524C);
  static const Color statusInProgressBg = Color(0xFFFBDEDD);
  static const Color statusInProgressFg = Color(0xFFD9534F);
  static const Color statusPausedBg = Color(0xFFE7E4EC);
  static const Color statusPausedFg = Color(0xFF6B6572);
  static const Color statusYourTurnBg = Color(0xFFE9DEF6);
  static const Color statusYourTurnFg = Color(0xFF6D4AA6);

  static const Color rankGoldBg = Color(0xFFF6E9C9);
  static const Color rankGoldCircle = Color(0xFFC9A227);
  static const Color rankGoldFg = Color(0xFF8A6D1D);
  static const Color rankNeutralCircle = Color(0xFFE7E4EC);

  static const Color chartLeaderLine = primaryDark;
  static const Color chartRunnerUpLine = primaryLight;
  static const Color chartBarFill = Color(0xFFEAE3F3);
  static const Color chartGrid = Color(0xFFE4DFEC);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        surface: AppColors.background,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
    );
  }
}
