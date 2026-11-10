import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_config.dart';
import '../../../../core/services/brevo_email_service.dart';
import '../../../../models/booking.dart';
import '../../data/ticket_pdf_service.dart';

typedef TicketPdfGenerator = Future<File> Function(Booking booking);

final emailConfiguredProvider = Provider<bool>(
  (ref) => AppConfig.emailConfigured,
);

final emailServiceProvider = Provider<EmailService>((ref) {
  final service = BrevoEmailService(
    apiKey: AppConfig.brevoApiKey,
    senderEmail: AppConfig.brevoSenderEmail,
    senderName: AppConfig.brevoSenderName,
  );
  ref.onDispose(service.close);
  return service;
});

final ticketPdfGeneratorProvider = Provider<TicketPdfGenerator>(
  (ref) => TicketPdfService.create,
);

final ticketEmailControllerProvider =
    AsyncNotifierProvider<TicketEmailController, void>(
      TicketEmailController.new,
    );

class TicketEmailController extends AsyncNotifier<void> {
  bool _isSending = false;

  @override
  Future<void> build() async {}

  Future<void> sendTicket({
    required Booking booking,
    required String toEmail,
    required String toName,
    required TicketEmailContent content,
  }) async {
    if (_isSending) return;
    _isSending = true;
    state = const AsyncLoading();
    try {
      final pdf = await ref.read(ticketPdfGeneratorProvider)(booking);
      await ref
          .read(emailServiceProvider)
          .sendTicket(
            toEmail: toEmail,
            toName: toName,
            booking: booking,
            pdf: pdf,
            content: content,
          );
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    } finally {
      _isSending = false;
    }
  }
}
