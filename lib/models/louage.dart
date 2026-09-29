import 'package:cloud_firestore/cloud_firestore.dart';

class Louage {
  final String id;
  final String from;
  final String to;
  final String plate;
  final String time;
  final int price; // in DT
  final int freeSeats;
  final int totalSeats;

  const Louage({
    required this.id,
    required this.from,
    required this.to,
    required this.plate,
    required this.time,
    required this.price,
    required this.freeSeats,
    required this.totalSeats,
  });

  factory Louage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Louage(
      id: doc.id,
      from: d['from'] ?? '',
      to: d['to'] ?? '',
      plate: d['plate'] ?? '',
      time: d['time'] ?? '',
      price: (d['price'] as num? ?? 0).toInt(),
      freeSeats: (d['freeSeats'] as num? ?? 0).toInt(),
      totalSeats: (d['totalSeats'] as num? ?? 8).toInt(),
    );
  }
}