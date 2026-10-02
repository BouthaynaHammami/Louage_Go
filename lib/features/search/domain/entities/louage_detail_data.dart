import '../../../../models/driver_profile.dart';
import '../../../../models/louage.dart';
import '../../../../models/route_line.dart';
import '../../../../models/station.dart';
import '../../../../models/trip.dart';

class LouageDetailData {
  final Trip trip;
  final RouteLine? route;
  final Louage? louage;
  final Station? fromStation;
  final Station? toStation;
  final String driverName;
  final DriverProfile? driverProfile;

  const LouageDetailData({
    required this.trip,
    required this.route,
    required this.louage,
    required this.fromStation,
    required this.toStation,
    required this.driverName,
    required this.driverProfile,
  });
}
