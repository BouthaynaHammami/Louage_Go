import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/seat_dots.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../l10n/generated/app_localizations.dart';
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
              return Scaffold(
                appBar: AppBar(title: Text(l10n.louageDetailTitle)),
                body: EmptyState(
                  icon: Icons.search_off,
                  title: l10n.louageNotFound,
                ),
              );
            }
            if (detail.route == null || detail.louage == null) {
              return Scaffold(
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
    final driverProfile = detail.driverProfile;
    final driverName = detail.driverName.trim().isEmpty
        ? l10n.profileDriverFallback
        : detail.driverName;
    final rating = driverProfile?.ratingAverage ?? 0;
    final filledStars = rating.round().clamp(0, 5);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.louageDetailTitle)),
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
                                from?.city ?? l10n.searchDeparture,
                                to?.city ?? l10n.searchDestination,
                              ),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          StatusChip(status: full ? 'full' : trip.status),
                        ],
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
                                color: colorScheme.primary,
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
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
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
                AppCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: colorScheme.secondary.withValues(
                          alpha: 0.18,
                        ),
                        foregroundColor: colorScheme.primary,
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
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (var index = 0; index < 5; index++)
                                      Icon(
                                        index < filledStars
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        size: 18,
                                        color: colorScheme.secondary,
                                      ),
                                  ],
                                ),
                                Text(
                                  l10n.louageDriverRating(
                                    rating.toStringAsFixed(1),
                                  ),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 16),
              child: AppButton(label: l10n.searchReservation, onPressed: null),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatPrice(double price) => price == price.roundToDouble()
    ? price.toStringAsFixed(0)
    : price.toStringAsFixed(2);
