import 'model_map.dart';

class DriverEarning {
  final String id;
  final String driverId;
  final String bookingId;
  final String tripId;
  final double amount;
  final String earnedAt;
  final String method;
  final String passengerName;
  final String fromCity;
  final String toCity;

  const DriverEarning({
    this.id = '',
    this.driverId = '',
    this.bookingId = '',
    this.tripId = '',
    this.amount = 0,
    this.earnedAt = '',
    this.method = '',
    this.passengerName = '',
    this.fromCity = '',
    this.toCity = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'driverId': driverId,
    'bookingId': bookingId,
    'tripId': tripId,
    'amount': amount,
    'earnedAt': earnedAt,
    'method': method,
    'passengerName': passengerName,
    'fromCity': fromCity,
    'toCity': toCity,
  };

  factory DriverEarning.fromMap(Map<dynamic, dynamic> map) => DriverEarning(
    id: ModelMap.text(map, 'id'),
    driverId: ModelMap.text(map, 'driverId'),
    bookingId: ModelMap.text(map, 'bookingId'),
    tripId: ModelMap.text(map, 'tripId'),
    amount: ModelMap.decimal(map, 'amount'),
    earnedAt: ModelMap.date(map, 'earnedAt'),
    method: ModelMap.text(map, 'method'),
    passengerName: ModelMap.text(map, 'passengerName'),
    fromCity: ModelMap.text(map, 'fromCity'),
    toCity: ModelMap.text(map, 'toCity'),
  );
}
