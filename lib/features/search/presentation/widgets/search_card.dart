import 'package:flutter/material.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';

class SearchCard extends StatelessWidget {
  final String departureLabel;
  final String destinationLabel;
  final String chooseCityLabel;
  final String dateLabel;
  final String dateValue;
  final String timeLabel;
  final String timeValue;
  final String swapTooltip;
  final String searchLabel;
  final String? departure;
  final String? destination;
  final Animation<double> swapAnimation;
  final bool departureError;
  final bool destinationError;
  final bool isLoading;
  final VoidCallback onDepartureTap;
  final VoidCallback onDestinationTap;
  final VoidCallback onSwap;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;
  final VoidCallback onSearch;

  const SearchCard({
    super.key,
    required this.departureLabel,
    required this.destinationLabel,
    required this.chooseCityLabel,
    required this.dateLabel,
    required this.dateValue,
    required this.timeLabel,
    required this.timeValue,
    required this.swapTooltip,
    required this.searchLabel,
    required this.departure,
    required this.destination,
    required this.swapAnimation,
    required this.departureError,
    required this.destinationError,
    required this.isLoading,
    required this.onDepartureTap,
    required this.onDestinationTap,
    required this.onSwap,
    required this.onDateTap,
    required this.onTimeTap,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      color: colorScheme.surfaceContainerLow,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      padding: const EdgeInsetsDirectional.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 136,
                child: Column(
                  children: [
                    Icon(
                      Icons.trip_origin_rounded,
                      size: 14,
                      color: colorScheme.secondary,
                    ),
                    Expanded(
                      child: CustomPaint(
                        painter: _DottedRoutePainter(
                          color: colorScheme.secondary.withValues(alpha: 0.7),
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    Icon(
                      Icons.location_on_rounded,
                      size: 18,
                      color: colorScheme.secondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: 64,
                      child: LocationField(
                        label: departureLabel,
                        value: departure,
                        placeholder: chooseCityLabel,
                        isError: departureError,
                        onTap: onDepartureTap,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 64,
                      child: LocationField(
                        label: destinationLabel,
                        value: destination,
                        placeholder: chooseCityLabel,
                        isError: destinationError,
                        onTap: onDestinationTap,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 48,
                height: 136,
                child: Center(
                  child: RotationTransition(
                    turns: swapAnimation,
                    child: IconButton.filledTonal(
                      tooltip: swapTooltip,
                      constraints: const BoxConstraints.tightFor(
                        width: 48,
                        height: 48,
                      ),
                      style: IconButton.styleFrom(
                        shape: const CircleBorder(),
                        foregroundColor: colorScheme.onSurface,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      onPressed: onSwap,
                      icon: const Icon(Icons.swap_vert_rounded),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DateTimeField(
                  label: dateLabel,
                  value: dateValue,
                  icon: Icons.calendar_today_outlined,
                  onTap: onDateTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateTimeField(
                  label: timeLabel,
                  value: timeValue,
                  icon: Icons.access_time_rounded,
                  onTap: onTimeTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppButton(
            label: searchLabel,
            icon: Icons.search_rounded,
            variant: AppButtonVariant.accent,
            height: 52,
            isLoading: isLoading,
            onPressed: isLoading ? null : onSearch,
          ),
        ],
      ),
    );
  }
}

class LocationField extends StatelessWidget {
  final String label;
  final String? value;
  final String placeholder;
  final bool isError;
  final VoidCallback onTap;

  const LocationField({
    super.key,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.isError,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = isError ? colorScheme.error : colorScheme.onSurface;
    return Semantics(
      button: true,
      label: '$label, ${value ?? placeholder}',
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isError ? colorScheme.error : colorScheme.outlineVariant,
                width: isError ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isError
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? placeholder,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: value == null
                        ? colorScheme.onSurfaceVariant
                        : foreground,
                    fontWeight: FontWeight.w600,
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

class _DateTimeField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _DateTimeField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: '$label, $value',
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: const BoxConstraints(minHeight: 60),
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: colorScheme.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
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

class _DottedRoutePainter extends CustomPainter {
  final Color color;

  const _DottedRoutePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final centerX = size.width / 2;
    for (var y = 2.0; y < size.height; y += 7) {
      canvas.drawLine(
        Offset(centerX, y),
        Offset(centerX, (y + 3).clamp(0, size.height)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DottedRoutePainter oldDelegate) =>
      oldDelegate.color != color;
}
