import 'model_map.dart';

class Payment {
  final String id;
  final String bookingId;
  final double amount;
  final String method;
  final String status;
  final String transactionId;
  final String paidAt;

  const Payment({
    this.id = '',
    this.bookingId = '',
    this.amount = 0,
    this.method = '',
    this.status = 'pending',
    this.transactionId = '',
    this.paidAt = '',
  });

  Payment copyWith({
    String? id,
    String? bookingId,
    double? amount,
    String? method,
    String? status,
    String? transactionId,
    String? paidAt,
  }) =>
      Payment(
        id: id ?? this.id,
        bookingId: bookingId ?? this.bookingId,
        amount: amount ?? this.amount,
        method: method ?? this.method,
        status: status ?? this.status,
        transactionId: transactionId ?? this.transactionId,
        paidAt: paidAt ?? this.paidAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'bookingId': bookingId,
        'amount': amount,
        'method': method,
        'status': status,
        'transactionId': transactionId,
        'paidAt': paidAt,
      };

  factory Payment.fromMap(Map<dynamic, dynamic> map) => Payment(
        id: ModelMap.text(map, 'id'),
        bookingId: ModelMap.text(map, 'bookingId'),
        amount: ModelMap.decimal(map, 'amount'),
        method: ModelMap.text(map, 'method'),
        status: ModelMap.text(map, 'status', 'pending'),
        transactionId: ModelMap.text(map, 'transactionId'),
        paidAt: ModelMap.date(map, 'paidAt'),
      );
}