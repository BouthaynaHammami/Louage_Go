import '../../../models/booking.dart';

abstract interface class BookingRepository {
  Stream<List<Booking>> watchForUser(String userId);

  Future<Booking> create({
    required String userId,
    required String tripId,
    required List<int> seats,
    required String paymentMethod,
  });

  Future<Booking> cancel({
    required String bookingId,
    required String userId,
  });
}
