import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../core/services/location_service.dart';
import '../../../../core/services/osrm_service.dart';
import '../../../../models/station.dart';
import 'trip_search_results_provider.dart';

final routeServiceProvider = Provider<RouteService>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return OsrmRouteService(client: client);
});

final routeToStationProvider = FutureProvider.autoDispose
    .family<RouteInfo, RouteToStationQuery>((ref, query) async {
      final locationService = ref.watch(locationServiceProvider);
      final routeService = ref.watch(routeServiceProvider);
      final location = await locationService.getCurrentLocation(
        requestConsent: query.requestConsent,
      );
      switch (location.status) {
        case LocationResultStatus.ok:
          final position = location.position;
          if (position == null) {
            throw const RouteException(RouteExceptionType.locationUnavailable);
          }
          return routeService.getRoute(
            fromLat: position.latitude,
            fromLng: position.longitude,
            toLat: query.station.lat,
            toLng: query.station.lng,
          );
        case LocationResultStatus.denied:
          throw const RouteException(RouteExceptionType.locationDenied);
        case LocationResultStatus.deniedForever:
          throw const RouteException(RouteExceptionType.locationDeniedForever);
        case LocationResultStatus.serviceDisabled:
          throw const RouteException(
            RouteExceptionType.locationServiceDisabled,
          );
        case LocationResultStatus.error:
          throw RouteException(
            RouteExceptionType.locationUnavailable,
            location.error,
          );
      }
    }, retry: (_, _) => null);

class RouteToStationQuery {
  const RouteToStationQuery({
    required this.station,
    required this.requestConsent,
  });

  final Station station;
  final Future<bool> Function() requestConsent;
}
