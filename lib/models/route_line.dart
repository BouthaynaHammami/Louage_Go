import 'model_map.dart';

class RouteLine {
  final String id;
  final String fromStationId;
  final String toStationId;
  final double pricePerSeat;
  final double distanceKm;
  final int durationMin;

  const RouteLine({
    this.id = '',
    this.fromStationId = '',
    this.toStationId = '',
    this.pricePerSeat = 0,
    this.distanceKm = 0,
    this.durationMin = 0,
  });

  RouteLine copyWith({
    String? id,
    String? fromStationId,
    String? toStationId,
    double? pricePerSeat,
    double? distanceKm,
    int? durationMin,
  }) =>
      RouteLine(
        id: id ?? this.id,
        fromStationId: fromStationId ?? this.fromStationId,
        toStationId: toStationId ?? this.toStationId,
        pricePerSeat: pricePerSeat ?? this.pricePerSeat,
        distanceKm: distanceKm ?? this.distanceKm,
        durationMin: durationMin ?? this.durationMin,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'fromStationId': fromStationId,
        'toStationId': toStationId,
        'pricePerSeat': pricePerSeat,
        'distanceKm': distanceKm,
        'durationMin': durationMin,
      };

  factory RouteLine.fromMap(Map<dynamic, dynamic> map) => RouteLine(
        id: ModelMap.text(map, 'id'),
        fromStationId: ModelMap.text(map, 'fromStationId'),
        toStationId: ModelMap.text(map, 'toStationId'),
        pricePerSeat: ModelMap.decimal(map, 'pricePerSeat'),
        distanceKm: ModelMap.decimal(map, 'distanceKm'),
        durationMin: ModelMap.integer(map, 'durationMin'),
      );
}