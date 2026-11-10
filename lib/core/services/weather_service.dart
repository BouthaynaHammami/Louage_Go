import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

enum WeatherCondition { clear, cloudy, fog, rain, storm, snow }

enum WeatherExceptionType { network, timeout, invalidResponse }

class WeatherException implements Exception {
  const WeatherException(this.type, [this.cause]);

  final WeatherExceptionType type;
  final Object? cause;

  @override
  String toString() =>
      'WeatherException($type${cause == null ? '' : ': $cause'})';
}

class WeatherInfo {
  const WeatherInfo({
    required this.temperatureC,
    required this.windKmh,
    required this.weatherCode,
    this.precipitationProbability,
  });

  final double temperatureC;
  final double windKmh;
  final int weatherCode;
  final int? precipitationProbability;

  WeatherCondition get condition {
    if (weatherCode >= 0 && weatherCode <= 1) return WeatherCondition.clear;
    if (weatherCode >= 2 && weatherCode <= 3) return WeatherCondition.cloudy;
    if (weatherCode == 45 || weatherCode == 48) return WeatherCondition.fog;
    if (weatherCode >= 95) return WeatherCondition.storm;
    if ((weatherCode >= 71 && weatherCode <= 77) ||
        weatherCode == 85 ||
        weatherCode == 86) {
      return WeatherCondition.snow;
    }
    if (weatherCode >= 51) return WeatherCondition.rain;
    return WeatherCondition.cloudy;
  }

  bool get isHazardous {
    if (condition == WeatherCondition.storm ||
        condition == WeatherCondition.snow ||
        condition == WeatherCondition.fog) {
      return true;
    }
    if (condition == WeatherCondition.rain &&
        (weatherCode >= 65 ||
            (precipitationProbability != null &&
                precipitationProbability! >= 70))) {
      return true;
    }
    return windKmh >= 50;
  }
}

abstract interface class WeatherService {
  Future<WeatherInfo> getWeather({
    required double lat,
    required double lng,
    DateTime? at,
  });
}

class OpenMeteoWeatherService implements WeatherService {
  OpenMeteoWeatherService({
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  @override
  Future<WeatherInfo> getWeather({
    required double lat,
    required double lng,
    DateTime? at,
  }) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': lat.toStringAsFixed(4),
      'longitude': lng.toStringAsFixed(4),
      'current': 'temperature_2m,weather_code,wind_speed_10m',
      'hourly':
          'temperature_2m,precipitation_probability,weather_code,wind_speed_10m',
      'forecast_days': '7',
      'timezone': 'auto',
    });

    late final http.Response response;
    try {
      response = await _client.get(uri).timeout(timeout);
    } on TimeoutException catch (error) {
      throw WeatherException(WeatherExceptionType.timeout, error);
    } on http.ClientException catch (error) {
      throw WeatherException(WeatherExceptionType.network, error);
    }

    if (response.statusCode != 200) {
      throw WeatherException(
        WeatherExceptionType.network,
        'Open-Meteo returned HTTP ${response.statusCode}',
      );
    }

    late final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException catch (error) {
      throw WeatherException(WeatherExceptionType.invalidResponse, error);
    }

    if (decoded is! Map<String, dynamic>) {
      throw const WeatherException(WeatherExceptionType.invalidResponse);
    }

    final currentMap = _readMap(decoded['current']);
    final hourlyMap = _readMap(decoded['hourly']);
    final selected = at == null ? currentMap : _hourlySnapshot(hourlyMap, at);

    if (selected == null) {
      if (currentMap.isEmpty) {
        throw const WeatherException(WeatherExceptionType.invalidResponse);
      }
      return _weatherFromMap(currentMap);
    }

    return _weatherFromMap(selected);
  }

  Map<String, dynamic>? _hourlySnapshot(
    Map<String, dynamic> hourlyMap,
    DateTime at,
  ) {
    final times = hourlyMap['time'];
    if (times is! List || times.isEmpty) return null;

    final target = _openMeteoHourString(at);
    final index = times.indexWhere((value) => value == target);
    if (index < 0) return null;

    final weatherCodes = _readList(hourlyMap['weather_code']);
    final temperatures = _readList(hourlyMap['temperature_2m']);
    final winds = _readList(hourlyMap['wind_speed_10m']);
    final probabilities = _readList(hourlyMap['precipitation_probability']);

    if (weatherCodes == null ||
        temperatures == null ||
        winds == null ||
        index >= weatherCodes.length ||
        index >= temperatures.length ||
        index >= winds.length) {
      throw const WeatherException(WeatherExceptionType.invalidResponse);
    }

    return {
      'temperature_2m': temperatures[index],
      'wind_speed_10m': winds[index],
      'weather_code': weatherCodes[index],
      if (probabilities != null && index < probabilities.length)
        'precipitation_probability': probabilities[index],
    };
  }

  WeatherInfo _weatherFromMap(Map<String, dynamic> map) {
    final temperature = _readDouble(map['temperature_2m']);
    final wind = _readDouble(map['wind_speed_10m']);
    final weatherCode = _readInt(map['weather_code']);
    final rawPrecipitation = map['precipitation_probability'];
    final precipitation =
        rawPrecipitation == null ? null : _readInt(rawPrecipitation);

    if (temperature == null ||
        wind == null ||
        weatherCode == null ||
        (rawPrecipitation != null && precipitation == null)) {
      throw const WeatherException(WeatherExceptionType.invalidResponse);
    }

    return WeatherInfo(
      temperatureC: temperature,
      windKmh: wind,
      weatherCode: weatherCode,
      precipitationProbability: precipitation,
    );
  }

  Map<String, dynamic> _readMap(Object? value) {
    if (value == null) return const <String, dynamic>{};
    if (value is! Map) {
      throw const WeatherException(WeatherExceptionType.invalidResponse);
    }
    return Map<String, dynamic>.from(value);
  }

  List<dynamic>? _readList(Object? value) {
    if (value == null) return null;
    if (value is! List) {
      throw const WeatherException(WeatherExceptionType.invalidResponse);
    }
    return value;
  }

  double? _readDouble(Object? value) {
    final parsed = switch (value) {
      num value => value.toDouble(),
      String value => num.tryParse(value)?.toDouble(),
      _ => null,
    };
    return parsed != null && parsed.isFinite ? parsed : null;
  }

  int? _readInt(Object? value) {
    final parsed = _readDouble(value);
    if (parsed == null || !parsed.isFinite) return null;
    return parsed.round();
  }

  String _openMeteoHourString(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}T'
      '${value.hour.toString().padLeft(2, '0')}:00';
}
