import 'dart:async';

import 'package:hive_ce/hive.dart';

import '../../../core/storage/hive_service.dart';
import '../../../models/favorite.dart';
import '../../../models/louage.dart';
import '../../../models/route_line.dart';
import '../../../models/station.dart';
import '../../../models/trip.dart';
import '../domain/favorites_data.dart';
import '../domain/favorites_repository.dart';

class HiveFavoritesRepository implements FavoritesRepository {
  HiveFavoritesRepository({
    Box<Map>? favoritesBox,
    Box<Map>? routesBox,
    Box<Map>? stationsBox,
    Box<Map>? louagesBox,
    Box<Map>? tripsBox,
  }) : _favoritesBox = favoritesBox ?? HiveService.favorites,
       _routesBox = routesBox ?? HiveService.routes,
       _stationsBox = stationsBox ?? HiveService.stations,
       _louagesBox = louagesBox ?? HiveService.louages,
       _tripsBox = tripsBox ?? HiveService.trips;

  final Box<Map> _favoritesBox;
  final Box<Map> _routesBox;
  final Box<Map> _stationsBox;
  final Box<Map> _louagesBox;
  final Box<Map> _tripsBox;

  @override
  Stream<FavoritesData> watchFavorites(String userId) =>
      Stream<FavoritesData>.multi((controller) {
        void reload() {
          try {
            controller.add(_loadFavorites(userId));
          } catch (error, stackTrace) {
            controller.addError(error, stackTrace);
          }
        }

        final subscriptions = [
          _favoritesBox.watch().listen((_) => reload()),
          _routesBox.watch().listen((_) => reload()),
          _stationsBox.watch().listen((_) => reload()),
          _louagesBox.watch().listen((_) => reload()),
          _tripsBox.watch().listen((_) => reload()),
        ];
        controller.onCancel = () async {
          await Future.wait(
            subscriptions.map((subscription) => subscription.cancel()),
          );
        };
        reload();
      });

  @override
  bool isFavorite(String userId, String referenceId, {String type = 'route'}) =>
      _favoritesFor(userId, type, referenceId).isNotEmpty;

  @override
  Future<void> toggleRoute(String userId, String routeId) =>
      _toggle(userId, 'route', routeId);

  @override
  Future<void> toggleStation(String userId, String stationId) =>
      _toggle(userId, 'station', stationId);

  @override
  bool isOfferFavorite(String userId, String louageId, String departureHm) =>
      _offerFavoritesFor(userId, louageId, departureHm).isNotEmpty;

  @override
  Future<void> toggleOffer(
    String userId,
    String louageId,
    String departureHm,
    String routeId,
  ) async {
    final normalizedHm = _normalizeHm(departureHm);
    if (userId.isEmpty ||
        louageId.isEmpty ||
        normalizedHm == null ||
        routeId.isEmpty) {
      throw ArgumentError('A user, louage, departure time and route are required.');
    }
    final existing = _offerFavoritesFor(userId, louageId, normalizedHm);
    if (existing.isNotEmpty) {
      for (final entry in existing) {
        await _favoritesBox.delete(entry.key);
      }
      return;
    }

    final id = '${userId}_offer_${louageId}_${normalizedHm.replaceAll(':', '')}';
    final louageMap = _louagesBox.get(louageId);
    final matricule = louageMap == null
        ? ''
        : Louage.fromMap(louageMap).matricule;
    await _favoritesBox.put(
      id,
      Favorite(
        id: id,
        userId: userId,
        routeId: routeId,
        type: 'offer',
        louageId: louageId,
        departureHm: normalizedHm,
        matricule: matricule,
        createdAt: DateTime.now().toIso8601String(),
      ).toMap(),
    );
  }

  Future<void> _toggle(String userId, String type, String referenceId) async {
    if (userId.isEmpty || referenceId.isEmpty) {
      throw ArgumentError('A user and favorite reference are required.');
    }
    final existing = _favoritesFor(userId, type, referenceId);
    if (existing.isNotEmpty) {
      for (final entry in existing) {
        await _favoritesBox.delete(entry.key);
      }
      return;
    }

    final id = '${userId}_${type}_$referenceId';
    await _favoritesBox.put(
      id,
      Favorite(
        id: id,
        userId: userId,
        routeId: type == 'route' ? referenceId : '',
        type: type,
        stationId: type == 'station' ? referenceId : '',
        createdAt: DateTime.now().toIso8601String(),
      ).toMap(),
    );
  }

  List<MapEntry<dynamic, Favorite>> _favoritesFor(
    String userId,
    String type,
    String referenceId,
  ) => [
    for (final entry in _favoritesBox.toMap().entries)
      if (_matches(Favorite.fromMap(entry.value), userId, type, referenceId))
        MapEntry(entry.key, Favorite.fromMap(entry.value)),
  ];

  List<MapEntry<dynamic, Favorite>> _offerFavoritesFor(
    String userId,
    String louageId,
    String departureHm,
  ) {
    final normalizedHm = _normalizeHm(departureHm);
    if (normalizedHm == null) return const [];
    return [
      for (final entry in _favoritesBox.toMap().entries)
        if (Favorite.fromMap(entry.value).userId == userId &&
            Favorite.fromMap(entry.value).type == 'offer' &&
            Favorite.fromMap(entry.value).louageId == louageId &&
            _normalizeHm(Favorite.fromMap(entry.value).departureHm) ==
                normalizedHm)
          MapEntry(entry.key, Favorite.fromMap(entry.value)),
    ];
  }

