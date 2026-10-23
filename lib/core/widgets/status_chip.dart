import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final normalized = status.toLowerCase();
    final l10n = AppLocalizations.of(context)!;
    final isDark = colorScheme.brightness == Brightness.dark;
    final (label, icon, foreground, background, border) = switch (normalized) {
      'full' => (
        l10n.statusFull,
        Icons.event_busy_outlined,
        colorScheme.error,
        colorScheme.errorContainer,
        colorScheme.error,
      ),
      'cancelled' => (
        l10n.statusCancelled,
        Icons.cancel_outlined,
        colorScheme.error,
        colorScheme.errorContainer,
        colorScheme.error,
      ),
      'confirmed' => (
        l10n.statusConfirmed,
        Icons.verified_outlined,
        colorScheme.tertiary,
        colorScheme.tertiary.withValues(alpha: 0.12),
        colorScheme.tertiary,
      ),
      'arrived' => (
        l10n.statusArrived,
        Icons.check_circle_outline,
        colorScheme.tertiary,
        colorScheme.tertiary.withValues(alpha: 0.12),
        colorScheme.tertiary,
      ),
      'departed' => (
        l10n.statusDeparted,
        Icons.directions_bus_outlined,
        isDark ? colorScheme.onSurface : colorScheme.onSecondary,
        isDark ? colorScheme.surfaceContainer : colorScheme.secondary,
        isDark ? colorScheme.surfaceContainer : colorScheme.secondary,
      ),
      'open' => (
        l10n.supportStatusOpen,
        Icons.mark_email_unread_outlined,
        colorScheme.onSurface,
        colorScheme.surface,
        colorScheme.outline,
      ),
      'inprogress' || 'in_progress' => (
        l10n.supportStatusInProgress,
        Icons.hourglass_top_rounded,
        colorScheme.onSurface,
        colorScheme.surface,
        colorScheme.outline,
      ),
      'resolved' => (
        l10n.supportStatusResolved,
        Icons.task_alt_rounded,
        colorScheme.tertiary,
        colorScheme.tertiary.withValues(alpha: 0.12),
        colorScheme.tertiary,
      ),
      _ => (
        l10n.statusWaiting,
        Icons.schedule_outlined,
        colorScheme.onSurface,
        colorScheme.surface,
        colorScheme.outline,
      ),
    };

    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
