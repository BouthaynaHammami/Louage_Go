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
import 'package:louage_go/features/driver/presentation/providers/driver_home_provider.dart';
import 'package:louage_go/features/driver/presentation/screens/driver_create_trip_screen.dart';
import 'package:louage_go/l10n/generated/app_localizations.dart';
import 'package:louage_go/models/app_user.dart';
import 'package:louage_go/models/driver_profile.dart';
import 'package:louage_go/models/louage.dart';
import 'package:louage_go/models/route_line.dart';
import 'package:louage_go/models/station.dart';
import 'package:louage_go/models/trip.dart';
import 'package:louage_go/features/driver/domain/entities/driver_dashboard_data.dart';

class FakeCreateDriverTripController extends CreateDriverTripController {
  static bool called = false;
  static double? submittedPrice;

  @override
  Future<Trip?> build() async => null;

  @override
  Future<Trip> createTrip({
    required String driverId,
    required String fromStationId,
    required String toStationId,
    required DateTime departureTime,
    required double pricePerSeat,
  }) async {
    called = true;
    submittedPrice = pricePerSeat;
    final trip = Trip(
      id: 'trip-123',
      louageId: 'vehicle-1',
      routeId: 'route-1',
      status: 'waiting',
      departureTime: departureTime.toIso8601String(),
      pricePerSeat: pricePerSeat,
    );
    state = AsyncData(trip);
    return trip;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    final tempDir = await Directory.systemTemp.createTemp(
      'louagego_driver_create',
    );
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
    await HiveService.routes.put(
      'route-1',
      const RouteLine(
        id: 'route-1',
        fromStationId: 'station-1',
        toStationId: 'station-2',
        pricePerSeat: 19.5,
      ).toMap(),
    );
  });

  testWidgets('driver create trip screen validates and submits', (
    tester,
  ) async {
    final user = const AppUser(id: 'driver-1', role: 'driver');
    const louage = Louage(
      id: 'vehicle-1',
      chauffeurId: 'driver-1',
      matricule: '123 TUN 4567',
      stationActuelle: 'station-1',
    );
    FakeCreateDriverTripController.called = false;
    FakeCreateDriverTripController.submittedPrice = null;
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
          driverLouageProvider.overrideWith(
            (ref, driverId) => Stream.value(louage),
          ),
          driverDashboardProvider.overrideWith(
            (ref, driverId) => Stream.value(
              DriverDashboardData(
                profile: DriverProfile(
                  userId: driverId,
                  validationStatus: 'approved',
                ),
                louage: louage,
                station: null,
                trips: const [],
                bookings: const [],
                passengers: const {},
              ),
            ),
          ),
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
    expect(find.text('Heure de départ'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            RegExp(r'^\d{2}:\d{2}$').hasMatch(widget.data ?? ''),
      ),
      findsOneWidget,
    );
    expect(find.text('19.50'), findsOneWidget);
    expect(find.byType(AppButton), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '0');
    await tester.pump();
    expect(find.text('Le prix doit être supérieur à 0 DT.'), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    await tester.enterText(find.byType(TextField).first, '15.75');
    await tester.ensureVisible(find.byType(AppButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AppButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(FakeCreateDriverTripController.called, isTrue);
    expect(FakeCreateDriverTripController.submittedPrice, 15.75);
    expect(find.text('Trips destination'), findsOneWidget);
  });
}
