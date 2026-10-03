import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_config.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/auth_providers.dart';

class LegalConsentGate extends ConsumerStatefulWidget {
  const LegalConsentGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<LegalConsentGate> createState() => _LegalConsentGateState();
}

class _LegalConsentGateState extends ConsumerState<LegalConsentGate> {
  final Set<String> _shownFor = {};

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).asData?.value;
    if (user != null && user.acceptedTermsVersion != AppConfig.legalVersion) {
      final signature = '${user.id}:${AppConfig.legalVersion}';
      if (_shownFor.add(signature)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showConsentDialog();
        });
      }
    }
    return widget.child;
  }

  Future<void> _showConsentDialog() async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text(l10n.legalUpdateTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.legalUpdateMessage),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => GoRouter.of(dialogContext).pushNamed(
                      'legalTerms',
                    ),
                    child: Text(l10n.legalTermsTitle),
                  ),
                  TextButton(
                    onPressed: () => GoRouter.of(dialogContext).pushNamed(
                      'legalPrivacy',
                    ),
                    child: Text(l10n.legalPrivacyTitle),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  if (mounted) GoRouter.of(context).go('/login');
                } catch (_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.authUnexpectedError)),
                    );
                  }
                }
              },
              child: Text(l10n.legalSignOut),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await ref
                      .read(authControllerProvider.notifier)
                      .acceptTerms();
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                } catch (_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.authUnexpectedError)),
                    );
                  }
                }
              },
              child: Text(l10n.legalAcceptUpdate),
            ),
          ],
        ),
      ),
    );
  }
}
