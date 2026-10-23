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
import '../widgets/louage_seat_layout.dart';

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
    final occupiedSeatState = ref.watch(
      occupiedSeatNumbersProvider(widget.tripId),
    );
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
            final colors = Theme.of(context).colorScheme;
            final darkHeader = colors.brightness == Brightness.dark
                ? colors.surfaceContainerHigh
                : colors.secondary;
            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.searchReservation),
                backgroundColor: darkHeader,
                foregroundColor: colors.onPrimary,
                iconTheme: IconThemeData(color: colors.onPrimary),
              ),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '${detail.fromStation?.name ?? ''} → ${detail.toStation?.name ?? ''}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${price.toStringAsFixed(2)} DT ${l10n.bookingPerSeat}',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: colors.inversePrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  occupiedSeatState.when(
                    data: (occupiedSeats) => LouageSeatLayout(
                      totalSeats: trip.totalSeats,
                      occupiedSeats: occupiedSeats,
                      selectedSeats: _selected,
                      onSeatChanged: (seat, selected) => setState(() {
                        selected ? _selected.add(seat) : _selected.remove(seat);
                      }),
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, stack) => AppCard(
                      child: Text(
                        '$error',
                        style: TextStyle(color: colors.error),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.bookingSummary(_selected.length),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(_selected.length * price).toStringAsFixed(2)} DT',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: colors.inversePrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.bookingPaymentSimulation,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
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
                            if (value != null) {
                              setState(() => _payment = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
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

class _Ticket extends StatelessWidget {
  const _Ticket({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final darkHeader = colors.brightness == Brightness.dark
        ? colors.surfaceContainerHigh
        : colors.secondary;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookingConfirmed),
        backgroundColor: darkHeader,
        foregroundColor: colors.onPrimary,
        iconTheme: IconThemeData(color: colors.onPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(Icons.check_circle, color: colors.tertiary, size: 72),
          const SizedBox(height: 12),
          Text(
            l10n.bookingTicketReady,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          AppCard(
            shape: _NotchedTicketBorder(
              side: BorderSide(color: colors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.confirmation_number_rounded,
                  color: colors.primary,
                  size: 32,
                ),
                const SizedBox(height: 10),
                Center(child: QrImageView(data: booking.qrCode, size: 220)),
                const SizedBox(height: 18),
                Divider(color: colors.outlineVariant),
                const SizedBox(height: 10),
                Text(
                  '${l10n.bookingReference}: ${booking.id}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  '${l10n.bookingSeats}: ${booking.selectedSeats.join(', ')}',
                ),
                Text('${l10n.bookingDriver}: ${booking.driverName}'),
                Text('${l10n.bookingMatricule}: ${booking.matricule}'),
                const SizedBox(height: 10),
                Text(
                  '${booking.totalPrice.toStringAsFixed(2)} DT',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colors.inversePrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.end,
                ),
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

class _NotchedTicketBorder extends ShapeBorder {
  const _NotchedTicketBorder({required this.side});

  final BorderSide side;
  static const _radius = 16.0;
  static const _notchRadius = 12.0;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  Path _path(Rect rect) {
    final middle = rect.center.dy;
    return Path()
      ..moveTo(rect.left + _radius, rect.top)
      ..lineTo(rect.right - _radius, rect.top)
      ..quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + _radius)
      ..lineTo(rect.right, middle - _notchRadius)
      ..quadraticBezierTo(
        rect.right - _notchRadius,
        middle,
        rect.right,
        middle + _notchRadius,
      )
      ..lineTo(rect.right, rect.bottom - _radius)
      ..quadraticBezierTo(
        rect.right,
        rect.bottom,
        rect.right - _radius,
        rect.bottom,
      )
      ..lineTo(rect.left + _radius, rect.bottom)
      ..quadraticBezierTo(
        rect.left,
        rect.bottom,
        rect.left,
        rect.bottom - _radius,
      )
      ..lineTo(rect.left, middle + _notchRadius)
      ..quadraticBezierTo(
        rect.left + _notchRadius,
        middle,
        rect.left,
        middle - _notchRadius,
      )
      ..lineTo(rect.left, rect.top + _radius)
      ..quadraticBezierTo(rect.left, rect.top, rect.left + _radius, rect.top)
      ..close();
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => _path(rect);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _path(rect.deflate(side.width));

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    canvas.drawPath(_path(rect), side.toPaint());
  }

  @override
  ShapeBorder scale(double t) => _NotchedTicketBorder(side: side.scale(t));
}
