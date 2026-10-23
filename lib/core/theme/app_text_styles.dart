import 'package:flutter/material.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const theme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.1,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.1,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
  );

  static TextTheme forLocale(TextTheme textTheme, Locale locale) {
    final isArabic = locale.languageCode == 'ar';
    final localizedTheme = textTheme.apply(
      fontFamily: isArabic ? 'Cairo' : 'Poppins',
    );
    if (!isArabic) return localizedTheme;

    return localizedTheme.copyWith(
      displayLarge: localizedTheme.displayLarge?.copyWith(height: 1.3),
      displayMedium: localizedTheme.displayMedium?.copyWith(height: 1.3),
      displaySmall: localizedTheme.displaySmall?.copyWith(height: 1.3),
      headlineLarge: localizedTheme.headlineLarge?.copyWith(height: 1.3),
      headlineMedium: localizedTheme.headlineMedium?.copyWith(height: 1.3),
      headlineSmall: localizedTheme.headlineSmall?.copyWith(height: 1.3),
      titleLarge: localizedTheme.titleLarge?.copyWith(height: 1.3),
      titleMedium: localizedTheme.titleMedium?.copyWith(height: 1.3),
      titleSmall: localizedTheme.titleSmall?.copyWith(height: 1.3),
      bodyLarge: localizedTheme.bodyLarge?.copyWith(height: 1.5),
      bodyMedium: localizedTheme.bodyMedium?.copyWith(height: 1.5),
      bodySmall: localizedTheme.bodySmall?.copyWith(height: 1.5),
      labelLarge: localizedTheme.labelLarge?.copyWith(height: 1.3),
      labelMedium: localizedTheme.labelMedium?.copyWith(height: 1.3),
      labelSmall: localizedTheme.labelSmall?.copyWith(height: 1.3),
    );
  }
}
