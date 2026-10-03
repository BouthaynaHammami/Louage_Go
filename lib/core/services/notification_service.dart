import '../../models/app_notification.dart';
import '../../models/app_user.dart';

typedef PersistRemoteNotification = Future<void> Function({
  required String title,
  required String message,
  required String type,
  required String route,
  required Map<String, dynamic> data,
  required String messageId,
});

abstract interface class NotificationService {
  Stream<String> get routeTaps;

  bool get firebaseAvailable;

  Future<void> init({
    required PersistRemoteNotification persistRemoteNotification,
    required String channelName,
  });

  Future<void> updateChannelName(String name);

  Future<void> syncForUser({
    required AppUser? user,
    required String language,
    required bool enabled,
  });

  Future<bool> requestPermission();

  Future<void> showLocal(AppNotification notification);

  Future<void> openSettings();

  Future<void> dispose();
}

class NotificationRouteAllowlist {
  const NotificationRouteAllowlist._();

  static const _staticRoutes = {
    '/notifications',
    '/passenger/home',
    '/passenger/profile',
    '/passenger/stations',
    '/passenger/trips',
    '/passenger/favorites',
    '/driver/home',
    '/driver/profile',
    '/driver/queue',
    '/driver/earnings',
    '/driver/reviews',
    '/support',
    '/support/faq',
    '/support/contact',
    '/support/requests',
    '/profile/edit',
    '/profile/verify-phone',
    '/settings',
  };

  static final _passengerTrip = RegExp(r'^/passenger/louages/[^/?#]+$');
  static final _supportRequest = RegExp(r'^/support/requests/[^/?#]+$');

  static String? validate(String? route) {
    if (route == null || route.isEmpty || !route.startsWith('/')) return null;
    if (route.contains('://') || route.contains(r'\')) return null;
    if (_staticRoutes.contains(route) ||
        _passengerTrip.hasMatch(route) ||
        _supportRequest.hasMatch(route)) {
      return route;
    }
    return null;
  }
}
