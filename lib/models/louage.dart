import 'model_map.dart';

class Louage {
  final String id;
  final String driverId;
  final String matricule;
  final int capacity;
  final String currentStationId;
  final String status;

  const Louage({
    this.id = '',
    this.driverId = '',
    this.matricule = '',
    this.capacity = 8,
    this.currentStationId = '',
    this.status = 'active',
  });

  Louage copyWith({
    String? id,
    String? driverId,
    String? matricule,
    int? capacity,
    String? currentStationId,
    String? status,
  }) =>
      Louage(
        id: id ?? this.id,
        driverId: driverId ?? this.driverId,
        matricule: matricule ?? this.matricule,
        capacity: capacity ?? this.capacity,
        currentStationId: currentStationId ?? this.currentStationId,
        status: status ?? this.status,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'driverId': driverId,
        'matricule': matricule,
        'capacity': capacity,
        'currentStationId': currentStationId,
        'status': status,
      };

  factory Louage.fromMap(Map<dynamic, dynamic> map) => Louage(
        id: ModelMap.text(map, 'id'),
        driverId: ModelMap.text(map, 'driverId'),
        matricule: ModelMap.text(map, 'matricule'),
        capacity: ModelMap.integer(map, 'capacity', 8),
        currentStationId: ModelMap.text(map, 'currentStationId'),
        status: ModelMap.text(map, 'status', 'active'),
      );
}