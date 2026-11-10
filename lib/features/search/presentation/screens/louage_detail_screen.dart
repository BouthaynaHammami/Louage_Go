import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/favorite_button.dart';
import '../../../../core/widgets/seat_dots.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../features/reviews/presentation/providers/reviews_provider.dart';
import '../../../../features/reviews/presentation/widgets/review_stars.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../widgets/route_to_station_card.dart';
import '../providers/trip_search_results_provider.dart';

class LouageDetailScreen extends ConsumerWidget {
  final String tripId;

  const LouageDetailScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ref
        .watch(louageDetailDataProvider(tripId))
        .when(
          loading: () => Scaffold(
            appBar: AppBar(title: Text(l10n.louageDetailTitle)),
            body: const SafeArea(
              child: Padding(
                padding: EdgeInsetsDirectional.all(16),
                child: Column(
                  children: [
                    SkeletonBox(height: 160),
                    SizedBox(height: 14),
                    SkeletonBox(height: 120),
                    SizedBox(height: 14),
                    SkeletonBox(height: 96),
                  ],
                ),
              ),
            ),
          ),
          error: (error, stackTrace) => Scaffold(
            appBar: AppBar(title: Text(l10n.louageDetailTitle)),
            body: EmptyState(
              icon: Icons.error_outline,
              title: l10n.louageDetailUnavailable,
            ),
          ),
          data: (detail) {
            if (detail == null) {
              return AppScaffold(
                appBar: AppBar(title: Text(l10n.louageDetailTitle)),
                body: EmptyState(
                  icon: Icons.search_off,
                  title: l10n.louageNotFound,
                ),
              );
            }
            if (detail.route == null || detail.louage == null) {
              return AppScaffold(
                appBar: AppBar(title: Text(l10n.louageDetailTitle)),
                body: EmptyState(
                  icon: Icons.error_outline,
                  title: l10n.louageDetailUnavailable,
                ),
              );
            }
            return _buildDetail(context, detail);
          },
        );
  }

  Widget _buildDetail(BuildContext context, LouageDetailData detail) {
    final l10n = AppLocalizations.of(context)!;
    final trip = detail.trip;
    final route = detail.route!;
    final louage = detail.louage!;
    final from = detail.fromStation;
    final to = detail.toStation;
    final departure = DateTime.tryParse(trip.departureTime);
    final full = trip.freeSeats == 0 || trip.status == 'full';
    final colorScheme = Theme.of(context).colorScheme;
    final darkHeader = colorScheme.brightness == Brightness.dark
        ? colorScheme.surfaceContainerHigh
        : colorScheme.secondary;
    final driverProfile = detail.driverProfile;
    final driverName = detail.driverName.trim().isEmpty
        ? l10n.profileDriverFallback
        : detail.driverName;

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: darkHeader,
        foregroundColor: colorScheme.onPrimary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        actionsIconTheme: IconThemeData(color: colorScheme.onPrimary),
        title: Text(l10n.louageDetailTitle),
        actions: [FavoriteButton.route(routeId: route.id)],
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
              children: [
                AppCard(
                  padding: const EdgeInsetsDirectional.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.searchRoutePair(
                                from?.localizedCity(
                                      Localizations.localeOf(context),
                                    ) ??
                                    l10n.searchDeparture,
                                to?.localizedCity(
                                      Localizations.localeOf(context),
                                    ) ??
                                    l10n.searchDestination,
                              ),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          StatusChip(status: full ? 'full' : trip.status),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _RouteStops(
                        departure:
                            from?.localizedName(
                              Localizations.localeOf(context),
                            ) ??
                            l10n.searchDeparture,
                        arrival:
                            to?.localizedName(
                              Localizations.localeOf(context),
                            ) ??
                            l10n.searchDestination,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colorScheme.secondary.withValues(
                                alpha: 0.16,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox.square(
                              dimension: 48,
                              child: Icon(
                                Icons.schedule_rounded,
                                color: colorScheme.inversePrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  departure == null
                                      ? l10n.louageDepartureUnavailable
                                      : TimeOfDay.fromDateTime(departure)
                                            .format(context),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                if (departure != null)
                                  Text(
                                    MaterialLocalizations.of(context)
                                        .formatFullDate(departure),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                if (departure != null)
                                  FavoriteButton.offer(
                                    louageId: louage.id,
                                    departureHm: _departureHm(departure),
                                    routeId: route.id,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.louagePricePerSeat,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Text(
                            '${_formatPrice(route.pricePerSeat)} DT',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: colorScheme.inversePrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (from != null) ...[
                  RouteToStationCard(station: from),
                  const SizedBox(height: 14),
                ],
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.airport_shuttle_rounded,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            l10n.louageVehicle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        louage.matricule,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      SeatDots(
                        freeSeats: trip.freeSeats,
                        totalSeats: trip.totalSeats,
                        diameter: 14,
                        spacing: 9,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.louageSeatsFreeOfTotal(
                          trip.freeSeats.toString(),
                          trip.totalSeats.toString(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _DriverReviewsPreview(
                  driverId: louage.driverId,
                  driverName: driverName,
                  initialAverage: driverProfile?.ratingAverage ?? 0,
                  initialCount: driverProfile?.reviewCount ?? 0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteStops extends StatelessWidget {
  const _RouteStops({required this.departure, required this.arrival});

  final String departure;
  final String arrival;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 66,
          child: Column(
            children: [
              Icon(Icons.trip_origin_rounded, size: 14, color: colors.primary),
              Expanded(
                child: CustomPaint(
                  painter: _RouteDotsPainter(color: colors.outline),
                  child: const SizedBox.expand(),
                ),
              ),
              Icon(
                Icons.location_on_rounded,
                size: 18,
                color: colors.secondary,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                departure,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 14),
              Text(
                arrival,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RouteDotsPainter extends CustomPainter {
  const _RouteDotsPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (var y = 1.0; y < size.height; y += 7) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, (y + 3).clamp(0, size.height)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RouteDotsPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _DriverReviewsPreview extends ConsumerWidget {
  const _DriverReviewsPreview({
    required this.driverId,
    required this.driverName,
    required this.initialAverage,
    required this.initialCount,
  });

  final String driverId;
  final String driverName;
  final double initialAverage;
  final int initialCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final summary = ref.watch(driverReviewSummaryProvider(driverId));
    final reviews = ref.watch(driverReviewsProvider(driverId));
    final average = summary.asData?.value.average ?? initialAverage;
    final count = summary.asData?.value.total ?? initialCount;
    final latest = reviews.asData?.value.take(3).toList() ?? const [];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colors.secondary.withValues(alpha: 0.18),
                foregroundColor: colors.primary,
                child: driverName.trim().isEmpty
                    ? const Icon(Icons.person_outline, size: 32)
                    : Text(
                        driverName.trim().characters.first,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        ReviewStars(rating: average.round(), size: 18),
                        Text(
                          l10n.louageDriverRating(average.toStringAsFixed(1)),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          l10n.reviewsCount(count),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (latest.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              l10n.reviewsLatest,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            for (final entry in latest)
              Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.authorDisplayName.isEmpty
                              ? l10n.reviewsAnonymous
                              : entry.authorDisplayName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        ReviewStars(
                          rating: entry.review.rating.round(),
                          size: 16,
                        ),
                      ],
                    ),
                    if (entry.review.comment.isNotEmpty)
                      Text(
                        entry.review.comment,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
          ],
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: driverId.isEmpty
                  ? null
                  : () => context.pushNamed(
                      'driverReviewsForDriver',
                      pathParameters: {'driverId': driverId},
                    ),
              child: Text(l10n.reviewsSeeAll),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatPrice(double price) => price == price.roundToDouble()
    ? price.toStringAsFixed(0)
    : price.toStringAsFixed(2);

String _departureHm(DateTime departure) =>
    '${departure.hour.toString().padLeft(2, '0')}:${departure.minute.toString().padLeft(2, '0')}';
