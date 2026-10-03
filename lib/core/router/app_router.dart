import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_providers.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/otp_arguments.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/legal/domain/legal_document.dart';
import '../../features/legal/presentation/legal_document_screen.dart';
import '../../features/support/presentation/screens/support_home_screen.dart';
import '../../features/support/presentation/screens/support_faq_screen.dart';
import '../../features/support/presentation/screens/support_contact_screen.dart';
import '../../features/support/presentation/screens/support_requests_screen.dart';
import '../../features/support/presentation/screens/support_request_detail_screen.dart';
import '../../features/reviews/presentation/screens/driver_reviews_screen.dart';
import '../../features/reviews/presentation/screens/rate_trip_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/search/domain/trip_search_criteria.dart';
import '../../features/search/presentation/screens/louage_detail_screen.dart';
import '../../features/booking/presentation/screens/booking_flow_screen.dart';
import '../../features/booking/presentation/screens/booking_history_screen.dart';
import '../../features/search/presentation/screens/louage_list_screen.dart';
import '../../features/search/presentation/screens/passenger_home_screen.dart';
import '../../features/search/presentation/screens/stations_screen.dart';
import '../../features/search/presentation/screens/stations_map_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/users/presentation/screens/passenger_profile_screen.dart';
import '../../models/app_user.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/driver/presentation/screens/driver_home_screen.dart';
import '../../features/driver/presentation/screens/driver_placeholder_screen.dart';
import '../../features/driver/presentation/screens/driver_profile_screen.dart';
import '../../l10n/generated/app_localizations.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefreshNotifier();
  ref.listen<AsyncValue<AppUser?>>(currentUserProvider, (previous, next) {
    refresh.refresh();
  });

  final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) async {
      AppUser? user;
      final authState = ref.read(authControllerProvider);
      if (authState is AsyncData<AppUser?>) {
        user = authState.value;
      } else {
        try {
          user = await ref.read(currentUserProvider.future);
        } catch (_) {
          user = null;
        }
      }

      return routeRedirect(state.matchedLocation, user);
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) =>
            _authTransitionPage(state: state, child: const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) =>
            _authTransitionPage(state: state, child: const RegisterScreen()),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'profileEdit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) {
          final extra = state.extra;
          return OtpScreen(arguments: extra is OtpArguments ? extra : null);
        },
      ),
      GoRoute(
        path: '/profile/verify-phone',
        name: 'profileVerifyPhone',
        builder: (context, state) {
          final extra = state.extra;
          return OtpScreen(arguments: extra is OtpArguments ? extra : null);
        },
      ),
      GoRoute(
        path: '/legal/terms',
        name: 'legalTerms',
        builder: (context, state) =>
            const LegalDocumentScreen(document: LegalDocumentType.terms),
      ),
      GoRoute(
        path: '/legal/privacy',
        name: 'legalPrivacy',
        builder: (context, state) =>
            const LegalDocumentScreen(document: LegalDocumentType.privacy),
      ),
      GoRoute(
        path: '/support',
        name: 'supportHome',
        builder: (context, state) => const SupportHomeScreen(),
      ),
      GoRoute(
        path: '/support/faq',
        name: 'supportFaq',
        builder: (context, state) => const SupportFaqScreen(),
      ),
      GoRoute(
        path: '/support/contact',
        name: 'supportContact',
        builder: (context, state) => const SupportContactScreen(),
      ),
      GoRoute(
        path: '/support/requests',
        name: 'supportRequests',
        builder: (context, state) => const SupportRequestsScreen(),
      ),
      GoRoute(
        path: '/support/requests/:requestId',
        name: 'supportRequestDetail',
        builder: (context, state) => SupportRequestDetailScreen(
          requestId: state.pathParameters['requestId']!,
        ),
      ),
      GoRoute(
        path: '/drivers/:driverId/reviews',
        name: 'driverReviewsForDriver',
        builder: (context, state) =>
            DriverReviewsScreen(driverId: state.pathParameters['driverId']!),
      ),
      GoRoute(
        path: '/help/faq',
        name: 'helpFaq',
        redirect: (context, state) => '/support/faq',
      ),
      ShellRoute(
        builder: (context, state, child) =>
            _PassengerShell(state: state, child: child),
        routes: [
          GoRoute(
            path: '/passenger/home',
            name: 'passengerHome',
            builder: (context, state) => PassengerHomeScreen(
              initialFromStationId: state.uri.queryParameters['fromStationId'],
            ),
          ),
          GoRoute(
            path: '/passenger/stations',
            name: 'passengerStations',
            builder: (context, state) => const StationsScreen(),
          ),
          GoRoute(
            path: '/passenger/stations/map',
            name: 'passengerStationsMap',
            builder: (context, state) => StationsMapScreen(
              stationId: state.uri.queryParameters['stationId'],
            ),
          ),
          GoRoute(
            path: '/passenger/search-results',
            name: 'passengerSearchResults',
            builder: (context, state) {
              final extra = state.extra;
              if (extra is! TripSearchCriteria) {
                return _SimplePage(
                  title: AppLocalizations.of(context)!.searchPageNotFound,
                  icon: Icons.search_off,
                );
              }
              final criteria = extra;
              return LouageListScreen(criteria: criteria);
            },
          ),
          GoRoute(
            path: '/passenger/louages/:tripId',
            name: 'passengerLouageDetail',
            builder: (context, state) =>
                LouageDetailScreen(tripId: state.pathParameters['tripId']!),
          ),
          GoRoute(
            path: '/passenger/book/:tripId',
            name: 'passengerBook',
            builder: (context, state) =>
                BookingFlowScreen(tripId: state.pathParameters['tripId']!),
          ),
          GoRoute(
            path: '/passenger/rate/:tripId',
            name: 'passengerRateTrip',
            builder: (context, state) =>
                RateTripScreen(tripId: state.pathParameters['tripId']!),
          ),
          GoRoute(
            path: '/passenger/trips',
            name: 'passengerTrips',
            builder: (context, state) => const BookingHistoryScreen(),
          ),
          GoRoute(
            path: '/passenger/favorites',
            name: 'passengerFavorites',
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: '/passenger/profile',
            name: 'passengerProfile',
            builder: (context, state) => const PassengerProfileScreen(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) =>
            _DriverShell(state: state, child: child),
        routes: [
          GoRoute(
            path: '/driver/home',
            name: 'driverHome',
            builder: (context, state) => const DriverHomeScreen(),
          ),
          GoRoute(
            path: '/driver/queue',
            name: 'driverQueue',
            builder: (context, state) => DriverPlaceholderScreen(
              title: AppLocalizations.of(context)!.driverQueueTitle,
              icon: Icons.format_list_numbered,
            ),
          ),
          GoRoute(
            path: '/driver/scan',
            name: 'driverScan',
            builder: (context, state) => DriverPlaceholderScreen(
              title: AppLocalizations.of(context)!.driverScanTitle,
              icon: Icons.qr_code_scanner,
            ),
          ),
          GoRoute(
            path: '/driver/earnings',
            name: 'driverEarnings',
            builder: (context, state) => DriverPlaceholderScreen(
              title: AppLocalizations.of(context)!.driverEarningsTitle,
              icon: Icons.payments_outlined,
            ),
          ),
          GoRoute(
            path: '/driver/profile',
            name: 'driverProfile',
            builder: (context, state) => const DriverProfileScreen(),
          ),
          GoRoute(
            path: '/driver/reviews',
            name: 'driverReviews',
            builder: (context, state) => const DriverReviewsScreen(),
          ),
          GoRoute(
            path: '/driver/documents',
            name: 'driverDocuments',
            builder: (context, state) => DriverPlaceholderScreen(
              title: AppLocalizations.of(context)!.driverDocumentsTitle,
              icon: Icons.upload_file_outlined,
            ),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) =>
            _AdminShell(state: state, child: child),
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            name: 'adminDashboard',
            builder: (context, state) => _AdminPage(
              title: AppLocalizations.of(context)!.adminNavDashboard,
            ),
          ),
          GoRoute(
            path: '/admin/stations',
            name: 'adminStations',
            builder: (context, state) => _AdminPage(
              title: AppLocalizations.of(context)!.adminNavStations,
            ),
          ),
          GoRoute(
            path: '/admin/drivers',
            name: 'adminDrivers',
            builder: (context, state) => _AdminPage(
              title: AppLocalizations.of(context)!.adminNavDrivers,
            ),
          ),
          GoRoute(
            path: '/admin/users',
            name: 'adminUsers',
            builder: (context, state) =>
                _AdminPage(title: AppLocalizations.of(context)!.adminNavUsers),
          ),
          GoRoute(
            path: '/admin/reports',
            name: 'adminReports',
            builder: (context, state) => _AdminPage(
              title: AppLocalizations.of(context)!.adminNavReports,
            ),
          ),
          GoRoute(
            path: '/admin/notifications',
            name: 'adminNotifications',
            builder: (context, state) => _AdminPage(
              title: AppLocalizations.of(context)!.adminNavNotifications,
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const _NotFoundPage(),
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });

  return router;
});

String? routeRedirect(String location, AppUser? user) {
  const alwaysAccessible = {'/legal/terms', '/legal/privacy'};
  const publicLocations = {
    '/splash',
    '/onboarding',
    '/login',
    '/register',
    '/otp',
  };
  const publicHelpLocations = {
    '/help/faq',
    '/support',
    '/support/faq',
    '/support/contact',
  };
  if (alwaysAccessible.contains(location) ||
      publicHelpLocations.contains(location)) {
    return null;
  }
  if (location == '/splash') {
    return user == null ? null : _homeForRole(user.role);
  }
  if (user == null) {
    return publicLocations.contains(location) ? null : '/login';
  }

  final home = _homeForRole(user.role);
  if (publicLocations.contains(location)) return home;
  if (user.role == 'passenger' &&
      (location.startsWith('/driver/') || location.startsWith('/admin/'))) {
    return home;
  }
  if (user.role == 'driver' &&
      (location.startsWith('/passenger/') || location.startsWith('/admin/'))) {
    return home;
  }
  if (user.role == 'admin' &&
      (location.startsWith('/passenger/') || location.startsWith('/driver/'))) {
    return home;
  }
  return null;
}

String _homeForRole(String role) => switch (role) {
  'driver' => '/driver/home',
  'admin' => '/admin/dashboard',
  _ => '/passenger/home',
};

CustomTransitionPage<void> _authTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final isRtl = Directionality.of(context) == TextDirection.rtl;
      final progress = animation.drive(CurveTween(curve: Curves.easeOutCubic));
      final slide = Tween<Offset>(
        begin: Offset(isRtl ? -0.035 : 0.035, 0),
        end: Offset.zero,
      ).animate(progress);
      return FadeTransition(
        opacity: progress,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

class _NavDestination {
  final String name;
  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _NavDestination({
    required this.name,
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

List<_NavDestination> _passengerDestinations(AppLocalizations l10n) => [
  _NavDestination(
    name: 'passengerHome',
    path: '/passenger/home',
    label: l10n.passengerNavHome,
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  _NavDestination(
    name: 'passengerTrips',
    path: '/passenger/trips',
    label: l10n.passengerNavTrips,
    icon: Icons.luggage_outlined,
    selectedIcon: Icons.luggage,
  ),
  _NavDestination(
    name: 'passengerFavorites',
    path: '/passenger/favorites',
    label: l10n.passengerNavFavorites,
    icon: Icons.favorite_border,
    selectedIcon: Icons.favorite,
  ),
  _NavDestination(
    name: 'passengerProfile',
    path: '/passenger/profile',
    label: l10n.passengerNavProfile,
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
  ),
];

List<_NavDestination> _driverDestinations(AppLocalizations l10n) => [
  _NavDestination(
    name: 'driverHome',
    path: '/driver/home',
    label: l10n.driverNavHome,
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  _NavDestination(
    name: 'driverQueue',
    path: '/driver/queue',
    label: l10n.driverNavQueue,
    icon: Icons.format_list_numbered,
    selectedIcon: Icons.format_list_numbered,
  ),
  _NavDestination(
    name: 'driverScan',
    path: '/driver/scan',
    label: l10n.driverNavScan,
    icon: Icons.qr_code_scanner_outlined,
    selectedIcon: Icons.qr_code_scanner,
  ),
  _NavDestination(
    name: 'driverEarnings',
    path: '/driver/earnings',
    label: l10n.driverNavEarnings,
    icon: Icons.payments_outlined,
    selectedIcon: Icons.payments,
  ),
  _NavDestination(
    name: 'driverProfile',
    path: '/driver/profile',
    label: l10n.driverNavProfile,
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
  ),
];

List<_NavDestination> _adminDestinations(AppLocalizations l10n) => [
  _NavDestination(
    name: 'adminDashboard',
    path: '/admin/dashboard',
    label: l10n.adminNavDashboard,
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
  ),
  _NavDestination(
    name: 'adminStations',
    path: '/admin/stations',
    label: l10n.adminNavStations,
    icon: Icons.location_on_outlined,
    selectedIcon: Icons.location_on,
  ),
  _NavDestination(
    name: 'adminDrivers',
    path: '/admin/drivers',
    label: l10n.adminNavDrivers,
    icon: Icons.badge_outlined,
    selectedIcon: Icons.badge,
  ),
  _NavDestination(
    name: 'adminUsers',
    path: '/admin/users',
    label: l10n.adminNavUsers,
    icon: Icons.people_outline,
    selectedIcon: Icons.people,
  ),
  _NavDestination(
    name: 'adminReports',
    path: '/admin/reports',
    label: l10n.adminNavReports,
    icon: Icons.flag_outlined,
    selectedIcon: Icons.flag,
  ),
  _NavDestination(
    name: 'adminNotifications',
    path: '/admin/notifications',
    label: l10n.adminNavNotifications,
    icon: Icons.notifications_outlined,
    selectedIcon: Icons.notifications,
  ),
];

class _PassengerShell extends StatelessWidget {
  final GoRouterState state;
  final Widget child;

  const _PassengerShell({required this.state, required this.child});

  @override
  Widget build(BuildContext context) => _BottomNavigationShell(
    destinations: _passengerDestinations(AppLocalizations.of(context)!),
    state: state,
    child: child,
  );
}

class _DriverShell extends StatelessWidget {
  final GoRouterState state;
  final Widget child;

  const _DriverShell({required this.state, required this.child});

  @override
  Widget build(BuildContext context) => _BottomNavigationShell(
    destinations: _driverDestinations(AppLocalizations.of(context)!),
    state: state,
    child: child,
  );
}

class _BottomNavigationShell extends StatelessWidget {
  final GoRouterState state;
  final Widget child;
  final List<_NavDestination> destinations;

  const _BottomNavigationShell({
    required this.state,
    required this.child,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedIndex = destinations.indexWhere(
      (destination) => destination.path == state.uri.path,
    );
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: colorScheme.secondary,
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? colorScheme.onSecondary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          labelTextStyle: WidgetStatePropertyAll(
            Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: colorScheme.onSurface),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) =>
              context.goNamed(destinations[index].name),
          destinations: [
            for (final destination in destinations)
              NavigationDestination(
                icon: Icon(destination.icon),
                selectedIcon: Icon(destination.selectedIcon),
                label: destination.label,
              ),
          ],
        ),
      ),
    );
  }
}

class _AdminShell extends StatelessWidget {
  final GoRouterState state;
  final Widget child;

  const _AdminShell({required this.state, required this.child});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final destinations = _adminDestinations(l10n);
    final selectedIndex = destinations.indexWhere(
      (destination) => destination.path == state.uri.path,
    );
    final selected = selectedIndex < 0 ? 0 : selectedIndex;
    final isWide = MediaQuery.sizeOf(context).width > 800;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selected,
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: (index) =>
                  context.goNamed(destinations[index].name),
              trailing: IconButton(
                tooltip: l10n.settingsTitle,
                onPressed: () => context.pushNamed('settings'),
                icon: const Icon(Icons.settings_outlined),
              ),
              destinations: [
                for (final destination in destinations)
                  NavigationRailDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: Text(destination.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(destinations[selected].label)),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsetsDirectional.zero,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 12),
                child: Text(
                  l10n.adminMenuTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              for (var index = 0; index < destinations.length; index++)
                ListTile(
                  selected: selected == index,
                  leading: Icon(destinations[index].icon),
                  title: Text(destinations[index].label),
                  onTap: () {
                    Navigator.pop(context);
                    context.goNamed(destinations[index].name);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: Text(l10n.settingsTitle),
                onTap: () {
                  Navigator.pop(context);
                  context.pushNamed('settings');
                },
              ),
            ],
          ),
        ),
      ),
      body: child,
    );
  }
}

class _SimplePage extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SimplePage({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    ),
  );
}

class _AdminPage extends StatelessWidget {
  final String title;

  const _AdminPage({required this.title});

  @override
  Widget build(BuildContext context) => Center(
    child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
  );
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48),
            const SizedBox(height: 12),
            Text(
              l10n.pageNotFound,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
