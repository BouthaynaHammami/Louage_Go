import 'dart:async';

import 'package:hive_ce/hive.dart';

import '../../../core/storage/hive_service.dart';
import '../../../models/favorite.dart';
import '../../../models/driver_profile.dart';
import '../../../models/louage.dart';
import '../../../models/model_map.dart';
import '../../../models/route_line.dart';
import '../../../models/station.dart';
import '../../../models/trip.dart';
import '../domain/entities/louage_detail_data.dart';
import '../domain/entities/passenger_home_data.dart';
import '../domain/entities/search_route_shortcut.dart';
import '../domain/entities/trip_search_result.dart';
import '../../search/domain/search_repository.dart';
import '../domain/trip_search_criteria.dart';

class HiveSearchRepository implements SearchRepository {
  HiveSearchRepository({
    Box<Map>? stationsBox,
    Box<Map>? routesBox,
    Box<Map>? louagesBox,
    Box<Map>? tripsBox,
    Box<Map>? favoritesBox,
    Box<Map>? sessionBox,
    Box<Map>? driversBox,
    Box<Map>? usersBox,
  }) : _stationsBox = stationsBox ?? HiveService.stations,
       _routesBox = routesBox ?? HiveService.routes,
       _louagesBox = louagesBox ?? HiveService.louages,
       _tripsBox = tripsBox ?? HiveService.trips,
       _favoritesBox = favoritesBox ?? HiveService.favorites,
       _sessionBox = sessionBox ?? HiveService.session,
       _driversBox = driversBox ?? HiveService.drivers,
       _usersBox = usersBox ?? HiveService.users;

  final Box<Map> _stationsBox;
  final Box<Map> _routesBox;
  final Box<Map> _louagesBox;
  final Box<Map> _tripsBox;
  final Box<Map> _favoritesBox;
  final Box<Map> _sessionBox;
  final Box<Map> _driversBox;
  final Box<Map> _usersBox;

  @override
  Stream<PassengerHomeData> watchPassengerHomeData(String? userId) =>
      Stream<PassengerHomeData>.multi((controller) {
        final subscriptions = <StreamSubscription<dynamic>>[];

        void reload() => controller.add(_loadPassengerHomeData(userId));

        subscriptions
          ..add(_stationsBox.watch().listen((_) => reload()))
          ..add(_routesBox.watch().listen((_) => reload()))
          ..add(_favoritesBox.watch().listen((_) => reload()))
          ..add(_sessionBox.watch(key: 'lastTrips').listen((_) => reload()));

        controller.onCancel = () async {
          await Future.wait(
            subscriptions.map((subscription) => subscription.cancel()),
          );
        };
        reload();
      });

  @override
  Future<void> rememberSearch(String from, String to) async {
    final stored = _sessionBox.get('lastTrips')?['items'];
    final recent = <Map<String, String>>[];
    if (stored is Iterable) {
      for (final item in stored) {
        if (item is Map && item['from'] is String && item['to'] is String) {
          final oldFrom = item['from'] as String;
          final oldTo = item['to'] as String;
          if (oldFrom != from || oldTo != to) {
            recent.add({'from': oldFrom, 'to': oldTo});
          }
        }
      }
    }
    recent.insert(0, {'from': from, 'to': to});
    await _sessionBox.put('lastTrips', {'items': recent.take(5).toList()});
  }

  @override
  Stream<List<TripSearchResult>> watchTripResults(
    TripSearchCriteria criteria,
  ) => Stream<List<TripSearchResult>>.multi((controller) {
    final subscriptions = <StreamSubscription<dynamic>>[];

    void reload() {
      try {
        controller.add(findTrips(criteria));
      } catch (error, stackTrace) {
        controller.addError(error, stackTrace);
      }
    }

    subscriptions
      ..add(_tripsBox.watch().listen((_) => reload()))
      ..add(_routesBox.watch().listen((_) => reload()))
      ..add(_louagesBox.watch().listen((_) => reload()))
      ..add(_stationsBox.watch().listen((_) => reload()));

    controller.onCancel = () async {
      await Future.wait(
        subscriptions.map((subscription) => subscription.cancel()),
      );
    };
    reload();
  });

