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
    expect(colors.onPrimary, AppColors.background);
    expect(
      contrastRatio(colors.onPrimary, colors.primary),
      greaterThanOrEqualTo(4.5),
    );
    expect(colors.secondary, AppColors.secondary);
    expect(colors.secondary, isNot(AppColors.primary));
    expect(colors.surface, AppColors.white);
    expect(colors.onSurface, AppColors.text);
    expect(colors.onSurfaceVariant, AppColors.secondaryText);
    expect(colors.outline, AppColors.border);
    expect(colors.tertiary, AppColors.success);
    expect(colors.tertiaryContainer, AppColors.lightWarningContainer);
    expect(colors.error, AppColors.error);
    expect(theme.inputDecorationTheme.fillColor, AppColors.background);
  });

  test('dark theme uses the requested palette', () {
    final theme = AppTheme.dark;
    final colors = theme.colorScheme;

    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, AppColors.darkBackground);
    expect(colors.primary, AppColors.primary);
    expect(colors.secondary, AppColors.darkSecondary);
    expect(colors.surface, AppColors.darkSurface);
    expect(colors.onSurface, AppColors.darkText);
    expect(colors.onSurfaceVariant, AppColors.darkSecondaryText);
    expect(colors.outline, AppColors.darkBorder);
    expect(colors.surfaceContainerLow, AppColors.darkSecondaryBackground);
    expect(theme.inputDecorationTheme.fillColor, AppColors.darkSurface);
    expect(colors.tertiary, AppColors.success);
    expect(colors.tertiaryContainer, AppColors.darkWarningContainer);
    expect(colors.error, AppColors.error);
    expect(colors.onPrimary, AppColors.background);
    expect(
      contrastRatio(AppColors.primaryOnDark, AppColors.darkBackground),
      greaterThanOrEqualTo(4.5),
    );
  });
}

double contrastRatio(Color foreground, Color background) {
  final luminances = [
    foreground.computeLuminance(),
    background.computeLuminance(),
  ]..sort((a, b) => b.compareTo(a));
  return (luminances[0] + 0.05) / (luminances[1] + 0.05);
}
