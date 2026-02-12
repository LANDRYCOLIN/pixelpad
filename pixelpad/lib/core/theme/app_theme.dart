import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF212020);
  static const Color splashBackground = Color(0xFF232323);
  static const Color header = Color(0xFFB7A2FF);
  static const Color primary = Color(0xFF896CFE);
  static const Color tabUnselected = Color(0xFFC6B7FF);
  static const Color wordmark = Color(0xFFB49CFF);
  static const Color arrow = Color(0xFFF1F27A);
  static const Color white = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData light() {
    final colorScheme = const ColorScheme.dark().copyWith(
      primary: AppColors.primary,
      secondary: AppColors.header,
      surface: AppColors.background,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
    );
  }
}

class AppTextStyles {
  static const TextStyle pageTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.white,
  );

  static const TextStyle wordmark = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 3,
    color: AppColors.wordmark,
  );

  static const TextStyle profileName = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.white,
  );

  static const TextStyle profileEmail = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    height: 1.2,
    color: AppColors.white,
  );

  static const TextStyle profileMeta = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.white,
  );

  static const TextStyle statsValue = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.white,
  );

  static const TextStyle statsLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: AppColors.white,
  );

  static const TextStyle menuText = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: AppColors.white,
  );
}
