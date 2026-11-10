import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:go_router/go_router.dart';

import 'package:louage_go/core/storage/hive_service.dart';
import 'package:louage_go/features/auth/auth_providers.dart';
import 'package:louage_go/features/driver/presentation/providers/louage_provider.dart';
import 'package:louage_go/features/driver/presentation/providers/driver_home_provider.dart';
import 'package:louage_go/features/driver/presentation/screens/driver_trips_screen.dart';
import 'package:louage_go/features/driver/domain/entities/driver_dashboard_data.dart';
import 'package:louage_go/l10n/generated/app_localizations.dart';
import 'package:louage_go/models/app_user.dart';
import 'package:louage_go/models/louage.dart';
import 'package:louage_go/models/driver_profile.dart';
import 'package:louage_go/models/route_line.dart';
import 'package:louage_go/models/station.dart';
import 'package:louage_go/models/trip.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    final tempDir = await Directory.systemTemp.createTemp(
      'louagego_driver_trips',
    );
    Hive.init(tempDir.path);
    addTearDown(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });
    final stationBox = await Hive.openBox<Map>('stations');
    final routeBox = await Hive.openBox<Map>('routes');
    await HiveService.initWithBoxes({
      'stations': stationBox,
      'routes': routeBox,
    });
    await HiveService.stations.clear();
    await HiveService.routes.clear();
    await HiveService.stations.put(
      'station-1',
      const Station(id: 'station-1', name: 'Tunis').toMap(),
    );
    await HiveService.stations.put(
      'station-2',
      const Station(id: 'station-2', name: 'Sousse').toMap(),
    );
    await HiveService.routes.put(
      'route-1',
      const RouteLine(
        id: 'route-1',
        fromStationId: 'station-1',
        toStationId: 'station-2',
        pricePerSeat: 18,
        durationMin: 120,
      ).toMap(),
    );
  });

  testWidgets('new trip action remains available with several trips', (
    tester,
  ) async {
    await _pumpTripsScreen(tester, [
      _trip('trip-1', '2026-05-10T08:30:00.000'),
      _trip('trip-2', '2026-05-11T08:30:00.000'),
      _trip('trip-3', '2026-05-12T08:30:00.000'),
    ]);

    expect(find.textContaining('Station actuelle'), findsOneWidget);
    expect(find.textContaining('Tunis'), findsWidgets);
    expect(find.text('Ajouter un trajet'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    for (var index = 0; index < 12; index++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('New trip destination'), findsOneWidget);
  });

  testWidgets('new trip action remains available with no trips', (
    tester,
  ) async {
    await _pumpTripsScreen(tester, const []);

    expect(find.text('Ajouter un trajet'), findsOneWidget);
    expect(find.text('Créer mon premier trajet'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    for (var index = 0; index < 12; index++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('New trip destination'), findsOneWidget);
  });
}

const _louage = Louage(
  id: 'vehicle-1',
  chauffeurId: 'driver-1',
  matricule: '123 TUN 4567',
  stationActuelle: 'station-1',
);

Trip _trip(String id, String departureTime) => Trip(
  id: id,
  louageId: 'vehicle-1',
  routeId: 'route-1',
  totalSeats: 8,
  reservedSeats: 2,
  status: 'waiting',
  departureTime: departureTime,
);

Future<void> _pumpTripsScreen(WidgetTester tester, List<Trip> trips) async {
  const user = AppUser(id: 'driver-1', role: 'driver');
  final router = GoRouter(
    initialLocation: '/driver/trips',
    routes: [
      GoRoute(
        path: '/driver/trips',
        name: 'driverTrips',
        builder: (context, state) => const DriverTripsScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'driverCreateTrip',
            builder: (context, state) =>
                const Scaffold(body: Text('New trip destination')),
          ),
          GoRoute(
            path: ':tripId',
            name: 'driverTripDetail',
            builder: (context, state) =>
                const Scaffold(body: Text('Trip detail destination')),
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
        driverLouageProvider.overrideWith(
          (ref, driverId) => Stream.value(_louage),
        ),
        driverDashboardProvider.overrideWith(
          (ref, driverId) => Stream.value(
            DriverDashboardData(
              profile: DriverProfile(
                userId: driverId,
                validationStatus: 'approved',
              ),
              louage: _louage,
              station: null,
              trips: trips,
              bookings: const [],
              passengers: const {},
            ),
          ),
        ),
        driverTripsProvider.overrideWith(
          (ref, driverId) => Stream.value(trips),
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
}
