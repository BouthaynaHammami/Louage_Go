import 'model_map.dart';

class Favorite {
  final String id;
  final String userId;
  final String routeId;
  final String createdAt;

  const Favorite({
    this.id = '',
    this.userId = '',
    this.routeId = '',
    this.createdAt = '',
  });

  Favorite copyWith({
    String? id,
    String? userId,
    String? routeId,
    String? createdAt,
  }) =>
      Favorite(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        routeId: routeId ?? this.routeId,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'routeId': routeId,
        'createdAt': createdAt,
      };

  factory Favorite.fromMap(Map<dynamic, dynamic> map) => Favorite(
        id: ModelMap.text(map, 'id'),
        userId: ModelMap.text(map, 'userId'),
        routeId: ModelMap.text(map, 'routeId'),
        createdAt: ModelMap.date(map, 'createdAt'),
      );
}