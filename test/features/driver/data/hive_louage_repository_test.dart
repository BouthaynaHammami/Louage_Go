import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:louage_go/features/driver/data/hive_louage_repository.dart';
import 'package:louage_go/features/driver/domain/entities/ticket_validation_result.dart';
import 'package:louage_go/models/booking.dart';
import 'package:louage_go/models/louage.dart';
import 'package:louage_go/models/trip.dart';

void main() {
  late Directory tempDirectory;
  late Box<Map> louagesBox;
  late Box<Map> tripsBox;
  late Box<Map> bookingsBox;
  late Box<Map> usersBox;
  late Box<Map> reviewsBox;
  late HiveLouageRepository repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'louagego_louage_test',
    );
    Hive.init(tempDirectory.path);
    louagesBox = await Hive.openBox<Map>('louages');
    tripsBox = await Hive.openBox<Map>('trips');
    bookingsBox = await Hive.openBox<Map>('bookings');
    usersBox = await Hive.openBox<Map>('users');
    reviewsBox = await Hive.openBox<Map>('reviews');
    repository = HiveLouageRepository(
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
}
