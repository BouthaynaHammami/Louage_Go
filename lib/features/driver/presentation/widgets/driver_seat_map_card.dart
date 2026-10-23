import 'package:flutter/material.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../features/driver/domain/entities/driver_passenger.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/booking.dart';
import '../../../../models/trip.dart';

class DriverSeatMapCard extends StatelessWidget {
  const DriverSeatMapCard({
    required this.trip,
    required this.bookings,
    required this.passengers,
    super.key,
  });

  final Trip trip;
  final List<Booking> bookings;
  final Map<String, DriverPassenger> passengers;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final seatMap = <int, String>{};
    for (final booking in bookings) {
      if (booking.tripId != trip.id ||
          const {'cancelled', 'rejected'}.contains(booking.status)) {
        continue;
      }
      final passengerName =
          passengers[booking.userId]?.name ?? l10n.driverPassengerFallback;
      for (final seat in booking.numerosPlaces) {
        seatMap[seat] = passengerName;
      }
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.driverPassengersReserved,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _LouageSeatDiagram(
            totalSeats: trip.totalSeats.clamp(0, 8),
            seatMap: seatMap,
          ),
        ],
      ),
    );
  }
}

class _LouageSeatDiagram extends StatelessWidget {
  const _LouageSeatDiagram({required this.totalSeats, required this.seatMap});

  final int totalSeats;
  final Map<int, String> seatMap;

  @override
  Widget build(BuildContext context) {
    Widget seatWidget(int number) => _SeatButton(
      number: number,
      passengerName: seatMap[number],
      visible: number <= totalSeats,
    );

    Widget row(List<int> seats) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: seats
          .map(
            (number) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: seatWidget(number),
            ),
          )
          .toList(),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_DriverSeat(), seatWidget(1)],
          ),
          const SizedBox(height: 8),
          Divider(
            color: Theme.of(context).colorScheme.outlineVariant,
            height: 1,
          ),
          const SizedBox(height: 8),
          row([2, 3]),
          const SizedBox(height: 8),
          row([4, 5]),
          const SizedBox(height: 8),
          row([6, 7, 8]),
        ],
      ),
    );
  }
}

class _DriverSeat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: 60,
          height: 52,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Icon(
            Icons.directions_car_filled_outlined,
            color: colors.onSurfaceVariant,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context)!.bookingDriverSeat,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _SeatButton extends StatelessWidget {
  const _SeatButton({
    required this.number,
    required this.passengerName,
    required this.visible,
  });

  final int number;
  final String? passengerName;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox(width: 60, height: 52);
    final colors = Theme.of(context).colorScheme;
    final occupied = passengerName != null;

    return Tooltip(
      message: occupied
          ? passengerName!
          : AppLocalizations.of(context)!.bookingFree,
      child: Container(
        width: 60,
        height: 52,
        decoration: BoxDecoration(
          color: occupied
              ? colors.primary.withValues(alpha: 0.15)
              : colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: occupied ? colors.primary : colors.outlineVariant,
            width: occupied ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                occupied ? Icons.person : Icons.event_seat_outlined,
                size: 16,
                color: occupied ? colors.primary : colors.onSurfaceVariant,
              ),
              Text(
                '$number',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: occupied ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
