import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:louage_go/core/theme/app_theme.dart';
import 'package:louage_go/core/widgets/app_logo.dart';
import 'package:louage_go/core/widgets/interactive_logo.dart';
import 'package:louage_go/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:louage_go/features/auth/presentation/screens/splash_screen.dart';
import 'package:louage_go/l10n/generated/app_localizations.dart';

Widget _localizedApp(
  Widget home, {
  Locale locale = const Locale('fr'),
  ThemeData? theme,
}) => MaterialApp(
  theme: theme ?? AppTheme.light,
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  testWidgets('splash uses the dark brand background and light wordmark', (
    tester,
  ) async {
    await tester.pumpWidget(_localizedApp(const SplashScreen()));
    await tester.pump();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppTheme.light.colorScheme.secondary);
    expect(find.byType(AppLogoMark), findsOneWidget);

    final wordmark = tester.widget<AppWordmark>(find.byType(AppWordmark));
    expect(wordmark.onDark, isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('onboarding uses the shared dark header and fits the screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_localizedApp(const OnboardingScreen()));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(InteractiveLogo), findsOneWidget);
    final wordmark = tester.widget<AppWordmark>(find.byType(AppWordmark));
    expect(wordmark.onDark, isTrue);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('onboarding fits every locale and theme on a compact screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final locale in AppLocalizations.supportedLocales) {
      for (final theme in [AppTheme.light, AppTheme.dark]) {
        await tester.pumpWidget(
          _localizedApp(const OnboardingScreen(), locale: locale, theme: theme),
        );
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.byType(InteractiveLogo), findsOneWidget);
        expect(
          tester.takeException(),
          isNull,
          reason: '${locale.languageCode} ${theme.brightness}',
        );
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'onboarding CTA and progress indicators navigate between slides',
    (tester) async {
      await tester.pumpWidget(_localizedApp(const OnboardingScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.byType(ElevatedButton));
      for (var frame = 0; frame < 7; frame++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Suivez votre départ'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('onboarding-page-0')));
      for (var frame = 0; frame < 7; frame++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Réservez votre trajet'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
