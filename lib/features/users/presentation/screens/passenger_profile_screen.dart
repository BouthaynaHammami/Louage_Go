import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/theme/app_preferences.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';

class PassengerProfileScreen extends ConsumerWidget {
  const PassengerProfileScreen({super.key});

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
            child: Padding(
              padding: const EdgeInsetsDirectional.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.18),
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          child: Icon(
                            Icons.person_outline,
                            size: 40,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? l10n.profilePassengerFallback,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(user?.email ?? ''),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: AppCard(
                      padding: EdgeInsetsDirectional.zero,
                      child: Column(
                        children: [
                          _ProfileSettingRow(
                            icon: Icons.settings_outlined,
                            title: l10n.settingsTitle,
                            onTap: () => context.pushNamed('settings'),
                          ),
                          const Divider(height: 1, indent: 56),
                          _ProfileSettingRow(
                            icon: Icons.language_rounded,
                            title: l10n.settingsLanguageLabel,
                            value: languageLabel,
                            onTap: () => context.pushNamed('settings'),
                          ),
                          const Divider(height: 1, indent: 56),
                          _ProfileSettingRow(
                            icon: Icons.dark_mode_outlined,
                            title: l10n.settingsThemeLabel,
                            value: themeLabel,
                            onTap: () => context.pushNamed('settings'),
                          ),
                          const Divider(height: 1, indent: 56),
                          _ProfileSettingRow(
                            icon: Icons.help_outline_rounded,
                            title: l10n.profileHelp,
                          ),
                          const Divider(height: 1, indent: 56),
                          _ProfileSettingRow(
                            icon: Icons.description_outlined,
                            title: l10n.profileTerms,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: l10n.driverLogout,
                    icon: Icons.logout,
                    variant: AppButtonVariant.secondary,
                    onPressed: () =>
                        ref.read(authControllerProvider.notifier).logout(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileSettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;

  const _ProfileSettingRow({
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      minTileHeight: 60,
      leading: Icon(icon, color: colorScheme.secondary),
      title: Text(title),
      subtitle: value == null ? null : Text(value!),
      trailing: onTap == null
          ? null
          : Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
      onTap: onTap,
    );
  }
}
