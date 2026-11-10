import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:louage_go/core/services/weather_service.dart';

void main() {
  group('OpenMeteoWeatherService', () {
    test('uses the matching hourly forecast', () async {
      final service = OpenMeteoWeatherService(
        client: MockClient((request) async {
          expect(request.url.host, 'api.open-meteo.com');
          expect(request.url.path, '/v1/forecast');
          expect(request.url.queryParameters['latitude'], '36.8000');
          expect(request.url.queryParameters['longitude'], '10.1800');

          return http.Response(
            '{"current":{"temperature_2m":18.0,"weather_code":3,"wind_speed_10m":18.0},"hourly":{"time":["2026-11-11T08:00","2026-11-11T09:00"],"temperature_2m":[17.0,21.0],"precipitation_probability":[30,90],"weather_code":[1,96],"wind_speed_10m":[12.0,55.0]}}',
            200,
          );
        }),
      );

      final weather = await service.getWeather(
        lat: 36.8,
        lng: 10.18,
        at: DateTime(2026, 11, 11, 9, 30),
      );

      expect(weather.temperatureC, 21);
      expect(weather.windKmh, 55);
      expect(weather.weatherCode, 96);
      expect(weather.precipitationProbability, 90);
      expect(weather.condition, WeatherCondition.storm);
      expect(weather.isHazardous, isTrue);
    });

    test('falls back to current when the requested hour is absent', () async {
      final service = OpenMeteoWeatherService(
        client: MockClient(
          (request) async => http.Response(
            '{"current":{"temperature_2m":12.5,"weather_code":45,"wind_speed_10m":22.0},"hourly":{"time":["2026-11-11T08:00"],"temperature_2m":[10.0],"precipitation_probability":[10],"weather_code":[1],"wind_speed_10m":[8.0]}}',
            200,
          ),
        ),
      );

      final weather = await service.getWeather(
        lat: 36.8,
        lng: 10.18,
        at: DateTime(2026, 11, 11, 12, 30),
      );

      expect(weather.temperatureC, 12.5);
      expect(weather.weatherCode, 45);
      expect(weather.precipitationProbability, isNull);
      expect(weather.condition, WeatherCondition.fog);
      expect(weather.isHazardous, isTrue);
    });

    test('maps HTTP failures to network exceptions', () async {
      final service = OpenMeteoWeatherService(
        client: MockClient(
          (request) async => http.Response('error', 500),
        ),
      );

      await expectLater(
        service.getWeather(lat: 1, lng: 2),
        throwsA(
          isA<WeatherException>().having(
            (error) => error.type,
            'type',
            WeatherExceptionType.network,
          ),
        ),
      );
    });

    test('maps invalid JSON to invalidResponse exceptions', () async {
      final service = OpenMeteoWeatherService(
        client: MockClient(
          (request) async => http.Response('not json', 200),
        ),
      );

      await expectLater(
        service.getWeather(lat: 1, lng: 2),
        throwsA(
          isA<WeatherException>().having(
            (error) => error.type,
            'type',
            WeatherExceptionType.invalidResponse,
          ),
        ),
      );
    });

    test('rejects a missing current snapshot', () async {
      final service = OpenMeteoWeatherService(
        client: MockClient(
          (request) async => http.Response(
            '{"current":{},"hourly":{"time":["2026-11-11T08:00"],"temperature_2m":[10.0],"precipitation_probability":[0],"weather_code":[1],"wind_speed_10m":[5.0]}}',
            200,
          ),
        ),
      );

      await expectLater(
        service.getWeather(lat: 1, lng: 2),
        throwsA(
          isA<WeatherException>().having(
            (error) => error.type,
            'type',
            WeatherExceptionType.invalidResponse,
          ),
        ),
      );
    });

    test('maps a stalled request to timeout exception', () async {
      final service = OpenMeteoWeatherService(
        client: MockClient(
          (request) async => Completer<http.Response>().future,
        ),
        timeout: const Duration(milliseconds: 50),
      );

      await expectLater(
        service.getWeather(lat: 1, lng: 2),
        throwsA(
          isA<WeatherException>().having(
            (error) => error.type,
            'type',
            WeatherExceptionType.timeout,
          ),
        ),
      );
    });

    test('classifies WMO weather codes', () {
      expect(_weather(0).condition, WeatherCondition.clear);
      expect(_weather(3).condition, WeatherCondition.cloudy);
      expect(_weather(45).condition, WeatherCondition.fog);
      expect(_weather(61).condition, WeatherCondition.rain);
      expect(_weather(75).condition, WeatherCondition.snow);
      expect(_weather(99).condition, WeatherCondition.storm);
    });

    test('marks rain hazardous only at the specified thresholds', () {
      expect(_weather(61, probability: 69).isHazardous, isFalse);
      expect(_weather(61, probability: 70).isHazardous, isTrue);
      expect(_weather(65).isHazardous, isTrue);
      expect(_weather(3, wind: 50).isHazardous, isTrue);
    });
  });
}

WeatherInfo _weather(
  int weatherCode, {
  int? probability,
  double wind = 0,
}) =>
    WeatherInfo(
      temperatureC: 20,
      windKmh: wind,
      weatherCode: weatherCode,
      precipitationProbability: probability,
    );
