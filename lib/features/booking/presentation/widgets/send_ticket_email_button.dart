import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/brevo_email_service.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/booking.dart';
import '../providers/ticket_email_provider.dart';

// Shared regex used for validation; identical to the one in AuthRepositoryImpl.
final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

bool _isValidEmail(String value) => _emailRegex.hasMatch(value.trim());

/// Returns a display name for the recipient: uses [name] if non-empty,
/// otherwise falls back to the local part of [email] (before the @).
String _recipientName(String name, String email) {
  final trimmed = name.trim();
  if (trimmed.isNotEmpty) return trimmed;
  final at = email.indexOf('@');
  return at > 0 ? email.substring(0, at) : email;
}

class SendTicketEmailButton extends ConsumerStatefulWidget {
  const SendTicketEmailButton({required this.booking, super.key});

  final Booking booking;

  @override
  ConsumerState<SendTicketEmailButton> createState() =>
      _SendTicketEmailButtonState();
}

class _SendTicketEmailButtonState extends ConsumerState<SendTicketEmailButton> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final configured = ref.watch(emailConfiguredProvider);

    // ── Brevo not configured ───────────────────────────────────────────────
    if (!configured) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.email_outlined),
              label: Text(l10n.ticketEmailSend),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.ticketEmailNotConfigured,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.50),
            ),
          ),
        ],
      );
    }

    // ── User still loading ─────────────────────────────────────────────────
    final userAsync = ref.watch(currentUserProvider);
    if (userAsync.isLoading) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          label: Text(l10n.ticketEmailSend),
        ),
      );
    }

    final user = userAsync.asData?.value;
    final emailState = ref.watch(ticketEmailControllerProvider);
    final isSending = emailState.isLoading;

    final accountEmail = user?.email.trim() ?? '';
    final hasValidEmail = _isValidEmail(accountEmail);

    // ── Button + optional recipient hint ──────────────────────────────────
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: user == null || isSending
                ? null
                : () => _startSend(l10n, accountEmail, user.name),
            icon: isSending
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.email_outlined),
            label: Text(l10n.ticketEmailSend),
          ),
        ),
        if (hasValidEmail) ...[
          const SizedBox(height: 4),
          Text(
            l10n.ticketEmailRecipientHint(accountEmail),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.50),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _startSend(
    AppLocalizations l10n,
    String accountEmail,
    String accountName,
  ) async {
    if (_isValidEmail(accountEmail)) {
      await _send(l10n, accountEmail.trim(), _recipientName(accountName, accountEmail));
      return;
    }

    // Email absent or invalid — ask the user.
    final enteredEmail = await _askForEmail(l10n);
    if (!mounted || enteredEmail == null) return;
    await _send(l10n, enteredEmail, _recipientName(accountName, enteredEmail));
  }

  Future<String?> _askForEmail(AppLocalizations l10n) async {
    return showDialog<String>(
      context: context,
      builder: (_) => _TicketEmailAddressDialog(l10n: l10n),
    );
  }

  Future<void> _send(AppLocalizations l10n, String email, String name) async {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final departure = DateTime.tryParse(widget.booking.departureTime);
    try {
      await ref
          .read(ticketEmailControllerProvider.notifier)
          .sendTicket(
            booking: widget.booking,
            toEmail: email,
            toName: name,
            content: TicketEmailContent(
              subject: l10n.ticketEmailSubject,
              fromLabel: l10n.ticketEmailFrom,
              toLabel: l10n.ticketEmailTo,
              departureLabel: l10n.ticketEmailDeparture,
              seatsLabel: l10n.bookingSeats,
              totalLabel: l10n.bookingTotal,
              currencyLabel: l10n.driverCurrencyDt,
              plateLabel: l10n.bookingMatricule,
              referenceLabel: l10n.bookingReference,
              departureValue: departure == null
                  ? widget.booking.departureTime
                  : DateFormat.yMMMd(locale).add_Hm().format(departure),
              totalValue: widget.booking.totalPrice.toStringAsFixed(2),
            ),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.ticketEmailSent(email))));
    } on EmailException catch (exception) {
      if (!mounted) return;
      final message = switch (exception.failure) {
        EmailFailure.notConfigured => l10n.ticketEmailNotConfigured,
        EmailFailure.network => l10n.ticketEmailNetworkError,
        EmailFailure.timeout => l10n.ticketEmailTimeoutError,
        EmailFailure.invalidApiKey => l10n.ticketEmailInvalidKey,
        EmailFailure.invalidRequest => l10n.ticketEmailInvalidRequest,
        EmailFailure.quotaExceeded => l10n.ticketEmailQuotaError,
        EmailFailure.server => l10n.ticketEmailServerError,
      };
      _showRetry(l10n, email, name, message);
    } catch (_) {
      if (!mounted) return;
      _showRetry(l10n, email, name, l10n.ticketEmailServerError);
    }
  }

  void _showRetry(
    AppLocalizations l10n,
    String email,
    String name,
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: l10n.supportRetry,
            onPressed: () => _send(l10n, email, name),
          ),
        ),
      );
  }
}

class _TicketEmailAddressDialog extends StatefulWidget {
  const _TicketEmailAddressDialog({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_TicketEmailAddressDialog> createState() =>
      _TicketEmailAddressDialogState();
}

class _TicketEmailAddressDialogState extends State<_TicketEmailAddressDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;

    void submit() {
      final value = _controller.text.trim();
      if (!_isValidEmail(value)) {
        setState(() => _error = l10n.ticketEmailInvalidAddress);
        return;
      }
      Navigator.pop(context, value);
    }

    return AlertDialog(
      title: Text(l10n.ticketEmailDialogTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        decoration: InputDecoration(
          labelText: l10n.ticketEmailAddress,
          errorText: _error,
        ),
        onSubmitted: (_) => submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.authCancel),
        ),
        FilledButton(onPressed: submit, child: Text(l10n.ticketEmailSend)),
      ],
    );
  }
}
