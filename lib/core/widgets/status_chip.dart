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
    final (label, icon, isError) = switch (normalized) {
      'full' => (l10n.statusFull, Icons.event_busy_outlined, true),
      'departed' => (l10n.statusDeparted, Icons.directions_bus_outlined, false),
      'arrived' => (l10n.statusArrived, Icons.check_circle_outline, false),
      'cancelled' => (l10n.statusCancelled, Icons.cancel_outlined, true),
      'open' => (l10n.supportStatusOpen, Icons.mark_email_unread_outlined, false),
      'inprogress' || 'in_progress' => (
        l10n.supportStatusInProgress,
        Icons.hourglass_top_rounded,
        false,
      ),
      'resolved' => (
        l10n.supportStatusResolved,
        Icons.task_alt_rounded,
        false,
      ),
      _ => (l10n.statusWaiting, Icons.schedule_outlined, false),
    };
    final foreground = isError ? colorScheme.error : colorScheme.onSurface;
    final background = isError
        ? colorScheme.error.withValues(alpha: 0.12)
        : colorScheme.surface;

    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(
          color: isError ? colorScheme.error : colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(20),
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
