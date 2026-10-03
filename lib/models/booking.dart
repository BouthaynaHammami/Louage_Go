import 'model_map.dart';

class Booking {
  final String id;
  final String userId;
  final String tripId;
  final int seats;
  final double totalPrice;
  final String status;
  final String createdAt;
  final List<int> selectedSeats;
  final String paymentMethod;
  final String paymentStatus;
  final String qrCode;
  final String departureTime;
  final String cancelledAt;
  final String driverName;
  final String matricule;

  const Booking({
    this.id = '',
    this.userId = '',
    this.tripId = '',
    this.seats = 1,
    this.totalPrice = 0,
    this.status = 'pending',
    this.createdAt = '',
    this.selectedSeats = const [],
    this.paymentMethod = '',
    this.paymentStatus = 'pending',
    this.qrCode = '',
    this.departureTime = '',
    this.cancelledAt = '',
    this.driverName = '',
    this.matricule = '',
  });

  Booking copyWith({
    String? id,
    String? userId,
    String? tripId,
    int? seats,
    double? totalPrice,
    String? status,
    String? createdAt,
    List<int>? selectedSeats,
    String? paymentMethod,
    String? paymentStatus,
    String? qrCode,
    String? departureTime,
    String? cancelledAt,
    String? driverName,
    String? matricule,
  }) =>
      Booking(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        tripId: tripId ?? this.tripId,
        seats: seats ?? this.seats,
        totalPrice: totalPrice ?? this.totalPrice,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        selectedSeats: selectedSeats ?? this.selectedSeats,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        qrCode: qrCode ?? this.qrCode,
        departureTime: departureTime ?? this.departureTime,
        cancelledAt: cancelledAt ?? this.cancelledAt,
        driverName: driverName ?? this.driverName,
        matricule: matricule ?? this.matricule,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'tripId': tripId,
        'seats': seats,
        'totalPrice': totalPrice,
        'status': status,
        'createdAt': createdAt,
        'selectedSeats': selectedSeats,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
        'qrCode': qrCode,
        'departureTime': departureTime,
        'cancelledAt': cancelledAt,
        'driverName': driverName,
        'matricule': matricule,
      };

  factory Booking.fromMap(Map<dynamic, dynamic> map) => Booking(
        id: ModelMap.text(map, 'id'),
        userId: ModelMap.text(map, 'userId'),
        tripId: ModelMap.text(map, 'tripId'),
        seats: ModelMap.integer(map, 'seats', 1),
        totalPrice: ModelMap.decimal(map, 'totalPrice'),
        status: ModelMap.text(map, 'status', 'pending'),
        createdAt: ModelMap.date(map, 'createdAt'),
        selectedSeats: (map['selectedSeats'] is Iterable)
            ? (map['selectedSeats'] as Iterable)
                .whereType<num>()
                .map((value) => value.toInt())
                .toList()
            : const [],
        paymentMethod: ModelMap.text(map, 'paymentMethod'),
        paymentStatus: ModelMap.text(map, 'paymentStatus', 'pending'),
        qrCode: ModelMap.text(map, 'qrCode'),
        departureTime: ModelMap.text(map, 'departureTime'),
        cancelledAt: ModelMap.text(map, 'cancelledAt'),
        driverName: ModelMap.text(map, 'driverName'),
        matricule: ModelMap.text(map, 'matricule'),
      );
}