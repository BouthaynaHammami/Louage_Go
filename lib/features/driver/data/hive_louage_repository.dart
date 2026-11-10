import 'dart:async';
import 'dart:math' as math;

import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/hive_service.dart';
import '../../../models/app_user.dart';
import '../../../models/booking.dart';
import '../../../models/louage.dart';
import '../../../models/review.dart';
import '../../../models/route_line.dart';
import '../../../models/station.dart';
import '../../../models/trip.dart';
import '../domain/entities/driver_booking.dart';
import '../domain/entities/ticket_validation_result.dart';
import '../domain/louage_repository.dart';

class HiveLouageRepository implements LouageRepository {
  HiveLouageRepository({
    Box<Map>? stationsBox,
    Box<Map>? routesBox,
    Box<Map>? louagesBox,
    Box<Map>? tripsBox,
    Box<Map>? bookingsBox,
    Box<Map>? usersBox,
    Box<Map>? reviewsBox,
  }) : _stations = stationsBox ?? HiveService.stations,
       _routes = routesBox ?? HiveService.routes,
       _louages = louagesBox ?? HiveService.louages,
       _trips = tripsBox ?? HiveService.trips,
       _bookings = bookingsBox ?? HiveService.bookings,
       _users = usersBox ?? HiveService.users,
       _reviews = reviewsBox ?? HiveService.reviews;

  static const _uuid = Uuid();
  final Box<Map> _stations;
  final Box<Map> _routes;
  final Box<Map> _louages;
  final Box<Map> _trips;
  final Box<Map> _bookings;
  final Box<Map> _users;
  final Box<Map> _reviews;

  @override
  Stream<Louage?> watchLouage(String driverId) =>
      Stream<Louage?>.multi((controller) {
        void reload() {
          try {
            controller.add(_louageFor(driverId));
          } catch (error, stackTrace) {
            controller.addError(error, stackTrace);
          }
        }

        final subscription = _louages.watch().listen((_) => reload());
        controller.onCancel = subscription.cancel;
        reload();
      });

  @override
  Future<Louage> saveLouage(Louage louage) async {
    louage.validate();
    if (louage.chauffeurId.trim().isEmpty) {
      throw const FormatException('Le chauffeur est obligatoire.');
    }
    final existing = _louageFor(louage.chauffeurId);
    final id = louage.id.isNotEmpty ? louage.id : existing?.id ?? _uuid.v4();
    final updated = louage.copyWith(id: id);
    final stored = _louages.get(id);
    if (stored != null &&
        Louage.fromMap(stored).chauffeurId != louage.chauffeurId) {
      throw StateError('Ce louage appartient à un autre chauffeur.');
    }
    await _louages.put(id, updated.toMap());
    return updated;
  }

  @override
  Future<void> updateStatus(String louageId, LouageStatus status) async {
    final louage = _louageById(louageId);
    await _louages.put(louageId, louage.copyWith(statut: status).toMap());
  }

  @override
  Future<void> updateAvailableSeats(String louageId, int availableSeats) async {
    final louage = _louageById(louageId);
    if (availableSeats < 0 || availableSeats > louage.placesTotal) {
      throw RangeError.range(
        availableSeats,
        0,
        louage.placesTotal,
        'availableSeats',
      );
    }
    await _louages.put(
      louageId,
      louage.copyWith(placesDisponibles: availableSeats).toMap(),
    );
  }

  @override
  Future<void> updateCurrentStation(String louageId, String stationId) async {
    final louage = _louageById(louageId);
    if (stationId.trim().isEmpty) {
      throw const DriverTripException(DriverTripFailure.stationRequired);
    }
    await _louages.put(
      louageId,
      louage.copyWith(stationActuelle: stationId.trim()).toMap(),
    );
  }

