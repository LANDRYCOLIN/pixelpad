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
  static const String _fontTitle = 'Geometos';
  static const String _fontBody = 'Outfit';
  static const String _fontCjk = 'OPPO Sans 4.0';

  static ThemeData light() {
    final colorScheme = const ColorScheme.dark().copyWith(
      primary: AppColors.primary,
      secondary: AppColors.header,
      surface: AppColors.background,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.white,
    );

    final TextTheme baseTextTheme = ThemeData.dark().textTheme.apply(
      fontFamily: _fontBody,
      fontFamilyFallback: const <String>[_fontCjk],
    );

    final TextTheme textTheme = baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontFamily: _fontTitle,
        fontFamilyFallback: const <String>[_fontCjk],
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontFamily: _fontTitle,
        fontFamilyFallback: const <String>[_fontCjk],
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontFamily: _fontTitle,
        fontFamilyFallback: const <String>[_fontCjk],
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontFamily: _fontTitle,
        fontFamilyFallback: const <String>[_fontCjk],
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontFamily: _fontTitle,
        fontFamilyFallback: const <String>[_fontCjk],
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontFamily: _fontTitle,
        fontFamilyFallback: const <String>[_fontCjk],
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontFamily: _fontTitle,
        fontFamilyFallback: const <String>[_fontCjk],
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontFamily: _fontTitle,
        fontFamilyFallback: const <String>[_fontCjk],
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontFamily: _fontTitle,
        fontFamilyFallback: const <String>[_fontCjk],
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: _fontBody,
      fontFamilyFallback: const <String>[_fontCjk],
      textTheme: textTheme,
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
    fontFamily: AppTheme._fontTitle,
    fontFamilyFallback: <String>[AppTheme._fontCjk],
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.white,
  );

  static const TextStyle wordmark = TextStyle(
    fontFamily: AppTheme._fontTitle,
    fontFamilyFallback: <String>[AppTheme._fontCjk],
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 3,
    color: AppColors.wordmark,
  );

  static const TextStyle profileName = TextStyle(
    fontFamily: AppTheme._fontTitle,
    fontFamilyFallback: <String>[AppTheme._fontCjk],
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.white,
  );

  static const TextStyle profileEmail = TextStyle(
    fontFamily: AppTheme._fontBody,
    fontFamilyFallback: <String>[AppTheme._fontCjk],
    fontSize: 14,
    fontWeight: FontWeight.w300,
    height: 1.2,
    color: AppColors.white,
  );

  static const TextStyle profileMeta = TextStyle(
    fontFamily: AppTheme._fontBody,
    fontFamilyFallback: <String>[AppTheme._fontCjk],
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.white,
  );

  static const TextStyle statsValue = TextStyle(
    fontFamily: AppTheme._fontBody,
    fontFamilyFallback: <String>[AppTheme._fontCjk],
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.white,
  );

  static const TextStyle statsLabel = TextStyle(
    fontFamily: AppTheme._fontBody,
    fontFamilyFallback: <String>[AppTheme._fontCjk],
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: AppColors.white,
  );

  static const TextStyle menuText = TextStyle(
    fontFamily: AppTheme._fontBody,
    fontFamilyFallback: <String>[AppTheme._fontCjk],
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: AppColors.white,
  );
}
