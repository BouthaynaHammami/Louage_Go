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
import 'package:louage_go/models/driver_earning.dart';
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
  late Box<Map> bookingsBox;
  late Box<Map> usersBox;
  late Box<Map> reviewsBox;
  late Box<Map> sessionBox;
  late Box<Map> driversBox;
  late Box<Map> earningsBox;
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
    earningsBox = await Hive.openBox<Map>('earnings');
    repository = HiveLouageRepository(
      stationsBox: stationsBox,
      routesBox: routesBox,
      louagesBox: louagesBox,
      tripsBox: tripsBox,
      bookingsBox: bookingsBox,
      usersBox: usersBox,
      reviewsBox: reviewsBox,
      earningsBox: earningsBox,
    );
  });

  tearDown(() async {
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('trip price is optional for legacy records and has route fallback', () {
    final legacyTrip = Trip.fromMap({'id': 'legacy', 'routeId': 'route'});
    const route = RouteLine(id: 'route', pricePerSeat: 18.5);
    expect(legacyTrip.pricePerSeat, isNull);
    expect(legacyTrip.effectivePrice(route), 18.5);
    expect(legacyTrip.toMap()['pricePerSeat'], isNull);

    final pricedTrip = Trip.fromMap({
      'id': 'priced',
      'routeId': 'route',
      'pricePerSeat': 22.25,
    });
    expect(pricedTrip.effectivePrice(route), 22.25);
    expect(pricedTrip.copyWith(pricePerSeat: 24).pricePerSeat, 24);
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
        totalPrice: 37.5,
        paymentMethod: 'cash',
        paymentStatus: 'cashOnBoard',
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
    expect(accepted.amount, 37.5);
    final validatedBooking = Booking.fromMap(bookingsBox.get('booking-1')!);
    expect(validatedBooking.status, 'validated');
    expect(validatedBooking.paymentStatus, 'paid');
    expect(earningsBox.length, 1);
    final earning = DriverEarning.fromMap(earningsBox.get('booking-1')!);
    expect(earning.driverId, 'driver-1');
    expect(earning.bookingId, 'booking-1');
    expect(earning.tripId, 'trip-1');
    expect(earning.amount, 37.5);
    expect(DateTime.tryParse(earning.earnedAt), isNotNull);

    final used = await repository.validateTicket(
      driverId: 'driver-1',
      tripId: 'trip-1',
      qrPayload: 'louagego://ticket/booking-1',
    );
    expect(used.status, TicketValidationStatus.alreadyUsed);
    expect(earningsBox.length, 1);

    final cancelled = await repository.validateTicket(
      driverId: 'driver-1',
      tripId: 'trip-1',
      qrPayload: 'booking-cancelled',
    );
    expect(cancelled.status, TicketValidationStatus.invalid);
    expect(earningsBox.length, 1);

    final wrongDriver = await repository.validateTicket(
      driverId: 'another-driver',
      tripId: 'trip-1',
      qrPayload: 'louagego://ticket/booking-1',
    );
    expect(wrongDriver.status, TicketValidationStatus.invalid);
    expect(earningsBox.length, 1);
  });

  test('createTrip creates route and trip, updates current station', () async {
    await stationsBox.put(
      'from',
      const Station(
        id: 'from',
        name: 'Tunis',
        lat: 36.8065,
        lng: 10.1815,
      ).toMap(),
    );
    await stationsBox.put(
      'to',
      const Station(
        id: 'to',
        name: 'Sousse',
        lat: 35.8256,
        lng: 10.6367,
      ).toMap(),
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
      if (trips.any((entry) => entry.id.isNotEmpty) &&
          !tripEmitted.isCompleted) {
        tripEmitted.complete(trips);
      }
    });
    final trip = await repository.createTrip(
      driverId: 'driver-1',
      fromStationId: 'from',
      toStationId: 'to',
      departureTime: futureDeparture,
      pricePerSeat: 23.45,
    );

    expect(trip.louageId, 'vehicle');
    expect(trip.routeId, isNotEmpty);
    expect(trip.status, 'waiting');
    expect(trip.pricePerSeat, 23.45);
    expect(Trip.fromMap(tripsBox.get(trip.id)!).id, trip.id);
    expect(Louage.fromMap(louagesBox.get('vehicle')!).stationActuelle, 'from');
    final storedRoute = RouteLine.fromMap(routesBox.get(trip.routeId)!);
    expect(storedRoute.pricePerSeat, isNot(23.45));

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
      const Station(
        id: 'station1',
        name: 'Tunis',
        lat: 36.8,
        lng: 10.1,
      ).toMap(),
    );
    await stationsBox.put(
      'station2',
      const Station(
        id: 'station2',
        name: 'Sousse',
        lat: 35.8,
        lng: 10.6,
      ).toMap(),
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
        pricePerSeat: 18,
      ),
      throwsA(isA<DriverTripException>()),
    );

    expect(
      () => repository.createTrip(
        driverId: 'driver-1',
        fromStationId: 'station1',
        toStationId: 'station2',
        departureTime: DateTime.now().subtract(const Duration(minutes: 1)),
        pricePerSeat: 18,
      ),
      throwsA(isA<DriverTripException>()),
    );

    expect(
      () => repository.createTrip(
        driverId: 'missing',
        fromStationId: 'station1',
        toStationId: 'station2',
        departureTime: DateTime.now().add(const Duration(hours: 2)),
        pricePerSeat: 18,
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
      pricePerSeat: 18,
    );

    expect(
      () => repository.createTrip(
        driverId: 'driver-1',
        fromStationId: 'station1',
        toStationId: 'station2',
        departureTime: duplicateDeparture,
        pricePerSeat: 18,
      ),
      throwsA(isA<DriverTripException>()),
    );

    for (final invalidPrice in [0.0, -1.0, 100.01, 1.234]) {
      await expectLater(
        repository.createTrip(
          driverId: 'driver-1',
          fromStationId: 'station1',
          toStationId: 'station2',
          departureTime: DateTime.now().add(const Duration(days: 10)),
          pricePerSeat: invalidPrice,
        ),
        throwsA(
          isA<DriverTripException>().having(
            (error) => error.failure,
            'failure',
            DriverTripFailure.invalidPrice,
          ),
        ),
      );
    }
  });
}