  @override
  Future<Trip> createTrip({
    required String driverId,
    required String fromStationId,
    required String toStationId,
    required DateTime departureTime,
  }) async {
    final louage = _louageFor(driverId);
    if (louage == null) {
      throw const DriverTripException(DriverTripFailure.louageMissing);
    }
    if (louage.statut == LouageStatus.horsService) {
      throw const DriverTripException(DriverTripFailure.louageOutOfService);
    }
    if (fromStationId.trim().isEmpty || toStationId.trim().isEmpty) {
      throw const DriverTripException(DriverTripFailure.stationRequired);
    }
    if (fromStationId == toStationId) {
      throw const DriverTripException(DriverTripFailure.sameStation);
    }
    final now = DateTime.now();
    if (departureTime.isBefore(now)) {
      throw const DriverTripException(DriverTripFailure.departureInPast);
    }

    final route = await _ensureRoute(fromStationId: fromStationId, toStationId: toStationId);
    final duplicate = _trips.values
        .map(Trip.fromMap)
        .any((trip) {
          if (trip.louageId != louage.id || trip.status != 'waiting') return false;
          final tripTime = DateTime.tryParse(trip.departureTime);
          return tripTime != null && tripTime.isAtSameMomentAs(departureTime);
        });
    if (duplicate) {
      throw const DriverTripException(DriverTripFailure.duplicateDeparture);
    }

    final updatedLouage = louage.copyWith(stationActuelle: fromStationId.trim());
    await _louages.put(updatedLouage.id, updatedLouage.toMap());

    final trip = Trip(
      id: _uuid.v4(),
      louageId: updatedLouage.id,
      routeId: route.id,
      totalSeats: updatedLouage.placesTotal,
      reservedSeats: 0,
      status: 'waiting',
      departureTime: departureTime.toIso8601String(),
      arrivalTime: departureTime
          .add(Duration(minutes: route.durationMin))
          .toIso8601String(),
    );
    await _trips.put(trip.id, trip.toMap());
    return trip;
  }

  @override
  Future<void> cancelTrip(String tripId) async {
    final map = _trips.get(tripId);
    if (map == null) {
      throw const DriverTripException(DriverTripFailure.tripMissing);
    }
    final trip = Trip.fromMap(map);
    if (trip.status != 'waiting') {
      throw const DriverTripException(DriverTripFailure.tripNotWaiting);
    }
    await _trips.put(tripId, trip.copyWith(status: 'cancelled').toMap());
  }

  @override
  Stream<List<Trip>> watchTrips(String driverId) =>
      Stream<List<Trip>>.multi((controller) {
        void reload() {
          try {
            final louageIds = _louages.values
                .map(Louage.fromMap)
                .where((louage) => louage.chauffeurId == driverId)
                .map((louage) => louage.id)
                .toSet();
            final trips = _trips.values
                .map(Trip.fromMap)
                .where((trip) => louageIds.contains(trip.louageId))
                .toList()
              ..sort((a, b) => a.departureTime.compareTo(b.departureTime));
            controller.add(trips);
          } catch (error, stackTrace) {
            controller.addError(error, stackTrace);
          }
        }

        final subscriptions = [
          _louages.watch().listen((_) => reload()),
          _trips.watch().listen((_) => reload()),
        ];
        controller.onCancel = () async {
          await Future.wait(subscriptions.map((item) => item.cancel()));
        };
        reload();
      });

  @override
  Stream<List<DriverBooking>> watchBookings(String tripId) =>
      Stream<List<DriverBooking>>.multi((controller) {
        void reload() {
          try {
            final bookings = _bookings.values
                .map(Booking.fromMap)
                .where((booking) => booking.tripId == tripId)
                .map(
                  (booking) => DriverBooking(
                    booking: booking,
                    passenger: _passengerFor(booking.userId),
                  ),
                )
                .toList()
              ..sort(
                (a, b) => a.booking.createdAt.compareTo(b.booking.createdAt),
              );
            controller.add(bookings);
          } catch (error, stackTrace) {
            controller.addError(error, stackTrace);
          }
        }

        final subscriptions = [
          _bookings.watch().listen((_) => reload()),
          _users.watch().listen((_) => reload()),
        ];
        controller.onCancel = () async {
          await Future.wait(subscriptions.map((item) => item.cancel()));
        };
        reload();
      });

  @override
  Future<TicketValidationResult> validateTicket({
    required String driverId,
    required String tripId,
    required String qrPayload,
  }) async {
    final bookingId = _bookingIdFromQr(qrPayload);
    if (bookingId.isEmpty) {
      return const TicketValidationResult(TicketValidationStatus.invalid);
    }
    final bookingMap = _bookings.get(bookingId);
    if (bookingMap == null) {
      return const TicketValidationResult(TicketValidationStatus.invalid);
    }
    final booking = Booking.fromMap(bookingMap);
    if (booking.qrCode != qrPayload.trim() && booking.qrCode != booking.id) {
      return const TicketValidationResult(TicketValidationStatus.invalid);
    }
    final bookingStatus = booking.status.toLowerCase();
    if (booking.tripId != tripId ||
        const {'cancelled', 'canceled', 'annulled', 'rejected'}
                .contains(bookingStatus) ||
        !const {
          'confirmed',
          'validated',
          'used',
          'completed',
          'checkedin',
        }.contains(bookingStatus)) {
      return const TicketValidationResult(TicketValidationStatus.invalid);
    }
    final tripMap = _trips.get(tripId);
    if (tripMap == null) {
      return const TicketValidationResult(TicketValidationStatus.invalid);
    }
    final trip = Trip.fromMap(tripMap);
    final louageMap = _louages.get(trip.louageId);
    if (louageMap == null ||
        Louage.fromMap(louageMap).chauffeurId != driverId) {
      return const TicketValidationResult(TicketValidationStatus.invalid);
    }
    if (const {'validated', 'used', 'completed', 'checkedin'}
        .contains(bookingStatus)) {
      return TicketValidationResult(
        TicketValidationStatus.alreadyUsed,
        bookingId: booking.id,
      );
    }
    await _bookings.put(
      booking.id,
      booking.copyWith(status: 'validated').toMap(),
    );
    return TicketValidationResult(
      TicketValidationStatus.valid,
      bookingId: booking.id,
    );
  }

