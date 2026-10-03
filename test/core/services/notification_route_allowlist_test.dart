import 'package:flutter_test/flutter_test.dart';
import 'package:louage_go/core/services/notification_service.dart';

void main() {
  test('allows known notification destinations only', () {
    expect(
      NotificationRouteAllowlist.validate('/notifications'),
      '/notifications',
    );
    expect(
      NotificationRouteAllowlist.validate('/passenger/louages/trip-12'),
      '/passenger/louages/trip-12',
    );
    expect(
      NotificationRouteAllowlist.validate('/support/requests/request-2'),
      '/support/requests/request-2',
    );
    expect(NotificationRouteAllowlist.validate('/admin/users'), isNull);
    expect(
      NotificationRouteAllowlist.validate('https://malicious.example'),
      isNull,
    );
    expect(NotificationRouteAllowlist.validate('//external'), isNull);
    expect(NotificationRouteAllowlist.validate('/notifications?x=1'), isNull);
  });
}
