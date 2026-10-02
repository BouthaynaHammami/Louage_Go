import 'model_map.dart';

class Booking {
  final String id;
  final String userId;
  final String tripId;
  final int seats;
  final double totalPrice;
  final String status;
  final String createdAt;

  const Booking({
    this.id = '',
    this.userId = '',
    this.tripId = '',
    this.seats = 1,
    this.totalPrice = 0,
    this.status = 'pending',
    this.createdAt = '',
  });

  Booking copyWith({
    String? id,
    String? userId,
    String? tripId,
    int? seats,
    double? totalPrice,
    String? status,
    String? createdAt,
  }) =>
      Booking(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        tripId: tripId ?? this.tripId,
        seats: seats ?? this.seats,
        totalPrice: totalPrice ?? this.totalPrice,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'tripId': tripId,
        'seats': seats,
        'totalPrice': totalPrice,
        'status': status,
        'createdAt': createdAt,
      };

  factory Booking.fromMap(Map<dynamic, dynamic> map) => Booking(
        id: ModelMap.text(map, 'id'),
        userId: ModelMap.text(map, 'userId'),
        tripId: ModelMap.text(map, 'tripId'),
        seats: ModelMap.integer(map, 'seats', 1),
        totalPrice: ModelMap.decimal(map, 'totalPrice'),
        status: ModelMap.text(map, 'status', 'pending'),
        createdAt: ModelMap.date(map, 'createdAt'),
      );
}