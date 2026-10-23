import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:louage_go/core/theme/app_text_styles.dart';
import 'package:louage_go/core/theme/app_theme.dart';

void main() {
  test('uses the requested weights and Latin text hierarchy', () {
    final styles = AppTextStyles.theme;

    expect(styles.displayLarge?.fontWeight, FontWeight.w700);
    expect(styles.headlineLarge?.fontWeight, FontWeight.w700);
    expect(styles.headlineMedium?.fontWeight, FontWeight.w700);
    expect(styles.titleLarge?.fontWeight, FontWeight.w700);
    expect(styles.titleMedium?.fontWeight, FontWeight.w700);
    expect(styles.displayLarge?.letterSpacing, lessThan(0));
    expect(styles.labelLarge?.fontWeight, FontWeight.w600);
    expect(styles.labelMedium?.fontWeight, FontWeight.w600);
    expect(styles.bodyLarge?.fontWeight, FontWeight.w400);
    expect(styles.bodyMedium?.fontWeight, FontWeight.w400);
    expect(styles.bodyLarge?.height, 1.4);
    expect(styles.bodyMedium?.height, 1.4);
  });

  test('selects Poppins or Cairo and increases Arabic line height', () {
    final latin = AppTheme.withLocale(AppTheme.light, const Locale('fr'));
    final arabic = AppTheme.withLocale(AppTheme.light, const Locale('ar'));

    expect(latin.textTheme.bodyLarge?.fontFamily, 'Poppins');
    expect(arabic.textTheme.bodyLarge?.fontFamily, 'Cairo');
    expect(arabic.textTheme.bodyLarge?.height, greaterThan(1.4));
    expect(arabic.textTheme.titleMedium?.height, greaterThan(1));
  });
}
