import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/hive_service.dart';
import '../../../models/app_notification.dart';
import '../domain/notification_repository.dart';

class HiveNotificationRepository implements NotificationRepository {
  HiveNotificationRepository({
    Box<Map>? notificationsBox,
    DateTime Function()? now,
    this._onCreated,
  }) : _box = notificationsBox ?? HiveService.notifications,
       _now = now ?? DateTime.now;

  static const _uuid = Uuid();

  final Box<Map> _box;
  final DateTime Function() _now;
  final Future<void> Function(AppNotification notification)? _onCreated;

  @override
  Future<AppNotification> create({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? route,
    Map<String, dynamic> data = const {},
    String messageId = '',
  }) async {
    if (messageId.isNotEmpty) {
      for (final value in _box.values) {
        final existing = AppNotification.fromMap(value);
        if (existing.userId == userId && existing.messageId == messageId) {
          return existing;
        }
      }
    }

    final notification = AppNotification(
      id: 'notification_${_uuid.v4()}',
      userId: userId,
      title: title,
      message: message,
      type: type,
      createdAt: _now().toIso8601String(),
      route: route ?? '',
      data: data,
      messageId: messageId,
    );
    await _box.put(notification.id, notification.toMap());
    await _onCreated?.call(notification);
    return notification;
  }

  @override
  Stream<List<AppNotification>> watchForUser(String userId) async* {
    List<AppNotification> current() =>
        _box.values
            .map(AppNotification.fromMap)
            .where((notification) => notification.userId == userId)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    yield current();
    await for (final _ in _box.watch()) {
      yield current();
    }
  }

  @override
  Stream<int> unreadCount(String userId) =>
      watchForUser(userId)
          .map((items) => items.where((item) => !item.isRead).length);

  @override
  Future<void> markRead(String notificationId) async {
    final map = _box.get(notificationId);
    if (map == null) return;
    final notification = AppNotification.fromMap(map);
    await _box.put(notificationId, notification.copyWith(isRead: true).toMap());
  }

  @override
  Future<void> markAllRead(String userId) async {
    for (final entry in _box.toMap().entries) {
      final notification = AppNotification.fromMap(entry.value);
      if (notification.userId == userId && !notification.isRead) {
        await _box.put(entry.key, notification.copyWith(isRead: true).toMap());
      }
    }
  }

  @override
  Future<void> delete(String notificationId) => _box.delete(notificationId);

  @override
  Future<void> restore(AppNotification notification) =>
      _box.put(notification.id, notification.toMap());

  @override
  Future<void> clear(String userId) async {
    for (final entry in _box.toMap().entries) {
      if (AppNotification.fromMap(entry.value).userId == userId) {
        await _box.delete(entry.key);
      }
    }
  }
}
