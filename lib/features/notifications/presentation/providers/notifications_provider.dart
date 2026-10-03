import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/fcm_notification_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../../models/app_notification.dart';
import '../../data/hive_notification_repository.dart';
import '../../domain/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => HiveNotificationRepository(
    onCreated: (notification) =>
        ref.read(notificationServiceProvider).showLocal(notification),
  ),
);

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = FcmNotificationService();
  ref.onDispose(() => service.dispose());
  return service;
});

final notificationsForUserProvider =
    StreamProvider.family<List<AppNotification>, String>((ref, userId) {
      return ref.watch(notificationRepositoryProvider).watchForUser(userId);
    });

final unreadNotificationCountProvider = StreamProvider.family<int, String>((
  ref,
  userId,
) {
  return ref.watch(notificationRepositoryProvider).unreadCount(userId);
});

final notificationsEnabledProvider =
    NotifierProvider<NotificationsEnabledNotifier, bool>(
      NotificationsEnabledNotifier.new,
    );

class NotificationsEnabledNotifier extends Notifier<bool> {
  @override
  bool build() {
    try {
      final stored = HiveService.session.get('notificationsEnabled');
      final value = stored is Map ? stored['value'] : stored;
      return value is bool ? value : false;
    } on StateError {
      return false;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    try {
      await HiveService.session.put('notificationsEnabled', {'value': enabled});
    } on StateError {
      return;
    }
  }
}
