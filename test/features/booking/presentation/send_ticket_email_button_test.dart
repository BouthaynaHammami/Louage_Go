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

// ── Helpers ──────────────────────────────────────────────────────────────────

const _booking = Booking(
  id: 'booking-1',
  fromCity: 'Tunis',
  toCity: 'Sousse',
  totalPrice: 25,
);

Future<void> _pump(
  WidgetTester tester,
  _FakeEmailService service, {
  String email = 'passenger@example.test',
  String name = 'Amira',
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
            AppUser(id: 'passenger-1', name: name, email: email),
          ),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const Scaffold(body: SendTicketEmailButton(booking: _booking)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── (a) Valid account email → direct send, no dialog ─────────────────────
  testWidgets(
    'sends directly when account has a valid email, no dialog shown',
    (tester) async {
      final service = _FakeEmailService();
      await _pump(tester, service, email: 'passenger@example.test');

      await tester.tap(find.text('Envoyer par e-mail'));
      await tester.pumpAndSettle();

      // No dialog appeared
      expect(find.byType(AlertDialog), findsNothing);
      // Email was sent to the account address
      expect(service.lastEmail, 'passenger@example.test');
      expect(service.callCount, 1);
    },
  );

  // ── (b) Empty email → dialog opens ───────────────────────────────────────
  testWidgets('opens dialog when account email is empty', (tester) async {
    final service = _FakeEmailService();
    await _pump(tester, service, email: '');

    await tester.tap(find.text('Envoyer par e-mail'));
    await tester.pumpAndSettle();

    expect(find.text('Adresse e-mail du destinataire'), findsOneWidget);
    expect(service.callCount, 0);
  });

  // ── (c) Invalid email → dialog opens ─────────────────────────────────────
  testWidgets('opens dialog when account email is invalid', (tester) async {
    final service = _FakeEmailService();
    // An address without '@' or domain is invalid per the shared regex
    await _pump(tester, service, email: 'not-an-email');

    await tester.tap(find.text('Envoyer par e-mail'));
    await tester.pumpAndSettle();

    expect(find.text('Adresse e-mail du destinataire'), findsOneWidget);
    expect(service.callCount, 0);
  });

  // ── (d) SnackBar contains the real recipient address ─────────────────────
  testWidgets('SnackBar shows the actual recipient address after sending', (
    tester,
  ) async {
    final service = _FakeEmailService();
    await _pump(tester, service, email: 'passenger@example.test');

    await tester.tap(find.text('Envoyer par e-mail'));
    await tester.pumpAndSettle();

    expect(
      find.text('Billet envoyé à passenger@example.test.'),
      findsOneWidget,
    );
  });

  // ── (d-alt) SnackBar shows address entered through dialog ────────────────
  testWidgets(
    'SnackBar shows address entered in dialog when account email is empty',
    (tester) async {
      final service = _FakeEmailService();
      await _pump(tester, service, email: '');

      await tester.tap(find.text('Envoyer par e-mail'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'other@example.test');
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(service.lastEmail, 'other@example.test');
      expect(
        find.text('Billet envoyé à other@example.test.'),
        findsOneWidget,
      );
    },
  );

  // ── Progress indicator while sending ─────────────────────────────────────
  testWidgets('shows progress indicator while sending', (tester) async {
    final service = _FakeEmailService();
    final completer = Completer<void>();
    service.onSend = () => completer.future;
    await _pump(tester, service);

    await tester.tap(find.text('Envoyer par e-mail'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete();
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  // ── Retry on error ────────────────────────────────────────────────────────
  testWidgets('shows a localized retry action after an email error', (
    tester,
  ) async {
    final service = _FakeEmailService()
      ..onSend = () => throw const EmailException(EmailFailure.quotaExceeded);
    await _pump(tester, service);

    await tester.tap(find.text('Envoyer par e-mail'));
    await tester.pumpAndSettle();

    expect(
      find.text('La limite d\u2019envoi e-mail est atteinte. Réessayez plus tard.'),
      findsOneWidget,
    );
    expect(find.text('Réessayer'), findsOneWidget);
  });

  // ── Dialog validation ─────────────────────────────────────────────────────
  testWidgets('dialog rejects an invalid address and accepts a valid one', (
    tester,
  ) async {
    final service = _FakeEmailService();
    await _pump(tester, service, email: '');

    await tester.tap(find.text('Envoyer par e-mail'));
    await tester.pumpAndSettle();

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

  // ── Recipient hint shown when email is known ──────────────────────────────
  testWidgets(
    'shows recipient hint text under the button when email is known',
    (tester) async {
      final service = _FakeEmailService();
      await _pump(tester, service, email: 'passenger@example.test');

      expect(find.text('→ passenger@example.test'), findsOneWidget);
    },
  );

  // ── No hint when email is empty ───────────────────────────────────────────
  testWidgets('no recipient hint when account email is empty', (tester) async {
    final service = _FakeEmailService();
    await _pump(tester, service, email: '');

    expect(find.textContaining('→'), findsNothing);
  });

  // ── Brevo not configured ──────────────────────────────────────────────────
  testWidgets(
    'shows a disabled button with a hint when Brevo is not configured',
    (tester) async {
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
            home: const Scaffold(
              body: SendTicketEmailButton(booking: Booking(id: 'booking-1')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(button.onPressed, isNull);
      expect(find.text('Envoi par e-mail non configuré.'), findsOneWidget);
    },
  );
}

// ── Fake email service ────────────────────────────────────────────────────────

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
