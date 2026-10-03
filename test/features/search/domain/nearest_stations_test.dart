import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:louage_go/features/search/domain/nearest_stations.dart';
import 'package:louage_go/models/station.dart';

void main() {
  test('empty station list returns no candidates', () {
    expect(nearestStations(_position(36, 10), const []), isEmpty);
  });

  test('results are ordered by distance and limited', () {
    final stations = [
      const Station(id: 'far', lat: 37, lng: 11),
      const Station(id: 'near', lat: 36.0001, lng: 10),
      const Station(id: 'tie-a', lat: 36, lng: 10.001),
      const Station(id: 'tie-b', lat: 36, lng: 10.001),
    ];

    final results = nearestStations(_position(36, 10), stations, limit: 3);

    expect(results, hasLength(3));
    expect(results.first.station.id, 'near');
    expect(
      results[1].distanceMeters,
      closeTo(results[2].distanceMeters, 0.001),
    );
    expect(results.map((result) => result.station.id).toSet(), {
      'near',
      'tie-a',
      'tie-b',
    });
  });

  test('stations with unknown zero-zero coordinates are ignored', () {
    final stations = [
      const Station(id: 'invalid', lat: 0, lng: 0),
      const Station(id: 'valid', lat: 35, lng: 10),
    ];

    expect(
      nearestStations(_position(36, 10), stations).single.station.id,
      'valid',
    );
    expect(
      nearestStations(_position(0, 0), stations).single.station.id,
      'valid',
    );
  });
}

Position _position(double latitude, double longitude) => Position(
  latitude: latitude,
  longitude: longitude,
  timestamp: DateTime(2026),
  accuracy: 1,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);
