import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:louage_go/core/theme/app_theme.dart';
import 'package:louage_go/features/auth/auth_providers.dart';
import 'package:louage_go/features/driver/presentation/screens/driver_profile_screen.dart';
import 'package:louage_go/features/profile/presentation/widgets/profile_widgets.dart';
import 'package:louage_go/features/users/presentation/screens/passenger_profile_screen.dart';
import 'package:louage_go/l10n/generated/app_localizations.dart';
import 'package:louage_go/models/app_user.dart';

void main() {
  testWidgets(
    'passenger and driver profiles share the same layout and actions',
    (tester) async {
      const driver = AppUser(
        id: 'driver-1',
        name: 'Sami Ben Salem',
        phone: '+21620000001',
        email: 'sami@example.com',
        role: 'driver',
        city: 'Tunis',
      );
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final passenger = driver.copyWith(role: 'passenger');
      final passengerRows = await _renderProfile(
        tester,
        const PassengerProfileScreen(),
        passenger,
      );
      expect(find.text(l10n.profileTitle), findsOneWidget);
      expect(find.text(driver.name), findsOneWidget);
      expect(find.textContaining(driver.phone), findsOneWidget);
      expect(find.text(driver.email), findsOneWidget);
      expect(find.textContaining(driver.city), findsOneWidget);

      final driverRows = await _renderProfile(
        tester,
        const DriverProfileScreen(),
        driver,
      );

      expect(find.text(l10n.profileTitle), findsOneWidget);
      expect(find.text(driver.name), findsOneWidget);
      expect(find.textContaining(driver.phone), findsOneWidget);
      expect(find.text(driver.email), findsOneWidget);
      expect(find.textContaining(driver.city), findsOneWidget);
      expect(driverRows, passengerRows + 1);
      expect(find.byType(ProfileOptionRow), findsNWidgets(7));
      expect(find.text(l10n.profileDriverReviews), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byType(DeleteAccountButton),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.byType(DeleteAccountButton), findsOneWidget);
      expect(find.byType(SignOutButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

Future<int> _renderProfile(
  WidgetTester tester,
  Widget screen,
  AppUser user,
) async {
  await tester.pumpWidget(
    ProviderScope(
      key: ValueKey(user.role),
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(user)),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light,
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return find.byType(ProfileOptionRow).evaluate().length;
}
