import 'package:flutter/material.dart';

import 'app_logo.dart';

class HomeGreetingHeader extends StatelessWidget {
  const HomeGreetingHeader({
    required this.greeting,
    required this.subtitle,
    required this.profileTooltip,
    required this.onProfile,
    this.notificationsTooltip,
    this.onNotifications,
    this.unreadCount = 0,
    super.key,
  });

  final String greeting;
  final String subtitle;
  final String profileTooltip;
  final VoidCallback onProfile;
  final String? notificationsTooltip;
  final VoidCallback? onNotifications;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final notificationLabel = notificationsTooltip;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const AppLogoMark(size: 72, showBackground: false),
                const Spacer(),
                if (notificationLabel != null) ...[
                  IconButton.filledTonal(
                    tooltip: notificationLabel,
                    onPressed: onNotifications,
                    constraints: const BoxConstraints.tightFor(
                      width: 48,
                      height: 48,
                    ),
                    style: IconButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      foregroundColor: colorScheme.onSurface,
                    ),
                    icon: Badge(
                      isLabelVisible: unreadCount > 0,
                      label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                      child: const Icon(Icons.notifications_none_rounded),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                IconButton.filledTonal(
                  tooltip: profileTooltip,
                  onPressed: onProfile,
                  constraints: const BoxConstraints.tightFor(
                    width: 48,
                    height: 48,
                  ),
                  style: IconButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    foregroundColor: colorScheme.onSurface,
                  ),
                  icon: const Icon(Icons.person_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              greeting,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
