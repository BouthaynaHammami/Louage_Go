import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

enum LegalDocument { terms, privacy }

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({required this.document, super.key});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = switch (document) {
      LegalDocument.terms => l10n.legalTermsTitle,
      LegalDocument.privacy => l10n.legalPrivacyTitle,
    };
    final sections = switch (document) {
      LegalDocument.terms => [
        (l10n.legalTermsSectionServiceTitle, l10n.legalTermsSectionServiceBody),
        (
          l10n.legalTermsSectionBookingsTitle,
          l10n.legalTermsSectionBookingsBody,
        ),
        (l10n.legalTermsSectionDemoTitle, l10n.legalTermsSectionDemoBody),
      ],
      LegalDocument.privacy => [
        (l10n.legalPrivacySectionDataTitle, l10n.legalPrivacySectionDataBody),
        (l10n.legalPrivacySectionUseTitle, l10n.legalPrivacySectionUseBody),
        (
          l10n.legalPrivacySectionControlTitle,
          l10n.legalPrivacySectionControlBody,
        ),
        (l10n.legalPrivacySectionDemoTitle, l10n.legalPrivacySectionDemoBody),
      ],
    };

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.legalUpdatedAt,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (final (sectionTitle, sectionBody) in sections) ...[
                    Text(
                      sectionTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      sectionBody,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(height: 1.55),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
