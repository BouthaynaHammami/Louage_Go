import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../models/booking.dart';

abstract interface class EmailService {
  Future<void> sendTicket({
    required String toEmail,
    required String toName,
    required Booking booking,
    required File pdf,
    required TicketEmailContent content,
  });
}

enum EmailFailure {
  notConfigured,
  network,
  timeout,
  invalidApiKey,
  invalidRequest,
  quotaExceeded,
  server,
}

class EmailException implements Exception {
  const EmailException(this.failure);

  final EmailFailure failure;
}

class TicketEmailContent {
  const TicketEmailContent({
    required this.subject,
    required this.fromLabel,
    required this.toLabel,
    required this.departureLabel,
    required this.seatsLabel,
    required this.totalLabel,
    required this.currencyLabel,
    required this.plateLabel,
    required this.referenceLabel,
    required this.departureValue,
    required this.totalValue,
  });

  final String subject;
  final String fromLabel;
  final String toLabel;
  final String departureLabel;
  final String seatsLabel;
  final String totalLabel;
  final String currencyLabel;
  final String plateLabel;
  final String referenceLabel;
  final String departureValue;
  final String totalValue;
}

class BrevoEmailService implements EmailService {
  BrevoEmailService({
    required this.apiKey,
    required this.senderEmail,
    this.senderName = 'LouageGo',
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null;

  static final _endpoint = Uri.https('api.brevo.com', '/v3/smtp/email');

  final String apiKey;
  final String senderEmail;
  final String senderName;
  final http.Client _client;
  final bool _ownsClient;
  final Duration timeout;

  void close() {
    if (_ownsClient) _client.close();
  }

  @override
  Future<void> sendTicket({
    required String toEmail,
    required String toName,
    required Booking booking,
    required File pdf,
    required TicketEmailContent content,
  }) async {
    if (apiKey.trim().isEmpty || senderEmail.trim().isEmpty) {
      throw const EmailException(EmailFailure.notConfigured);
    }

    late final http.Response response;
    try {
      final attachment = base64Encode(await pdf.readAsBytes());
      response = await _client
          .post(
            _endpoint,
            headers: {
              'api-key': apiKey,
              'content-type': 'application/json',
              'accept': 'application/json',
            },
            body: jsonEncode({
              'sender': {'name': senderName, 'email': senderEmail},
              'to': [
                {'email': toEmail, 'name': toName},
              ],
              'subject': content.subject,
              'htmlContent': _htmlContent(booking, content),
              'attachment': [
                {
                  'name': 'billet-${_safeFileName(booking.id)}.pdf',
                  'content': attachment,
                },
              ],
            }),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const EmailException(EmailFailure.timeout);
    } on SocketException {
      throw const EmailException(EmailFailure.network);
    } on http.ClientException {
      throw const EmailException(EmailFailure.network);
    } on FileSystemException {
      throw const EmailException(EmailFailure.network);
    }

    if (response.statusCode == 201) return;
    throw EmailException(switch (response.statusCode) {
      400 => EmailFailure.invalidRequest,
      401 => EmailFailure.invalidApiKey,
      429 => EmailFailure.quotaExceeded,
      _ => EmailFailure.server,
    });
  }

  String _htmlContent(Booking booking, TicketEmailContent content) {
    final seats = booking.selectedSeats.isEmpty
        ? booking.seats.toString()
        : booking.selectedSeats.join(', ');
    final rows = <(String, String)>[
      (content.fromLabel, booking.fromCity),
      (content.toLabel, booking.toCity),
      (content.departureLabel, content.departureValue),
      (content.seatsLabel, seats),
      (content.totalLabel, '${content.totalValue} ${content.currencyLabel}'),
      (content.plateLabel, booking.matricule),
      (content.referenceLabel, booking.id),
    ];
    final tableRows = rows
        .map(
          (row) =>
              '<tr><th style="text-align:left;padding:8px">${_escapeHtml(row.$1)}</th>'
              '<td style="padding:8px">${_escapeHtml(row.$2)}</td></tr>',
        )
        .join();
    return '<!doctype html><html><body style="font-family:Arial,sans-serif;color:#202124">'
        '<h2>${_escapeHtml(content.subject)}</h2>'
        '<table style="border-collapse:collapse">$tableRows</table>'
        '</body></html>';
  }

  String _escapeHtml(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');

  String _safeFileName(String value) =>
      value.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
}
