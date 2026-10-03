import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/generated/app_localizations.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _copy(BuildContext context, String value, String message) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _reportProblem(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final controller = TextEditingController();
    try {
      final report = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.helpReportProblem),
          content: TextField(
            controller: controller,
            autofocus: true,
            minLines: 3,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: l10n.helpReportHint,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.authCancel),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, controller.text.trim()),
              child: Text(l10n.helpCopyReport),
            ),
          ],
        ),
      );
      if (report == null || report.isEmpty || !context.mounted) return;
      await _copy(context, report, l10n.helpReportCopied);
    } finally {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpSupportTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 24),
              children: [
                Text(
                  l10n.helpFaqSection,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                _FaqTile(
                  question: l10n.helpFaqBookingQuestion,
                  answer: l10n.helpFaqBookingAnswer,
                ),
                _FaqTile(
                  question: l10n.helpFaqPaymentQuestion,
                  answer: l10n.helpFaqPaymentAnswer,
                ),
                _FaqTile(
                  question: l10n.helpFaqPhoneQuestion,
                  answer: l10n.helpFaqPhoneAnswer,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.helpHowItWorksTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Card(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.42,
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.all(16),
                    child: Text(
                      l10n.helpHowItWorksBody,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(height: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.helpContactTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ListTile(
                  contentPadding: EdgeInsetsDirectional.zero,
                  leading: Icon(
                    Icons.mail_outline,
                    color: colorScheme.secondary,
                  ),
                  title: Text(l10n.helpContactSupport),
                  subtitle: const Text('support@louagego.tn'),
                  trailing: const Icon(Icons.copy_outlined),
                  onTap: () => _copy(
                    context,
                    'support@louagego.tn',
                    l10n.helpEmailCopied,
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsetsDirectional.zero,
                  leading: Icon(
                    Icons.report_problem_outlined,
                    color: colorScheme.secondary,
                  ),
                  title: Text(l10n.helpReportProblem),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _reportProblem(context, l10n),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) => Card(
    child: ExpansionTile(
      title: Text(question),
      childrenPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            answer,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(height: 1.5),
          ),
        ),
      ],
    ),
  );
}
