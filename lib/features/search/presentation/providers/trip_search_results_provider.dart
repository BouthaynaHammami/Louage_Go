import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/hive_service.dart';
import '../../../../models/louage.dart';
import '../../../../models/route_line.dart';
import '../../../../models/station.dart';
import '../../../../models/trip.dart';
import '../../domain/trip_search_criteria.dart';

class TripSearchResult {
  final Trip trip;
  final RouteLine route;
  final Louage louage;
  final Station fromStation;
  final Station toStation;
  final DateTime departure;

  const TripSearchResult({
    required this.trip,
    required this.route,
    required this.louage,
    required this.fromStation,
    required this.toStation,
    required this.departure,
  });

  double get price => route.pricePerSeat;
  int get freeSeats => trip.freeSeats;
  int get totalSeats => trip.totalSeats;
  bool get isFull => freeSeats == 0 || trip.status == 'full';
}

final tripSearchResultsProvider =
    StreamProvider.family<List<TripSearchResult>, TripSearchCriteria>(
      (ref, criteria) => Stream<List<TripSearchResult>>.multi((controller) {
        final subscriptions = <StreamSubscription<dynamic>>[];

        void reload() {
          try {
            controller.add(_loadResults(criteria));
          } catch (error, stackTrace) {
            controller.addError(error, stackTrace);
          }
        }

        subscriptions
          ..add(HiveService.trips.watch().listen((_) => reload()))
          ..add(HiveService.routes.watch().listen((_) => reload()))
          ..add(HiveService.louages.watch().listen((_) => reload()))
          ..add(HiveService.stations.watch().listen((_) => reload()));

        controller.onCancel = () async {
          await Future.wait(
            subscriptions.map((subscription) => subscription.cancel()),
          );
        };
        reload();
      }),
    );

List<TripSearchResult> _loadResults(TripSearchCriteria criteria) {
  final stations = {
    for (final map in HiveService.stations.values)
      Station.fromMap(map).id: Station.fromMap(map),
  };
  final routes = {
    for (final map in HiveService.routes.values)
      RouteLine.fromMap(map).id: RouteLine.fromMap(map),
  };
  final louages = {
    for (final entry in HiveService.louages.toMap().entries)
      entry.key.toString(): Louage.fromMap(entry.value),
  };

  final results = <TripSearchResult>[];
  for (final entry in HiveService.trips.toMap().entries) {
    var trip = Trip.fromMap(entry.value);
    if (trip.id.isEmpty) trip = trip.copyWith(id: entry.key.toString());
    final route = routes[trip.routeId];
    final louage = louages[trip.louageId];
    final departure = DateTime.tryParse(trip.departureTime);
    if (route == null || louage == null || departure == null) continue;

    final fromStation = stations[route.fromStationId];
    final toStation = stations[route.toStationId];
    if (fromStation == null || toStation == null) continue;
    if (fromStation.city != criteria.from || toStation.city != criteria.to) {
      continue;
    }

    results.add(
      TripSearchResult(
        trip: trip,
        route: route,
        louage: louage,
        fromStation: fromStation,
        toStation: toStation,
        departure: departure,
      ),
    );
  }
  return results;
}
