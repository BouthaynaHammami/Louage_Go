import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:louage_go/core/services/brevo_email_service.dart';
import 'package:louage_go/features/auth/auth_providers.dart';
import 'package:louage_go/features/booking/presentation/providers/ticket_email_provider.dart';
import 'package:louage_go/features/booking/presentation/widgets/send_ticket_email_button.dart';
import 'package:louage_go/l10n/generated/app_localizations.dart';
import 'package:louage_go/models/app_user.dart';
import 'package:louage_go/models/booking.dart';

void main() {
  testWidgets('button shows progress while sending, then success message', (
    tester,
  ) async {
    final service = _FakeEmailService();
    final completer = Completer<void>();
    service.onSend = () => completer.future;
    await _pump(tester, service);

    await tester.tap(find.text('Envoyer par e-mail'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete();
    await tester.pumpAndSettle();
    expect(
      find.text('Billet envoyé à passenger@example.test.'),
      findsOneWidget,
    );
    expect(service.callCount, 1);
  });

  testWidgets('shows a localized retry action after an email error', (
    tester,
  ) async {
    final service = _FakeEmailService()
      ..onSend = () => throw const EmailException(EmailFailure.quotaExceeded);
    await _pump(tester, service);

    await tester.tap(find.text('Envoyer par e-mail'));
    await tester.pumpAndSettle();

    expect(
      find.text('La limite d’envoi e-mail est atteinte. Réessayez plus tard.'),
      findsOneWidget,
    );
    expect(find.text('Réessayer'), findsOneWidget);
  });

  testWidgets('asks for and validates an email when the account has none', (
    tester,
  ) async {
    final service = _FakeEmailService();
    await _pump(tester, service, email: '');

    await tester.tap(find.text('Envoyer par e-mail'));
    await tester.pumpAndSettle();
    expect(find.text('Adresse e-mail du destinataire'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'bad');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(find.text('Saisissez une adresse e-mail valide.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'alternate@example.test');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(service.lastEmail, 'alternate@example.test');
    expect(
      find.text('Billet envoyé à alternate@example.test.'),
      findsOneWidget,
    );
  });

  testWidgets('hides the action when Brevo is not configured', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          emailConfiguredProvider.overrideWith((ref) => false),
          currentUserProvider.overrideWith(
            (ref) => Stream.value(
              const AppUser(
                id: 'passenger-1',
                name: 'Amira',
                email: 'passenger@example.test',
              ),
            ),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: SendTicketEmailButton(booking: Booking(id: 'booking-1')),
          ),
        ),
      ),
    );

    expect(find.text('Send by email'), findsNothing);
  });
}

Future<void> _pump(
  WidgetTester tester,
  _FakeEmailService service, {
  String email = 'passenger@example.test',
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        emailConfiguredProvider.overrideWith((ref) => true),
        emailServiceProvider.overrideWithValue(service),
        ticketPdfGeneratorProvider.overrideWithValue(
          (booking) async => File('mock-ticket.pdf'),
        ),
        currentUserProvider.overrideWith(
          (ref) => Stream.value(
            AppUser(id: 'passenger-1', name: 'Amira', email: email),
          ),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const Scaffold(
          body: SendTicketEmailButton(
            booking: Booking(
              id: 'booking-1',
              fromCity: 'Tunis',
              toCity: 'Sousse',
              totalPrice: 25,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeEmailService implements EmailService {
  int callCount = 0;
  String? lastEmail;
  Future<void> Function()? onSend;

  @override
  Future<void> sendTicket({
    required String toEmail,
    required String toName,
    required Booking booking,
    required File pdf,
    required TicketEmailContent content,
  }) async {
    callCount++;
    lastEmail = toEmail;
    await onSend?.call();
  }
}
