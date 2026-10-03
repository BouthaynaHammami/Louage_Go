import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:louage_go/core/theme/app_theme.dart';
import 'package:louage_go/features/auth/auth_providers.dart';
import 'package:louage_go/features/driver/domain/driver_repository.dart';
import 'package:louage_go/features/driver/domain/entities/driver_dashboard_data.dart';
import 'package:louage_go/features/driver/domain/entities/driver_passenger.dart';
import 'package:louage_go/features/driver/presentation/providers/driver_home_provider.dart';
import 'package:louage_go/features/driver/presentation/screens/driver_home_screen.dart';
import 'package:louage_go/l10n/generated/app_localizations.dart';
import 'package:louage_go/models/app_user.dart';
import 'package:louage_go/models/driver_profile.dart';
import 'package:louage_go/models/louage.dart';
import 'package:louage_go/models/station.dart';
import 'package:louage_go/models/trip.dart';

void main() {
  const driver = AppUser(
    id: 'driver-1',
    name: 'Sami Driver',
    phone: '+21620000001',
    role: 'driver',
  );
  final dashboard = DriverDashboardData(
    profile: const DriverProfile(
      userId: 'driver-1',
      validationStatus: 'approved',
    ),
    louage: const Louage(
      id: 'louage-1',
      driverId: 'driver-1',
      matricule: '511 TUN 6307',
      capacity: 8,
    ),
    station: const Station(id: 'station-1', name: 'Station Beja'),
    trips: [
      Trip(
        id: 'trip-1',
        louageId: 'louage-1',
        reservedSeats: 5,
        totalSeats: 8,
        departureTime: DateTime(2026, 10, 3, 15).toIso8601String(),
      ),
    ],
    bookings: const [],
    passengers: const {
      'passenger-1': DriverPassenger(
        id: 'passenger-1',
        name: 'Passenger Only',
        phone: '+21620000002',
      ),
    },
  );

  testWidgets('home uses the connected driver data and adapts on 320dp', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _FakeDriverRepository(dashboard);
    await tester.pumpWidget(
      _driverApp(driver: driver, dashboard: dashboard, repository: repository),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bonjour Sami'), findsOneWidget);
    expect(find.text('511 TUN 6307'), findsOneWidget);
    expect(find.text('Station Beja'), findsOneWidget);
    expect(find.text('Passenger Only'), findsNothing);
    expect(find.text('5/8'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile and trip queue actions use the existing driver routes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _FakeDriverRepository(dashboard);
    final router = _driverRouter();
    await tester.pumpWidget(
      _driverApp(
        driver: driver,
        dashboard: dashboard,
        repository: repository,
        router: router,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Driver profile destination'), findsOneWidget);

    router.go('/driver/home');
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rejoindre la file'));
    await tester.pumpAndSettle();

    expect(repository.queueToggles, 1);
    expect(find.text('Driver trips destination'), findsOneWidget);
  });
}

Widget _driverApp({
  required AppUser driver,
  required DriverDashboardData dashboard,
  required _FakeDriverRepository repository,
  GoRouter? router,
}) => ProviderScope(
  overrides: [
    currentUserProvider.overrideWith((ref) => Stream.value(driver)),
    driverDashboardProvider.overrideWith((ref, id) => Stream.value(dashboard)),
    driverRepositoryProvider.overrideWithValue(repository),
  ],
  child: MaterialApp.router(
    locale: const Locale('fr'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.light,
    routerConfig: router ?? _driverRouter(),
  ),
);

GoRouter _driverRouter() => GoRouter(
  initialLocation: '/driver/home',
  routes: [
    GoRoute(
      path: '/driver/home',
      name: 'driverHome',
      builder: (context, state) => const DriverHomeScreen(),
    ),
    GoRoute(
      path: '/driver/profile',
      name: 'driverProfile',
      builder: (context, state) =>
          const Scaffold(body: Text('Driver profile destination')),
    ),
    GoRoute(
      path: '/driver/queue',
      name: 'driverQueue',
      builder: (context, state) =>
          const Scaffold(body: Text('Driver trips destination')),
    ),
    GoRoute(
      path: '/driver/documents',
      name: 'driverDocuments',
      builder: (context, state) =>
          const Scaffold(body: Text('Driver documents destination')),
    ),
  ],
);

class _FakeDriverRepository implements DriverRepository {
  _FakeDriverRepository(this.dashboard);

  final DriverDashboardData dashboard;
  int queueToggles = 0;

  @override
  Stream<DriverDashboardData> watchDashboard(String driverId) =>
      Stream.value(dashboard);

  @override
  Future<void> toggleQueue(String louageId) async {
    queueToggles++;
  }
}
