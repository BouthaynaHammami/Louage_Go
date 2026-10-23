import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:louage_go/core/theme/app_theme.dart';
import 'package:louage_go/features/booking/presentation/widgets/louage_seat_layout.dart';
import 'package:louage_go/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('shows exact louage seat positions and toggles selected seat', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final changes = <(int, bool)>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LouageSeatLayout(
            totalSeats: 8,
            occupiedSeats: const {3},
            selectedSeats: const {},
            onSeatChanged: (seat, selected) => changes.add((seat, selected)),
          ),
        ),
      ),
    );

    for (var seat = 1; seat <= 8; seat++) {
      expect(find.text('$seat'), findsOneWidget);
    }
    expect(find.text('Conducteur'), findsNWidgets(2));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('6'));
    await tester.pump();
    expect(changes, [(6, true)]);

    await tester.tap(find.text('3'));
    await tester.pump();
    expect(changes, [(6, true)]);
    expect(tester.takeException(), isNull);
  });
}
