import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_config.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/legal_document.dart';
import 'legal_document_provider.dart';

class LegalDocumentScreen extends ConsumerWidget {
  const LegalDocumentScreen({required this.document, super.key});

  final LegalDocumentType document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final content = ref
        .watch(legalDocumentRepositoryProvider)
        .getDocument(document, locale);
    final sectionKeys = {
      for (final section in content.sections)
        section.title: GlobalKey(debugLabel: section.title),
    };
    final title = switch (document) {
      LegalDocumentType.terms => l10n.legalTermsTitle,
      LegalDocumentType.privacy => l10n.legalPrivacyTitle,
    };
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Scrollbar(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsetsDirectional.all(16),
                      decoration: BoxDecoration(
                        color: colors.tertiaryContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.outlineVariant),
                      ),
                      child: Text(
                        l10n.legalDemoDisclaimer,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onTertiaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ExpansionTile(
                      tilePadding: EdgeInsetsDirectional.zero,
                      title: Text(
                        l10n.legalTableOfContents,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      children: [
                        for (final section in content.sections)
                          ListTile(
                            dense: true,
                            title: Text(section.title),
                            onTap: () {
                              final sectionContext =
                                  sectionKeys[section.title]?.currentContext;
                              if (sectionContext != null) {
                                Scrollable.ensureVisible(
                                  sectionContext,
                                  duration:
                                      MediaQuery.of(context).disableAnimations
                                      ? Duration.zero
                                      : const Duration(milliseconds: 250),
                                  alignment: 0.08,
                                );
                              }
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (final section in content.sections) ...[
                      Text(
                        section.title,
                        key: sectionKeys[section.title],
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      for (final paragraph in section.paragraphs) ...[
                        SelectableText(
                          paragraph,
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(height: 1.55),
                        ),
                        const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 8),
                    ],
                    const Divider(),
                    Text(
                      '${l10n.legalDocumentVersion(content.version)}\n'
                      '${l10n.legalUpdatedAt(MaterialLocalizations.of(context).formatMediumDate(content.updatedAt))}\n'
                      '${l10n.legalContactLabel} ${AppConfig.legalContactEmail} · ${AppConfig.legalContactPhone}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
