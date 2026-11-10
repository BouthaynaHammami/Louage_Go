import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../core/services/weather_service.dart';

final weatherServiceProvider = Provider<WeatherService>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return OpenMeteoWeatherService(client: client);
});

class TripWeatherQuery {
  const TripWeatherQuery({required this.lat, required this.lng, this.at});

  final double lat;
  final double lng;
  final DateTime? at;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripWeatherQuery &&
          other.lat == lat &&
          other.lng == lng &&
          other.at == at;

  @override
  int get hashCode => Object.hash(lat, lng, at);
}

final tripWeatherProvider = FutureProvider.autoDispose
    .family<WeatherInfo, TripWeatherQuery>(
  (ref, query) => ref.watch(weatherServiceProvider).getWeather(
    lat: query.lat,
    lng: query.lng,
    at: query.at,
  ),
  retry: (_, _) => null,
);
