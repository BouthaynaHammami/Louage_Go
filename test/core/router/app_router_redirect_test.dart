import 'package:flutter_test/flutter_test.dart';
import 'package:louage_go/core/router/app_router.dart';
import 'package:louage_go/models/app_user.dart';

void main() {
  test('legal routes stay accessible when signed in or signed out', () {
    const legalRoutes = ['/legal/terms', '/legal/privacy'];

    for (final route in legalRoutes) {
      expect(routeRedirect(route, null), isNull);
      expect(
        routeRedirect(route, const AppUser(id: 'user', role: 'passenger')),
        isNull,
      );
    }
  });

  test('support hub, FAQ and contact are public for every account role', () {
    for (final route in ['/support', '/support/faq', '/support/contact']) {
      expect(routeRedirect(route, null), isNull);
      for (final role in ['passenger', 'driver', 'admin']) {
        expect(routeRedirect(route, AppUser(id: 'user', role: role)), isNull);
      }
    }
  });

  test('support requests require sign-in but work for all account roles', () {
    expect(routeRedirect('/support/requests', null), '/login');
    for (final role in ['passenger', 'driver', 'admin']) {
      expect(
        routeRedirect('/support/requests', AppUser(id: 'user', role: role)),
        isNull,
      );
    }
  });

  test(
    'notifications are authenticated and available to every signed-in role',
    () {
      expect(routeRedirect('/notifications', null), '/login');
      for (final role in ['passenger', 'driver', 'admin']) {
        expect(
          routeRedirect('/notifications', AppUser(id: 'user', role: role)),
          isNull,
        );
      }
    },
  );

  test('review routes are restricted to the appropriate role', () {
    expect(
      routeRedirect(
        '/passenger/rate/trip-1',
        const AppUser(id: 'passenger', role: 'passenger'),
      ),
      isNull,
    );
    expect(
      routeRedirect(
        '/passenger/rate/trip-1',
        const AppUser(id: 'driver', role: 'driver'),
      ),
      '/driver/home',
    );
    expect(
      routeRedirect(
        '/driver/reviews',
        const AppUser(id: 'driver', role: 'driver'),
      ),
      isNull,
    );
    expect(
      routeRedirect(
        '/driver/reviews',
        const AppUser(id: 'passenger', role: 'passenger'),
      ),
      '/passenger/home',
    );
    expect(
      routeRedirect(
        '/drivers/driver-1/reviews',
        const AppUser(id: 'passenger', role: 'passenger'),
      ),
      isNull,
    );
  });
}
