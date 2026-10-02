import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_preferences.dart';
import '../../../../l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsetsDirectional.all(20),
              children: [
                DropdownButtonFormField<ThemeMode>(
                  initialValue: themeMode,
                  decoration: InputDecoration(
                    labelText: l10n.settingsThemeLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(l10n.settingsThemeSystem),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(l10n.settingsThemeLight),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(l10n.settingsThemeDark),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(themeModeProvider.notifier).setThemeMode(value);
                    }
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<Locale>(
                  initialValue: locale,
                  decoration: InputDecoration(
                    labelText: l10n.settingsLanguageLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: const Locale('fr'),
                      child: Text(l10n.settingsLanguageFrench),
                    ),
                    DropdownMenuItem(
                      value: const Locale('en'),
                      child: Text(l10n.settingsLanguageEnglish),
                    ),
                    DropdownMenuItem(
                      value: const Locale('ar'),
                      child: Text(l10n.settingsLanguageArabic),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(localeProvider.notifier).setLocale(value);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
