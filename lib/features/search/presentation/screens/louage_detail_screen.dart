import 'package:flutter/material.dart';

import '../../../../core/storage/hive_service.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/seat_dots.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/louage.dart';
import '../../../../models/route_line.dart';
import '../../../../models/station.dart';
import '../../../../models/trip.dart';

class LouageDetailScreen extends StatelessWidget {
  final String tripId;

  const LouageDetailScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tripMap = HiveService.trips.get(tripId);
    if (tripMap == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.louageDetailTitle)),
        body: EmptyState(icon: Icons.search_off, title: l10n.louageNotFound),
      );
    }

    final trip = Trip.fromMap(tripMap);
    final routeMap = HiveService.routes.get(trip.routeId);
    final louageMap = HiveService.louages.get(trip.louageId);
    if (routeMap == null || louageMap == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.louageDetailTitle)),
        body: EmptyState(
          icon: Icons.error_outline,
          title: l10n.louageDetailUnavailable,
        ),
      );
    }

    final route = RouteLine.fromMap(routeMap);
    final louage = Louage.fromMap(louageMap);
    final stations = {
      for (final entry in HiveService.stations.toMap().entries)
        Station.fromMap(entry.value).id: Station.fromMap(entry.value),
    };
    final from = stations[route.fromStationId];
    final to = stations[route.toStationId];
    final departure = DateTime.tryParse(trip.departureTime);
    final full = trip.freeSeats == 0 || trip.status == 'full';
    final priceColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.louageDetailTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 28),
              children: [
                AppCard(
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
                      Text(
                        departure == null
                            ? l10n.louageDepartureUnavailable
                            : '${MaterialLocalizations.of(context).formatFullDate(departure)} · ${TimeOfDay.fromDateTime(departure).format(context)}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.louageVehicle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(louage.matricule),
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
                const SizedBox(height: 12),
                AppCard(
                  child: Row(
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
                              color: priceColor,
                              fontWeight: FontWeight.w700,
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
    );
  }
}

String _formatPrice(double price) => price == price.roundToDouble()
    ? price.toStringAsFixed(0)
    : price.toStringAsFixed(2);
