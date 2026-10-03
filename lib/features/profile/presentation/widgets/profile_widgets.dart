import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_preferences.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../features/auth/domain/auth_exception.dart';
import '../../../../features/auth/presentation/auth_error_message.dart';
import '../../../../features/profile/data/profile_photo.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/app_user.dart';

class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({
    required this.user,
    required this.fallbackName,
    super.key,
  });

  final AppUser? user;
  final String fallbackName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final photo = user?.photo ?? '';
    final photoProvider = photo.isEmpty ? null : profilePhotoProvider(photo);
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: colorScheme.secondaryContainer,
              child: photoProvider == null
                  ? Icon(
                      Icons.person_outline,
                      size: 38,
                      color: colorScheme.onSecondaryContainer,
                    )
                  : ClipOval(
                      child: Image(
                        image: photoProvider,
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.person_outline,
                          size: 38,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name.isNotEmpty == true ? user!.name : fallbackName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (user?.phone.isNotEmpty == true)
                    Text(
                      '${AppLocalizations.of(context)!.loginPhoneLabel}: ${user!.phone}',
                    ),
                  if (user?.email.isNotEmpty == true) Text(user!.email),
                  if (user?.city.isNotEmpty == true)
                    Text(
                      '${AppLocalizations.of(context)!.profileCityLabel}: ${user!.city}',
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileOptionRow extends StatelessWidget {
  const ProfileOptionRow({
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 4),
      child: Material(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          minTileHeight: 60,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          leading: Icon(icon, color: colorScheme.secondary),
          title: Text(title),
          subtitle: value == null ? null : Text(value!),
          trailing: onTap == null
              ? null
              : Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          onTap: onTap,
        ),
      ),
    );
  }
}

Future<void> showProfileLanguagePicker(
  BuildContext context,
  WidgetRef ref,
) async {
  final l10n = AppLocalizations.of(context)!;
  final selectedCode = ref.read(localeProvider).languageCode;
  final options = [
    (const Locale('en'), l10n.settingsLanguageEnglish),
    (const Locale('fr'), l10n.settingsLanguageFrench),
    (const Locale('ar'), l10n.settingsLanguageArabic),
  ];
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.settingsLanguageLabel,
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            for (final (locale, label) in options)
              ListTile(
                title: Text(label),
                trailing: selectedCode == locale.languageCode
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(sheetContext).colorScheme.secondary,
                      )
                    : null,
                onTap: () async {
                  try {
                    final user = ref
                        .read(currentUserProvider)
                        .maybeWhen(data: (value) => value, orElse: () => null);
                    if (user != null) {
                      await ref
                          .read(authControllerProvider.notifier)
                          .updateProfile(language: locale.languageCode);
                    }
                    await ref.read(localeProvider.notifier).setLocale(locale);
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  } on AuthException catch (error) {
                    if (!sheetContext.mounted) return;
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      SnackBar(
                        content: Text(authErrorMessage(l10n, error.code)),
                      ),
                    );
                  } catch (_) {
                    if (!sheetContext.mounted) return;
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      SnackBar(content: Text(l10n.authUnexpectedError)),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    ),
  );
}

Future<void> showProfileThemePicker(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context)!;
  final selectedMode = ref.read(themeModeProvider);
  final options = [
    (ThemeMode.light, l10n.settingsThemeLight, Icons.light_mode_outlined),
    (ThemeMode.dark, l10n.settingsThemeDark, Icons.dark_mode_outlined),
    (
      ThemeMode.system,
      l10n.settingsThemeSystem,
      Icons.brightness_auto_outlined,
    ),
  ];
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.settingsThemeLabel,
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            for (final (mode, label, icon) in options)
              ListTile(
                leading: Icon(
                  icon,
                  color: Theme.of(sheetContext).colorScheme.secondary,
                ),
                title: Text(label),
                trailing: selectedMode == mode
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(sheetContext).colorScheme.secondary,
                      )
                    : null,
                onTap: () async {
                  await ref.read(themeModeProvider.notifier).setThemeMode(mode);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
          ],
        ),
      ),
    ),
  );
}

class DeleteAccountButton extends ConsumerWidget {
  const DeleteAccountButton({required this.user, super.key});

  final AppUser? user;

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteAccountTitle),
        content: Text(l10n.deleteAccountWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.authCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: Text(l10n.deleteAccountAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    var confirmationValue = '';
    bool confirmedByWord;
    confirmedByWord =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              final confirmationWord = l10n.deleteAccountConfirmationWord;
              final matches = confirmationValue.trim() == confirmationWord;
              return AlertDialog(
                title: Text(l10n.deleteAccountConfirmTitle),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.deleteAccountTypeConfirmation(confirmationWord)),
                    const SizedBox(height: 16),
                    TextField(
                      autofocus: true,
                      onChanged: (value) =>
                          setDialogState(() => confirmationValue = value),
                      decoration: InputDecoration(
                        errorText: confirmationValue.isEmpty || matches
                            ? null
                            : l10n.deleteAccountConfirmationMismatch,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(l10n.authCancel),
                  ),
                  FilledButton(
                    onPressed: matches
                        ? () => Navigator.pop(dialogContext, true)
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(dialogContext)
                          .colorScheme
                          .error,
                      foregroundColor: Theme.of(dialogContext)
                          .colorScheme
                          .onError,
                    ),
                    child: Text(l10n.deleteAccountAction),
                  ),
                ],
              );
            },
          ),
        ) ??
        false;
    if (!confirmedByWord || !context.mounted) return;

    try {
      await ref.read(authControllerProvider.notifier).deleteAccount();
      final photo = user?.photo;
      if (photo != null && photo.isNotEmpty) {
        try {
          await deleteProfilePhoto(photo);
        } on Exception catch (error) {
          debugPrint('Could not remove deleted account avatar: $error');
        }
      }
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      context.go('/login');
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.deleteAccountCompleted)),
      );
    } on AuthException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(l10n, error.code))),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.authUnexpectedError)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => TextButton.icon(
    onPressed: () => _deleteAccount(context, ref),
    icon: const Icon(Icons.delete_outline),
    label: Text(AppLocalizations.of(context)!.deleteAccountAction),
    style: TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.error,
      minimumSize: const Size(48, 48),
    ),
  );
}

class SignOutButton extends ConsumerWidget {
  const SignOutButton({super.key});

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.profileSignOutTitle),
        content: Text(l10n.profileSignOutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.authCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.driverLogout),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(authControllerProvider.notifier).logout();
      if (!context.mounted) return;
      context.goNamed('login');
    } on AuthException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(l10n, error.code))),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.authUnexpectedError)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => TextButton.icon(
    onPressed: () => _confirmSignOut(context, ref),
    icon: const Icon(Icons.logout),
    label: Text(AppLocalizations.of(context)!.driverLogout),
    style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
  );
}
