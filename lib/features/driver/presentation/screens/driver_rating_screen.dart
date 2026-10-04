import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../features/reviews/presentation/providers/reviews_provider.dart';
import '../providers/louage_provider.dart';

class DriverRatingScreen extends ConsumerWidget {
  const DriverRatingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ref
        .watch(currentUserProvider)
        .when(
          loading: () => Scaffold(
            appBar: AppBar(title: Text(l10n.driverRatingTitle)),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Scaffold(
            appBar: AppBar(title: Text(l10n.driverRatingTitle)),
            body: EmptyState(
              icon: Icons.error_outline,
              title: l10n.driverOperationFailed,
            ),
          ),
          data: (user) {
            if (user == null || user.role != 'driver') {
              return Scaffold(
                appBar: AppBar(title: Text(l10n.driverRatingTitle)),
                body: EmptyState(
                  icon: Icons.person_off_outlined,
                  title: l10n.sessionExpired,
                ),
              );
            }
            final summary = ref.watch(driverReviewSummaryProvider(user.id));
            final reviews = ref.watch(driverReviewsProvider(user.id));
            final stats = ref.watch(driverLouageStatsProvider(user.id));
            return Scaffold(
              appBar: AppBar(title: Text(l10n.driverRatingTitle)),
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView(
                    padding: const EdgeInsetsDirectional.all(20),
                    children: [
                      summary.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, stackTrace) => EmptyState(
                          icon: Icons.error_outline,
                          title: l10n.driverOperationFailed,
                        ),
                        data: (value) => AppCard(
                          child: Column(
                            children: [
                              Text(
                                l10n.driverRatingTitle,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                value.average.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                              const SizedBox(height: 8),
                              _RatingStars(rating: value.average),
                              const SizedBox(height: 8),
                              Text(
                                l10n.driverRatingsCount(value.total.toString()),
                              ),
                              const SizedBox(height: 12),
                              stats.when(
                                loading: () => const LinearProgressIndicator(),
                                error: (error, stackTrace) =>
                                    Text(l10n.driverOperationFailed),
                                data: (stats) => Text(
                                  '${l10n.driverCompletedTrips} : ${stats.$2}',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.profileDriverReviews,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      reviews.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, stackTrace) => EmptyState(
                          icon: Icons.error_outline,
                          title: l10n.driverOperationFailed,
                        ),
                        data: (items) => items.isEmpty
                            ? EmptyState(
                                icon: Icons.star_outline,
                                title: l10n.driverRatingsCount('0'),
                              )
                            : Column(
                                children: [
                                  for (final item in items)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: AppCard(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item
                                                            .authorDisplayName
                                                            .isEmpty
                                                        ? l10n.driverPassengerFallback
                                                        : item.authorDisplayName,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                ),
                                                _RatingStars(
                                                  rating: item.review.rating,
                                                  compact: true,
                                                ),
                                              ],
                                            ),
                                            if (item
                                                .review
                                                .comment
                                                .isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Text(item.review.comment),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.rating, this.compact = false});

  final double rating;
  final bool compact;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var star = 1; star <= 5; star++)
        Icon(
          rating >= star
              ? Icons.star_rounded
              : rating >= star - 0.5
              ? Icons.star_half_rounded
              : Icons.star_outline_rounded,
          size: compact ? 18 : 30,
          color: Theme.of(context).colorScheme.secondary,
        ),
    ],
  );
}
