import 'package:geolocator/geolocator.dart';

import '../../../models/station.dart';

class NearestStation {
  const NearestStation({required this.station, required this.distanceMeters});

  final Station station;
  final double distanceMeters;
}

List<NearestStation> nearestStations(
  Position position,
  List<Station> stations, {
  int limit = 3,
}) {
  if (limit <= 0) return const [];
  final nearest = <NearestStation>[
    for (final station in stations)
      if (!(station.lat == 0 && station.lng == 0))
        NearestStation(
          station: station,
          distanceMeters: Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            station.lat,
            station.lng,
          ),
        ),
  ]..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
  return nearest.take(limit).toList(growable: false);
}
