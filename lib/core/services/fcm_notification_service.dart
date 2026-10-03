import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

import '../storage/hive_service.dart';
import '../../firebase_options.dart';
import '../../models/app_notification.dart';
import '../../models/app_user.dart';
import 'notification_service.dart';

typedef FirebaseInitializer = Future<void> Function();
typedef LocalNotificationsInitializer = Future<void> Function();
typedef AndroidChannelInitializer = Future<void> Function(String channelName);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on Object {
    return;
  }
}

class FcmNotificationService
    with WidgetsBindingObserver
    implements NotificationService {
  FcmNotificationService({
    FirebaseInitializer? initializeFirebase,
    this._initializeLocalNotifications,
    this._initializeAndroidChannel,
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _initializeFirebase =
           initializeFirebase ??
           (() async {
             await Firebase.initializeApp(
               options: DefaultFirebaseOptions.currentPlatform,
             );
           }),
       _messagingOverride = messaging,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  final FirebaseInitializer _initializeFirebase;
  final LocalNotificationsInitializer? _initializeLocalNotifications;
  final AndroidChannelInitializer? _initializeAndroidChannel;
  final FirebaseMessaging? _messagingOverride;
  FirebaseMessaging get _messaging =>
      _messagingOverride ?? FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final StreamController<String> _routeTaps =
      StreamController<String>.broadcast();
  final Set<String> _subscribedTopics = {};
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<String>? _tokenSubscription;
  PersistRemoteNotification? _persistRemoteNotification;
  String _channelName = 'LouageGo';
  bool _firebaseReady = false;
  bool _localReady = false;
  bool _foreground = true;
  bool _initialized = false;

  @override
  Stream<String> get routeTaps => _routeTaps.stream;

  @override
  bool get firebaseAvailable => _firebaseReady;

  @override
  Future<void> init({
    required PersistRemoteNotification persistRemoteNotification,
    required String channelName,
  }) async {
    if (_initialized) return;
    _initialized = true;
    _persistRemoteNotification = persistRemoteNotification;
    _channelName = channelName;
    WidgetsBinding.instance.addObserver(this);
    try {
      await (_initializeLocalNotifications?.call() ??
          _initializeLocalPlugin(channelName));
      _localReady = true;
      await (_initializeAndroidChannel?.call(channelName) ??
          _configureAndroidChannel());
    } on MissingPluginException {
      _localReady = false;
    } on PlatformException {
      _localReady = false;
    }

    try {
      await _initializeFirebase();
      _firebaseReady = true;
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      _messageSubscription = FirebaseMessaging.onMessage.listen(
        _receiveForegroundMessage,
      );
      _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
        _openRemoteMessage,
      );
      _tokenSubscription = _messaging.onTokenRefresh.listen(_storeToken);
      await _storeToken(await _messaging.getToken() ?? '');
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) await _openRemoteMessage(initialMessage);
    } on Object {
      _firebaseReady = false;
    }
  }

  Future<void> _initializeLocalPlugin(String channelName) async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      linux: LinuxInitializationSettings(defaultActionName: 'Open'),
      windows: WindowsInitializationSettings(
        appName: 'LouageGo',
        appUserModelId: 'tn.louagego.app.LouageGo',
        guid: '4B6B410E-7D8A-4D8B-B509-6BA4CB7C7221',
      ),
      web: WebInitializationSettings(),
    );
    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final route =
            NotificationRouteAllowlist.validate(response.payload) ??
            '/notifications';
        _routeTaps.add(route);
      },
    );
    _channelName = channelName;
  }

  Future<void> _configureAndroidChannel() async {
    final android = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      AndroidNotificationChannel(
        'louagego_default',
        _channelName,
        description: _channelName,
        importance: Importance.high,
      ),
    );
  }

  @override
  Future<void> updateChannelName(String name) async {
    if (_channelName == name) return;
    _channelName = name;
    if (_localReady) await _configureAndroidChannel();
  }

  @override
  Future<void> syncForUser({
    required AppUser? user,
    required String language,
    required bool enabled,
  }) async {
    if (!_firebaseReady) return;
    final desired = <String>{};
    if (user != null && enabled) {
      desired
        ..add('all')
        ..add(
          'lang_${const {'fr', 'en', 'ar'}.contains(language) ? language : 'fr'}',
        );
      if (user.role == 'passenger' || user.role == 'driver') {
        desired.add('role_${user.role}');
      }
    }
    const knownTopics = {
      'all',
      'role_passenger',
      'role_driver',
      'lang_fr',
      'lang_en',
      'lang_ar',
    };
    for (final topic in knownTopics.difference(desired)) {
      await _messaging.unsubscribeFromTopic(topic);
      _subscribedTopics.remove(topic);
    }
    for (final topic in desired.difference(_subscribedTopics)) {
      await _messaging.subscribeToTopic(topic);
      _subscribedTopics.add(topic);
    }
    if (user == null || !enabled) {
      await _clearStoredToken();
    } else if (_localReady) {
      await _storeToken(await _messaging.getToken() ?? '');
    }
  }

  @override
  Future<bool> requestPermission() async {
    if (!_firebaseReady) {
      if (kIsWeb) return true;
      return switch (defaultTargetPlatform) {
        TargetPlatform.android =>
          await _localNotifications
                  .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin
                  >()
                  ?.requestNotificationsPermission() ??
              false,
        TargetPlatform.iOS =>
          await _localNotifications
                  .resolvePlatformSpecificImplementation<
                    IOSFlutterLocalNotificationsPlugin
                  >()
                  ?.requestPermissions(alert: true, badge: true, sound: true) ??
              false,
        TargetPlatform.macOS =>
          await _localNotifications
                  .resolvePlatformSpecificImplementation<
                    MacOSFlutterLocalNotificationsPlugin
                  >()
                  ?.requestPermissions(alert: true, badge: true, sound: true) ??
              false,
        _ => true,
      };
    }
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<void> showLocal(AppNotification notification) async {
    if (!_localReady || !_foreground) return;
    final route = NotificationRouteAllowlist.validate(notification.route);
    try {
      await _localNotifications.show(
        id: notification.id.hashCode & 0x7fffffff,
        title: notification.title,
        body: notification.message,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'louagego_default',
            _channelName,
            channelDescription: _channelName,
            icon: 'ic_notification',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          macOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          linux: const LinuxNotificationDetails(),
          windows: const WindowsNotificationDetails(),
          web: const WebNotificationDetails(),
        ),
        payload: route,
      );
    } on MissingPluginException {
      _localReady = false;
    } on PlatformException {
      _localReady = false;
    }
  }

  Future<void> _receiveForegroundMessage(RemoteMessage message) async {
    await _persistRemoteMessage(message);
  }

  Future<void> _openRemoteMessage(RemoteMessage message) async {
    await _persistRemoteMessage(message);
    final route =
        NotificationRouteAllowlist.validate(
          message.data['route']?.toString(),
        ) ??
        '/notifications';
    _routeTaps.add(route);
  }

  Future<void> _persistRemoteMessage(RemoteMessage message) async {
    final persist = _persistRemoteNotification;
    if (persist == null) return;
    final data = <String, dynamic>{
      for (final entry in message.data.entries) entry.key: entry.value,
    };
    await persist(
      title: message.notification?.title ?? data['title']?.toString() ?? '',
      message: message.notification?.body ?? data['message']?.toString() ?? '',
      type: data['type']?.toString() ?? 'system',
      route: data['route']?.toString() ?? '',
      data: data,
      messageId: message.messageId ?? '',
    );
  }

  Future<void> _storeToken(String token) async {
    if (token.isEmpty) return;
    try {
      await _writeToken(token);
    } on StateError {
      return;
    }
  }

  Future<void> _writeToken(String token) async {
    await HiveService.session.put('fcmToken', {'value': token});
  }

  Future<void> _clearStoredToken() async {
    try {
      await HiveService.session.delete('fcmToken');
    } on StateError {
      return;
    }
  }

  @override
  Future<void> openSettings() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final android = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.openAppNotificationSettings();
      return;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      await launchUrl(Uri.parse('app-settings:'));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _messageSubscription?.cancel();
    await _openedSubscription?.cancel();
    await _tokenSubscription?.cancel();
    await _routeTaps.close();
  }
}
