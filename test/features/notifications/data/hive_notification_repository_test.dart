import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:louage_go/features/notifications/data/hive_notification_repository.dart';
import 'package:louage_go/models/app_notification.dart';

void main() {
  late Directory directory;
  late Box<Map> notifications;
  late HiveNotificationRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('louagego_notifications');
    Hive.init(directory.path);
    notifications = await Hive.openBox<Map>('notifications');
    repository = HiveNotificationRepository(
      notificationsBox: notifications,
      now: () => DateTime(2026, 10, 3, 12),
    );
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('deduplicates received messages by messageId and user', () async {
    final first = await repository.create(
      userId: 'user-1',
      title: 'First title',
      message: 'Trip updated',
      type: 'trip',
      messageId: 'firebase-message-1',
    );
    final duplicate = await repository.create(
      userId: 'user-1',
      title: 'Duplicate title',
      message: 'Trip updated',
      type: 'trip',
      messageId: 'firebase-message-1',
    );

    expect(duplicate.id, first.id);
    expect(notifications.length, 1);
  });

  test('unreadCount reacts to markAllRead and filters by account', () async {
    await repository.create(
      userId: 'user-1',
      title: 'One',
      message: 'A',
      type: 'booking',
    );
    await repository.create(
      userId: 'user-1',
      title: 'Two',
      message: 'B',
      type: 'trip',
    );
    await repository.create(
      userId: 'user-2',
      title: 'Other account',
      message: 'C',
      type: 'system',
    );

    expect(await repository.unreadCount('user-1').first, 2);
    await repository.markAllRead('user-1');
    expect(await repository.unreadCount('user-1').first, 0);
    expect(
      (await repository.watchForUser('user-2').first).single.title,
      'Other account',
    );
  });

  test(
    'markRead, restore and clear only change the selected records',
    () async {
      final notification = await repository.create(
        userId: 'user-1',
        title: 'One',
        message: 'A',
        type: 'system',
      );
      await repository.markRead(notification.id);
      expect(
        AppNotification.fromMap(notifications.get(notification.id)!).isRead,
        isTrue,
      );

      await repository.delete(notification.id);
      await repository.restore(notification);
      await repository.clear('user-1');
      expect(notifications, isEmpty);
    },
  );

  test('legacy notification records default new fields safely', () {
    final notification = AppNotification.fromMap({
      'id': 'legacy',
      'userId': 'user-1',
      'title': 'Old item',
    });

    expect(notification.route, isEmpty);
    expect(notification.data, isEmpty);
    expect(notification.messageId, isEmpty);
  });
}
