import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/booking.dart';
import '../../data/ticket_pdf_service.dart';
import '../providers/booking_provider.dart';

class BookingHistoryScreen extends ConsumerWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.passengerNavTrips)),
      body: ref
          .watch(userBookingsProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('$error')),
            data: (bookings) => bookings.isEmpty
                ? Center(child: Text(l10n.bookingEmpty))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      final cancelled = booking.status == 'cancelled';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _showDetails(context, ref, booking),
                          borderRadius: BorderRadius.circular(16),
                          child: AppCard(
                            child: ListTile(
                            leading: Icon(
                              cancelled
                                  ? Icons.cancel
                                  : Icons.confirmation_number,
                            ),
                              title: Text(
                                '${booking.seats} • ${booking.totalPrice.toStringAsFixed(2)} DT',
                            ),
                              subtitle: Text(
                                '${booking.status} • ${booking.selectedSeats.join(', ')}',
                              ),
                              trailing: cancelled
                                  ? null
                                  : TextButton(
                                      child: Text(l10n.bookingCancel),
                                      onPressed: () =>
                                          _cancel(context, ref, booking.id),
                                    ),
                                  ),
                            ),
                        ),
                      );
                    },
                  ),
          ),
    );
  }

  Future<void> _showDetails(
    BuildContext context,
    WidgetRef ref,
    Booking booking,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Wrap(
            runSpacing: 10,
            children: [
              Text(l10n.bookingDetails,
                  style: Theme.of(context).textTheme.headlineSmall),
              Text('${l10n.bookingReference}: ${booking.id}'),
              Text('${l10n.bookingDriver}: ${booking.driverName.isEmpty ? '—' : booking.driverName}'),
              Text('${l10n.bookingMatricule}: ${booking.matricule.isEmpty ? '—' : booking.matricule}'),
              Text('${l10n.bookingSeats}: ${booking.selectedSeats.join(', ')}'),
              Text('${l10n.bookingDeparture}: ${booking.departureTime}'),
              Text('${l10n.bookingTotal}: ${booking.totalPrice.toStringAsFixed(2)} DT'),
              if (booking.status != 'cancelled')
                FilledButton.icon(
                  icon: const Icon(Icons.cancel_outlined),
                  label: Text(l10n.bookingCancel),
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _cancel(context, ref, booking.id);
                  },
                ),
              OutlinedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(l10n.bookingDownloadTicket),
                onPressed: () async {
                  try {
                    await TicketPdfService.share(booking);
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('$error')));
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.bookingCancelTitle),
        content: Text(
          AppLocalizations.of(context)!.bookingCancelMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.authCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.bookingCancel),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) throw StateError('Sign-in required');
      await ref.read(bookingRepositoryProvider).cancel(
            bookingId: id,
            userId: user.id,
          );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error')));
      }
    }
  }
}
