import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
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
                        const CircleAvatar(
                          radius: 28,
                          child: Icon(Icons.person_outline),
                        ),
                        const SizedBox(width: 14),
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
                  const SizedBox(height: 16),
                  AppButton(
                    label: l10n.settingsTitle,
                    icon: Icons.settings_outlined,
                    onPressed: () => context.pushNamed('settings'),
                  ),
                  const Spacer(),
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
