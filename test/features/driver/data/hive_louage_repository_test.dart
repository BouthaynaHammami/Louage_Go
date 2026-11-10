import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:louage_go/features/driver/data/hive_louage_repository.dart';
import 'package:louage_go/features/driver/domain/entities/ticket_validation_result.dart';
import 'package:louage_go/features/driver/domain/louage_repository.dart';
import 'package:louage_go/features/search/data/hive_search_repository.dart';
import 'package:louage_go/features/search/domain/trip_search_criteria.dart';
import 'package:louage_go/models/booking.dart';
import 'package:louage_go/models/louage.dart';
import 'package:louage_go/models/station.dart';
import 'package:louage_go/models/trip.dart';

void main() {
  late Directory tempDirectory;
  late Box<Map> stationsBox;
  late Box<Map> routesBox;
  late Box<Map> louagesBox;
  late Box<Map> tripsBox;
  late Box<Map> bookingsBox;
  late Box<Map> usersBox;
  late Box<Map> reviewsBox;
  late Box<Map> sessionBox;
  late Box<Map> driversBox;
  late HiveLouageRepository repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'louagego_louage_test',
    );
    Hive.init(tempDirectory.path);
    stationsBox = await Hive.openBox<Map>('stations');
    routesBox = await Hive.openBox<Map>('routes');
    louagesBox = await Hive.openBox<Map>('louages');
    tripsBox = await Hive.openBox<Map>('trips');
    bookingsBox = await Hive.openBox<Map>('bookings');
    usersBox = await Hive.openBox<Map>('users');
    reviewsBox = await Hive.openBox<Map>('reviews');
    sessionBox = await Hive.openBox<Map>('session');
    driversBox = await Hive.openBox<Map>('drivers');
    repository = HiveLouageRepository(
      stationsBox: stationsBox,
      routesBox: routesBox,
      louagesBox: louagesBox,
      tripsBox: tripsBox,
      bookingsBox: bookingsBox,
      usersBox: usersBox,
      reviewsBox: reviewsBox,
    );
  });

  tearDown(() async {
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('model validates and reads legacy Hive fields', () {
    final oldLouage = Louage.fromMap({
      'id': 'vehicle',
      'driverId': 'driver-1',
      'matricule': '123 TUN 4567',
      'capacity': 8,
      'currentStationId': 'station-1',
      'status': 'active',
    });
    expect(oldLouage.chauffeurId, 'driver-1');
    expect(oldLouage.placesTotal, 8);
    expect(oldLouage.placesDisponibles, 8);
    expect(oldLouage.stationActuelle, 'station-1');
    expect(oldLouage.statut, LouageStatus.disponible);

    expect(
      () => const Louage(matricule: '', placesTotal: 4).validate(),
      throwsFormatException,
    );
    expect(
      () => const Louage(
        matricule: '123 TUN 4567',
        placesTotal: 4,
        placesDisponibles: 5,
      ).validate(),
      throwsFormatException,
    );
  });

  test('ticket is accepted once only for the selected driver trip', () async {
    await louagesBox.put(
      'vehicle',
      const Louage(
        id: 'vehicle',
        chauffeurId: 'driver-1',
        matricule: '123 TUN 4567',
      ).toMap(),
    );
    await tripsBox.put(
      'trip-1',
      const Trip(id: 'trip-1', louageId: 'vehicle').toMap(),
    );
    await tripsBox.put(
      'trip-2',
      const Trip(id: 'trip-2', louageId: 'vehicle').toMap(),
    );
    await bookingsBox.put(
      'booking-1',
      const Booking(
        id: 'booking-1',
        userId: 'passenger-1',
        tripId: 'trip-1',
        status: 'confirmed',
        qrCode: 'louagego://ticket/booking-1',
      ).toMap(),
    );
    await bookingsBox.put(
      'booking-cancelled',
      const Booking(
        id: 'booking-cancelled',
        tripId: 'trip-1',
        status: 'cancelled',
      ).toMap(),
    );

    final mismatch = await repository.validateTicket(
      driverId: 'driver-1',
      tripId: 'trip-2',
      qrPayload: 'louagego://ticket/booking-1',
    );
    expect(mismatch.status, TicketValidationStatus.invalid);

    final accepted = await repository.validateTicket(
      driverId: 'driver-1',
      tripId: 'trip-1',
      qrPayload: 'louagego://ticket/booking-1',
    );
    expect(accepted.status, TicketValidationStatus.valid);
    expect(Booking.fromMap(bookingsBox.get('booking-1')!).status, 'validated');

    final used = await repository.validateTicket(
      driverId: 'driver-1',
      tripId: 'trip-1',
      qrPayload: 'louagego://ticket/booking-1',
    );
    expect(used.status, TicketValidationStatus.alreadyUsed);

    final cancelled = await repository.validateTicket(
      driverId: 'driver-1',
      tripId: 'trip-1',
      qrPayload: 'booking-cancelled',
    );
    expect(cancelled.status, TicketValidationStatus.invalid);
  });

  test('createTrip creates route and trip, updates current station', () async {
    await stationsBox.put(
      'from',
      const Station(id: 'from', name: 'Tunis', lat: 36.8065, lng: 10.1815).toMap(),
    );
    await stationsBox.put(
      'to',
      const Station(id: 'to', name: 'Sousse', lat: 35.8256, lng: 10.6367).toMap(),
    );
    await louagesBox.put(
      'vehicle',
      const Louage(
        id: 'vehicle',
        chauffeurId: 'driver-1',
        matricule: '123 TUN 4567',
        stationActuelle: 'from',
      ).toMap(),
    );

    final futureDeparture = DateTime.now().add(
      const Duration(days: 2, hours: 2),
    );
    final tripEmitted = Completer<List<Trip>>();
    final subscription = repository.watchTrips('driver-1').listen((trips) {
      if (trips.any((entry) => entry.id.isNotEmpty) && !tripEmitted.isCompleted) {
        tripEmitted.complete(trips);
      }
    });
    final trip = await repository.createTrip(
      driverId: 'driver-1',
      fromStationId: 'from',
      toStationId: 'to',
      departureTime: futureDeparture,
    );

    expect(trip.louageId, 'vehicle');
    expect(trip.routeId, isNotEmpty);
    expect(trip.status, 'waiting');
    expect(Trip.fromMap(tripsBox.get(trip.id)!).id, trip.id);
    expect(Louage.fromMap(louagesBox.get('vehicle')!).stationActuelle, 'from');

    final trips = await tripEmitted.future;
    expect(trips, isNotEmpty);
    expect(trips.any((entry) => entry.id == trip.id), isTrue);
    await subscription.cancel();

    final searchRepository = HiveSearchRepository(
      stationsBox: stationsBox,
      routesBox: routesBox,
      louagesBox: louagesBox,
      tripsBox: tripsBox,
      sessionBox: sessionBox,
      driversBox: driversBox,
      usersBox: usersBox,
    );
    final searchResults = searchRepository.findTrips(
      TripSearchCriteria(
        from: 'Tunis',
        to: 'Sousse',
        date: futureDeparture,
        time: TimeOfDay.fromDateTime(futureDeparture),
        fromStationId: 'from',
        toStationId: 'to',
      ),
    );
    expect(searchResults.map((result) => result.trip.id), contains(trip.id));
  });

  test('createTrip validates station, departure and duplicates', () async {
    await stationsBox.put(
      'station1',
      const Station(id: 'station1', name: 'Tunis', lat: 36.8, lng: 10.1).toMap(),
    );
    await stationsBox.put(
      'station2',
      const Station(id: 'station2', name: 'Sousse', lat: 35.8, lng: 10.6).toMap(),
    );
    await louagesBox.put(
      'vehicle',
      const Louage(
        id: 'vehicle',
        chauffeurId: 'driver-1',
        matricule: '123 TUN 4567',
        stationActuelle: 'station1',
      ).toMap(),
    );

    expect(
      () => repository.createTrip(
        driverId: 'driver-1',
        fromStationId: 'station1',
        toStationId: 'station1',
        departureTime: DateTime.now().add(const Duration(hours: 1)),
      ),
      throwsA(isA<DriverTripException>()),
    );

    expect(
      () => repository.createTrip(
        driverId: 'driver-1',
        fromStationId: 'station1',
        toStationId: 'station2',
        departureTime: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      throwsA(isA<DriverTripException>()),
    );

    expect(
      () => repository.createTrip(
        driverId: 'missing',
        fromStationId: 'station1',
        toStationId: 'station2',
        departureTime: DateTime.now().add(const Duration(hours: 2)),
      ),
      throwsA(isA<DriverTripException>()),
    );

    final duplicateDeparture = DateTime.now().add(
      const Duration(days: 7, hours: 2),
    );
    await repository.createTrip(
      driverId: 'driver-1',
      fromStationId: 'station1',
      toStationId: 'station2',
      departureTime: duplicateDeparture,
    );

    expect(
      () => repository.createTrip(
        driverId: 'driver-1',
        fromStationId: 'station1',
        toStationId: 'station2',
        departureTime: duplicateDeparture,
      ),
      throwsA(isA<DriverTripException>()),
    );
  });
}
