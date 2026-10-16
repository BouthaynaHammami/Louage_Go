import '../../../models/booking.dart';

abstract interface class BookingRepository {
  Stream<List<Booking>> watchForUser(String userId);

  Stream<Set<int>> watchOccupiedSeats(String tripId);

  Future<Booking> create({
    required String userId,
    required String tripId,
    required List<int> seats,
    required String paymentMethod,
    String fromCity,
    String toCity,
  });

  Future<Booking> cancel({
    required String bookingId,
    required String userId,
  });
}
