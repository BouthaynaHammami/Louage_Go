import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_preferences.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../features/profile/presentation/widgets/profile_widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref
        .watch(currentUserProvider)
        .maybeWhen(data: (value) => value, orElse: () => null);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final languageLabel = switch (locale.languageCode) {
      'ar' => l10n.settingsLanguageArabic,
      'en' => l10n.settingsLanguageEnglish,
      _ => l10n.settingsLanguageFrench,
    };
    final themeLabel = switch (themeMode) {
      ThemeMode.light => l10n.settingsThemeLight,
      ThemeMode.dark => l10n.settingsThemeDark,
      _ => l10n.settingsThemeSystem,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 24),
              children: [
                _SettingsSectionTitle(title: l10n.settingsAccountSection),
                ProfileOptionRow(
                  icon: Icons.person_outline,
                  title: l10n.profileEditTitle,
                  onTap: () => context.pushNamed('profileEdit'),
                ),
                const SizedBox(height: 20),
                _SettingsSectionTitle(title: l10n.settingsPreferencesSection),
                ProfileOptionRow(
                  icon: Icons.language_rounded,
                  title: l10n.settingsLanguageLabel,
                  value: languageLabel,
                  onTap: () => showProfileLanguagePicker(context, ref),
                ),
                ProfileOptionRow(
                  icon: Icons.dark_mode_outlined,
                  title: l10n.settingsThemeLabel,
                  value: themeLabel,
                  onTap: () => showProfileThemePicker(context, ref),
                ),
                const SizedBox(height: 20),
                _SettingsSectionTitle(title: l10n.settingsSecuritySection),
                DeleteAccountButton(user: user),
                const SizedBox(height: 20),
                _SettingsSectionTitle(title: l10n.settingsSupportSection),
                ProfileOptionRow(
                  icon: Icons.help_outline_rounded,
                  title: l10n.profileHelp,
                  onTap: () => context.pushNamed('helpFaq'),
                ),
                ProfileOptionRow(
                  icon: Icons.description_outlined,
                  title: l10n.profileTerms,
                  onTap: () => context.pushNamed('legalTerms'),
                ),
                ProfileOptionRow(
                  icon: Icons.privacy_tip_outlined,
                  title: l10n.profilePrivacy,
                  onTap: () => context.pushNamed('legalPrivacy'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsSectionTitle extends StatelessWidget {
  const _SettingsSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(bottom: 8, start: 4),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