  @override
  Stream<List<Booking>> watchDriverBookings(String driverId) =>
      Stream<List<Booking>>.multi((controller) {
        void reload() {
          try {
            final tripIds = _trips.values
                .map(Trip.fromMap)
                .where((trip) {
                  final louage = _louages.get(trip.louageId);
                  return louage != null &&
                      Louage.fromMap(louage).chauffeurId == driverId;
                })
                .map((trip) => trip.id)
                .toSet();
            controller.add(
              _bookings.values
                  .map(Booking.fromMap)
                  .where((booking) => tripIds.contains(booking.tripId))
                  .toList(),
            );
          } catch (error, stackTrace) {
            controller.addError(error, stackTrace);
          }
        }

        final subscriptions = [
          _trips.watch().listen((_) => reload()),
          _louages.watch().listen((_) => reload()),
          _bookings.watch().listen((_) => reload()),
        ];
        controller.onCancel = () async {
          await Future.wait(subscriptions.map((item) => item.cancel()));
        };
        reload();
      });

  @override
  Future<(double, int)> ratingAndCompletedTrips(String driverId) async {
    final louageIds = _louages.values
        .map(Louage.fromMap)
        .where((louage) => louage.chauffeurId == driverId)
        .map((louage) => louage.id)
        .toSet();
    final trips = _trips.values
        .map(Trip.fromMap)
        .where(
          (trip) =>
              louageIds.contains(trip.louageId) && trip.status == 'arrived',
        )
        .toList();
    final reviews = _reviews.values
        .map(Review.fromMap)
        .where((review) => review.driverId == driverId && review.rating > 0)
        .toList();
    final average = reviews.isEmpty
        ? 0.0
        : reviews.fold<double>(0, (sum, review) => sum + review.rating) /
              reviews.length;
    return (average, trips.length);
  }

  Future<RouteLine> _ensureRoute({
    required String fromStationId,
    required String toStationId,
  }) async {
    for (final map in _routes.values) {
      final route = RouteLine.fromMap(map);
      if (route.fromStationId == fromStationId &&
          route.toStationId == toStationId) {
        return route;
      }
    }

    final fromMap = _stations.get(fromStationId);
    final toMap = _stations.get(toStationId);
    final fromStation = fromMap == null ? null : Station.fromMap(fromMap);
    final toStation = toMap == null ? null : Station.fromMap(toMap);

    final distanceKm = fromStation != null && toStation != null
        ? _haversineKm(fromStation.lat, fromStation.lng, toStation.lat, toStation.lng)
        : 42.0;
    final durationMin = ((distanceKm / 55) * 60).round().clamp(20, 240);
    final pricePerSeat = (distanceKm * 0.7 + 9.0).roundToDouble();

    final route = RouteLine(
      id: _uuid.v4(),
      fromStationId: fromStationId,
      toStationId: toStationId,
      pricePerSeat: pricePerSeat,
      distanceKm: distanceKm,
      durationMin: durationMin,
    );
    await _routes.put(route.id, route.toMap());
    return route;
  }

  double _haversineKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = (lat2 - lat1) * (math.pi / 180);
    final dLon = (lon2 - lon1) * (math.pi / 180);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180)) *
            math.cos(lat2 * (math.pi / 180)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  Louage? _louageFor(String driverId) {
    for (final value in _louages.values) {
      final louage = Louage.fromMap(value);
      if (louage.chauffeurId == driverId) return louage;
    }
    return null;
  }

  Louage _louageById(String id) {
    final map = _louages.get(id);
    if (map == null) throw StateError('Louage introuvable.');
    return Louage.fromMap(map);
  }

  AppUser? _passengerFor(String userId) {
    final map = _users.get(userId);
    return map == null ? null : AppUser.fromMap(map);
  }

  String _bookingIdFromQr(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null) return '';
    if (uri.scheme == 'louagego' && uri.host == 'ticket') {
      return uri.pathSegments.isEmpty ? '' : uri.pathSegments.first;
    }
    return value.trim();
  }
}
