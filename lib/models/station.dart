import 'package:flutter/widgets.dart';

import 'model_map.dart';

class Station {
  final String id;
  final String name;
  final String city;
  final String governorate;
  final String nameAr;
  final String cityAr;
  final String governorateAr;
  final double lat;
  final double lng;
  final String address;

  const Station({
    this.id = '',
    this.name = '',
    this.city = '',
    this.governorate = '',
    this.nameAr = '',
    this.cityAr = '',
    this.governorateAr = '',
    this.lat = 0,
    this.lng = 0,
    this.address = '',
  });

  Station copyWith({
    String? id,
    String? name,
    String? city,
    String? governorate,
    String? nameAr,
    String? cityAr,
    String? governorateAr,
    double? lat,
    double? lng,
    String? address,
  }) => Station(
    id: id ?? this.id,
    name: name ?? this.name,
    city: city ?? this.city,
    governorate: governorate ?? this.governorate,
    nameAr: nameAr ?? this.nameAr,
    cityAr: cityAr ?? this.cityAr,
    governorateAr: governorateAr ?? this.governorateAr,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    address: address ?? this.address,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'city': city,
    'governorate': governorate,
    'nameAr': nameAr,
    'cityAr': cityAr,
    'governorateAr': governorateAr,
    'lat': lat,
    'lng': lng,
    'address': address,
  };

  factory Station.fromMap(Map<dynamic, dynamic> map) => Station(
    id: ModelMap.text(map, 'id'),
    name: ModelMap.text(map, 'name'),
    city: ModelMap.text(map, 'city'),
    governorate: ModelMap.text(map, 'governorate'),
    nameAr: ModelMap.text(map, 'nameAr'),
    cityAr: ModelMap.text(map, 'cityAr'),
    governorateAr: ModelMap.text(map, 'governorateAr'),
    lat: ModelMap.decimal(map, 'lat'),
    lng: ModelMap.decimal(map, 'lng'),
    address: ModelMap.text(map, 'address'),
  );

  String localizedName(Locale locale) =>
      locale.languageCode == 'ar' && nameAr.isNotEmpty ? nameAr : name;

  String localizedCity(Locale locale) =>
      locale.languageCode == 'ar' && cityAr.isNotEmpty ? cityAr : city;

  String localizedGovernorate(Locale locale) =>
      locale.languageCode == 'ar' && governorateAr.isNotEmpty
      ? governorateAr
      : governorate;
}
