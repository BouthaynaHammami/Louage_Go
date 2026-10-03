import 'model_map.dart';

class Favorite {
  final String id;
  final String userId;
  final String routeId;
  final String type;
  final String stationId;
  final String louageId;
  final String departureHm;
  final String matricule;
  final String createdAt;

  const Favorite({
    this.id = '',
    this.userId = '',
    this.routeId = '',
    this.type = 'route',
    this.stationId = '',
    this.louageId = '',
    this.departureHm = '',
    this.matricule = '',
    this.createdAt = '',
  });

  Favorite copyWith({
    String? id,
    String? userId,
    String? routeId,
    String? type,
    String? stationId,
    String? louageId,
    String? departureHm,
    String? matricule,
    String? createdAt,
  }) => Favorite(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    routeId: routeId ?? this.routeId,
    type: type ?? this.type,
    stationId: stationId ?? this.stationId,
    louageId: louageId ?? this.louageId,
    departureHm: departureHm ?? this.departureHm,
    matricule: matricule ?? this.matricule,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'routeId': routeId,
    'type': type,
    'stationId': stationId,
    'louageId': louageId,
    'departureHm': departureHm,
    'matricule': matricule,
    'createdAt': createdAt,
  };

  factory Favorite.fromMap(Map<dynamic, dynamic> map) => Favorite(
    id: ModelMap.text(map, 'id'),
    userId: ModelMap.text(map, 'userId'),
    routeId: ModelMap.text(map, 'routeId'),
    type: ModelMap.text(map, 'type').isEmpty
        ? 'route'
        : ModelMap.text(map, 'type'),
    stationId: ModelMap.text(map, 'stationId'),
    louageId: ModelMap.text(map, 'louageId'),
    departureHm: ModelMap.text(map, 'departureHm'),
    matricule: ModelMap.text(map, 'matricule'),
    createdAt: ModelMap.date(map, 'createdAt'),
  );
}
