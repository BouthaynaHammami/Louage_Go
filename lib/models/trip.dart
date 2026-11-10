import 'model_map.dart';
import 'route_line.dart';

class Trip {
  static const statuses = {
    'waiting',
    'full',
    'departed',
    'arrived',
    'cancelled',
  };

  final String id;
  final String louageId;
  final String routeId;
  final int totalSeats;
  final int reservedSeats;
  final String status;
  final String departureTime;
  final String arrivalTime;
  final double? pricePerSeat;

  const Trip({
    this.id = '',
    this.louageId = '',
    this.routeId = '',
    this.totalSeats = 8,
    this.reservedSeats = 0,
    this.status = 'waiting',
    this.departureTime = '',
    this.arrivalTime = '',
    this.pricePerSeat,
  });

  int get freeSeats =>
      totalSeats > reservedSeats ? totalSeats - reservedSeats : 0;

  double effectivePrice(RouteLine? route) =>
      pricePerSeat ?? route?.pricePerSeat ?? 0;

  Trip copyWith({
    String? id,
    String? louageId,
    String? routeId,
    int? totalSeats,
    int? reservedSeats,
    String? status,
    String? departureTime,
    String? arrivalTime,
    double? pricePerSeat,
  }) => Trip(
    id: id ?? this.id,
    louageId: louageId ?? this.louageId,
    routeId: routeId ?? this.routeId,
    totalSeats: totalSeats ?? this.totalSeats,
    reservedSeats: reservedSeats ?? this.reservedSeats,
    status: status ?? this.status,
    departureTime: departureTime ?? this.departureTime,
    arrivalTime: arrivalTime ?? this.arrivalTime,
    pricePerSeat: pricePerSeat ?? this.pricePerSeat,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'louageId': louageId,
    'routeId': routeId,
    'totalSeats': totalSeats,
    'reservedSeats': reservedSeats,
    'status': status,
    'departureTime': departureTime,
    'arrivalTime': arrivalTime,
    'pricePerSeat': pricePerSeat,
  };

  factory Trip.fromMap(Map<dynamic, dynamic> map) {
    final status = ModelMap.text(map, 'status', 'waiting');
    return Trip(
      id: ModelMap.text(map, 'id'),
      louageId: ModelMap.text(map, 'louageId'),
      routeId: ModelMap.text(map, 'routeId'),
      totalSeats: ModelMap.integer(map, 'totalSeats', 8),
      reservedSeats: ModelMap.integer(map, 'reservedSeats'),
      status: statuses.contains(status) ? status : 'waiting',
      departureTime: ModelMap.date(map, 'departureTime'),
      arrivalTime: ModelMap.date(map, 'arrivalTime'),
      pricePerSeat: map['pricePerSeat'] == null
          ? null
          : ModelMap.decimal(map, 'pricePerSeat'),
    );
  }
}
