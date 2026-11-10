import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:louage_go/core/services/location_service.dart';
import 'package:louage_go/core/services/osrm_service.dart';
import 'package:louage_go/core/widgets/skeleton_box.dart';
import 'package:louage_go/features/search/presentation/providers/route_to_station_provider.dart';
import 'package:louage_go/features/search/presentation/providers/trip_search_results_provider.dart';
import 'package:louage_go/features/search/presentation/widgets/route_to_station_card.dart';
import 'package:louage_go/l10n/generated/app_localizations.dart';
import 'package:louage_go/models/station.dart';

const station = Station(
  id: 'tunis',
  name: 'Station Tunis',
  city: 'Tunis',
  lat: 36.8,
  lng: 10.18,
);
const routeInfo = RouteInfo(distanceMeters: 4213, durationSeconds: 720);

void main() {
  testWidgets('shows a skeleton while the route is loading', (tester) async {
    final pendingRoute = Completer<RouteInfo>();
    final l10n = await AppLocalizations.delegate.load(const Locale('fr'));
    await tester.pumpWidget(
      _testApp(_FakeRouteService(() => pendingRoute.future)),
    );

    expect(find.byType(SkeletonBox), findsNWidgets(2));
    pendingRoute.complete(routeInfo);
    await tester.pump();
    await tester.pump();
    expect(find.text(l10n.routeDistanceFromStation('4,2 km')), findsOneWidget);
  });

  testWidgets('shows the localized distance and driving duration', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('fr'));
    await tester.pumpWidget(_testApp(_FakeRouteService(() async => routeInfo)));
    await tester.pump();
    await tester.pump();

    expect(find.text(l10n.routeDistanceFromStation('4,2 km')), findsOneWidget);
    expect(find.text(l10n.routeDurationByCar('12 min')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows a clear error and retry action', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(
      _testApp(
        _FakeRouteService(
          () async => throw const RouteException(RouteExceptionType.network),
        ),
        locale: const Locale('en'),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text(l10n.routeErrorNetwork), findsOneWidget);
    expect(find.text(l10n.routeRetry), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows arrived state for a route shorter than 100 meters', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(
      _testApp(
        _FakeRouteService(
          () async => const RouteInfo(distanceMeters: 85, durationSeconds: 60),
        ),
        locale: const Locale('en'),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text(l10n.routeArrivedAtStation), findsOneWidget);
  });

  testWidgets('renders localized route information right-to-left in Arabic', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    await tester.pumpWidget(
      _testApp(
        _FakeRouteService(() async => routeInfo),
        locale: const Locale('ar'),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(
      Directionality.of(tester.element(find.byType(RouteToStationCard))),
      TextDirection.rtl,
    );
    expect(find.text(l10n.routeToStationTitle), findsOneWidget);
    expect(
      find.text(l10n.routeDurationByCar(l10n.routeDurationMinutes('12'))),
      findsOneWidget,
    );
  });
}

Widget _testApp(
  RouteService routeService, {
  Locale locale = const Locale('fr'),
}) => ProviderScope(
  overrides: [
    locationServiceProvider.overrideWithValue(_FakeLocationService()),
    routeServiceProvider.overrideWithValue(routeService),
  ],
  child: MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: const Scaffold(body: RouteToStationCard(station: station)),
  ),
);

class _FakeRouteService implements RouteService {
  _FakeRouteService(this.route);

  final Future<RouteInfo> Function() route;

  @override
  Future<RouteInfo> getRoute({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) => route();
}

class _FakeLocationService implements LocationService {
  @override
  Future<LocationResult> getCurrentLocation({
    required Future<bool> Function() requestConsent,
  }) async => LocationResult.ok(
    Position(
      latitude: 36.7,
      longitude: 10.1,
      timestamp: DateTime(2026),
      accuracy: 1,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    ),
  );

  @override
  Future<bool> openAppSettings() async => true;
}
