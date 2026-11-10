import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:louage_go/core/services/brevo_email_service.dart';
import 'package:louage_go/models/booking.dart';

void main() {
  late Directory directory;
  late File pdf;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('brevo_email_test');
    pdf = File('${directory.path}\\ticket.pdf');
    await pdf.writeAsBytes([1, 2, 3, 4]);
  });

  tearDown(() async {
    await directory.delete(recursive: true);
  });

  test('sends localized ticket payload and base64 PDF to Brevo', () async {
    http.Request? captured;
    final service = BrevoEmailService(
      apiKey: 'test-key',
      senderEmail: 'sender@example.test',
      senderName: 'LouageGo',
      client: MockClient((request) async {
        captured = request;
        return http.Response('', 201);
      }),
    );

    await service.sendTicket(
      toEmail: 'passenger@example.test',
      toName: 'Amira',
      booking: const Booking(
        id: 'booking-123',
        fromCity: '<Tunis>',
        toCity: 'Sousse',
        departureTime: '2026-11-10T09:30:00.000',
        seats: 2,
        selectedSeats: [1, 2],
        totalPrice: 42.5,
        matricule: '123 TUN 4567',
      ),
      pdf: pdf,
      content: _content,
    );

    expect(captured?.url, Uri.https('api.brevo.com', '/v3/smtp/email'));
    expect(captured?.headers['api-key'], 'test-key');
    expect(captured?.headers['content-type'], 'application/json');
    final body = jsonDecode(captured!.body) as Map<String, dynamic>;
    expect(body['sender'], {
      'name': 'LouageGo',
      'email': 'sender@example.test',
    });
    expect(body['to'], [
      {'email': 'passenger@example.test', 'name': 'Amira'},
    ]);
    expect(body['subject'], 'Ticket confirmed');
    expect(body['htmlContent'], contains('From</th><td'));
    expect(body['htmlContent'], contains('&lt;Tunis&gt;'));
    expect(body['htmlContent'], contains('November 10 · 09:30'));
    expect(body['htmlContent'], contains('42.50 DT'));
    expect(body['attachment'], [
      {
        'name': 'billet-booking-123.pdf',
        'content': base64Encode([1, 2, 3, 4]),
      },
    ]);
  });

  for (final (statusCode, failure) in [
    (400, EmailFailure.invalidRequest),
    (401, EmailFailure.invalidApiKey),
    (429, EmailFailure.quotaExceeded),
    (503, EmailFailure.server),
  ]) {
    test('maps HTTP $statusCode to $failure', () async {
      final service = BrevoEmailService(
        apiKey: 'test-key',
        senderEmail: 'sender@example.test',
        client: MockClient((_) async => http.Response('', statusCode)),
      );

      await expectLater(
        _send(service, pdf),
        throwsA(
          isA<EmailException>().having(
            (error) => error.failure,
            'failure',
            failure,
          ),
        ),
      );
    });
  }

  test('maps an unresponsive request to timeout', () async {
    final service = BrevoEmailService(
      apiKey: 'test-key',
      senderEmail: 'sender@example.test',
      timeout: const Duration(milliseconds: 10),
      client: MockClient((_) => Completer<http.Response>().future),
    );

    await expectLater(
      _send(service, pdf),
      throwsA(
        isA<EmailException>().having(
          (error) => error.failure,
          'failure',
          EmailFailure.timeout,
        ),
      ),
    );
  });

  test('maps client exceptions to network failure', () async {
    final service = BrevoEmailService(
      apiKey: 'test-key',
      senderEmail: 'sender@example.test',
      client: MockClient((_) async => throw http.ClientException('offline')),
    );

    await expectLater(
      _send(service, pdf),
      throwsA(
        isA<EmailException>().having(
          (error) => error.failure,
          'failure',
          EmailFailure.network,
        ),
      ),
    );
  });

  test(
    'does not make a request when email configuration is incomplete',
    () async {
      var requestCount = 0;
      final service = BrevoEmailService(
        apiKey: '',
        senderEmail: '',
        client: MockClient((_) async {
          requestCount++;
          return http.Response('', 201);
        }),
      );

      await expectLater(
        _send(service, pdf),
        throwsA(
          isA<EmailException>().having(
            (error) => error.failure,
            'failure',
            EmailFailure.notConfigured,
          ),
        ),
      );
      expect(requestCount, 0);
    },
  );
}

Future<void> _send(EmailService service, File pdf) => service.sendTicket(
  toEmail: 'passenger@example.test',
  toName: 'Amira',
  booking: const Booking(id: 'booking-123'),
  pdf: pdf,
  content: _content,
);

const _content = TicketEmailContent(
  subject: 'Ticket confirmed',
  fromLabel: 'From',
  toLabel: 'To',
  departureLabel: 'Departure',
  seatsLabel: 'Seats',
  totalLabel: 'Total',
  currencyLabel: 'DT',
  plateLabel: 'Plate',
  referenceLabel: 'Reference',
  departureValue: 'November 10 · 09:30',
  totalValue: '42.50',
);
