import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:louage_go/core/storage/seed_data.dart';
import 'package:louage_go/features/search/data/hive_search_repository.dart';
import 'package:louage_go/features/search/domain/trip_search_criteria.dart';
import 'package:louage_go/models/booking.dart';
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
  late Box<Map> bookingsBox;
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
    bookingsBox = await Hive.openBox<Map>('bookings');
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

  test(
    'station search ignores French accents and matches Arabic names',
    () async {
      await stationsBox.put(
        'sfax',
        const Station(
          id: 'sfax',
          name: 'Station de Sfax',
          city: 'Sfax',
          governorate: 'Sfax',
          nameAr: 'محطة صفاقس',
          cityAr: 'صفاقس',
          governorateAr: 'صفاقس',
        ).toMap(),
      );
      await stationsBox.put(
        'beja',
        const Station(
          id: 'beja',
          name: 'Gare de Béja',
          city: 'Béja',
          governorate: 'Béja',
          nameAr: 'محطة باجة',
          cityAr: 'باجة',
          governorateAr: 'باجة',
        ).toMap(),
      );

      expect(repository.searchStations('beja').single.id, 'beja');
      expect(repository.searchStations('صفاقس').single.id, 'sfax');
      expect(repository.searchStations('صَفاقس').single.id, 'sfax');
      expect(repository.searchStations('BEJA').single.id, 'beja');
    },
  );

  test('station groups retain governorate and station entries', () async {
    await stationsBox.put(
      'one',
      const Station(
        id: 'one',
        name: 'Station 1',
        city: 'Tunis',
        governorate: 'Tunis',
        governorateAr: 'تونس',
      ).toMap(),
    );
    await stationsBox.put(
      'two',
      const Station(
        id: 'two',
        name: 'Station 2',
        city: 'Tunis',
        governorate: 'Tunis',
        governorateAr: 'تونس',
      ).toMap(),
    );

    final groups = await repository.watchStationsByGovernorate().first;

    expect(groups, hasLength(1));
    expect(groups.single.governorate, 'Tunis');
    expect(groups.single.governorateAr, 'تونس');
    expect(groups.single.stations, hasLength(2));
  });

  test(
    'trip search can target exact station ids while preserving city search',
    () async {
      for (final station in const [
        Station(id: 'from-main', city: 'Tunis'),
        Station(id: 'from-other', city: 'Tunis'),
        Station(id: 'to', city: 'Sfax'),
      ]) {
        await stationsBox.put(station.id, station.toMap());
      }
      for (final route in const [
        RouteLine(
          id: 'main-route',
          fromStationId: 'from-main',
          toStationId: 'to',
        ),
        RouteLine(
          id: 'other-route',
          fromStationId: 'from-other',
          toStationId: 'to',
        ),
      ]) {
        await routesBox.put(route.id, route.toMap());
      }
      await louagesBox.put(
        'vehicle',
        const Louage(id: 'vehicle', matricule: '123 TN 456').toMap(),
      );
      for (final routeId in ['main-route', 'other-route']) {
        await tripsBox.put(
          '$routeId-trip',
          Trip(
            id: '$routeId-trip',
            routeId: routeId,
            louageId: 'vehicle',
            departureTime: DateTime(2026, 10, 3, 8).toIso8601String(),
          ).toMap(),
        );
      }
      final base = TripSearchCriteria(
        from: 'Tunis',
        to: 'Sfax',
        date: DateTime(2026, 10, 3),
        time: const TimeOfDay(hour: 8, minute: 0),
      );

      expect(repository.findTrips(base), hasLength(2));
      expect(
        repository
            .findTrips(
              TripSearchCriteria(
                from: base.from,
                to: base.to,
                date: base.date,
                time: base.time,
                fromStationId: 'from-other',
              ),
            )
            .single
            .route
            .id,
        'other-route',
      );
    },
  );

  test(
    'seed is idempotent, preserves user data and creates seven days',
    () async {
      const changedUser = {'id': 'demo_passenger', 'name': 'Updated passenger'};
      await usersBox.put('demo_passenger', changedUser);
      const reservedTrip = Trip(
        id: '20261001_tunis_sfax_1',
        routeId: 'tunis_sfax',
        louageId: 'tunis_sfax_01',
        reservedSeats: 6,
        departureTime: '2026-10-01T06:30:00.000',
      );
      await tripsBox.put(reservedTrip.id, reservedTrip.toMap());

      Future<void> runSeed() => SeedData.seedForTesting(
        stationsBox: stationsBox,
        usersBox: usersBox,
        driversBox: driversBox,
        routesBox: routesBox,
        louagesBox: louagesBox,
        tripsBox: tripsBox,
        sessionBox: sessionBox,
        bookingsBox: bookingsBox,
        now: DateTime(2026, 10, 1, 12),
      );

      await runSeed();
      final stationCount = stationsBox.length;
      final routeCount = routesBox.length;
      final tripCount = tripsBox.length;
      final firstRunTripIds = tripsBox.keys.toSet();
      final generatedDays = tripsBox.values
          .where(
            (raw) => !(raw['id'] as String).startsWith('demo_review_trip_'),
          )
          .map((raw) => DateTime.parse(raw['departureTime'] as String))
          .map((date) => DateTime(date.year, date.month, date.day))
          .toSet();
      await runSeed();

      expect(stationsBox.length, stationCount);
      expect(routesBox.length, routeCount);
      expect(tripsBox.length, tripCount);
      expect(tripsBox.keys.toSet(), firstRunTripIds);
      expect(generatedDays, hasLength(7));
      expect(Trip.fromMap(tripsBox.get(reservedTrip.id)!).reservedSeats, 6);
      expect(usersBox.get('demo_passenger'), changedUser);
      expect(sessionBox.get('seedVersion')?['value'], 2);
      expect(bookingsBox.length, 2);
      final demoReviewBookings = bookingsBox.values
          .map(Booking.fromMap)
          .where((booking) => booking.id.startsWith('demo_review_booking_'))
          .toList();
      expect(demoReviewBookings, hasLength(2));
      expect(
        demoReviewBookings.every(
          (booking) => booking.userId == 'demo_passenger',
        ),
        isTrue,
      );
      expect(
        demoReviewBookings.every(
          (booking) =>
              Trip.fromMap(tripsBox.get(booking.tripId)!).status == 'arrived',
        ),
        isTrue,
      );
      final seededStations = stationsBox.values.map(Station.fromMap).toList();
      expect(
        seededStations.map((station) => station.governorate).toSet(),
        hasLength(24),
      );

      final demoBooking = Booking.fromMap(bookingsBox.get('demo_review_booking_1')!);
      final demoTrip = Trip.fromMap(tripsBox.get(demoBooking.tripId)!);
      await bookingsBox.put(
        demoBooking.id,
        demoBooking.copyWith(status: 'cancelled').toMap(),
      );
      await tripsBox.put(
        demoTrip.id,
        demoTrip.copyWith(status: 'departed').toMap(),
      );
      await runSeed();
      expect(
        Booking.fromMap(bookingsBox.get(demoBooking.id)!).status,
        'cancelled',
      );
      expect(Trip.fromMap(tripsBox.get(demoTrip.id)!).status, 'departed');
      expect(
        seededStations.every(
          (station) =>
              station.nameAr.isNotEmpty &&
              station.cityAr.isNotEmpty &&
              station.governorateAr.isNotEmpty,
        ),
        isTrue,
      );
      expect(routesBox.containsKey('tunis_sfax'), isTrue);
      expect(routesBox.containsKey('sfax_tunis'), isTrue);
      expect(
        routesBox.values
            .map(RouteLine.fromMap)
            .any((route) => route.fromStationId == 'station_tunis_bardo'),
        isTrue,
      );
    },
  );

  test('legacy station maps default Arabic names to empty strings', () {
    final station = Station.fromMap({
      'id': 'legacy',
      'name': 'Legacy',
      'city': 'Tunis',
      'governorate': 'Tunis',
    });

    expect(station.nameAr, isEmpty);
    expect(station.cityAr, isEmpty);
    expect(station.governorateAr, isEmpty);
  });
}
