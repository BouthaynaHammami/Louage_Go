import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'reminder_scheduler.dart';

/// Implémentation réelle de [ReminderScheduler] via flutter_local_notifications
/// (v22+) et le fuseau Africa/Tunis.
///
/// Doit être initialisée une seule fois (via [init]) avant tout appel à
/// [schedule] — typiquement dans main() après HiveService.init().
class LocalReminderScheduler implements ReminderScheduler {
  LocalReminderScheduler({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  static const _channelId = 'louagego_reminders';
  static const _channelNameDefault = 'Rappels de départ';
  static const _tzName = 'Africa/Tunis';

  /// Initialise le plugin et le fuseau horaire.
  Future<void> init({String channelName = _channelNameDefault}) async {
    try {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(_tzName));
    } on Object catch (e) {
      debugPrint('LocalReminderScheduler: timezone init error: $e');
    }

    try {
      const initSettings = InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      await _plugin.initialize(settings: initSettings);

      // Canal dédié aux rappels (Android 8+).
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            AndroidNotificationChannel(
              _channelId,
              channelName,
              description: channelName,
              importance: Importance.high,
            ),
          );
      _ready = true;
    } on MissingPluginException catch (e) {
      debugPrint('LocalReminderScheduler: plugin unavailable: $e');
    } on PlatformException catch (e) {
      debugPrint('LocalReminderScheduler: platform error: $e');
    }
  }

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
  }) async {
    if (!_ready) return;

    // Ne jamais planifier dans le passé ni dans moins d'une minute.
    final now = DateTime.now().toUtc();
    if (scheduledTime.toUtc().isBefore(now.add(const Duration(minutes: 1)))) {
      return;
    }

    final tzTime = tz.TZDateTime.from(scheduledTime.toUtc(), tz.local);

    try {
      await _scheduleExact(
        id: id,
        title: title,
        body: body,
        tzTime: tzTime,
        payload: payload,
      );
    } on PlatformException catch (e) {
      // Alarme exacte refusée (Android 12+ sans SCHEDULE_EXACT_ALARM) → repli.
      debugPrint('LocalReminderScheduler: exact alarm denied ($e), falling back');
      try {
        await _scheduleInexact(
          id: id,
          title: title,
          body: body,
          tzTime: tzTime,
          payload: payload,
        );
      } on PlatformException catch (e2) {
        debugPrint('LocalReminderScheduler: inexact schedule also failed: $e2');
      }
    } on MissingPluginException catch (e) {
      debugPrint('LocalReminderScheduler: plugin missing on schedule: $e');
    }
  }

  Future<void> _scheduleExact({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime tzTime,
    required String payload,
  }) => _plugin.zonedSchedule(
    id: id,
    title: title,
    body: body,
    scheduledDate: tzTime,
    notificationDetails: _details(),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    payload: payload,
  );

  Future<void> _scheduleInexact({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime tzTime,
    required String payload,
  }) => _plugin.zonedSchedule(
    id: id,
    title: title,
    body: body,
    scheduledDate: tzTime,
    notificationDetails: _details(),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    payload: payload,
  );

  NotificationDetails _details() => const NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelNameDefault,
      channelDescription: _channelNameDefault,
      icon: 'ic_notification',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  @override
  Future<void> cancel(int id) async {
    if (!_ready) return;
    try {
      await _plugin.cancel(id: id);
    } on MissingPluginException {
      // Plugin absent (desktop / web) : ignorer silencieusement.
    } on PlatformException catch (e) {
      debugPrint('LocalReminderScheduler: cancel error: $e');
    }
  }
}
