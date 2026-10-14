import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:louage_go/core/theme/app_colors.dart';
import 'package:louage_go/core/theme/app_theme.dart';

void main() {
  test('light theme uses the requested palette', () {
    final theme = AppTheme.light;
    final colors = theme.colorScheme;

    expect(theme.brightness, Brightness.light);
    expect(theme.scaffoldBackgroundColor, AppColors.background);
    expect(colors.primary, AppColors.primary);
    expect(colors.onPrimary, AppColors.white);
    expect(colors.surface, AppColors.white);
    expect(colors.onSurface, AppColors.text);
    expect(colors.onSurfaceVariant, AppColors.secondaryText);
    expect(colors.outline, AppColors.border);
    expect(colors.tertiary, AppColors.success);
    expect(colors.tertiaryContainer, AppColors.warning);
    expect(colors.error, AppColors.error);
    expect(theme.inputDecorationTheme.fillColor, AppColors.background);
  });

  test('dark theme uses the requested palette', () {
    final theme = AppTheme.dark;
    final colors = theme.colorScheme;

    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, AppColors.darkBackground);
    expect(colors.primary, AppColors.primary);
    expect(colors.surface, AppColors.darkSurface);
    expect(colors.onSurface, AppColors.darkText);
    expect(colors.onSurfaceVariant, AppColors.darkSecondaryText);
    expect(colors.outline, AppColors.darkBorder);
    expect(colors.surfaceContainerLow, AppColors.darkSecondaryBackground);
    expect(theme.inputDecorationTheme.fillColor, AppColors.darkSurface);
    expect(colors.tertiary, AppColors.success);
    expect(colors.tertiaryContainer, AppColors.warning);
    expect(colors.error, AppColors.error);
  });
}
