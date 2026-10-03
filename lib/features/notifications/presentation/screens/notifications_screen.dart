import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/app_notification.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider).asData?.value;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          IconButton(
            tooltip: l10n.notificationsMarkAllRead,
            onPressed: user == null
                ? null
                : () => ref
                      .read(notificationRepositoryProvider)
                      .markAllRead(user.id),
            icon: const Icon(Icons.done_all_rounded),
          ),
        ],
      ),
      body: user == null
          ? EmptyState(
              icon: Icons.notifications_off_outlined,
              title: l10n.notificationsEmptyTitle,
              description: l10n.notificationsEmptyBody,
            )
          : ref
                .watch(notificationsForUserProvider(user.id))
                .when(
                  loading: () => ListView(
                    padding: const EdgeInsetsDirectional.all(20),
                    children: [
                      SkeletonBox(height: 82),
                      SizedBox(height: 12),
                      SkeletonBox(height: 82),
                    ],
                  ),
                  error: (error, stackTrace) => EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: l10n.notificationsLoadError,
                  ),
                  data: (items) => items.isEmpty
                      ? EmptyState(
                          icon: Icons.notifications_none_rounded,
                          title: l10n.notificationsEmptyTitle,
                          description: l10n.notificationsEmptyBody,
                        )
                      : _NotificationList(items: items),
                ),
    );
  }
}

class _NotificationList extends ConsumerWidget {
  const _NotificationList({required this.items});

  final List<AppNotification> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = <AppNotification>[];
    final yesterday = <AppNotification>[];
    final older = <AppNotification>[];
    for (final item in items) {
      final date = DateTime.tryParse(item.createdAt);
      if (date == null || _isSameDay(date, now)) {
        today.add(item);
      } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
        yesterday.add(item);
      } else {
        older.add(item);
      }
    }
    final groups = [
      (l10n.notificationsToday, today),
      (l10n.notificationsYesterday, yesterday),
      (l10n.notificationsOlder, older),
    ].where((group) => group.$2.isNotEmpty);
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
      children: [
        for (final group in groups) ...[
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(4, 12, 4, 8),
            child: Text(
              group.$1,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          for (final notification in group.$2)
            _NotificationTile(
              notification: notification,
              onTap: () async {
                await ref
                    .read(notificationRepositoryProvider)
                    .markRead(notification.id);
                final route = NotificationRouteAllowlist.validate(
                  notification.route,
                );
                if (route != null && context.mounted) context.go(route);
              },
              onDismissed: () async {
                final repository = ref.read(notificationRepositoryProvider);
                await repository.delete(notification.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.notificationsDeleted),
                    action: SnackBarAction(
                      label: l10n.favoritesUndo,
                      onPressed: () => repository.restore(notification),
                    ),
                  ),
                );
              },
            ),
        ],
      ],
    );
  }

  bool _isSameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismissed,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final Future<void> Function() onDismissed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final (icon, label) = switch (notification.type) {
      'booking' || 'reservation' => (
        Icons.confirmation_number_outlined,
        l10n.notificationsTypeBooking,
      ),
      'trip' ||
      'ride' => (Icons.directions_bus_outlined, l10n.notificationsTypeTrip),
      'promotion' ||
      'promo' => (Icons.local_offer_outlined, l10n.notificationsTypePromotion),
      _ => (Icons.notifications_outlined, l10n.notificationsTypeSystem),
    };
    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        margin: const EdgeInsetsDirectional.only(bottom: 8),
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 20),
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: colors.onErrorContainer,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 8),
        child: AppCard(
          color: notification.isRead
              ? colors.surfaceContainerLow
              : colors.secondaryContainer,
          child: ListTile(
            minVerticalPadding: 12,
            leading: CircleAvatar(
              backgroundColor: colors.surface,
              child: Icon(icon, color: colors.primary),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    notification.title.isEmpty ? label : notification.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: notification.isRead
                          ? FontWeight.w500
                          : FontWeight.w700,
                    ),
                  ),
                ),
                if (!notification.isRead)
                  Semantics(
                    label: l10n.notificationsUnread,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text(notification.message),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
