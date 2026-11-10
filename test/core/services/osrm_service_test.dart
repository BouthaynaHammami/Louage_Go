import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:louage_go/core/services/osrm_service.dart';

void main() {
  group('OsrmRouteService', () {
    test(
      'parses route and sends coordinates in longitude-latitude order',
      () async {
        late Uri requestedUri;
        final service = OsrmRouteService(
          client: MockClient((request) async {
            requestedUri = request.url;
            return http.Response(
              '{"code":"Ok","routes":[{"distance":4213,"duration":720}]}',
              200,
            );
          }),
        );

        final route = await service.getRoute(
          fromLat: 36.8,
          fromLng: 10.18,
          toLat: 36.9,
          toLng: 10.22,
        );

        expect(requestedUri.path, '/route/v1/driving/10.18,36.8;10.22,36.9');
        expect(requestedUri.queryParameters['overview'], 'false');
        expect(route.distanceMeters, 4213);
        expect(route.durationSeconds, 720);
      },
    );

    test('reports an OSRM no-route result', () async {
      final service = OsrmRouteService(
        client: MockClient(
          (_) async => http.Response('{"code":"NoRoute","routes":[]}', 200),
        ),
      );

      await expectLater(
        service.getRoute(fromLat: 0, fromLng: 0, toLat: 1, toLng: 1),
        throwsA(
          isA<RouteException>().having(
            (error) => error.type,
            'type',
            RouteExceptionType.noRoute,
          ),
        ),
      );
    });

    test('reports HTTP server failures as network errors', () async {
      final service = OsrmRouteService(
        client: MockClient((_) async => http.Response('error', 500)),
      );

      await expectLater(
        service.getRoute(fromLat: 0, fromLng: 0, toLat: 1, toLng: 1),
        throwsA(
          isA<RouteException>().having(
            (error) => error.type,
            'type',
            RouteExceptionType.network,
          ),
        ),
      );
    });

    test('reports malformed JSON as an invalid response', () async {
      final service = OsrmRouteService(
        client: MockClient((_) async => http.Response('{', 200)),
      );

      await expectLater(
        service.getRoute(fromLat: 0, fromLng: 0, toLat: 1, toLng: 1),
        throwsA(
          isA<RouteException>().having(
            (error) => error.type,
            'type',
            RouteExceptionType.invalidResponse,
          ),
        ),
      );
    });

    test('times out a stalled request', () async {
      final request = Completer<http.Response>();
      final service = OsrmRouteService(
        client: MockClient((_) => request.future),
        timeout: const Duration(milliseconds: 10),
      );

      await expectLater(
        service.getRoute(fromLat: 0, fromLng: 0, toLat: 1, toLng: 1),
        throwsA(
          isA<RouteException>().having(
            (error) => error.type,
            'type',
            RouteExceptionType.timeout,
          ),
        ),
      );
    });
  });

  group('RouteInfo formatting', () {
    test('formats distance in meters or kilometers', () {
      expect(
        const RouteInfo(
          distanceMeters: 850,
          durationSeconds: 0,
        ).formattedDistance,
        '850 m',
      );
      expect(
        const RouteInfo(
          distanceMeters: 4213,
          durationSeconds: 0,
        ).formattedDistance,
        '4.2 km',
      );
    });

    test('formats duration in minutes or hours and minutes', () {
      expect(
        const RouteInfo(
          distanceMeters: 0,
          durationSeconds: 12 * 60,
        ).formattedDuration,
        '12 min',
      );
      expect(
        const RouteInfo(
          distanceMeters: 0,
          durationSeconds: 65 * 60,
        ).formattedDuration,
        '1 h 05',
      );
    });
  });
}
