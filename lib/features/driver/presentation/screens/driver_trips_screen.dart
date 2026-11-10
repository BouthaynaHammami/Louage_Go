import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/storage/hive_service.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/seat_dots.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/route_line.dart';
import '../../../../models/station.dart';
import '../../../../models/trip.dart';
import '../../domain/louage_repository.dart';
import '../providers/louage_provider.dart';
import '../widgets/driver_app_bar.dart';

class DriverTripsScreen extends ConsumerWidget {
  const DriverTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ref.watch(currentUserProvider).when(
      loading: () => Scaffold(
        appBar: driverAppBar(context, l10n.driverTripsTitle),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: driverAppBar(context, l10n.driverTripsTitle),
        body: EmptyState(
          icon: Icons.error_outline,
          title: l10n.driverOperationFailed,
        ),
      ),
      data: (user) {
        if (user == null || user.role != 'driver') {
          return AppScaffold(
            appBar: driverAppBar(context, l10n.driverTripsTitle),
            body: EmptyState(
              icon: Icons.person_off_outlined,
              title: l10n.sessionExpired,
            ),
          );
        }

        final louageAsync = ref.watch(driverLouageProvider(user.id));
        return louageAsync.when(
          loading: () => Scaffold(
            appBar: driverAppBar(context, l10n.driverTripsTitle),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Scaffold(
            appBar: driverAppBar(context, l10n.driverTripsTitle),
            body: EmptyState(
              icon: Icons.error_outline,
              title: l10n.driverOperationFailed,
            ),
          ),
          data: (louage) {
            final stationLabel = _stationLabel(context, louage?.stationActuelle);
            return ref.watch(driverTripsProvider(user.id)).when(
              loading: () => Scaffold(
                appBar: driverAppBar(context, l10n.driverTripsTitle),
                body: const Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => Scaffold(
                appBar: driverAppBar(context, l10n.driverTripsTitle),
                body: EmptyState(
                  icon: Icons.error_outline,
                  title: l10n.driverOperationFailed,
                ),
              ),
              data: (trips) => Scaffold(
                appBar: driverAppBar(context, l10n.driverTripsTitle),
                floatingActionButton: FloatingActionButton.extended(
                  onPressed: () => context.pushNamed('driverCreateTrip'),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.driverCreateTripTitle),
                ),
                body: trips.isEmpty
                    ? Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: EmptyState(
                            icon: Icons.route_outlined,
                            title: l10n.driverTripsEmpty,
                            description: stationLabel.isEmpty
                                ? null
                                : '${l10n.driverCurrentStation} : $stationLabel',
                            actionLabel: l10n.driverCreateFirstTrip,
                            onAction: () => context.pushNamed('driverCreateTrip'),
                          ),
                        ),
                      )
                    : Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: ListView(
                            padding: const EdgeInsetsDirectional.all(16),
                            children: [
                              if (stationLabel.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    bottom: 8,
                                  ),
                                  child: AppCard(
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${l10n.driverCurrentStation} : $stationLabel',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ...trips.map((trip) => Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  bottom: 8,
                                ),
                                child: _TripCard(
                                  trip: trip,
                                  onCancel: () => _cancelTrip(
                                    context,
                                    ref,
                                    user.id,
                                    trip.id,
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
              ),
            );
          },
        );
      },
    );
  }

  String _stationLabel(BuildContext context, String? stationId) {
    if (stationId == null || stationId.trim().isEmpty) return '';
    final stationMap = HiveService.stations.get(stationId);
    if (stationMap == null) return stationId;
    final station = Station.fromMap(stationMap);
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' && station.nameAr.isNotEmpty
        ? station.nameAr
        : station.name;
  }

  Future<void> _cancelTrip(
    BuildContext context,
    WidgetRef ref,
    String userId,
    String tripId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.driverTripCancelTitle),
        content: Text(AppLocalizations.of(context)!.driverTripCancelMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppLocalizations.of(context)!.authCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppLocalizations.of(context)!.driverTripCancel),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(louageRepositoryProvider).cancelTrip(tripId);
      ref.invalidate(driverTripsProvider(userId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.driverTripCancelled)),
        );
      }
    } on DriverTripException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(switch (error.failure) {
              DriverTripFailure.louageMissing => AppLocalizations.of(context)!.driverLouageMissing,
              DriverTripFailure.louageOutOfService => AppLocalizations.of(context)!.driverLouageOutOfService,
              DriverTripFailure.stationRequired => AppLocalizations.of(context)!.driverStationRequired,
              DriverTripFailure.sameStation => AppLocalizations.of(context)!.driverTripSameStation,
              DriverTripFailure.departureInPast => AppLocalizations.of(context)!.driverDepartureInPast,
              DriverTripFailure.duplicateDeparture => AppLocalizations.of(context)!.driverDuplicateDeparture,
              DriverTripFailure.tripMissing => AppLocalizations.of(context)!.driverTripMissing,
              DriverTripFailure.tripNotWaiting => AppLocalizations.of(context)!.driverTripNotWaiting,
            }),
          ),
        );
      }
    }
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip, required this.onCancel});

  final Trip trip;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final routeMap = HiveService.routes.get(trip.routeId);
    final route = routeMap == null ? null : RouteLine.fromMap(routeMap);
    final fromMap = route == null
        ? null
        : HiveService.stations.get(route.fromStationId);
    final toMap = route == null
        ? null
        : HiveService.stations.get(route.toStationId);
    final from = fromMap == null
        ? l10n.driverStationUnavailable
        : Station.fromMap(fromMap)
              .localizedName(Localizations.localeOf(context));
    final to = toMap == null
        ? l10n.driverStationUnavailable
        : Station.fromMap(toMap).localizedName(Localizations.localeOf(context));
    final departure = DateTime.tryParse(trip.departureTime);
    final date = departure == null
        ? l10n.louageDepartureUnavailable
        : DateFormat.yMMMd(Localizations.localeOf(context).toString())
              .add_Hm()
              .format(departure);
    final colors = Theme.of(context).colorScheme;

    return AppCard(
      onTap: () => context.pushNamed(
        'driverTripDetail',
        pathParameters: {'tripId': trip.id},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.trip_origin_rounded, color: colors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$from → $to',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (trip.status == 'waiting')
                IconButton(
                  icon: const Icon(Icons.cancel_outlined),
                  tooltip: l10n.driverTripCancel,
                  onPressed: onCancel,
                ),
              StatusChip(status: trip.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule_outlined, size: 17, color: colors.outline),
              const SizedBox(width: 6),
              Expanded(child: Text('${l10n.driverTripDateTime} : $date')),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.driverTripPrice,
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                  Text(
                    '${route?.pricePerSeat ?? 0} DT',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.inversePrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SeatDots(
            freeSeats: trip.freeSeats,
            totalSeats: trip.totalSeats,
            diameter: 10,
            spacing: 6,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.driverTripSeatsAvailable(
              trip.freeSeats.toString(),
              trip.totalSeats.toString(),
            ),
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
