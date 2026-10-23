import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/storage/hive_service.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/seat_dots.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/route_line.dart';
import '../../../../models/station.dart';
import '../../../../models/trip.dart';
import '../widgets/driver_app_bar.dart';
import '../providers/louage_provider.dart';

class DriverTripsScreen extends ConsumerWidget {
  const DriverTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ref
        .watch(currentUserProvider)
        .when(
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
              return Scaffold(
                appBar: driverAppBar(context, l10n.driverTripsTitle),
                body: EmptyState(
                  icon: Icons.person_off_outlined,
                  title: l10n.sessionExpired,
                ),
              );
            }
            return ref
                .watch(driverTripsProvider(user.id))
                .when(
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
                    body: trips.isEmpty
                        ? EmptyState(
                            icon: Icons.route_outlined,
                            title: l10n.driverTripsEmpty,
                          )
                        : Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 760),
                              child: ListView.separated(
                                padding: const EdgeInsetsDirectional.all(16),
                                itemCount: trips.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) =>
                                    _TripCard(trip: trips[index]),
                              ),
                            ),
                          ),
                  ),
                );
          },
        );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});

  final Trip trip;

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
