import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/storage/hive_service.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/route_line.dart';
import '../../../../models/station.dart';
import '../../../../models/trip.dart';
import '../providers/louage_provider.dart';

class DriverTripsScreen extends ConsumerWidget {
  const DriverTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ref.watch(currentUserProvider).when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.driverTripsTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: Text(l10n.driverTripsTitle)),
        body: EmptyState(icon: Icons.error_outline, title: l10n.driverOperationFailed),
      ),
      data: (user) {
        if (user == null || user.role != 'driver') {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.driverTripsTitle)),
            body: EmptyState(icon: Icons.person_off_outlined, title: l10n.sessionExpired),
          );
        }
        return ref.watch(driverTripsProvider(user.id)).when(
          loading: () => Scaffold(
            appBar: AppBar(title: Text(l10n.driverTripsTitle)),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Scaffold(
            appBar: AppBar(title: Text(l10n.driverTripsTitle)),
            body: EmptyState(icon: Icons.error_outline, title: l10n.driverOperationFailed),
          ),
          data: (trips) => Scaffold(
            appBar: AppBar(title: Text(l10n.driverTripsTitle)),
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
    final toMap = route == null ? null : HiveService.stations.get(route.toStationId);
    final from = fromMap == null
        ? l10n.driverStationUnavailable
        : Station.fromMap(fromMap).localizedName(Localizations.localeOf(context));
    final to = toMap == null
        ? l10n.driverStationUnavailable
        : Station.fromMap(toMap).localizedName(Localizations.localeOf(context));
    final departure = DateTime.tryParse(trip.departureTime);
    final date = departure == null
        ? l10n.louageDepartureUnavailable
        : DateFormat.yMMMd(Localizations.localeOf(context).toString())
            .add_Hm()
            .format(departure);

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
          Text('${l10n.driverTripDateTime} : $date'),
          const SizedBox(height: 4),
          Text('${l10n.driverTripPrice} : ${route?.pricePerSeat ?? 0} DT'),
          const SizedBox(height: 4),
          Text(
            l10n.driverTripSeatsAvailable(
              trip.freeSeats.toString(),
              trip.totalSeats.toString(),
            ),
          ),
        ],
      ),
    );
  }
}
