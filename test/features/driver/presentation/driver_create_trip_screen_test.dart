import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';
import 'package:louage_go/core/storage/hive_service.dart';
import 'package:louage_go/core/widgets/app_button.dart';
import 'package:louage_go/features/auth/auth_providers.dart';
import 'package:louage_go/features/driver/presentation/providers/louage_provider.dart';
import 'package:louage_go/features/driver/presentation/screens/driver_create_trip_screen.dart';
import 'package:louage_go/l10n/generated/app_localizations.dart';
import 'package:louage_go/models/app_user.dart';
import 'package:louage_go/models/louage.dart';
import 'package:louage_go/models/station.dart';
import 'package:louage_go/models/trip.dart';

class FakeCreateDriverTripController extends CreateDriverTripController {
  static bool called = false;

  @override
  Future<Trip?> build() async => null;

  @override
  Future<Trip> createTrip({
    required String driverId,
    required String fromStationId,
    required String toStationId,
    required DateTime departureTime,
  }) async {
    called = true;
    final trip = Trip(
      id: 'trip-123',
      louageId: 'vehicle-1',
      routeId: 'route-1',
      status: 'waiting',
      departureTime: departureTime.toIso8601String(),
    );
    state = AsyncData(trip);
    return trip;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    final tempDir = await Directory.systemTemp.createTemp('louagego_driver_create');
    addTearDown(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });
    Hive.init(tempDir.path);
    final stationsBox = await Hive.openBox<Map>('stations');
    final routesBox = await Hive.openBox<Map>('routes');
    await HiveService.initWithBoxes({
      'stations': stationsBox,
      'routes': routesBox,
    });
    await HiveService.stations.put(
      'station-1',
      const Station(id: 'station-1', name: 'Tunis').toMap(),
    );
    await HiveService.stations.put(
      'station-2',
      const Station(id: 'station-2', name: 'Sousse').toMap(),
    );
  });

  testWidgets('driver create trip screen validates and submits', (tester) async {
    final user = const AppUser(id: 'driver-1', role: 'driver');
    const louage = Louage(
      id: 'vehicle-1',
      chauffeurId: 'driver-1',
      matricule: '123 TUN 4567',
      stationActuelle: 'station-1',
    );
    FakeCreateDriverTripController.called = false;
    final router = GoRouter(
      initialLocation: '/driver/trips/new',
      routes: [
        GoRoute(
          path: '/driver/trips',
          name: 'driverTrips',
          builder: (context, state) =>
              const Scaffold(body: Text('Trips destination')),
          routes: [
            GoRoute(
              path: 'new',
              name: 'driverCreateTrip',
              builder: (context, state) => const DriverCreateTripScreen(),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWith((ref) => Stream.value(user)),
          driverLouageProvider.overrideWith((ref, driverId) => Stream.value(louage)),
          createDriverTripControllerProvider.overrideWith(
            () => FakeCreateDriverTripController(),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );

    for (var index = 0; index < 8; index++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Station actuelle'), findsOneWidget);
    expect(find.text('Destination'), findsOneWidget);
    expect(find.byType(AppButton), findsOneWidget);

    await tester.tap(find.byType(AppButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(FakeCreateDriverTripController.called, isTrue);
    expect(find.text('Trips destination'), findsOneWidget);
  });
}
