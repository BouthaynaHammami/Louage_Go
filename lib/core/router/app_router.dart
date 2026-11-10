import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_providers.dart';
import '../../features/auth/presentation/screens/auth_gate_screen.dart';
import '../../features/auth/presentation/screens/intro_screen.dart';
import '../../features/auth/presentation/screens/intro_slides_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/otp_arguments.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../widgets/premium_nav_bar.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
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
import '../../features/driver/presentation/screens/driver_home_screen.dart';
import '../../features/driver/presentation/screens/driver_actions_screen.dart';
import '../../features/driver/presentation/screens/driver_pending_screen.dart';
import '../../features/driver/presentation/screens/driver_placeholder_screen.dart';
import '../../features/driver/presentation/screens/driver_profile_screen.dart';
import '../../features/driver/presentation/screens/driver_qr_scanner_screen.dart';
import '../../features/driver/presentation/screens/driver_rating_screen.dart';
import '../../features/driver/presentation/screens/driver_create_trip_screen.dart';
import '../../features/driver/presentation/screens/driver_trip_detail_screen.dart';
import '../../features/driver/presentation/screens/driver_trips_screen.dart';
import '../../l10n/generated/app_localizations.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefreshNotifier();
  ref.listen<AsyncValue<AppUser?>>(currentUserProvider, (previous, next) {
    refresh.refresh();
  });

  // L'intro s'affiche à chaque lancement de l'application.
  final router = GoRouter(
    initialLocation: '/intro',
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
      // ── Intro cinématique ─────────────────────────────────────────────────
      GoRoute(
        path: '/intro',
        name: 'intro',
        pageBuilder: (context, state) => _fadeScaleTransitionPage(
          state: state,
          child: const IntroScreen(),
        ),
      ),
      // ── Slides créatifs (après la vidéo, avant le splash) ─────────────────
      GoRoute(
        path: '/intro-slides',
        name: 'introSlides',
        pageBuilder: (context, state) => _slideTransitionPage(
          state: state,
          child: const IntroSlidesScreen(),
        ),
      ),
      // ── Auth / common ──────────────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        name: 'splash',
        pageBuilder: (context, state) =>
            _slideTransitionPage(state: state, child: const SplashScreen()),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) =>
            _slideTransitionPage(state: state, child: const OnboardingScreen()),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => _slideUpTransitionPage(
          state: state,
          child: const AuthGateScreen(initialPage: 0),
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) => _slideUpTransitionPage(
          state: state,
          child: const AuthGateScreen(initialPage: 1),
        ),
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

      // ── Passenger shell ────────────────────────────────────────────────────
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
              return LouageListScreen(criteria: extra);
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

      // ── Driver shell ───────────────────────────────────────────────────────
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
            builder: (context, state) => const DriverTripsScreen(),
          ),
          GoRoute(
            path: '/driver/trips/new',
            name: 'driverCreateTrip',
            builder: (context, state) => const DriverCreateTripScreen(),
          ),
          GoRoute(
            path: '/driver/trips/:tripId',
            name: 'driverTripDetail',
            builder: (context, state) =>
                DriverTripDetailScreen(tripId: state.pathParameters['tripId']!),
          ),
          GoRoute(
            path: '/driver/scan',
            name: 'driverScan',
            builder: (context, state) => DriverQrScannerScreen(
              initialTripId: state.uri.queryParameters['tripId'],
            ),
          ),
          GoRoute(
            path: '/driver/rating',
            name: 'driverRating',
            builder: (context, state) => const DriverRatingScreen(),
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
            path: '/driver/account',
            name: 'driverAccount',
            builder: (context, state) => ProfileScreen(
              fallbackName: (l10n) => l10n.profileDriverFallback,
            ),
          ),
          GoRoute(
            path: '/driver/reviews',
            name: 'driverReviews',
            builder: (context, state) => const DriverReviewsScreen(),
          ),
          GoRoute(
            path: '/driver/actions',
            name: 'driverActions',
            builder: (context, state) => DriverActionsScreen(
              tripId: state.uri.queryParameters['tripId'],
            ),
          ),
          GoRoute(
            path: '/driver/documents',
            name: 'driverDocuments',
            builder: (context, state) => const DriverPendingScreen(),
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

// ─────────────────────────────────────────────────────────────────────────────
// Redirect logic  (no admin role)
// ─────────────────────────────────────────────────────────────────────────────

String? routeRedirect(String location, AppUser? user) {
  const alwaysAccessible = {'/legal/terms', '/legal/privacy'};
  const publicLocations = {
    '/intro',
    '/intro-slides',
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
  // Intro et intro-slides : toujours accessibles (jamais de redirect)
  if (location == '/intro' || location == '/intro-slides') return null;
  if (location == '/splash') {
    return user == null ? null : _homeForRole(user.role);
  }
  if (user == null) {
    return publicLocations.contains(location) ? null : '/login';
  }

  final home = _homeForRole(user.role);
  if (publicLocations.contains(location)) return home;

  // Passengers cannot access driver routes
  if (user.role == 'passenger' && location.startsWith('/driver/')) {
    return home;
  }
  // Drivers cannot access passenger routes
  if (user.role == 'driver' && location.startsWith('/passenger/')) {
    return home;
  }

  return null;
}

String _homeForRole(String role) =>
    role == 'driver' ? '/driver/home' : '/passenger/home';

// ─────────────────────────────────────────────────────────────────────────────
// Auth transition
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Slide-up transition — pour Login/SignUp (panel qui monte depuis le bas)
// ─────────────────────────────────────────────────────────────────────────────

CustomTransitionPage<void> _slideUpTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 360),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slideIn = Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      );
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: SlideTransition(position: slideIn, child: child),
      );
    },
  );
}

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

