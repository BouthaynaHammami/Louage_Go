import 'package:cloud_firestore/cloud_firestore.dart';

class SeedService {
  static Future<void> seedLouages() async {
    final db = FirebaseFirestore.instance;
    final batch = db.batch();

    const routes = [
      ('Tunis', 'Sfax', 18),
      ('Sfax', 'Tunis', 18),
      ('Tunis', 'Sousse', 10),
      ('Sousse', 'Tunis', 10),
      ('Tunis', 'Nabeul', 7),
      ('Nabeul', 'Tunis', 7),
      ('Tunis', 'Bizerte', 6),
      ('Bizerte', 'Tunis', 6),
    ];
    const times = ['06:30', '07:15', '08:00', '09:45', '11:00'];

    var n = 0;
    for (final (from, to, price) in routes) {
      for (final time in times) {
        n++;
        final id = '${from}_${to}_$time';
        batch.set(db.collection('louages').doc(id), {
          'from': from,
          'to': to,
          'time': time,
          'price': price,
          'plate': '${100 + n} TUN ${1000 + n * 37}',
          'totalSeats': 8,
          'freeSeats': (n * 3) % 9, // 0 to 8, so some are full
        });
      }
    }

    await batch.commit();
  }
}