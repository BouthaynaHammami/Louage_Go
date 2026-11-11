// Tests SQLite — FavoritesRepository (mêmes scénarios que hive_favorites_repository_test)

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:louage_go/core/database/app_database.dart';
import 'package:louage_go/features/favorites/data/sqlite_favorites_repository.dart';
import 'package:louage_go/models/louage.dart';
import 'package:louage_go/models/route_line.dart';
import 'package:louage_go/models/station.dart';
import 'package:louage_go/models/trip.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late AppDatabase db;
  late SqliteFavoritesRepository repo;

  Future<void> seedBase() async {
    // Stations
    await db.insert('stations', {'id': 'from', 'name': 'Tunis-Nord', 'city': 'Tunis',
      'governorate': 'Tunis', 'nameAr': '', 'cityAr': '', 'governorateAr': '',
      'lat': 36.8, 'lng': 10.1, 'address': ''});
    await db.insert('stations', {'id': 'to', 'name': 'Sousse', 'city': 'Sousse',
      'governorate': 'Sousse', 'nameAr': '', 'cityAr': '', 'governorateAr': '',
      'lat': 35.8, 'lng': 10.6, 'address': ''});
    // Route
    await db.insert('routes', {'id': 'route-1', 'fromStationId': 'from',
      'toStationId': 'to', 'pricePerSeat': 10.0, 'distanceKm': 143.0, 'durationMin': 110});
  }

  setUp(() async {
    db = await AppDatabase.openInMemory(factory: databaseFactoryFfi);
    repo = SqliteFavoritesRepository(db);
    // Utilisateurs de test pour respecter FK favorites→users.
    for (final uid in ['user-1', 'user-2']) {
      await db.insert('users', {
        'id': uid, 'name': uid, 'email': '$uid@t.com',
        'phone': uid, 'role': 'passenger',
      });
    }
    await seedBase();
  });
  tearDown(() => db.close());

  // ── Toggle route ──────────────────────────────────────────────────────────
  test('toggle stores one deterministic record and toggles it off', () async {
    await repo.toggleRoute('user-1', 'route-1');

    final rows = await db.getAll('favorites');
    expect(rows, hasLength(1));
    expect(rows.single['id'], 'user-1_route_route-1');

    await repo.toggleRoute('user-1', 'route-1');
    expect(await db.getAll('favorites'), isEmpty);
  });

  // ── Toggle station ────────────────────────────────────────────────────────
  test('favorites are isolated by user and reference type', () async {
    await repo.toggleRoute('user-1', 'route-1');
    await repo.toggleStation('user-1', 'from');

    final data = await repo.watchFavorites('user-1').first;
    expect(data.routes, hasLength(1));
    expect(data.stations, hasLength(1));

    final dataUser2 = await repo.watchFavorites('user-2').first;
    expect(dataUser2.routes, isEmpty);
  });

  // ── watchFavorites ────────────────────────────────────────────────────────
  test('watchFavorites resolves routes with from/to city names', () async {
    await repo.toggleRoute('user-1', 'route-1');
    final data = await repo.watchFavorites('user-1').first;
    expect(data.routes.single.from, 'Tunis');
    expect(data.routes.single.to, 'Sousse');
  });

  // ── Offer ─────────────────────────────────────────────────────────────────
  test('offers use a deterministic key and separate departure times', () async {
    await db.insert('users', {'id': 'driver-1', 'name': 'd', 'email': 'd@t.com',
      'phone': 'd1', 'role': 'driver'});
    await db.insert('louages', {'id': 'louage-1', 'chauffeurId': 'driver-1',
      'matricule': '122 TUN 7014', 'modele': '', 'placesTotal': 8,
      'placesDisponibles': 8, 'stationActuelle': '', 'statut': 'disponible',
      'noteMoyenne': 0.0, 'nombreTrajets': 0, 'isQueued': 0});

    await repo.toggleOffer('user-1', 'louage-1', '7:15', 'route-1');
    await repo.toggleOffer('user-1', 'louage-1', '08:15', 'route-1');

    final rows = await db.getAll('favorites');
    expect(rows, hasLength(2));
    final ids = rows.map((r) => r['id'] as String).toSet();
    expect(ids, containsAll(['user-1_offer_louage-1_0715', 'user-1_offer_louage-1_0815']));
  });

  // ── nextTrip skips past ───────────────────────────────────────────────────
  test('offer nextTrip skips past departures', () async {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final tomorrow = todayMidnight.add(const Duration(days: 1));

    await db.insert('louages', {'id': 'louage-1', 'chauffeurId': 'd1',
      'matricule': 'X', 'modele': '', 'placesTotal': 8, 'placesDisponibles': 8,
      'stationActuelle': '', 'statut': 'disponible', 'noteMoyenne': 0.0,
      'nombreTrajets': 0, 'isQueued': 0});

    // past trip
    await db.insert('trips', {'id': 'past', 'louageId': 'louage-1', 'routeId': 'route-1',
      'totalSeats': 8, 'reservedSeats': 0, 'status': 'waiting',
      'departureTime': todayMidnight.toIso8601String(), 'arrivalTime': ''});
    // future trip
    await db.insert('trips', {'id': 'future', 'louageId': 'louage-1', 'routeId': 'route-1',
      'totalSeats': 8, 'reservedSeats': 0, 'status': 'waiting',
      'departureTime': tomorrow.toIso8601String(), 'arrivalTime': ''});

    await repo.toggleOffer('user-1', 'louage-1', '00:00', 'route-1');
    final data = await repo.watchFavorites('user-1').first;
    expect(data.offers.single.nextTrip?.id, 'future');
  });

  // ── watchFavorites réactif ────────────────────────────────────────────────
  test('watchFavorites re-emits after toggle', () async {
    final emissions = <int>[];
    final sub = repo.watchFavorites('user-1')
        .map((d) => d.routes.length)
        .listen(emissions.add);
    await Future<void>.delayed(const Duration(milliseconds: 30));

    await repo.toggleRoute('user-1', 'route-1');
    await Future<void>.delayed(const Duration(milliseconds: 50));

    await sub.cancel();
    expect(emissions, contains(1));
  });
}
