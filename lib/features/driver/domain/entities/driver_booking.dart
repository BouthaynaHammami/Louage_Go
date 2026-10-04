import '../../../../models/app_user.dart';
import '../../../../models/booking.dart';

class DriverBooking {
  final Booking booking;
  final AppUser? passenger;

  const DriverBooking({required this.booking, required this.passenger});
}
