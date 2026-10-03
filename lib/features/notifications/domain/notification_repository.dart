import '../../../../models/app_notification.dart';

abstract interface class NotificationRepository {
  Future<AppNotification> create({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? route,
    Map<String, dynamic> data = const {},
    String messageId = '',
  });

  Stream<List<AppNotification>> watchForUser(String userId);

  Stream<int> unreadCount(String userId);

  Future<void> markRead(String notificationId);

  Future<void> markAllRead(String userId);

  Future<void> delete(String notificationId);

  Future<void> restore(AppNotification notification);

  Future<void> clear(String userId);
}
