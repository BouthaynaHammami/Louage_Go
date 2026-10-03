import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:louage_go/features/auth/auth_providers.dart';
import 'package:louage_go/features/support/presentation/screens/support_faq_screen.dart';
import 'package:louage_go/l10n/generated/app_localizations.dart';
import 'package:louage_go/models/app_user.dart';

void main() {
  testWidgets('FAQ search ignores accents and prioritizes driver category', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWith(
            (ref) => Stream.value(const AppUser(id: 'driver', role: 'driver')),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SupportFaqScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'reservation');
    await tester.pumpAndSettle();

    expect(
      find.text('Une place est-elle garantie dès que je vois un trajet?'),
      findsNothing,
    );
    expect(
      find.text('Une place est-elle garantie dès que je vois un trajet ?'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  test('driver category is prioritized without removing other filters', () {
    final categories = faqCategoryOrder(isDriver: true);
    expect(categories.first, 'drivers');
    expect(categories[1], 'all');
    expect(categories, hasLength(6));
  });
}
