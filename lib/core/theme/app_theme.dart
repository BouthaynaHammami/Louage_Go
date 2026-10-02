import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData withLocale(ThemeData theme, Locale locale) => theme.copyWith(
    textTheme: theme.textTheme.apply(
      fontFamily: locale.languageCode == 'ar' ? 'Cairo' : 'Poppins',
    ),
  );

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: isDark ? AppColors.accent : AppColors.primary,
          brightness: brightness,
        ).copyWith(
          primary: isDark ? AppColors.accent : AppColors.primary,
          secondary: AppColors.accent,
          onSecondary: AppColors.text,
          surface: isDark ? AppColors.darkSurface : AppColors.background,
          error: AppColors.error,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: AppTextStyles.theme.apply(
        fontFamily: 'Poppins',
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
    );
  }
}
