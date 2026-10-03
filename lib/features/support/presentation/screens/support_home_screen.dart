import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/app_config.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/generated/app_localizations.dart';

class SupportHomeScreen extends StatelessWidget {
  const SupportHomeScreen({super.key});

  Future<void> _contact(
    BuildContext context,
    Uri uri,
    String unavailableMessage,
  ) async {
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(unavailableMessage)),
        );
      }
    } on PlatformException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(unavailableMessage)),
        );
      }
    } on MissingPluginException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(unavailableMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.supportTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 24),
              children: [
                _SupportCard(
                  icon: Icons.quiz_outlined,
                  title: l10n.supportFaqTitle,
                  onTap: () => context.pushNamed('supportFaq'),
                ),
                const SizedBox(height: 12),
                _SupportCard(
                  icon: Icons.mark_email_unread_outlined,
                  title: l10n.supportContactTitle,
                  onTap: () => context.pushNamed('supportContact'),
                ),
                const SizedBox(height: 12),
                _SupportCard(
                  icon: Icons.inbox_outlined,
                  title: l10n.supportRequestsTitle,
                  onTap: () => context.pushNamed('supportRequests'),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.supportQuickContact,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _contact(
                        context,
                        Uri(
                          scheme: 'tel',
                          path: AppConfig.supportPhone.replaceAll(
                            RegExp(r'[^0-9+]'),
                            '',
                          ),
                        ),
                        l10n.supportContactUnavailable,
                      ),
                      icon: const Icon(Icons.call_outlined),
                      label: Text(l10n.supportCallAction),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _contact(
                        context,
                        Uri(
                          scheme: 'mailto',
                          path: AppConfig.supportEmail,
                          queryParameters: {'subject': l10n.supportEmailSubject},
                        ),
                        l10n.supportContactUnavailable,
                      ),
                      icon: const Icon(Icons.email_outlined),
                      label: Text(l10n.supportEmailAction),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _contact(
                        context,
                        Uri.https(
                          'wa.me',
                          '/${AppConfig.supportWhatsapp.replaceAll(RegExp(r'\D'), '')}',
                        ),
                        l10n.supportContactUnavailable,
                      ),
                      icon: const Icon(Icons.chat_outlined),
                      label: Text(l10n.supportWhatsappAction),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: onTap,
    child: Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        const Icon(Icons.chevron_right_rounded),
      ],
    ),
  );
}
