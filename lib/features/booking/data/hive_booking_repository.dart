// ignore_for_file: prefer_initializing_formals

import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

import '../../../core/storage/hive_service.dart';
import '../../../features/notifications/domain/notification_repository.dart';
import '../../../models/booking.dart';
import '../../../models/app_user.dart';
import '../../../models/driver_profile.dart';
import '../../../models/louage.dart';
import '../../../models/payment.dart';
import '../../../models/route_line.dart';
import '../../../models/trip.dart';
import '../domain/booking_repository.dart';

class HiveBookingRepository implements BookingRepository {
  HiveBookingRepository({
    Box<Map>? bookingsBox,
    Box<Map>? paymentsBox,
    Box<Map>? tripsBox,
    Box<Map>? routesBox,
    Box<Map>? louagesBox,
    Box<Map>? usersBox,
    Box<Map>? driversBox,
    NotificationRepository? notifications,
    DateTime Function()? now,
  }) : _bookings = bookingsBox ?? HiveService.bookings,
       _payments = paymentsBox ?? HiveService.payments,
       _trips = tripsBox ?? HiveService.trips,
       _routes = routesBox ?? HiveService.routes,
       _louages = louagesBox ?? HiveService.louages,
       _users = usersBox ?? HiveService.users,
       _drivers = driversBox ?? HiveService.drivers,
       _notifications = notifications,
       _now = now ?? DateTime.now;

  final Box<Map> _bookings;
  final Box<Map> _payments;
  final Box<Map> _trips;
  final Box<Map> _routes;
  final Box<Map> _louages;
  final Box<Map> _users;
  final Box<Map> _drivers;
  final NotificationRepository? _notifications;
  final DateTime Function() _now;
  static const _uuid = Uuid();

  @override
  Stream<List<Booking>> watchForUser(String userId) async* {
    List<Booking> current() =>
        _bookings.values
            .map(Booking.fromMap)
            .where((item) => item.userId == userId)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    yield current();
    await for (final _ in _bookings.watch()) {
      yield current();
    }
  }

  @override
  Future<Booking> create({
    required String userId,
    required String tripId,
    required List<int> seats,
    required String paymentMethod,
  }) async {
    final tripMap = _trips.get(tripId);
    if (tripMap == null) throw StateError('Trip not found');
    final trip = Trip.fromMap(tripMap);
    final routeMap = _routes.get(trip.routeId);
    if (routeMap == null) throw StateError('Route not found');
    final route = RouteLine.fromMap(routeMap);
    final louageMap = _louages.get(trip.louageId);
    final louage = louageMap == null ? null : Louage.fromMap(louageMap);
    final driverMap = louage == null ? null : _users.get(louage.driverId);
    final driverName = driverMap == null ? '' : AppUser.fromMap(driverMap).name;
    final profileMap = louage == null ? null : _drivers.get(louage.driverId);
    final matricule = louage?.matricule.isNotEmpty == true
        ? louage!.matricule
        : profileMap == null
        ? ''
        : DriverProfile.fromMap(profileMap).matricule;
    final uniqueSeats = seats.toSet().toList()..sort();
    if (uniqueSeats.isEmpty || uniqueSeats.length > trip.freeSeats) {
      throw StateError('Not enough seats');
    }
    if (uniqueSeats.any((seat) => seat < 1 || seat > trip.totalSeats)) {
      throw StateError('Invalid seat');
    }
    final id = 'booking_${_uuid.v4()}';
    final paymentId = 'payment_${_uuid.v4()}';
    final now = _now();
    final booking = Booking(
      id: id,
      userId: userId,
      tripId: tripId,
      seats: uniqueSeats.length,
      totalPrice: route.pricePerSeat * uniqueSeats.length,
      status: 'confirmed',
      createdAt: now.toIso8601String(),
      selectedSeats: uniqueSeats,
      paymentMethod: paymentMethod,
      paymentStatus: paymentMethod == 'cash' ? 'cashOnBoard' : 'paid',
      qrCode: 'louagego://ticket/$id',
      departureTime: trip.departureTime,
      driverName: driverName,
      matricule: matricule,
    );
    await _trips.put(
      tripId,
      trip
          .copyWith(
            reservedSeats: trip.reservedSeats + uniqueSeats.length,
            status: trip.reservedSeats + uniqueSeats.length >= trip.totalSeats
                ? 'full'
                : trip.status,
          )
          .toMap(),
    );
    await _bookings.put(id, booking.toMap());
    await _payments.put(
      paymentId,
      Payment(
        id: paymentId,
        bookingId: id,
        amount: booking.totalPrice,
        method: paymentMethod,
        status: booking.paymentStatus,
        transactionId: 'SIM-${_uuid.v4().substring(0, 8).toUpperCase()}',
        paidAt: now.toIso8601String(),
      ).toMap(),
    );
    await _createNotificationSafely(
      userId: userId,
      title: 'Booking confirmed',
      message: 'Your local booking is confirmed.',
      type: 'booking_confirmed',
      data: {'bookingId': id},
      messageId: 'booking-confirmed-$id',
    );
    return booking;
  }

  @override
  Future<Booking> cancel({
    required String bookingId,
    required String userId,
  }) async {
    final map = _bookings.get(bookingId);
    if (map == null) throw StateError('Booking not found');
    final booking = Booking.fromMap(map);
    if (booking.userId != userId) throw StateError('Booking access denied');
    if (booking.status == 'cancelled') return booking;
    final tripMap = _trips.get(booking.tripId);
    if (tripMap == null) throw StateError('Trip not found');
    final trip = Trip.fromMap(tripMap);
    final departure = DateTime.tryParse(trip.departureTime);
    if (departure != null &&
        departure.difference(_now()) < const Duration(hours: 2)) {
      throw StateError(
        'Cancellation is closed less than 2 hours before departure',
      );
    }
    final updated = booking.copyWith(
      status: 'cancelled',
      cancelledAt: _now().toIso8601String(),
    );
    final remaining = (trip.reservedSeats - booking.seats)
        .clamp(0, trip.totalSeats)
        .toInt();
    await _trips.put(
      trip.id,
      trip
          .copyWith(
            reservedSeats: remaining,
            status: trip.status == 'full' ? 'waiting' : trip.status,
          )
          .toMap(),
    );
    await _bookings.put(booking.id, updated.toMap());
    await _createNotificationSafely(
      userId: booking.userId,
      title: 'Booking cancelled',
      message: 'Your booking has been cancelled.',
      type: 'booking_cancelled',
      data: {'bookingId': booking.id},
      messageId: 'booking-cancelled-${booking.id}',
    );
    return updated;
  }

  Future<void> _createNotificationSafely({
    required String userId,
    required String title,
    required String message,
    required String type,
    required Map<String, dynamic> data,
    required String messageId,
  }) async {
    final notifications = _notifications;
    if (notifications == null) return;
    try {
      await notifications.create(
        userId: userId,
        title: title,
        message: message,
        type: type,
        route: '/passenger/trips',
        data: data,
        messageId: messageId,
      );
    } on StateError catch (error) {
      // Notification permission is optional and must not undo a booking.
      debugPrint('Booking notification unavailable: $error');
    }
  }
}
