import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:louage_go/features/legal/domain/legal_document.dart';
import 'package:louage_go/features/legal/presentation/legal_document_screen.dart';
import 'package:louage_go/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('legal page renders at 320 dp in all supported locales', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final locale in AppLocalizations.supportedLocales) {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LegalDocumentScreen(
              document: LegalDocumentType.privacy,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold));
      expect(find.text(AppLocalizations.of(context)!.legalPrivacyTitle), findsOneWidget);
      expect(find.byType(SelectableText), findsWidgets);
      expect(tester.takeException(), isNull);
    }
  });
}
