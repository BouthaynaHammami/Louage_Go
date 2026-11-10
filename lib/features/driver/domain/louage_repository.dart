import '../../../models/booking.dart';
import '../../../models/louage.dart';
import '../../../models/trip.dart';
import 'entities/driver_booking.dart';
import 'entities/ticket_validation_result.dart';

enum DriverTripFailure {
  louageMissing,
  louageOutOfService,
  stationRequired,
  sameStation,
  departureInPast,
  duplicateDeparture,
  tripMissing,
  tripNotWaiting,
}

class DriverTripException implements Exception {
  const DriverTripException(this.failure);

  final DriverTripFailure failure;
}

abstract interface class LouageRepository {
  Stream<Louage?> watchLouage(String driverId);

  Future<Louage> saveLouage(Louage louage);

  Future<void> updateStatus(String louageId, LouageStatus status);

  Future<void> updateAvailableSeats(String louageId, int availableSeats);

  Future<void> updateCurrentStation(String louageId, String stationId);

  Future<Trip> createTrip({
    required String driverId,
    required String fromStationId,
    required String toStationId,
    required DateTime departureTime,
  });

  Future<void> cancelTrip(String tripId);

  Stream<List<Trip>> watchTrips(String driverId);

  Stream<List<DriverBooking>> watchBookings(String tripId);

  Future<TicketValidationResult> validateTicket({
    required String driverId,
    required String tripId,
    required String qrPayload,
  });

  Stream<List<Booking>> watchDriverBookings(String driverId);

  Future<(double, int)> ratingAndCompletedTrips(String driverId);
}
