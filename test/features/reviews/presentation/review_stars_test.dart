import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:louage_go/features/reviews/presentation/screens/rate_trip_screen.dart';
import 'package:louage_go/features/reviews/presentation/widgets/review_stars.dart';
import 'package:louage_go/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('rating stars remain LTR and accessible in Arabic at 320 dp', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: RateTripSheet(
                  userId: 'passenger',
                  tripId: 'trip-1',
                  driverId: 'driver-1',
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      Directionality.of(
        tester.element(
          find.descendant(
            of: find.byType(ReviewStars),
            matching: find.byType(Row),
          ),
        ),
      ),
      TextDirection.ltr,
    );
    expect(find.byTooltip('1 من 5 نجوم'), findsOneWidget);
    expect(find.byTooltip('5 من 5 نجوم'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('3 من 5 نجوم'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
