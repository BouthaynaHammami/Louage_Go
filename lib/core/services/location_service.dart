import 'package:geolocator/geolocator.dart';
import 'package:hive_ce/hive.dart';

import '../storage/hive_service.dart';

enum LocationResultStatus { ok, denied, deniedForever, serviceDisabled, error }

class LocationResult {
  const LocationResult._(this.status, {this.position, this.error});

  const LocationResult.ok(Position position)
    : this._(LocationResultStatus.ok, position: position);
  const LocationResult.denied() : this._(LocationResultStatus.denied);
  const LocationResult.deniedForever()
    : this._(LocationResultStatus.deniedForever);
  const LocationResult.serviceDisabled()
    : this._(LocationResultStatus.serviceDisabled);
  const LocationResult.error(Object error)
    : this._(LocationResultStatus.error, error: error);

  final LocationResultStatus status;
  final Position? position;
  final Object? error;
}

abstract interface class LocationService {
  Future<LocationResult> getCurrentLocation({
    required Future<bool> Function() requestConsent,
  });

  Future<bool> openAppSettings();
}

class GeolocatorLocationService implements LocationService {
  GeolocatorLocationService({Box<Map>? sessionBox})
    : _sessionBox = sessionBox ?? HiveService.session;

  static const _consentKey = 'locationConsent';
  final Box<Map> _sessionBox;

  @override
  Future<LocationResult> getCurrentLocation({
    required Future<bool> Function() requestConsent,
  }) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationResult.serviceDisabled();
      }

      final savedConsent = _sessionBox.get(_consentKey)?['accepted'];
      if (savedConsent is! bool) {
        final accepted = await requestConsent();
        await _sessionBox.put(_consentKey, {'accepted': accepted});
        if (!accepted) return const LocationResult.denied();
      } else if (!savedConsent) {
        return const LocationResult.denied();
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        return const LocationResult.denied();
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationResult.deniedForever();
      }

      return LocationResult.ok(await Geolocator.getCurrentPosition());
    } catch (error) {
      return LocationResult.error(error);
    }
  }

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();
}
