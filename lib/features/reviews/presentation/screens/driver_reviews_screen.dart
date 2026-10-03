import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/review.dart';
import '../../domain/driver_review.dart';
import '../../domain/review_exception.dart';
import '../providers/reviews_provider.dart';
import '../widgets/review_stars.dart';

class DriverReviewsScreen extends ConsumerStatefulWidget {
  const DriverReviewsScreen({this.driverId, super.key});

  final String? driverId;

  @override
  ConsumerState<DriverReviewsScreen> createState() =>
      _DriverReviewsScreenState();
}

class _DriverReviewsScreenState extends ConsumerState<DriverReviewsScreen> {
  static const _pageSize = 10;
  int _visibleCount = _pageSize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider).asData?.value;
    final driverId = widget.driverId ?? user?.id ?? '';
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reviewsTitle)),
      body: driverId.isEmpty
          ? EmptyState(
              icon: Icons.person_outline,
              title: l10n.reviewsSignInRequired,
            )
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: ref.watch(driverReviewSummaryProvider(driverId)).when(
                    loading: () => const Padding(
                      padding: EdgeInsetsDirectional.all(20),
                      child: Column(
                        children: [
                          SkeletonBox(height: 144),
                          SizedBox(height: 12),
                          SkeletonBox(height: 88),
                        ],
                      ),
                    ),
                    error: (error, stackTrace) => EmptyState(
                      icon: Icons.error_outline,
                      title: l10n.reviewsLoadError,
                    ),
                    data: (summary) => ref
                        .watch(driverReviewsProvider(driverId))
                        .when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (error, stackTrace) => EmptyState(
                            icon: Icons.error_outline,
                            title: l10n.reviewsLoadError,
                          ),
                          data: (reviews) {
                            final visibleReviews = reviews
                                .take(_visibleCount)
                                .toList();
                            return ListView(
                              padding: const EdgeInsetsDirectional.all(20),
                              children: [
                                _SummaryCard(
                                  average: summary.average,
                                  total: summary.total,
                                  distribution: summary.distribution,
                                ),
                                const SizedBox(height: 20),
                                if (reviews.isEmpty)
                                  EmptyState(
                                    icon: Icons.star_outline_rounded,
                                    title: l10n.reviewsNoReviews,
                                  )
                                else ...[
                                  Text(
                                    l10n.reviewsCount(summary.total),
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  for (final entry in visibleReviews)
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.only(
                                            bottom: 10,
                                          ),
                                      child: _ReviewCard(
                                        entry: entry,
                                        viewerId: user?.id ?? '',
                                        onReport: () => _report(entry.review),
                                      ),
                                    ),
                                  if (visibleReviews.length < reviews.length)
                                    TextButton(
                                      onPressed: () => setState(
                                        () => _visibleCount += _pageSize,
                                      ),
                                      child: Text(l10n.reviewsLoadMore),
                                    ),
                                ],
                              ],
                            );
                          },
                        ),
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _report(Review review) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.reviewsReportTitle),
        content: Text(l10n.reviewsReportBody),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(l10n.reviewsCancelAction),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: Text(l10n.reviewsReport),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final userId = ref.read(currentUserProvider).asData?.value?.id ?? '';
    try {
      await ref.read(reviewsRepositoryProvider).reportReview(
        userId: userId,
        reviewId: review.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.reviewsReportSent)),
      );
    } on ReviewException catch (error) {
      if (!mounted) return;
      final message = error.code == ReviewExceptionCode.signInRequired
          ? l10n.reviewsSignInRequired
          : l10n.reviewsNotFound;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stackTrace),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.reviewsLoadError)),
      );
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.average,
    required this.total,
    required this.distribution,
  });

  final double average;
  final int total;
  final Map<int, int> distribution;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                average.toStringAsFixed(1),
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReviewStars(rating: average.round(), size: 22),
                  const SizedBox(height: 4),
                  Text(
                    l10n.reviewsCount(total),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.reviewsDistribution,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          for (var stars = 5; stars >= 1; stars--)
            _DistributionRow(
              stars: stars,
              count: distribution[stars] ?? 0,
              total: total,
            ),
        ],
      ),
    );
  }
}

class _DistributionRow extends StatelessWidget {
  const _DistributionRow({
    required this.stars,
    required this.count,
    required this.total,
  });

  final int stars;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: AppLocalizations.of(context)!.reviewsStarSemantics(stars),
      value: '$count',
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '$stars',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Expanded(
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : count / total,
                color: colors.secondary,
                backgroundColor: colors.surfaceContainerHighest,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 28,
              child: Text(
                '$count',
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.entry,
    required this.viewerId,
    required this.onReport,
  });

  final DriverReview entry;
  final String viewerId;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final review = entry.review;
    final date = DateTime.tryParse(review.createdAt);
    final displayName = entry.authorDisplayName.isEmpty
        ? l10n.reviewsAnonymous
        : entry.authorDisplayName;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                displayName,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (date != null)
                Text(
                  MaterialLocalizations.of(context).formatMediumDate(date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ReviewStars(rating: review.rating.round(), size: 18),
              if (viewerId.isNotEmpty && viewerId != review.userId)
                TextButton.icon(
                  onPressed: onReport,
                  icon: const Icon(Icons.flag_outlined, size: 18),
                  label: Text(l10n.reviewsReport),
                ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(review.comment, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
