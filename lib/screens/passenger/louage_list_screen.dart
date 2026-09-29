import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../models/louage.dart';

class LouageListScreen extends StatelessWidget {
  final String from;
  final String to;
  final DateTime date;
  final TimeOfDay time;

  const LouageListScreen({
    super.key,
    required this.from,
    required this.to,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('louages')
        .where('from', isEqualTo: from)
        .where('to', isEqualTo: to);

    return Scaffold(
      appBar: AppBar(
        title: Text('$from → $to'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final louages = snapshot.data!.docs.map(Louage.fromDoc).toList()
            ..sort((a, b) => a.time.compareTo(b.time));

          if (louages.isEmpty) {
            return const Center(child: Text('Aucun louage pour ce trajet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: louages.length,
            itemBuilder: (context, index) =>
                _LouageCard(louage: louages[index]),
          );
        },
      ),
    );
  }
}

class _LouageCard extends StatelessWidget {
  final Louage louage;
  const _LouageCard({required this.louage});

  @override
  Widget build(BuildContext context) {
    final l = louage;
    final full = l.freeSeats == 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.time,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(l.plate, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  full ? 'Complet' : '${l.freeSeats} places libres',
                  style: TextStyle(
                    color: full ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${l.price} DT',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 36),
                    ),
                    onPressed: full
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Choix des places : prochaine étape'),
                              ),
                            );
                          },
                    child: const Text('Réserver'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}