// ─────────────────────────────────────────────────────────────────────────────
// Slide transition — navigation avant (gauche→droite style louage sur la route)
// ─────────────────────────────────────────────────────────────────────────────

CustomTransitionPage<void> _slideTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final isRtl = Directionality.of(context) == TextDirection.rtl;

      // Page entrante : glisse depuis la droite (avant)
      final enterSlide = Tween<Offset>(
        begin: Offset(isRtl ? -1.0 : 1.0, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      );

      // Page sortante : légère parallaxe vers la gauche
      final exitSlide = Tween<Offset>(
        begin: Offset.zero,
        end: Offset(isRtl ? 0.25 : -0.25, 0),
      ).animate(
        CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeInCubic,
        ),
      );

      return SlideTransition(
        position: exitSlide,
        child: SlideTransition(
          position: enterSlide,
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
            ),
            child: child,
          ),
        ),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Fade + scale — modals, overlays, écrans de détail
// ─────────────────────────────────────────────────────────────────────────────

CustomTransitionPage<void> _fadeScaleTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.7),
        ),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Router refresh notifier
// ─────────────────────────────────────────────────────────────────────────────

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation destinations
// ─────────────────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────
// Shell widgets
// ─────────────────────────────────────────────────────────────────────────────

class _PassengerShell extends StatelessWidget {
  final GoRouterState state;
  final Widget child;
  const _PassengerShell({required this.state, required this.child});

  @override
  Widget build(BuildContext context) => _BottomNavigationShell(
    destinations: _passengerDestinations(AppLocalizations.of(context)!),
    state: state,
    passenger: true,
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
    passenger: false,
    child: child,
  );
}

class _BottomNavigationShell extends StatelessWidget {
  final GoRouterState state;
  final Widget child;
  final List<_NavDestination> destinations;
  final bool passenger;

  const _BottomNavigationShell({
    required this.state,
    required this.child,
    required this.destinations,
    required this.passenger,
  });

  @override
  Widget build(BuildContext context) {
    final selectedIndex = destinations.indexWhere(
      (d) => d.path == state.uri.path,
    );
    final current = selectedIndex < 0 ? 0 : selectedIndex;

    // Find the centre FAB item index (driver scan = centre, passenger = none)
    final fabIndex = passenger
        ? -1
        : destinations.indexWhere((d) => d.name.contains('Scan') || d.name.contains('scan'));

    final items = destinations.asMap().entries.map((e) {
      final d = e.value;
      return PremiumNavItem(
        icon:         d.icon,
        selectedIcon: d.selectedIcon,
        label:        d.label,
        isFab:        e.key == fabIndex,
      );
    }).toList();

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: PremiumNavBar(
        items:       items,
        currentIndex: current,
        isPassenger: passenger,
        onTap: (i) => context.goNamed(destinations[i].name),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Utility pages
// ─────────────────────────────────────────────────────────────────────────────

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
