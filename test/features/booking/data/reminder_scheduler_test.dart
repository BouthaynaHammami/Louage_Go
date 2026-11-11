// Tests pour la planification des rappels de départ (Fonction 2).
//
// Toutes les interactions avec le plugin natif passent par la fausse
// implémentation [_FakeReminder] : aucun appel plugin réel dans ces tests.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:louage_go/core/services/reminder_scheduler.dart';
import 'package:louage_go/features/booking/data/hive_booking_repository.dart';
import 'package:louage_go/models/booking.dart';
import 'package:louage_go/models/driver_profile.dart';
import 'package:louage_go/models/louage.dart';
import 'package:louage_go/models/route_line.dart';
import 'package:louage_go/models/trip.dart';

void main() {
  late Directory tempDir;
  late Box<Map> bookingsBox;
  late Box<Map> paymentsBox;
  late Box<Map> tripsBox;
  late Box<Map> routesBox;
  late Box<Map> louagesBox;
  late Box<Map> usersBox;
  late Box<Map> driversBox;
  late _FakeReminder reminder;
  late DateTime now;

  // Identifiants stables pour tous les tests.
  const driverId = 'driver-1';
  const tripId = 'trip-1';
  const louageId = 'louage-1';
  const routeId = 'route-tunis-sfax';

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('reminder_test_');
    Hive.init(tempDir.path);
    bookingsBox = await Hive.openBox<Map>('bookings');
    paymentsBox = await Hive.openBox<Map>('payments');
    tripsBox    = await Hive.openBox<Map>('trips');
    routesBox   = await Hive.openBox<Map>('routes');
    louagesBox  = await Hive.openBox<Map>('louages');
    usersBox    = await Hive.openBox<Map>('users');
    driversBox  = await Hive.openBox<Map>('drivers');
    reminder    = _FakeReminder();
    now         = DateTime(2026, 11, 12, 10, 0); // 10:00 UTC

    // Données minimales.
    await louagesBox.put(louageId, const Louage(
      id: louageId, driverId: driverId, matricule: '101TUN4001',
    ).toMap());
    await driversBox.put(driverId, const DriverProfile(userId: driverId).toMap());
    await routesBox.put(routeId, const RouteLine(
      id: routeId,
      fromStationId: 'st-tunis', toStationId: 'st-sfax',
      pricePerSeat: 18, distanceKm: 270, durationMin: 210,
    ).toMap());
    await usersBox.put('passenger-1', {
      'id': 'passenger-1', 'name': 'Amira', 'email': 'a@example.test',
      'phone': '+21650000001', 'role': 'passenger',
    });
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  HiveBookingRepository repo() => HiveBookingRepository(
    bookingsBox:  bookingsBox,
    paymentsBox:  paymentsBox,
    tripsBox:     tripsBox,
    routesBox:    routesBox,
    louagesBox:   louagesBox,
    usersBox:     usersBox,
    driversBox:   driversBox,
    reminderScheduler: reminder,
    now: () => now,
  );

  /// Crée un trip avec le départ à [departure] et persiste une réservation.
  Future<Booking> book(DateTime departure) async {
    await tripsBox.put(tripId, Trip(
      id: tripId, louageId: louageId, routeId: routeId,
      totalSeats: 8, reservedSeats: 0, status: 'waiting',
      departureTime: departure.toIso8601String(),
    ).toMap());
    return repo().create(
      userId: 'passenger-1', tripId: tripId, seats: [1],
      paymentMethod: 'cash', fromCity: 'Tunis', toCity: 'Sfax',
    );
  }

  // ── 1. Planification au bon instant ──────────────────────────────────────
  test('planifie à départ − 2h quand le départ est dans le futur', () async {
    // Départ dans 4 heures → rappel dans 2 heures.
    final departure = now.add(const Duration(hours: 4));
    final booking = await book(departure);

    expect(reminder.scheduled, hasLength(1));
    final call = reminder.scheduled.single;
    expect(
      call.scheduledTime,
      departure.subtract(const Duration(hours: 2)),
    );
    expect(call.id, reminderIdForBooking(booking.id));
    expect(call.payload, '/passenger/trips');
  });

  // ── 2. Identifiant déterministe ───────────────────────────────────────────
  test('id déterministe : même bookingId → même id entier', () async {
    const bid = 'booking_abc123';
    expect(reminderIdForBooking(bid), reminderIdForBooking(bid));
    // Et reste dans la plage positive 31 bits.
    expect(reminderIdForBooking(bid), isNonNegative);
  });

  // ── 3. Pas de planification dans le passé ────────────────────────────────
  test('ne planifie pas quand départ − 2h est dans le passé', () async {
    // Départ dans 1 heure → rappel aurait dû être il y a 1 heure.
    final departure = now.add(const Duration(hours: 1));
    await book(departure);
    expect(reminder.scheduled, isEmpty);
  });

  test('ne planifie pas quand le départ est déjà passé', () async {
    final departure = now.subtract(const Duration(hours: 1));
    await book(departure);
    expect(reminder.scheduled, isEmpty);
  });

  // ── 4. Annulation à l'annulation de la réservation ───────────────────────
  test('annule le rappel quand la réservation est annulée', () async {
    final departure = now.add(const Duration(hours: 10));
    final booking = await book(departure);

    expect(reminder.scheduled, hasLength(1));
    expect(reminder.cancelled, isEmpty);

    await repo().cancel(
      bookingId: booking.id,
      userId: 'passenger-1',
    );

    expect(reminder.cancelled, hasLength(1));
    expect(reminder.cancelled.single, reminderIdForBooking(booking.id));
  });

  // ── 5. Re-planification ───────────────────────────────────────────────────
  test('replanifie après annulation + nouvelle réservation même trip', () async {
    final departure = now.add(const Duration(hours: 8));
    final booking1 = await book(departure);
    expect(reminder.scheduled, hasLength(1));

    // Annule la réservation.
    await repo().cancel(bookingId: booking1.id, userId: 'passenger-1');
    expect(reminder.cancelled, contains(reminderIdForBooking(booking1.id)));

    // Réouvre le siège (simule un nouveau trip disponible).
    await tripsBox.put(tripId, Trip(
      id: tripId, louageId: louageId, routeId: routeId,
      totalSeats: 8, reservedSeats: 0, status: 'waiting',
      departureTime: departure.toIso8601String(),
    ).toMap());

    // Nouvelle réservation → nouveau rappel planifié.
    final booking2 = await repo().create(
      userId: 'passenger-1', tripId: tripId, seats: [2],
      paymentMethod: 'cash', fromCity: 'Tunis', toCity: 'Sfax',
    );
    expect(reminder.scheduled, hasLength(2));
    expect(
      reminder.scheduled.last.scheduledTime,
      departure.subtract(const Duration(hours: 2)),
    );
    expect(reminder.scheduled.last.id, reminderIdForBooking(booking2.id));
  });

  // ── 6. Annulation impossible si depart < 2h ─────────────────────────────
  test('reminder not scheduled and cancel fails when departure < 2h', () async {
    // Départ dans 1h30 → annulation refusée par le repo.
    final departure = now.add(const Duration(hours: 1, minutes: 30));
    final booking = await book(departure);
    // Pas de rappel planifié (trop proche).
    expect(reminder.scheduled, isEmpty);

    await expectLater(
      repo().cancel(bookingId: booking.id, userId: 'passenger-1'),
      throwsStateError,
    );
    // Aucun cancel non plus puisqu'il n'y avait pas de rappel.
    expect(reminder.cancelled, isEmpty);
  });
}

// ── Fake ReminderScheduler ────────────────────────────────────────────────────

class _ScheduleCall {
  const _ScheduleCall({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.payload,
  });
  final int id;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final String payload;
}

class _FakeReminder implements ReminderScheduler {
  final List<_ScheduleCall> scheduled = [];
  final List<int> cancelled = [];

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
  }) async {
    // Reproduit exactement la garde du vrai scheduler.
    if (scheduledTime.toUtc().isBefore(
      DateTime.now().toUtc().add(const Duration(minutes: 1)),
    )) {
      return;
    }
    scheduled.add(_ScheduleCall(
      id: id, title: title, body: body,
      scheduledTime: scheduledTime, payload: payload,
    ));
  }

  @override
  Future<void> cancel(int id) async => cancelled.add(id);
}
