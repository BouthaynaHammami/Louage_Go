import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:louage_go/core/services/location_service.dart';
import 'package:louage_go/features/search/presentation/providers/trip_search_results_provider.dart';
import 'package:louage_go/features/search/presentation/widgets/nearest_station_card.dart';
import 'package:louage_go/l10n/generated/app_localizations.dart';
import 'package:louage_go/models/station.dart';

void main() {
  const station = Station(
    id: 'tunis',
    name: 'Station Tunis',
    city: 'Tunis',
    lat: 36.8,
    lng: 10.18,
  );

  testWidgets(
    'nearest station is displayed with distance after location is found',
    (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('fr'));
      await tester.pumpWidget(
        _testApp(LocationResult.ok(_testPosition), const [station]),
      );

      await tester.tap(find.text(l10n.locationUseMyPosition));
      await tester.pumpAndSettle();

      expect(find.text('Station Tunis'), findsOneWidget);
      expect(find.text('0 m'), findsOneWidget);
      expect(find.text(l10n.stationsSearchFrom), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('fake location service results map to localized UI messages', (
    tester,
  ) async {
    final cases = [
      (
        result: const LocationResult.denied(),
        message: (AppLocalizations l10n) => l10n.locationDenied,
      ),
      (
        result: const LocationResult.deniedForever(),
        message: (AppLocalizations l10n) => l10n.locationDeniedForever,
      ),
      (
        result: const LocationResult.serviceDisabled(),
        message: (AppLocalizations l10n) => l10n.locationServiceDisabled,
      ),
      (
        result: const LocationResult.error('platform error'),
        message: (AppLocalizations l10n) => l10n.locationError,
      ),
    ];
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    for (final testCase in cases) {
      await tester.pumpWidget(
        _testApp(testCase.result, const [station], locale: const Locale('en')),
      );
      await tester.tap(find.text(l10n.locationUseMyPosition));
      await tester.pumpAndSettle();
      expect(find.text(testCase.message(l10n)), findsOneWidget);
    }
  });
}

final _testPosition = Position(
  latitude: 36.8,
  longitude: 10.18,
  timestamp: DateTime(2026),
  accuracy: 1,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

Widget _testApp(
  LocationResult result,
  List<Station> stations, {
  Locale locale = const Locale('fr'),
}) {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) =>
            Scaffold(body: NearestStationCard(stations: stations)),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      locationServiceProvider.overrideWithValue(_FakeLocationService(result)),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

class _FakeLocationService implements LocationService {
  _FakeLocationService(this.result);

  final LocationResult result;

  @override
  Future<LocationResult> getCurrentLocation({
    required Future<bool> Function() requestConsent,
  }) async => result;

  @override
  Future<bool> openAppSettings() async => true;
}
