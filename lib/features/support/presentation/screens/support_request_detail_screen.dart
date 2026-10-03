import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../support_providers.dart';

class SupportRequestDetailScreen extends ConsumerWidget {
  const SupportRequestDetailScreen({required this.requestId, super.key});

  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authorId = ref.watch(currentUserProvider).asData?.value?.id;
    if (authorId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.supportRequestDetailTitle)),
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: l10n.supportSignInRequired,
        ),
      );
    }
    final requests = ref.watch(supportRequestsProvider(authorId));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.supportRequestDetailTitle)),
      body: requests.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: l10n.supportLoadFailed,
        ),
        data: (items) {
          final report = items.where((item) => item.id == requestId).firstOrNull;
          if (report == null) {
            return EmptyState(
              icon: Icons.inbox_outlined,
              title: l10n.supportRequestNotFound,
            );
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView(
                padding: const EdgeInsetsDirectional.all(20),
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _categoryLabel(l10n, report.category),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            StatusChip(status: report.status),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SelectableText(
                          report.description,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(height: 1.5),
                        ),
                        if (report.tripId.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            '${l10n.supportTripReference}: ${report.tripId}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.supportAdminReply,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          report.adminReply.isEmpty
                              ? l10n.supportNoAdminReply
                              : report.adminReply,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _categoryLabel(AppLocalizations l10n, String value) => switch (value) {
    'booking' => l10n.supportCategoryBooking,
    'payment' => l10n.supportCategoryPayment,
    'driver' => l10n.supportCategoryDrivers,
    'bug' => l10n.supportCategoryBug,
    _ => l10n.supportCategoryOther,
  };
}