  bool _matches(Favorite favorite, String userId, String type, String refId) {
    if (favorite.userId != userId) return false;
    final favoriteType = favorite.type.isEmpty ? 'route' : favorite.type;
    if (favoriteType != type) return false;
    return switch (type) {
      'station' => favorite.stationId == refId,
      'offer' => favorite.louageId == refId,
      _ => favorite.routeId == refId,
    };
  }

  FavoritesData _loadFavorites(String userId) {
    final routeMap = {
      for (final map in _routesBox.values)
        RouteLine.fromMap(map).id: RouteLine.fromMap(map),
    };
    final stationMap = {
      for (final map in _stationsBox.values)
        Station.fromMap(map).id: Station.fromMap(map),
    };
    final louageMap = {
      for (final map in _louagesBox.values)
        Louage.fromMap(map).id: Louage.fromMap(map),
    };
    final trips = [
      for (final entry in _tripsBox.toMap().entries)
        _tripWithId(entry.key, entry.value),
    ];
    final routes = <FavoriteRoute>[];
    final stations = <FavoriteStation>[];
    final offers = <FavoriteOffer>[];
    final seen = <String>{};
    for (final map in _favoritesBox.values) {
      final favorite = Favorite.fromMap(map);
      if (favorite.userId != userId) continue;
      final type = favorite.type.isEmpty ? 'route' : favorite.type;
      if (type == 'station') {
        final station = stationMap[favorite.stationId];
        if (station == null || !seen.add('station:${station.id}')) continue;
        stations.add(FavoriteStation(favorite: favorite, station: station));
      } else if (type == 'offer') {
        final louage = louageMap[favorite.louageId];
        final route = routeMap[favorite.routeId];
        final from = route == null ? null : stationMap[route.fromStationId];
        final to = route == null ? null : stationMap[route.toStationId];
        final departureHm = _normalizeHm(favorite.departureHm);
        if (louage == null ||
            route == null ||
            from == null ||
            to == null ||
            departureHm == null ||
            !seen.add('offer:${favorite.louageId}:$departureHm')) {
          continue;
        }
        final nextTrip = trips
            .where(
              (trip) =>
                  trip.louageId == favorite.louageId &&
                  trip.routeId == favorite.routeId &&
                  trip.status != 'cancelled' &&
                  _tripHm(trip) == departureHm &&
                  _isFutureTrip(trip),
            )
            .toList()
          ..sort(
            (a, b) => DateTime.parse(
              a.departureTime,
            ).compareTo(DateTime.parse(b.departureTime)),
          );
        offers.add(
          FavoriteOffer(
            favorite: favorite.copyWith(
              departureHm: departureHm,
              matricule: favorite.matricule.isEmpty
                  ? louage.matricule
                  : favorite.matricule,
            ),
            louage: louage,
            route: route,
            fromStation: from,
            toStation: to,
            nextTrip: nextTrip.isEmpty ? null : nextTrip.first,
          ),
        );
      } else {
        final route = routeMap[favorite.routeId];
        if (route == null || !seen.add('route:${route.id}')) continue;
        final from = stationMap[route.fromStationId];
        final to = stationMap[route.toStationId];
        if (from == null || to == null) continue;
        routes.add(
          FavoriteRoute(
            favorite: favorite,
            from: from.city,
            to: to.city,
            fromAr: from.cityAr,
            toAr: to.cityAr,
            fromStationId: from.id,
            toStationId: to.id,
          ),
        );
      }
    }
    routes.sort((a, b) => a.favorite.createdAt.compareTo(b.favorite.createdAt));
    stations.sort(
      (a, b) => a.favorite.createdAt.compareTo(b.favorite.createdAt),
    );
    offers.sort((a, b) {
      final timeCompare = a.favorite.departureHm.compareTo(
        b.favorite.departureHm,
      );
      return timeCompare != 0
          ? timeCompare
          : a.favorite.createdAt.compareTo(b.favorite.createdAt);
    });
    return FavoritesData(
      routes: List.unmodifiable(routes),
      stations: List.unmodifiable(stations),
      offers: List.unmodifiable(offers),
    );
  }

  Trip _tripWithId(dynamic key, Map<dynamic, dynamic> map) {
    final trip = Trip.fromMap(map);
    return trip.id.isEmpty ? trip.copyWith(id: key.toString()) : trip;
  }

  String? _normalizeHm(String value) {
    final match = RegExp(r'^(\d{1,2}):?(\d{2})$').firstMatch(value.trim());
    if (match == null) return null;
    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || hour > 23 || minute == null || minute > 59) {
      return null;
    }
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String? _tripHm(Trip trip) {
    final departure = DateTime.tryParse(trip.departureTime);
    if (departure == null) return null;
    return _normalizeHm(
      '${departure.hour.toString().padLeft(2, '0')}:${departure.minute.toString().padLeft(2, '0')}',
    );
  }

  bool _isFutureTrip(Trip trip) {
    final departure = DateTime.tryParse(trip.departureTime);
    return departure != null && departure.isAfter(DateTime.now());
  }
}
