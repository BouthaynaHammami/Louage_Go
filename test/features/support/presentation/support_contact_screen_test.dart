import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:louage_go/features/auth/auth_providers.dart';
import 'package:louage_go/features/support/presentation/screens/support_contact_screen.dart';
import 'package:louage_go/l10n/generated/app_localizations.dart';
import 'package:louage_go/models/app_user.dart';

void main() {
  testWidgets('contact form rejects a missing category and short message', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWith(
            (ref) => Stream.value(const AppUser(id: 'user')),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SupportContactScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send request'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a category.'), findsOneWidget);
    expect(find.text('The message must contain 10 to 1000 characters.'), findsOneWidget);
  });
}
