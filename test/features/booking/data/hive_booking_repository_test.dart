import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:louage_go/features/booking/data/hive_booking_repository.dart';
import 'package:louage_go/models/booking.dart';
import 'package:louage_go/models/louage.dart';
import 'package:louage_go/models/route_line.dart';
import 'package:louage_go/models/trip.dart';

void main() {
  late Directory tempDirectory;
  late Box<Map> bookingsBox;
  late Box<Map> paymentsBox;
  late Box<Map> tripsBox;
  late Box<Map> routesBox;
  late Box<Map> louagesBox;
  late Box<Map> usersBox;
  late Box<Map> driversBox;
  late HiveBookingRepository repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'louagego_booking_test',
    );
    Hive.init(tempDirectory.path);
    bookingsBox = await Hive.openBox<Map>('bookings');
    paymentsBox = await Hive.openBox<Map>('payments');
    tripsBox = await Hive.openBox<Map>('trips');
    routesBox = await Hive.openBox<Map>('routes');
    louagesBox = await Hive.openBox<Map>('louages');
    usersBox = await Hive.openBox<Map>('users');
    driversBox = await Hive.openBox<Map>('drivers');

    await routesBox.put(
      'route',
      const RouteLine(id: 'route', pricePerSeat: 20).toMap(),
    );
    await louagesBox.put(
      'louage',
      const Louage(
        id: 'louage',
        driverId: 'driver',
        matricule: '123 TN 456',
      ).toMap(),
    );
    await tripsBox.put(
      'trip',
      Trip(
        id: 'trip',
        routeId: 'route',
        louageId: 'louage',
        departureTime: DateTime(2026, 10, 2, 8).toIso8601String(),
      ).toMap(),
    );
    repository = HiveBookingRepository(
      bookingsBox: bookingsBox,
      paymentsBox: paymentsBox,
      tripsBox: tripsBox,
      routesBox: routesBox,
      louagesBox: louagesBox,
      usersBox: usersBox,
      driversBox: driversBox,
      now: () => DateTime(2026, 10, 1, 12),
    );
  });

  tearDown(() async {
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  Future<Booking> create(List<int> seats) => repository.create(
    userId: 'passenger',
    tripId: 'trip',
    seats: seats,
    paymentMethod: 'cash',
  );

  test(
    'persists selected seats and rejects an already reserved seat',
    () async {
      final booking = await create([4, 2]);

      expect(booking.numerosPlaces, [2, 4]);
      expect(booking.selectedSeats, [2, 4]);
      expect(bookingsBox.get(booking.id)?['numerosPlaces'], [2, 4]);
      expect(repository.occupiedSeatNumbers('trip'), {2, 4});

      await expectLater(create([4]), throwsA(isA<StateError>()));
      final otherBooking = await create([3]);
      expect(otherBooking.numerosPlaces, [3]);
      expect(Trip.fromMap(tripsBox.get('trip')!).reservedSeats, 3);
    },
  );

  test('serializes concurrent attempts to book the same seat', () async {
    final attempts = await Future.wait([
      create([5]).then((_) => true, onError: (Object error) => false),
      create([5]).then((_) => true, onError: (Object error) => false),
    ]);

    expect(attempts.where((success) => success), hasLength(1));
    expect(attempts.where((success) => !success), hasLength(1));
    expect(repository.occupiedSeatNumbers('trip'), {5});
  });

  test('cancelling a booking releases its exact seat', () async {
    final booking = await create([7]);

    await repository.cancel(bookingId: booking.id, userId: 'passenger');

    expect(repository.occupiedSeatNumbers('trip'), isEmpty);
    expect(Trip.fromMap(tripsBox.get('trip')!).reservedSeats, 0);
    expect(Booking.fromMap(bookingsBox.get(booking.id)!).status, 'cancelled');
  });

  test('reads legacy seat numbers from selectedSeats', () {
    final booking = Booking.fromMap({
      'id': 'legacy',
      'tripId': 'trip',
      'selectedSeats': [1, 6],
    });

    expect(booking.numerosPlaces, [1, 6]);
    expect(booking.toMap()['numerosPlaces'], [1, 6]);
  });
}
