import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

class SeatDots extends StatelessWidget {
  final int freeSeats;
  final int totalSeats;
  final double diameter;
  final double spacing;

  const SeatDots({
    super.key,
    required this.freeSeats,
    this.totalSeats = 8,
    this.diameter = 12,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final seats = totalSeats < 0 ? 0 : totalSeats;
    final available = freeSeats.clamp(0, seats).toInt();
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      label: l10n.searchSeatsAvailableSemantics(
        available.toString(),
        seats.toString(),
      ),
      child: ExcludeSemantics(
        child: Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (var index = 0; index < seats; index++)
              Container(
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < available
                      ? colorScheme.tertiary
                      : Colors.transparent,
                  border: Border.all(
                    color: index < available
                        ? colorScheme.tertiary
                        : colorScheme.outline,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
