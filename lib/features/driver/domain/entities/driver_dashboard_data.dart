import '../../../../models/booking.dart';
import '../../../../models/driver_profile.dart';
import '../../../../models/louage.dart';
import '../../../../models/station.dart';
import '../../../../models/trip.dart';
import 'driver_passenger.dart';

class DriverDashboardData {
  final DriverProfile profile;
  final Louage? louage;
  final Station? station;
  final List<Trip> trips;
  final List<Booking> bookings;
  final Map<String, DriverPassenger> passengers;

  const DriverDashboardData({
    required this.profile,
    required this.louage,
    required this.station,
    required this.trips,
    required this.bookings,
    required this.passengers,
  });
}
