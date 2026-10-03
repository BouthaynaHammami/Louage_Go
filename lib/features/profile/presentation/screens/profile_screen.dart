import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_preferences.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../features/profile/presentation/widgets/profile_widgets.dart';
import '../../../../l10n/generated/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({required this.fallbackName, super.key});

  final String Function(AppLocalizations l10n) fallbackName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref
        .watch(currentUserProvider)
        .maybeWhen(data: (user) => user, orElse: () => null);
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
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsetsDirectional.all(20),
              children: [
                ProfileSummaryCard(
                  user: user,
                  fallbackName: fallbackName(l10n),
                ),
                const SizedBox(height: 8),
                ProfileOptionRow(
                  icon: Icons.edit_outlined,
                  title: l10n.profileEditTitle,
                  onTap: () => context.pushNamed('profileEdit'),
                ),
                if (user?.role == 'driver')
                  ProfileOptionRow(
                    icon: Icons.star_outline_rounded,
                    title: l10n.profileDriverReviews,
                    onTap: () => context.pushNamed('driverReviews'),
                  ),
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
                ProfileOptionRow(
                  icon: Icons.help_outline_rounded,
                  title: l10n.profileHelp,
                  onTap: () => context.pushNamed('supportHome'),
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
                const SizedBox(height: 8),
                DeleteAccountButton(user: user),
                const SizedBox(height: 8),
                const SignOutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
