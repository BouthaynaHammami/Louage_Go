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
          seedColor: AppColors.primary,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: AppColors.white,
          primaryContainer: isDark
              ? AppColors.darkErrorContainer
              : AppColors.lightErrorContainer,
          onPrimaryContainer: isDark ? AppColors.darkText : AppColors.text,
          secondary: AppColors.primary,
          onSecondary: AppColors.white,
          secondaryContainer: isDark
              ? AppColors.darkErrorContainer
              : AppColors.lightErrorContainer,
          onSecondaryContainer: isDark ? AppColors.darkText : AppColors.text,
          tertiary: AppColors.success,
          onTertiary: AppColors.text,
          tertiaryContainer: AppColors.warning,
          onTertiaryContainer: AppColors.text,
          error: AppColors.error,
          onError: AppColors.white,
          errorContainer: isDark
              ? AppColors.darkErrorContainer
              : AppColors.lightErrorContainer,
          onErrorContainer: isDark ? AppColors.darkText : AppColors.text,
          surface: isDark ? AppColors.darkSurface : AppColors.surface,
          onSurface: isDark ? AppColors.darkText : AppColors.text,
          onSurfaceVariant: isDark
              ? AppColors.darkSecondaryText
              : AppColors.secondaryText,
          surfaceContainerLowest: isDark
              ? AppColors.darkSecondaryBackground
              : AppColors.white,
          surfaceContainerLow: isDark
              ? AppColors.darkSecondaryBackground
              : AppColors.background,
          surfaceContainer: isDark
              ? AppColors.darkBackground
              : AppColors.background,
          surfaceContainerHigh: isDark
              ? AppColors.darkSurface
              : AppColors.background,
          surfaceContainerHighest: isDark
              ? AppColors.darkSurface
              : AppColors.background,
          outline: isDark ? AppColors.darkBorder : AppColors.border,
          outlineVariant: isDark ? AppColors.darkBorder : AppColors.border,
          surfaceTint: AppColors.primary,
          inverseSurface: isDark ? AppColors.white : AppColors.darkBackground,
          onInverseSurface: isDark ? AppColors.text : AppColors.darkText,
          inversePrimary: AppColors.primary,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.background,
      textTheme: AppTextStyles.theme.apply(
        fontFamily: 'Poppins',
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        modalBackgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        floatingLabelStyle: TextStyle(color: colorScheme.primary),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant),
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.outlineVariant,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        contentTextStyle: TextStyle(color: colorScheme.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondary,
      ),
    );
  }
}
