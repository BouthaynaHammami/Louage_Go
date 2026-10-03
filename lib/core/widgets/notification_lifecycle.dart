import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_providers.dart';
import '../../features/notifications/presentation/providers/notifications_provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/app_user.dart';
import '../theme/app_preferences.dart';

class NotificationLifecycle extends ConsumerStatefulWidget {
  const NotificationLifecycle({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<NotificationLifecycle> createState() =>
      _NotificationLifecycleState();
}

class _NotificationLifecycleState extends ConsumerState<NotificationLifecycle> {
  late final service = ref.read(notificationServiceProvider);
  StreamSubscription<String>? _routeSubscription;
  bool _started = false;
  bool _hasUser = false;
  AppUser? _user;

  @override
  void initState() {
    super.initState();
    _routeSubscription = service.routeTaps.listen((route) {
      if (mounted) context.go(route);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final channelName =
        AppLocalizations.of(context)?.notificationsChannelName ?? 'LouageGo';
    unawaited(_initialize(channelName));
  }

  Future<void> _initialize(String channelName) async {
    try {
      await service.init(
        persistRemoteNotification: _persistRemoteNotification,
        channelName: channelName,
      );
      if (!mounted) return;
      final user = await ref.read(currentUserProvider.future);
      _hasUser = true;
      _user = user;
      await _sync();
    } on Object {
      // Push setup is optional and must not interfere with app startup.
    }
  }

  Future<void> _persistRemoteNotification({
    required String title,
    required String message,
    required String type,
    required String route,
    required Map<String, dynamic> data,
    required String messageId,
  }) async {
    final user = await ref.read(currentUserProvider.future);
    if (user == null) return;
    await ref
        .read(notificationRepositoryProvider)
        .create(
          userId: user.id,
          title: title,
          message: message,
          type: type,
          route: route,
          data: data,
          messageId: messageId,
        );
  }

  Future<void> _sync() async {
    if (!_hasUser) return;
    try {
      final channelName = AppLocalizations.of(context)
          ?.notificationsChannelName;
      if (channelName != null) await service.updateChannelName(channelName);
      await service.syncForUser(
        user: _user,
        language: ref.read(localeProvider).languageCode,
        enabled: ref.read(notificationsEnabledProvider),
      );
    } on Object {
      // A messaging service failure leaves local notifications available.
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentUserProvider, (previous, next) {
      next.whenData((user) {
        _hasUser = true;
        _user = user;
        unawaited(_sync());
      });
    });
    ref.listen(localeProvider, (previous, next) => unawaited(_sync()));
    ref.listen(
      notificationsEnabledProvider,
      (previous, next) => unawaited(_sync()),
    );
    return widget.child;
  }

  @override
  void dispose() {
    _routeSubscription?.cancel();
    super.dispose();
  }
}
