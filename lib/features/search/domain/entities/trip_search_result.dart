import '../../../../models/louage.dart';
import '../../../../models/route_line.dart';
import '../../../../models/station.dart';
import '../../../../models/trip.dart';

class TripSearchResult {
  final Trip trip;
  final RouteLine route;
  final Louage louage;
  final Station fromStation;
  final Station toStation;
  final DateTime departure;

  const TripSearchResult({
    required this.trip,
    required this.route,
    required this.louage,
    required this.fromStation,
    required this.toStation,
    required this.departure,
  });

  double get price => route.pricePerSeat;
  int get freeSeats => trip.freeSeats;
  int get totalSeats => trip.totalSeats;
  bool get isFull => freeSeats == 0 || trip.status == 'full';
}
