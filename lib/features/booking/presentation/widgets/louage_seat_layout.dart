import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_card.dart';
import '../../../../../l10n/generated/app_localizations.dart';

class LouageSeatLayout extends StatelessWidget {
  const LouageSeatLayout({
    required this.totalSeats,
    required this.occupiedSeats,
    required this.selectedSeats,
    required this.onSeatChanged,
    super.key,
  });

  final int totalSeats;
  final Set<int> occupiedSeats;
  final Set<int> selectedSeats;
  final void Function(int seat, bool selected) onSeatChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final seatCount = totalSeats.clamp(0, 8);

    Widget seat(int number) => _LouageSeat(
      number: number,
      occupied: occupiedSeats.contains(number),
      selected: selectedSeats.contains(number),
      onChanged: onSeatChanged,
    );

    return AppCard(
      child: Directionality(
        textDirection: TextDirection.ltr,
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
                l10n.bookingDriverSeat,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _CabinShell(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _DriverPosition(label: l10n.bookingDriverSeat),
                      ),
                      const SizedBox(width: 6),
                      if (seatCount >= 1) Expanded(child: seat(1)),
                    ],
                  ),
                  if (seatCount > 1) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    _SeatBench(
                      numbers: [2, 3].where((number) => number <= seatCount),
                      seatBuilder: seat,
                    ),
                  ],
                  if (seatCount > 3) ...[
                    const SizedBox(height: 10),
                    _SeatBench(
                      numbers: [4, 5].where((number) => number <= seatCount),
                      seatBuilder: seat,
                    ),
                  ],
                  if (seatCount > 5) ...[
                    const SizedBox(height: 10),
                    _SeatBench(
                      numbers: [6, 7, 8].where((number) => number <= seatCount),
                      seatBuilder: seat,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 14,
              runSpacing: 8,
              children: [
                _SeatLegend(
                  color: colors.error,
                  icon: Icons.person,
                  label: l10n.bookingTaken,
                ),
                _SeatLegend(
                  color: colors.primary,
                  icon: Icons.check,
                  label: l10n.bookingSelected,
                ),
                _SeatLegend(
                  color: colors.surface,
                  icon: Icons.event_seat_outlined,
                  borderColor: colors.outline,
                  label: l10n.bookingFree,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CabinShell extends StatelessWidget {
  const _CabinShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border.all(color: colors.outline),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(42),
          bottom: Radius.circular(24),
        ),
      ),
      child: child,
    );
  }
}

class _DriverPosition extends StatelessWidget {
  const _DriverPosition({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_filled_outlined,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeatBench extends StatelessWidget {
  const _SeatBench({required this.numbers, required this.seatBuilder});

  final Iterable<int> numbers;
  final Widget Function(int number) seatBuilder;

  @override
  Widget build(BuildContext context) {
    final seats = numbers.toList();
    return Row(
      children: [
        for (var index = 0; index < seats.length; index++) ...[
          if (index > 0) const SizedBox(width: 6),
          Expanded(child: seatBuilder(seats[index])),
        ],
      ],
    );
  }
}

class _LouageSeat extends StatelessWidget {
  const _LouageSeat({
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
    final l10n = AppLocalizations.of(context)!;
    final stateLabel = occupied
        ? l10n.bookingTaken
        : selected
        ? l10n.bookingSelected
        : l10n.bookingFree;
    final background = occupied
        ? colors.error
        : selected
        ? colors.primary
        : colors.surface;
    final foreground = occupied
        ? colors.onError
        : selected
        ? colors.onPrimary
        : colors.onSurface;

    return Semantics(
      button: !occupied,
      selected: selected,
      label: '$number, $stateLabel',
      child: Tooltip(
        message: '$number · $stateLabel',
        child: InkWell(
          onTap: occupied ? null : () => onChanged(number, !selected),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 60,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: background,
              border: Border.all(
                color: occupied
                    ? colors.error
                    : selected
                    ? colors.primary
                    : colors.outline,
                width: selected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  occupied
                      ? Icons.person
                      : selected
                      ? Icons.check
                      : Icons.event_seat_outlined,
                  size: 19,
                  color: foreground,
                ),
                Text(
                  '$number',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SeatLegend extends StatelessWidget {
  const _SeatLegend({
    required this.color,
    required this.icon,
    required this.label,
    this.borderColor,
  });

  final Color color;
  final IconData icon;
  final String label;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: borderColor ?? color),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 13,
          color: borderColor == null
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
      ),
    ],
  );
}
