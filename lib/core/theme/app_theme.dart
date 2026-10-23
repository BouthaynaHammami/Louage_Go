import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData withLocale(ThemeData theme, Locale locale) => theme.copyWith(
    textTheme: AppTextStyles.forLocale(theme.textTheme, locale),
  );

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: AppColors.background,
      primaryContainer: isDark
          ? AppColors.darkPrimaryContainer
          : AppColors.lightPrimaryContainer,
      onPrimaryContainer: isDark ? AppColors.darkText : AppColors.text,
      secondary: isDark ? AppColors.darkSecondary : AppColors.secondary,
      onSecondary: isDark ? AppColors.darkBackground : AppColors.background,
      secondaryContainer: isDark
          ? AppColors.darkSecondaryContainer
          : AppColors.lightSecondaryContainer,
      onSecondaryContainer: isDark ? AppColors.darkText : AppColors.text,
      tertiary: AppColors.success,
      onTertiary: AppColors.background,
      tertiaryContainer: isDark
          ? AppColors.darkWarningContainer
          : AppColors.lightWarningContainer,
      onTertiaryContainer: isDark ? AppColors.darkText : AppColors.text,
      error: AppColors.error,
      onError: AppColors.background,
      errorContainer: isDark
          ? AppColors.darkErrorContainer
          : AppColors.lightErrorContainer,
      onErrorContainer: isDark ? AppColors.darkText : AppColors.text,
      surface: isDark ? AppColors.darkSurface : AppColors.surface,
      onSurface: isDark ? AppColors.darkText : AppColors.text,
      onSurfaceVariant: isDark
          ? AppColors.darkSecondaryText
          : AppColors.secondaryText,
      outline: isDark ? AppColors.darkBorder : AppColors.border,
      outlineVariant: isDark ? AppColors.darkBorder : AppColors.border,
      shadow: isDark ? AppColors.darkBackground : AppColors.secondary,
      scrim: AppColors.darkShadow,
      inverseSurface: isDark ? AppColors.background : AppColors.darkBackground,
      onInverseSurface: isDark ? AppColors.text : AppColors.darkText,
      inversePrimary: isDark ? AppColors.primaryOnDark : AppColors.primary,
      surfaceTint: AppColors.primary,
      surfaceContainerLowest: isDark ? AppColors.darkSurface : AppColors.white,
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
    );
    final interactiveColor = isDark
        ? AppColors.primaryOnDark
        : AppColors.primary;

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
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: interactiveColor,
        selectionHandleColor: interactiveColor,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: interactiveColor,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: interactiveColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: AppColors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        modalBackgroundColor: colorScheme.surface,
        surfaceTintColor: AppColors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        labelStyle: TextStyle(color: colorScheme.onSurface),
        floatingLabelStyle: TextStyle(color: interactiveColor),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: interactiveColor, width: 1.5),
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
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: interactiveColor,
          side: BorderSide(color: colorScheme.outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: interactiveColor),
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant),
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: interactiveColor,
        linearTrackColor: colorScheme.outlineVariant,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        contentTextStyle: TextStyle(color: colorScheme.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
      ),
    );
  }
}
