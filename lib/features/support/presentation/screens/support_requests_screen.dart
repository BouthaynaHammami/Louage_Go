import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/report.dart';
import '../../support_providers.dart';

class SupportRequestsScreen extends ConsumerWidget {
  const SupportRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final userState = ref.watch(currentUserProvider);
    final user = userState.asData?.value;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.supportRequestsTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: userState.isLoading
                ? const _RequestSkeleton()
                : userState.hasError
                ? EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: l10n.supportLoadFailed,
                    actionLabel: l10n.supportRetry,
                    onAction: () => ref.invalidate(currentUserProvider),
                  )
                : user == null
                ? EmptyState(
                    icon: Icons.lock_outline_rounded,
                    title: l10n.supportSignInRequired,
                    actionLabel: l10n.supportSignInRequired,
                    onAction: () => context.goNamed('login'),
                  )
                : _RequestList(authorId: user.id),
          ),
        ),
      ),
    );
  }
}

class _RequestList extends ConsumerWidget {
  const _RequestList({required this.authorId});

  final String authorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final requests = ref.watch(supportRequestsProvider(authorId));
    return requests.when(
      loading: () => const _RequestSkeleton(),
      error: (_, _) => EmptyState(
        icon: Icons.error_outline_rounded,
        title: l10n.supportLoadFailed,
        actionLabel: l10n.supportRetry,
        onAction: () => ref.invalidate(supportRequestsProvider(authorId)),
      ),
      data: (items) => items.isEmpty
          ? EmptyState(
              icon: Icons.inbox_outlined,
              title: l10n.supportRequestsEmpty,
              actionLabel: l10n.supportContactTitle,
              onAction: () => context.pushNamed('supportContact'),
            )
          : ListView.separated(
              padding: const EdgeInsetsDirectional.all(20),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) =>
                  _RequestCard(report: items[index]),
            ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      onTap: () => context.pushNamed(
        'supportRequestDetail',
        pathParameters: {'requestId': report.id},
      ),
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
          const SizedBox(height: 8),
          Text(
            report.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            MaterialLocalizations.of(context).formatMediumDate(
              DateTime.tryParse(report.createdAt) ?? DateTime.now(),
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _RequestSkeleton extends StatelessWidget {
  const _RequestSkeleton();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsetsDirectional.all(20),
    child: Column(
      children: [
        SkeletonBox(height: 88),
        SizedBox(height: 12),
        SkeletonBox(height: 88),
        SizedBox(height: 12),
        SkeletonBox(height: 88),
      ],
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
