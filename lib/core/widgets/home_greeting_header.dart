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
    this.dark = false,
    this.compact = false,
    super.key,
  });

  final String greeting;
  final String subtitle;
  final String profileTooltip;
  final VoidCallback onProfile;
  final String? notificationsTooltip;
  final VoidCallback? onNotifications;
  final int unreadCount;
  final bool dark;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = dark
        ? colorScheme.brightness == Brightness.dark
              ? colorScheme.surfaceContainer
              : colorScheme.secondary
        : colorScheme.surface;
    final foreground = dark ? colorScheme.onPrimary : colorScheme.onSurface;
    final notificationLabel = notificationsTooltip;
    if (compact) {
      return ColoredBox(
        color: colorScheme.surfaceContainerLow,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            20,
            MediaQuery.viewPaddingOf(context).top + 8,
            20,
            8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      greeting,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.76),
                      ),
                    ),
                  ],
                ),
              ),
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
                const SizedBox(width: 4),
              ],
              IconButton.filledTonal(
                tooltip: profileTooltip,
                onPressed: onProfile,
                constraints: const BoxConstraints.tightFor(width: 48, height: 48),
                style: IconButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  foregroundColor: colorScheme.onSurface,
                ),
                icon: const Icon(Icons.person_outline_rounded),
              ),
            ],
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: dark
          ? const BorderRadiusDirectional.vertical(bottom: Radius.circular(28))
          : BorderRadius.zero,
      child: Container(
        decoration: BoxDecoration(
          color: background,
          border: dark
              ? null
              : Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.55),
                  ),
                ),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            20,
            dark ? MediaQuery.viewPaddingOf(context).top + 12 : 12,
            20,
            18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const AppLogoMark(size: 96, showBackground: false),
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
                        backgroundColor: dark
                            ? foreground.withValues(alpha: 0.12)
                            : colorScheme.surfaceContainerHighest,
                        foregroundColor: foreground,
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
                      backgroundColor: dark
                          ? foreground.withValues(alpha: 0.12)
                          : colorScheme.surfaceContainerHighest,
                      foregroundColor: foreground,
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
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: dark
                      ? foreground.withValues(alpha: 0.78)
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
