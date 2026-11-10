import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:louage_go/features/auth/auth_providers.dart';
import 'package:louage_go/features/driver/domain/entities/driver_dashboard_data.dart';
import 'package:louage_go/features/driver/presentation/providers/driver_home_provider.dart';
import 'package:louage_go/features/driver/presentation/providers/louage_provider.dart';
import 'package:louage_go/features/driver/presentation/screens/driver_earnings_screen.dart';
import 'package:louage_go/l10n/generated/app_localizations.dart';
import 'package:louage_go/models/app_user.dart';
import 'package:louage_go/models/booking.dart';
import 'package:louage_go/models/driver_earning.dart';
import 'package:louage_go/models/driver_profile.dart';
import 'package:louage_go/models/louage.dart';

void main() {
  testWidgets('earnings screen shows a clear empty state', (tester) async {
    await _pumpScreen(tester, const []);
    expect(find.text('0.00 DT'), findsWidgets);
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Aucun revenu enregistré. Scannez un billet valide pour commencer.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('earnings screen shows scanned fare details', (tester) async {
    await _pumpScreen(tester, [
      DriverEarning(
        id: 'booking-1',
        driverId: 'driver-1',
        bookingId: 'booking-1',
        tripId: 'trip-1',
        amount: 42.5,
        earnedAt: DateTime.now().toIso8601String(),
        passengerName: 'Amira',
        fromCity: 'Tunis',
        toCity: 'Sousse',
      ),
    ]);

    expect(find.text('42.50 DT'), findsWidgets);
    expect(find.text('1'), findsOneWidget);
    await tester.ensureVisible(find.text('30 jours'));
    await tester.tap(find.text('30 jours'));
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(find.text('Amira'), findsOneWidget);
    expect(find.text('Tunis → Sousse'), findsOneWidget);
    expect(find.text('30 jours'), findsOneWidget);
  });
}

Future<void> _pumpScreen(
  WidgetTester tester,
  List<DriverEarning> earnings,
) async {
  const driver = AppUser(id: 'driver-1', role: 'driver');
  final dashboard = DriverDashboardData(
    profile: const DriverProfile(
      userId: 'driver-1',
      validationStatus: 'approved',
    ),
    louage: const Louage(id: 'louage-1', driverId: 'driver-1'),
    station: null,
    trips: const [],
    bookings: const [],
    passengers: const {},
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(driver)),
        driverEarningsProvider.overrideWith(
          (ref, driverId) => Stream.value(earnings),
        ),
        driverBookingsProvider.overrideWith(
          (ref, driverId) => Stream.value(const <Booking>[]),
        ),
        driverDashboardProvider.overrideWith(
          (ref, driverId) => Stream.value(dashboard),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const DriverEarningsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
