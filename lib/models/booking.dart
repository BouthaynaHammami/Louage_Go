import 'model_map.dart';

class Booking {
  final String id;
  final String userId;
  final String tripId;
  final int seats;
  final double totalPrice;
  final String status;
  final String createdAt;
  final List<int> numerosPlaces;
  final String paymentMethod;
  final String paymentStatus;
  final String qrCode;
  final String departureTime;
  final String cancelledAt;
  final String driverName;
  final String matricule;
  final String fromCity;
  final String toCity;

  const Booking({
    this.id = '',
    this.userId = '',
    this.tripId = '',
    this.seats = 1,
    this.totalPrice = 0,
    this.status = 'pending',
    this.createdAt = '',
    List<int>? numerosPlaces,
    List<int>? selectedSeats,
    this.paymentMethod = '',
    this.paymentStatus = 'pending',
    this.qrCode = '',
    this.departureTime = '',
    this.cancelledAt = '',
    this.driverName = '',
    this.matricule = '',
    this.fromCity = '',
    this.toCity = '',
  }) : numerosPlaces = numerosPlaces ?? selectedSeats ?? const [];

  List<int> get selectedSeats => numerosPlaces;

  Booking copyWith({
    String? id,
    String? userId,
    String? tripId,
    int? seats,
    double? totalPrice,
    String? status,
    String? createdAt,
    List<int>? numerosPlaces,
    List<int>? selectedSeats,
    String? paymentMethod,
    String? paymentStatus,
    String? qrCode,
    String? departureTime,
    String? cancelledAt,
    String? driverName,
    String? matricule,
    String? fromCity,
    String? toCity,
  }) =>
      Booking(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        tripId: tripId ?? this.tripId,
        seats: seats ?? this.seats,
        totalPrice: totalPrice ?? this.totalPrice,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        numerosPlaces: numerosPlaces ?? selectedSeats ?? this.numerosPlaces,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        qrCode: qrCode ?? this.qrCode,
        departureTime: departureTime ?? this.departureTime,
        cancelledAt: cancelledAt ?? this.cancelledAt,
        driverName: driverName ?? this.driverName,
        matricule: matricule ?? this.matricule,
        fromCity: fromCity ?? this.fromCity,
        toCity: toCity ?? this.toCity,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'tripId': tripId,
        'seats': seats,
        'totalPrice': totalPrice,
        'status': status,
        'createdAt': createdAt,
        'numerosPlaces': numerosPlaces,
        'selectedSeats': numerosPlaces,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
        'qrCode': qrCode,
        'departureTime': departureTime,
        'cancelledAt': cancelledAt,
        'driverName': driverName,
        'matricule': matricule,
        'fromCity': fromCity,
        'toCity': toCity,
      };

  factory Booking.fromMap(Map<dynamic, dynamic> map) => Booking(
        id: ModelMap.text(map, 'id'),
        userId: ModelMap.text(map, 'userId'),
        tripId: ModelMap.text(map, 'tripId'),
        seats: ModelMap.integer(map, 'seats', 1),
        totalPrice: ModelMap.decimal(map, 'totalPrice'),
        status: ModelMap.text(map, 'status', 'pending'),
        createdAt: ModelMap.date(map, 'createdAt'),
        numerosPlaces: _readSeatNumbers(map),
        paymentMethod: ModelMap.text(map, 'paymentMethod'),
        paymentStatus: ModelMap.text(map, 'paymentStatus', 'pending'),
        qrCode: ModelMap.text(map, 'qrCode'),
        departureTime: ModelMap.text(map, 'departureTime'),
        cancelledAt: ModelMap.text(map, 'cancelledAt'),
        driverName: ModelMap.text(map, 'driverName'),
        matricule: ModelMap.text(map, 'matricule'),
        fromCity: ModelMap.text(map, 'fromCity'),
        toCity: ModelMap.text(map, 'toCity'),
      );

  static List<int> _readSeatNumbers(Map<dynamic, dynamic> map) {
    final value = map['numerosPlaces'] ?? map['selectedSeats'];
    if (value is! Iterable) return const [];
    return value.whereType<num>().map((number) => number.toInt()).toList();
  }
}