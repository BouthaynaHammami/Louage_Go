import 'model_map.dart';

class Station {
  final String id;
  final String name;
  final String city;
  final String governorate;
  final double lat;
  final double lng;
  final String address;

  const Station({
    this.id = '',
    this.name = '',
    this.city = '',
    this.governorate = '',
    this.lat = 0,
    this.lng = 0,
    this.address = '',
  });

  Station copyWith({
    String? id,
    String? name,
    String? city,
    String? governorate,
    double? lat,
    double? lng,
    String? address,
  }) =>
      Station(
        id: id ?? this.id,
        name: name ?? this.name,
        city: city ?? this.city,
        governorate: governorate ?? this.governorate,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        address: address ?? this.address,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'city': city,
        'governorate': governorate,
        'lat': lat,
        'lng': lng,
        'address': address,
      };

  factory Station.fromMap(Map<dynamic, dynamic> map) => Station(
        id: ModelMap.text(map, 'id'),
        name: ModelMap.text(map, 'name'),
        city: ModelMap.text(map, 'city'),
        governorate: ModelMap.text(map, 'governorate'),
        lat: ModelMap.decimal(map, 'lat'),
        lng: ModelMap.decimal(map, 'lng'),
        address: ModelMap.text(map, 'address'),
      );
}