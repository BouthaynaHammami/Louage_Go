import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:louage_go/core/app_config.dart';
import 'package:louage_go/features/auth/auth_providers.dart';
import 'package:louage_go/features/legal/presentation/legal_consent_gate.dart';
import 'package:louage_go/l10n/generated/app_localizations.dart';
import 'package:louage_go/models/app_user.dart';

void main() {
  Widget host(AppUser user) => ProviderScope(
    overrides: [
      currentUserProvider.overrideWith((ref) => Stream.value(user)),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: LegalConsentGate(
        child: const Scaffold(body: Text('main content')),
      ),
    ),
  );

  testWidgets('shows blocking consent when the accepted version is outdated', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const AppUser(id: 'user', acceptedTermsVersion: 'old-version')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Updated terms'), findsOneWidget);
    expect(find.text('main content'), findsOneWidget);
    expect(find.text('Accept and continue'), findsOneWidget);
  });

  testWidgets('does not show consent when the current version was accepted', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const AppUser(
          id: 'user',
          acceptedTermsVersion: AppConfig.legalVersion,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Updated terms'), findsNothing);
    expect(find.text('main content'), findsOneWidget);
  });
}
