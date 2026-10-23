import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_chip.dart';
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
    final colors = Theme.of(context).colorScheme;
    final darkHeader = colors.brightness == Brightness.dark
        ? colors.surfaceContainerHigh
        : colors.secondary;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.passengerNavTrips),
        backgroundColor: darkHeader,
        foregroundColor: colors.onPrimary,
        iconTheme: IconThemeData(color: colors.onPrimary),
      ),
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
                        padding: const EdgeInsetsDirectional.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _showDetails(context, ref, booking),
                          borderRadius: BorderRadius.circular(16),
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.confirmation_number_outlined,
                                      color: colors.primary,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        booking.fromCity.isNotEmpty &&
                                                booking.toCity.isNotEmpty
                                            ? '${booking.fromCity} → ${booking.toCity}'
                                            : l10n.bookingReference,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                    StatusChip(status: booking.status),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${l10n.bookingSeats}: ${booking.selectedSeats.join(', ')}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ),
                                    Text(
                                      '${booking.totalPrice.toStringAsFixed(2)} DT',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: colors.inversePrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                                if (!cancelled) ...[
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: AlignmentDirectional.centerEnd,
                                    child: TextButton.icon(
                                      icon: const Icon(
                                        Icons.cancel_outlined,
                                        size: 18,
                                      ),
                                      label: Text(l10n.bookingCancel),
                                      onPressed: () =>
                                          _cancel(context, ref, booking.id),
                                    ),
                                  ),
                                ],
                              ],
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
              SizedBox(
                width: double.infinity,
                child: Text(
                  l10n.bookingDetails,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Text('${l10n.bookingReference}: ${booking.id}'),
              Text(
                '${l10n.bookingDriver}: ${booking.driverName.isEmpty ? '—' : booking.driverName}',
              ),
              Text(
                '${l10n.bookingMatricule}: ${booking.matricule.isEmpty ? '—' : booking.matricule}',
              ),
              if (booking.fromCity.isNotEmpty || booking.toCity.isNotEmpty)
                Text(
                  'De ${booking.fromCity.isEmpty ? '?' : booking.fromCity} → ${booking.toCity.isEmpty ? '?' : booking.toCity}',
                ),
              Text('${l10n.bookingSeats}: ${booking.selectedSeats.join(', ')}'),
              Text('${l10n.bookingDeparture}: ${booking.departureTime}'),
              Text(
                '${l10n.bookingTotal}: ${booking.totalPrice.toStringAsFixed(2)} DT',
              ),
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
        content: Text(AppLocalizations.of(context)!.bookingCancelMessage),
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
      await ref
          .read(bookingRepositoryProvider)
          .cancel(bookingId: id, userId: user.id);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error')));
      }
    }
  }
}
