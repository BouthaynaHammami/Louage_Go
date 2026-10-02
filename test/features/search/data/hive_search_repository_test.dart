import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:louage_go/features/search/data/hive_search_repository.dart';
import 'package:louage_go/features/search/domain/trip_search_criteria.dart';
import 'package:louage_go/models/louage.dart';
import 'package:louage_go/models/route_line.dart';
import 'package:louage_go/models/station.dart';
import 'package:louage_go/models/trip.dart';

void main() {
  late Directory tempDirectory;
  late Box<Map> stationsBox;
  late Box<Map> routesBox;
  late Box<Map> louagesBox;
  late Box<Map> tripsBox;
  late Box<Map> favoritesBox;
  late Box<Map> sessionBox;
  late Box<Map> driversBox;
  late Box<Map> usersBox;
  late HiveSearchRepository repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'louagego_search_test',
    );
    Hive.init(tempDirectory.path);
    stationsBox = await Hive.openBox<Map>('stations');
    routesBox = await Hive.openBox<Map>('routes');
    louagesBox = await Hive.openBox<Map>('louages');
    tripsBox = await Hive.openBox<Map>('trips');
    favoritesBox = await Hive.openBox<Map>('favorites');
    sessionBox = await Hive.openBox<Map>('session');
    driversBox = await Hive.openBox<Map>('drivers');
    usersBox = await Hive.openBox<Map>('users');
    repository = HiveSearchRepository(
      stationsBox: stationsBox,
      routesBox: routesBox,
      louagesBox: louagesBox,
      tripsBox: tripsBox,
      favoritesBox: favoritesBox,
      sessionBox: sessionBox,
      driversBox: driversBox,
      usersBox: usersBox,
    );
  });

  tearDown(() async {
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test(
    'findTrips returns only matching routes with a valid departure',
    () async {
      await stationsBox.put(
        'from',
        const Station(id: 'from', city: 'Tunis').toMap(),
      );
      await stationsBox.put(
        'to',
        const Station(id: 'to', city: 'Sousse').toMap(),
      );
      await stationsBox.put(
        'other',
        const Station(id: 'other', city: 'Sfax').toMap(),
      );
      await routesBox.put(
        'matching',
        const RouteLine(
          id: 'matching',
          fromStationId: 'from',
          toStationId: 'to',
          pricePerSeat: 18,
        ).toMap(),
      );
      await routesBox.put(
        'other',
        const RouteLine(
          id: 'other',
          fromStationId: 'from',
          toStationId: 'other',
        ).toMap(),
      );
      await louagesBox.put(
        'vehicle',
        const Louage(id: 'vehicle', matricule: '123 TN 456').toMap(),
      );
      await tripsBox.put(
        'matching-trip',
        Trip(
          id: 'matching-trip',
          routeId: 'matching',
          louageId: 'vehicle',
          departureTime: DateTime(2026, 10, 3, 8).toIso8601String(),
        ).toMap(),
      );
      await tripsBox.put(
        'other-trip',
        Trip(
          id: 'other-trip',
          routeId: 'other',
          louageId: 'vehicle',
          departureTime: DateTime(2026, 10, 3, 9).toIso8601String(),
        ).toMap(),
      );
      await tripsBox.put(
        'invalid-trip',
        const Trip(
          id: 'invalid-trip',
          routeId: 'matching',
          louageId: 'vehicle',
          departureTime: 'not-a-date',
        ).toMap(),
      );

      final results = repository.findTrips(
        TripSearchCriteria(
          from: 'Tunis',
          to: 'Sousse',
          date: DateTime(2026, 10, 3),
          time: const TimeOfDay(hour: 8, minute: 0),
        ),
      );

      expect(results, hasLength(1));
      expect(results.single.trip.id, 'matching-trip');
      expect(results.single.price, 18);
    },
  );
}
