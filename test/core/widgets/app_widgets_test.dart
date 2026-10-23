import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:louage_go/core/theme/app_theme.dart';
import 'package:louage_go/core/widgets/app_button.dart';
import 'package:louage_go/core/widgets/app_card.dart';
import 'package:louage_go/core/widgets/app_logo.dart';
import 'package:louage_go/core/widgets/home_greeting_header.dart';
import 'package:louage_go/core/widgets/status_chip.dart';
import 'package:louage_go/l10n/generated/app_localizations.dart';

Widget buildLocalizedApp(Widget child) => MaterialApp(
  theme: AppTheme.light,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('status chips keep icon and text with semantic colors', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildLocalizedApp(const StatusChip(status: 'arrived')),
    );

    expect(find.text('Arrived'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    final chip = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(StatusChip),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = chip.decoration! as BoxDecoration;
    expect(
      decoration.color,
      AppTheme.light.colorScheme.tertiary.withValues(alpha: 0.12),
    );

    await tester.pumpWidget(
      buildLocalizedApp(const StatusChip(status: 'departed')),
    );
    expect(find.text('Departed'), findsOneWidget);
    expect(find.byIcon(Icons.directions_bus_outlined), findsOneWidget);

    await tester.pumpWidget(
      buildLocalizedApp(const StatusChip(status: 'cancelled')),
    );
    expect(find.text('Cancelled'), findsOneWidget);
    expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
  });

  testWidgets('app cards use a thin outline and no Material elevation', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildLocalizedApp(const AppCard(child: Text('Card'))),
    );

    final card = tester.widget<Card>(find.byType(Card));
    expect(card.elevation, 0);
    final shape = card.shape! as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(16));
    expect(shape.side.color, AppTheme.light.colorScheme.outline);
  });

  testWidgets('compact home greeting omits the oversized logo header', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildLocalizedApp(
        const HomeGreetingHeader(
          greeting: 'Bonjour Bouthayna',
          subtitle: 'Où allez-vous ?',
          profileTooltip: 'Profil',
          notificationsTooltip: 'Notifications',
          compact: true,
          onProfile: _noOp,
          onNotifications: _noOp,
        ),
      ),
    );

    expect(find.text('Bonjour Bouthayna'), findsOneWidget);
    expect(find.text('Où allez-vous ?'), findsOneWidget);
    expect(find.byType(AppLogoMark), findsNothing);
    expect(find.byType(IconButton), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('button variants use palette roles and expose focus', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildLocalizedApp(
        Column(
          children: [
            AppButton(label: 'Primary', onPressed: () {}),
            AppButton(
              label: 'Dark',
              variant: AppButtonVariant.accent,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );

    final primary = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Primary'),
    );
    expect(
      primary.style!.backgroundColor!.resolve({}),
      AppTheme.light.colorScheme.primary,
    );
    final dark = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Dark'),
    );
    expect(
      dark.style!.backgroundColor!.resolve({}),
      AppTheme.light.colorScheme.secondary,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    final focusDecorations = tester
        .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
        .map((container) => container.decoration)
        .whereType<BoxDecoration>();
    expect(
      focusDecorations.any((decoration) => decoration.boxShadow != null),
      isTrue,
    );
  });
}

void _noOp() {}