  @override
  List<TripSearchResult> findTrips(TripSearchCriteria criteria) {
    final stations = {
      for (final map in _stationsBox.values)
        Station.fromMap(map).id: Station.fromMap(map),
    };
    final routes = {
      for (final map in _routesBox.values)
        RouteLine.fromMap(map).id: RouteLine.fromMap(map),
    };
    final louages = {
      for (final entry in _louagesBox.toMap().entries)
        entry.key.toString(): Louage.fromMap(entry.value),
    };

    final results = <TripSearchResult>[];
    for (final entry in _tripsBox.toMap().entries) {
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

  @override
  Future<LouageDetailData?> getLouageDetail(String tripId) async {
    final tripMap = _tripsBox.get(tripId);
    if (tripMap == null) return null;

    final trip = Trip.fromMap(tripMap);
    final routeMap = _routesBox.get(trip.routeId);
    final louageMap = _louagesBox.get(trip.louageId);
    final route = routeMap == null ? null : RouteLine.fromMap(routeMap);
    final louage = louageMap == null ? null : Louage.fromMap(louageMap);
    if (route == null || louage == null) {
      return LouageDetailData(
        trip: trip,
        route: route,
        louage: louage,
        fromStation: null,
        toStation: null,
        driverName: '',
        driverProfile: null,
      );
    }

    final fromMap = _stationsBox.get(route.fromStationId);
    final toMap = _stationsBox.get(route.toStationId);
    final driverMap = _usersBox.get(louage.driverId);
    final driverProfileMap = _driversBox.get(louage.driverId);

    return LouageDetailData(
      trip: trip,
      route: route,
      louage: louage,
      fromStation: fromMap == null ? null : Station.fromMap(fromMap),
      toStation: toMap == null ? null : Station.fromMap(toMap),
      driverName: driverMap == null ? '' : ModelMap.text(driverMap, 'name'),
      driverProfile: driverProfileMap == null
          ? null
          : DriverProfile.fromMap(driverProfileMap),
    );
  }

  PassengerHomeData _loadPassengerHomeData(String? userId) {
    final stations = _stationsBox.values
        .map(Station.fromMap)
        .where((station) => station.city.isNotEmpty)
        .toList();
    final routes = _routesBox.values
        .map(RouteLine.fromMap)
        .where(
          (route) =>
              route.fromStationId.isNotEmpty && route.toStationId.isNotEmpty,
        )
        .toList();
    final stationsById = {for (final station in stations) station.id: station};
    final routesById = {for (final route in routes) route.id: route};

    return PassengerHomeData(
      stations: stations,
      routes: routes,
      recentTrips: _readRecentTrips(),
      favorites: _readFavorites(userId, routesById, stationsById),
    );
  }

  List<SearchRouteShortcut> _readRecentTrips() {
    final items = _sessionBox.get('lastTrips')?['items'];
    if (items is! Iterable) return const [];
    return [
      for (final item in items)
        if (item is Map && item['from'] is String && item['to'] is String)
          SearchRouteShortcut(
            from: item['from'] as String,
            to: item['to'] as String,
          ),
    ];
  }

  List<SearchRouteShortcut> _readFavorites(
    String? userId,
    Map<String, RouteLine> routes,
    Map<String, Station> stations,
  ) {
    if (userId == null) return const [];
    final shortcuts = <SearchRouteShortcut>[];
    for (final raw in _favoritesBox.values) {
      final favorite = Favorite.fromMap(raw);
      if (favorite.userId != userId) continue;
      final route = routes[favorite.routeId];
      final from = route == null ? null : stations[route.fromStationId]?.city;
      final to = route == null ? null : stations[route.toStationId]?.city;
      if (from != null && to != null) {
        shortcuts.add(
          SearchRouteShortcut(from: from, to: to, isFavorite: true),
        );
      }
    }
    return shortcuts;
  }
}
