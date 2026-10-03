import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../features/search/presentation/providers/trip_search_results_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../presentation/providers/booking_provider.dart';
import '../../../../models/booking.dart';
import '../../data/ticket_pdf_service.dart';

class BookingFlowScreen extends ConsumerStatefulWidget {
  const BookingFlowScreen({super.key, required this.tripId});
  final String tripId;

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  final _selected = <int>{};
  String _payment = 'cash';
  Booking? _confirmed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_confirmed != null) return _Ticket(booking: _confirmed!);
    return ref
        .watch(louageDetailDataProvider(widget.tripId))
        .when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stack) =>
              Scaffold(body: Center(child: Text('$error'))),
          data: (detail) {
            if (detail == null ||
                detail.route == null ||
                detail.louage == null) {
              return Scaffold(body: Center(child: Text(l10n.louageNotFound)));
            }
            final trip = detail.trip;
            final price = detail.route!.pricePerSeat;
            return Scaffold(
              appBar: AppBar(title: Text(l10n.searchReservation)),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    '${detail.fromStation?.name ?? ''} → ${detail.toStation?.name ?? ''}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('${price.toStringAsFixed(2)} DT ${l10n.bookingPerSeat}'),
                  const SizedBox(height: 18),
                  _SeatLayout(
                    totalSeats: trip.totalSeats,
                    reservedSeats: trip.reservedSeats,
                    selectedSeats: _selected,
                    onSeatChanged: (seat, selected) => setState(() {
                      selected ? _selected.add(seat) : _selected.remove(seat);
                    }),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.bookingSummary(_selected.length),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text('${(_selected.length * price).toStringAsFixed(2)} DT'),
                  const SizedBox(height: 14),
                  Text(
                    l10n.bookingPaymentSimulation,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _payment,
                    decoration: InputDecoration(
                      labelText: l10n.bookingPaymentMethod,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'cash',
                        child: Text(l10n.bookingPayOnBoarding),
                      ),
                      DropdownMenuItem(
                        value: 'card',
                        child: Text(l10n.bookingCardSimulation),
                      ),
                      DropdownMenuItem(
                        value: 'mobile',
                        child: Text(l10n.bookingMobileSimulation),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _payment = value);
                    },
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: l10n.bookingReviewAction,
                    onPressed: _selected.isEmpty ? null : _confirm,
                  ),
                ],
              ),
            );
          },
        );
  }

  Future<void> _confirm() async {
    final l10n = AppLocalizations.of(context)!;
    final detail = await ref.read(
      louageDetailDataProvider(widget.tripId).future,
    );
    final price = detail?.route?.pricePerSeat ?? 0;
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.bookingReviewTitle),
        content: Text(
          '${l10n.bookingSeats}: ${_selected.toList()..sort()}\n'
          '${l10n.bookingTotal}: ${(_selected.length * price).toStringAsFixed(2)} DT\n'
          '${l10n.bookingPayment}: $_payment',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.authCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.bookingConfirmAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final user = await ref.read(currentUserProvider.future);
    if (user == null || !mounted) return;
    try {
      final booking = await ref
          .read(bookingRepositoryProvider)
          .create(
            userId: user.id,
            tripId: widget.tripId,
            seats: _selected.toList(),
            paymentMethod: _payment,
          );
      if (mounted) setState(() => _confirmed = booking);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error')));
      }
    }
  }
}

class _SeatLayout extends StatelessWidget {
  const _SeatLayout({
    required this.totalSeats,
    required this.reservedSeats,
    required this.selectedSeats,
    required this.onSeatChanged,
  });

  final int totalSeats;
  final int reservedSeats;
  final Set<int> selectedSeats;
  final void Function(int seat, bool selected) onSeatChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final occupiedCount = reservedSeats.clamp(0, totalSeats);
    final rows = <Widget>[];
    for (var firstSeat = 1; firstSeat <= totalSeats; firstSeat += 2) {
      final secondSeat = firstSeat + 1;
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Seat(
              number: firstSeat,
              occupied: firstSeat <= occupiedCount,
              selected: selectedSeats.contains(firstSeat),
              onChanged: onSeatChanged,
            ),
            if (secondSeat <= totalSeats)
              _Seat(
                number: secondSeat,
                occupied: secondSeat <= occupiedCount,
                selected: selectedSeats.contains(secondSeat),
                onChanged: onSeatChanged,
              )
            else
              const SizedBox(width: 58),
          ],
        ),
      );
      if (firstSeat + 2 <= totalSeats) {
        rows.add(const SizedBox(height: 10));
      }
    }

    return AppCard(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              AppLocalizations.of(context)!.bookingDriverSeat,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: 14),
          ...rows,
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 8,
            children: [
              _Legend(
                color: colors.outlineVariant,
                label: AppLocalizations.of(context)!.bookingTaken,
              ),
              _Legend(
                color: colors.primary,
                label: AppLocalizations.of(context)!.bookingSelected,
              ),
              _Legend(
                color: colors.surface,
                label: AppLocalizations.of(context)!.bookingFree,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Seat extends StatelessWidget {
  const _Seat({
    required this.number,
    required this.occupied,
    required this.selected,
    required this.onChanged,
  });

  final int number;
  final bool occupied;
  final bool selected;
  final void Function(int seat, bool selected) onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = occupied
        ? colors.surfaceContainerHighest
        : selected
        ? colors.primary
        : colors.surface;
    final foreground = occupied
        ? colors.onSurfaceVariant
        : selected
        ? colors.onPrimary
        : colors.primary;

    return Semantics(
      button: !occupied,
      label: 'Seat $number${occupied ? ', taken' : ', free'}',
      child: InkWell(
        onTap: occupied ? null : () => onChanged(number, !selected),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 58,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.primary),
          ),
          child: Text(
            '$number',
            style: TextStyle(color: foreground, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 5),
      Text(label),
    ],
  );
}

class _Ticket extends StatelessWidget {
  const _Ticket({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingConfirmed)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 72),
          const SizedBox(height: 12),
          Text(
            l10n.bookingTicketReady,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          AppCard(
            child: Column(
              children: [
                QrImageView(data: booking.qrCode, size: 220),
                Text('${l10n.bookingReference}: ${booking.id}'),
                Text(
                  '${l10n.bookingSeats}: ${booking.selectedSeats.join(', ')}',
                ),
                Text('${l10n.bookingDriver}: ${booking.driverName}'),
                Text('${l10n.bookingMatricule}: ${booking.matricule}'),
                Text('${booking.totalPrice.toStringAsFixed(2)} DT'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppButton(
            label: l10n.passengerNavTrips,
            onPressed: () => context.go('/passenger/trips'),
          ),
          const SizedBox(height: 8),
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
    );
  }
}
