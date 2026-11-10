import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../features/favorites/presentation/providers/favorites_provider.dart';
import '../../../../features/notifications/presentation/providers/notifications_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/route_line.dart';
import '../../../../models/station.dart';
import '../../domain/trip_search_criteria.dart';
import '../providers/trip_search_results_provider.dart';
import 'stations_screen.dart';
import '../widgets/search_card.dart';
import '../widgets/nearest_station_card.dart';

// ─── Palette ──────────────────────────────────────────────────────────────
const _kRed    = Color(0xFFD71935);
const _kRedBg  = Color(0xFFFFF0F2);

// ═══════════════════════════════════════════════════════════════════════════
class PassengerHomeScreen extends ConsumerStatefulWidget {
  const PassengerHomeScreen({super.key, this.initialFromStationId});
  final String? initialFromStationId;

  @override
  ConsumerState<PassengerHomeScreen> createState() =>
      _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends ConsumerState<PassengerHomeScreen>
    with TickerProviderStateMixin {
  // ── Search form state ─────────────────────────────────────────────────
  String? _from;
  String? _to;
  Station? _fromStation;
  Station? _toStation;
  bool _showLocationError = false;
  bool _isSearching       = false;
  DateTime  _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

  late final AnimationController _swapController;
  late final Animation<double>   _swapTurns;

  // ── Sidebar state ─────────────────────────────────────────────────────
  bool _sidebarOpen = false;
  late final AnimationController _sideCtrl;
  late final Animation<double>   _sideSlide;
  late final Animation<double>   _sideFade;
  late final Animation<double>   _sideScale;

  @override
  void initState() {
    super.initState();

    if (widget.initialFromStationId != null) {
      _fromStation = ref
          .read(searchRepositoryProvider)
          .getStation(widget.initialFromStationId!);
      _from = _fromStation?.city;
    }

    _swapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _swapTurns = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _swapController, curve: Curves.easeInOut),
    );

    _sideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _sideSlide = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _sideCtrl, curve: Curves.easeOutCubic),
    );
    _sideFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sideCtrl, curve: const Interval(0.0, 0.6)),
    );
    _sideScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _sideCtrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(covariant PassengerHomeScreen old) {
    super.didUpdateWidget(old);
    if (old.initialFromStationId != widget.initialFromStationId) {
      _fromStation = widget.initialFromStationId == null
          ? null
          : ref.read(searchRepositoryProvider)
                .getStation(widget.initialFromStationId!);
      _from = _fromStation?.city;
      _toStation = null;
      _to = null;
    }
  }

  @override
  void dispose() {
    _swapController.dispose();
    _sideCtrl.dispose();
    super.dispose();
  }

  // ── Sidebar ───────────────────────────────────────────────────────────
  void _openSidebar() {
    setState(() => _sidebarOpen = true);
    _sideCtrl.forward();
  }

  void _closeSidebar() {
    _sideCtrl.reverse().then((_) {
      if (mounted) setState(() => _sidebarOpen = false);
    });
  }

  // ── Search logic ──────────────────────────────────────────────────────
  Future<void> _pickCity({required bool isFrom}) async {
    final station = await showStationPicker(
      context,
      title: AppLocalizations.of(context)!.searchCityPickerTitle,
    );
    if (station == null || !mounted) return;
    setState(() {
      if (isFrom) { _fromStation = station; _from = station.city; }
      else        { _toStation   = station; _to   = station.city; }
      if (_from != null && _to != null) _showLocationError = false;
    });
  }

  Future<void> _pickDate() async {
    final s = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 6)),
    );
    if (s != null && mounted) setState(() => _date = s);
  }

  Future<void> _pickTime() async {
    final s = await showTimePicker(context: context, initialTime: _time);
    if (s != null && mounted) setState(() => _time = s);
  }

  void _swapCities() {
    setState(() {
      final f = _from; final fs = _fromStation;
      _from = _to; _fromStation = _toStation;
      _to = f;     _toStation   = fs;
      if (_from != null && _to != null) _showLocationError = false;
    });
    _swapController.forward(from: 0);
  }

  Future<void> _search() async {
    final l10n = AppLocalizations.of(context)!;
    if (_from == null || _to == null) {
      setState(() => _showLocationError = true);
      _snack(l10n.searchChooseBothCities);
      return;
    }
    if ((_fromStation != null && _toStation != null &&
         _fromStation!.id == _toStation!.id) ||
        (_fromStation == null && _toStation == null && _from == _to)) {
      _snack(l10n.searchCitiesMustDiffer);
      return;
    }
    setState(() => _isSearching = true);
    try {
      await ref.read(searchRepositoryProvider).rememberSearch(_from!, _to!);
      if (!mounted) return;
      context.pushNamed('passengerSearchResults',
        extra: TripSearchCriteria(
          from: _from!, to: _to!, date: _date, time: _time,
          fromStationId: _fromStation?.id, toStationId: _toStation?.id,
        ));
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _snack(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  void _selectRoute(String from, String to) =>
      setState(() { _from = from; _to = to; _fromStation = null; _toStation = null; });

  TimeOfDay _favoriteTime(String v) {
    final p = v.split(':');
    return TimeOfDay(hour: int.tryParse(p.first) ?? 0,
        minute: p.length > 1 ? int.tryParse(p[1]) ?? 0 : 0);
  }

  // ── Build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      loading: () => _buildLoading(),
      error: (_, __) => Scaffold(
        body: EmptyState(icon: Icons.error_outline, title: l10n.searchLoadError)),
      data: (user) {
        final dataAsync = ref.watch(passengerHomeDataProvider(user?.id));
        final firstName = user?.name.trim().split(RegExp(r'\s+')).firstOrNull;
        return dataAsync.when(
          loading: () => _buildLoading(),
          error: (_, __) => Scaffold(
            body: EmptyState(icon: Icons.error_outline, title: l10n.searchLoadError)),
          data: (data) => _buildPage(l10n, data, firstName, user?.id),
        );
      },
    );
  }

  // ── Skeleton ──────────────────────────────────────────────────────────
  Widget _buildLoading() => Scaffold(
    backgroundColor: _kRedBg,
    body: ListView(padding: EdgeInsets.zero, children: const [
      SkeletonBox(height: 220), SizedBox(height: 20),
      Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: SkeletonBox(height: 280)),
      SizedBox(height: 20),
      Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: SkeletonBox(height: 140)),
    ]),
  );

  // ── Main page ─────────────────────────────────────────────────────────
  Widget _buildPage(AppLocalizations l10n, PassengerHomeData data,
      String? firstName, String? userId) {
    final cs      = Theme.of(context).colorScheme;
    final isDark  = cs.brightness == Brightness.dark;
    final topPad  = MediaQuery.viewPaddingOf(context).top;
    final screenW = MediaQuery.sizeOf(context).width;
    final screenH = MediaQuery.sizeOf(context).height;

    final stations    = data.stations;
    final stationById = {for (final s in stations) s.id: s};
    final routes      = data.routes;
    final lastTrips   = data.recentTrips;
    final favorites   = userId == null
        ? null : ref.watch(favoritesProvider(userId)).asData?.value;
    final unread      = userId == null
        ? 0 : ref.watch(unreadNotificationCountProvider(userId)).asData?.value ?? 0;

    final hPad = (screenW * 0.04).clamp(16.0, 24.0);

    // Image ratio 16:9 → height from width
    const ratio  = 16.0 / 9.0;
    final imageH = screenW / ratio;

    final greeting = l10n.greetingPassenger(
      firstName?.isEmpty ?? true ? l10n.profilePassengerFallback : firstName!);

    return Stack(
      children: [
        // ── Main scaffold ────────────────────────────────────────────────
        Scaffold(
          backgroundColor: isDark ? cs.surface : _kRedBg,
          body: CustomScrollView(
            slivers: [

              // ── Hero banner ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: _HeroBanner(
                  greeting: greeting,
                  subtitle: l10n.searchPrompt,
                  unreadCount: unread,
                  topPad: topPad,
                  screenW: screenW,
                  imageH: imageH,
                  isDark: isDark,
                  bgColor: isDark ? const Color(0xFF10111A) : _kRedBg,
                  onNotifications: () => context.pushNamed('notifications'),
                  onProfile:       () => context.goNamed('passengerProfile'),
                  onMenu:          _openSidebar,
                ),
              ),

              // ── Content ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      // Search card
                      _CardShell(isDark: isDark,
                        child: _buildSearchCard()),

                      const SizedBox(height: 28),

                      // Recent trips
                      if (lastTrips.isNotEmpty) ...[
                        _SectionTitle(title: l10n.searchLastTrips),
                        const SizedBox(height: 12),
                        _buildRouteChips(lastTrips, stations),
                        const SizedBox(height: 28),
                      ],

                      // Favorite routes
                      if (favorites != null && favorites.routes.isNotEmpty) ...[
                        _SectionTitle(title: l10n.searchFavorites),
                        const SizedBox(height: 12),
                        _buildRouteChips(
                          favorites.routes.map((f) => SearchRouteShortcut(
                              from: f.from, to: f.to, isFavorite: true))
                              .toList(growable: false),
                          stations),
                        const SizedBox(height: 28),
                      ],

                      // Favorite offers
                      if (favorites != null && favorites.offers.isNotEmpty) ...[
                        _SectionTitle(title: l10n.favoritesMyOffers),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: [
                            for (final offer in favorites.offers)
                              ActionChip(
                                avatar: Icon(Icons.schedule_rounded,
                                    size: 16, color: cs.inversePrimary),
                                label: Text('${offer.favorite.departureHm} · '
                                    '${offer.favorite.matricule.isEmpty ? offer.louage.matricule : offer.favorite.matricule}'),
                                onPressed: () => context.pushNamed(
                                  'passengerSearchResults',
                                  extra: TripSearchCriteria(
                                    from: offer.fromStation.city,
                                    to: offer.toStation.city,
                                    date: DateUtils.dateOnly(DateTime.now()),
                                    time: _favoriteTime(offer.favorite.departureHm),
                                    fromStationId: offer.fromStation.id,
                                    toStationId: offer.toStation.id,
                                  )),
                              ),
                          ],
                        ),
                        const SizedBox(height: 28),
                      ],

                      // Popular trips
                      _SectionTitle(title: l10n.searchPopularTrips),
                      const SizedBox(height: 12),
                      _buildPopularRoutes(routes, stationById),
                      const SizedBox(height: 28),

                      // Nearest station
                      NearestStationCard(stations: stations),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Sidebar overlay ─────────────────────────────────────────────
        if (_sidebarOpen)
          AnimatedBuilder(
            animation: _sideCtrl,
            builder: (_, __) {
              return Stack(
                children: [
                  // Scrim
                  GestureDetector(
                    onTap: _closeSidebar,
                    child: Container(
                      color: Colors.black.withValues(
                          alpha: 0.52 * _sideFade.value),
                    ),
                  ),

                  // Sidebar panel
                  Positioned(
                    top: 0, bottom: 0, left: 0,
                    child: Transform.translate(
                      offset: Offset(screenW * 0.80 * _sideSlide.value, 0),
                      child: ScaleTransition(
                        scale: _sideScale,
                        alignment: Alignment.centerLeft,
                        child: _SidebarPanel(
                          greeting: greeting,
                          screenW: screenW,
                          screenH: screenH,
                          topPad: topPad,
                          currentRoute: 'passengerHome',
                          onClose: _closeSidebar,
                          onNavigate: (name) {
                            _closeSidebar();
                            Future.delayed(
                              const Duration(milliseconds: 200),
                              () { if (mounted) context.goNamed(name); });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  // ── Search card ────────────────────────────────────────────────────────
  Widget _buildSearchCard() {
    final l10n   = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    return SearchCard(
      departureLabel:   l10n.searchDeparture,
      destinationLabel: l10n.searchDestination,
      chooseCityLabel:  l10n.searchChooseCity,
      dateLabel:        l10n.searchDate,
      dateValue:        MaterialLocalizations.of(context).formatShortDate(_date),
      timeLabel:        l10n.searchTime,
      timeValue:        _time.format(context),
      swapTooltip:      l10n.searchSwapRoute,
      searchLabel:      l10n.searchSubmit,
      departure:        _fromStation?.localizedCity(locale) ?? _from,
      destination:      _toStation?.localizedCity(locale) ?? _to,
      swapAnimation:    _swapTurns,
      departureError:   _showLocationError && _from == null,
      destinationError: _showLocationError && _to == null,
      isLoading:        _isSearching,
      onDepartureTap:   () => _pickCity(isFrom: true),
      onDestinationTap: () => _pickCity(isFrom: false),
      onSwap:           _swapCities,
      onDateTap:        _pickDate,
      onTimeTap:        _pickTime,
      onSearch:         _search,
    );
  }

  // ── Route chips ───────────────────────────────────────────────────────
  Widget _buildRouteChips(List<SearchRouteShortcut> shortcuts,
      List<Station> stations) =>
      SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 2),
          itemCount: shortcuts.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final s = shortcuts[i];
            return _RouteChip(
              label: AppLocalizations.of(context)!.searchRoutePair(
                _localizedCity(context, s.from, stations),
                _localizedCity(context, s.to, stations),
              ),
              isFavorite: s.isFavorite,
              onTap: () => _selectRoute(s.from, s.to),
            );
          },
        ),
      );

  // ── Popular routes ────────────────────────────────────────────────────
  Widget _buildPopularRoutes(List<RouteLine> routes,
      Map<String, Station> stations) {
    final popular = routes.map((r) {
      final from = stations[r.fromStationId];
      final to   = stations[r.toStationId];
      if (from == null || to == null) return null;
      return _PopularRoute(
        from: from.city, to: to.city,
        fromLabel: from.localizedCity(Localizations.localeOf(context)),
        toLabel:   to.localizedCity(Localizations.localeOf(context)),
        price:     r.pricePerSeat,
      );
    }).whereType<_PopularRoute>().toList();

    if (popular.isEmpty) {
      return SizedBox(height: 140, child: Center(
        child: EmptyState(icon: Icons.route_outlined,
          title: AppLocalizations.of(context)!.searchNoPopularTrips)));
    }

    return SizedBox(
      height: 156,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: popular.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final route = popular[i];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 240 + i * 60),
            curve: Curves.easeOutCubic,
            builder: (context, v, child) => Opacity(opacity: v,
              child: Transform.translate(offset: Offset(0, 10*(1-v)), child: child)),
            child: _PopularRouteCard(
              route: route, onTap: () => _selectRoute(route.from, route.to)),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HERO BANNER
// ═══════════════════════════════════════════════════════════════════════════
class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.greeting,
    required this.subtitle,
    required this.unreadCount,
    required this.topPad,
    required this.screenW,
    required this.imageH,
    required this.isDark,
    required this.bgColor,
    required this.onNotifications,
    required this.onProfile,
    required this.onMenu,
  });

  final String greeting;
  final String subtitle;
  final int    unreadCount;
  final double topPad, screenW, imageH;
  final bool   isDark;
  final Color  bgColor;
  final VoidCallback onNotifications, onProfile, onMenu;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: imageH + topPad,
      child: Stack(
        children: [
          // 1 — Image (bottom layer)
          Positioned(
            top: topPad, left: 0, right: 0, height: imageH,
            child: Image.asset(
              'assets/images/Voyage en louage vers Tunis.png',
              width: screenW, height: imageH, fit: BoxFit.fitWidth),
          ),

          // 2 — Red radial tint top-left
          Positioned(
            top: topPad, left: 0, right: 0, height: imageH * 0.55,
            child: DecoratedBox(decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-1.0, -1.0), radius: 1.3,
                colors: [_kRed.withValues(alpha: 0.38), Colors.transparent]))),
          ),

          // 3 — Fade-out bottom → page bg
          Positioned(
            left: 0, right: 0, bottom: 0, height: imageH * 0.48,
            child: DecoratedBox(decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter, end: Alignment.topCenter,
                stops: const [0.0, 0.25, 0.58, 1.0],
                colors: [
                  bgColor, bgColor.withValues(alpha: 0.92),
                  bgColor.withValues(alpha: 0.30), Colors.transparent]))),
          ),

          // 4 — Badge + greeting + subtitle (bottom-left)
          Positioned(
            left: 20, right: 76, bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    color: _kRed,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: _kRed.withValues(alpha: 0.45),
                        blurRadius: 12, offset: const Offset(0, 3))]),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('🇹🇳', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 5),
                    Text('LouageGo', style: TextStyle(
                      color: Colors.white, fontSize: 11,
                      fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  ]),
                ),
                const SizedBox(height: 9),
                Text(greeting, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    fontSize: 22, fontWeight: FontWeight.w800,
                    letterSpacing: -0.4, height: 1.18)),
                const SizedBox(height: 5),
                Row(children: [
                  Icon(Icons.location_on_rounded,
                    color: isDark ? Colors.white70 : const Color(0xFF555555),
                    size: 13),
                  const SizedBox(width: 3),
                  Text(subtitle, style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF555555),
                    fontSize: 13)),
                ]),
              ],
            ),
          ),

          // 5 — Status-bar gradient (top layer)
          Positioned(
            top: 0, left: 0, right: 0, height: topPad + 64,
            child: DecoratedBox(decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.black.withValues(alpha: 0.48), Colors.transparent]))),
          ),

          // 6 — Menu icon (top-left, topmost layer)
          Positioned(
            top: topPad + 8, left: 16,
            child: _HeaderIcon(icon: Icons.menu_rounded, onTap: onMenu),
          ),

          // 7 — Notif + Profile icons (top-right, topmost layer)
          Positioned(
            top: topPad + 8, right: 16,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _HeaderIcon(
                icon: Icons.notifications_none_rounded,
                badge: unreadCount,
                onTap: onNotifications),
              const SizedBox(width: 10),
              _HeaderIcon(icon: Icons.person_outline_rounded, onTap: onProfile),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Circular icon button for header ────────────────────────────────────────
class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.onTap, this.badge = 0});
  final IconData icon;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.32), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Center(
          child: badge > 0
              ? Badge(label: Text(badge > 99 ? '99+' : '$badge'),
                  child: Icon(icon, color: Colors.white, size: 20))
              : Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// SIDEBAR PANEL — Rouge/Blanc identité LouageGo
// ═══════════════════════════════════════════════════════════════════════════
class _SidebarPanel extends StatefulWidget {
  const _SidebarPanel({
    required this.greeting,
    required this.screenW,
    required this.screenH,
    required this.topPad,
    required this.currentRoute,
    required this.onClose,
    required this.onNavigate,
  });

  final String greeting;
  final double screenW, screenH, topPad;
  final String currentRoute;
  final VoidCallback onClose;
  final void Function(String routeName) onNavigate;

  @override
  State<_SidebarPanel> createState() => _SidebarPanelState();
}

class _SidebarPanelState extends State<_SidebarPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stagger;
  late final List<Animation<double>> _itemAnims;

  static const _navItems = [
    _NavItem('passengerHome',      Icons.home_rounded,           'Accueil'),
    _NavItem('passengerTrips',     Icons.luggage_rounded,        'Mes voyages'),
    _NavItem('passengerFavorites', Icons.favorite_rounded,       'Favoris'),
    _NavItem('notifications',      Icons.notifications_rounded,  'Notifications'),
    _NavItem('passengerProfile',   Icons.person_rounded,         'Mon profil'),
    _NavItem('passengerSettings',  Icons.settings_rounded,       'Paramètres'),
  ];

  static const _bottomItems = [
    _NavItem('passengerSupport',   Icons.help_outline_rounded,   'Aide & Support'),
    _NavItem('logout',             Icons.logout_rounded,         'Déconnexion'),
  ];

  @override
  void initState() {
    super.initState();
    _stagger = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    )..forward();

    final total = _navItems.length + _bottomItems.length;
    _itemAnims = List.generate(total, (i) {
      final start = 0.08 + i * 0.10;
      final end   = (start + 0.42).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _stagger,
        curve: Interval(start, end, curve: Curves.easeOutCubic));
    });
  }

  @override
  void dispose() { _stagger.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final w      = widget.screenW * 0.80;
    final botPad = MediaQuery.viewPaddingOf(context).bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Palette adaptive
    final bgTop   = isDark ? const Color(0xFF1A0A0C) : Colors.white;
    final bgBot   = isDark ? const Color(0xFF120608) : const Color(0xFFFAF8F8);
    final divCol  = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.grey.shade200;

    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(right: Radius.circular(28)),
      child: Container(
        width: w,
        height: widget.screenH,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgTop, bgBot],
          ),
          borderRadius:
              const BorderRadius.horizontal(right: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              blurRadius: 32,
              offset: const Offset(6, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── Header ──────────────────────────────────────────────────
            _SidebarHeader(
              greeting:  widget.greeting,
              topPad:    widget.topPad,
              onClose:   widget.onClose,
              isDark:    isDark,
            ),

            Divider(height: 1, color: divCol,
                indent: 20, endIndent: 20),
            const SizedBox(height: 10),

            // ── Main nav ────────────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: _navItems.length,
                itemBuilder: (_, i) {
                  final item     = _navItems[i];
                  final isActive = item.routeName == widget.currentRoute;
                  return _AnimatedNavTile(
                    anim:     _itemAnims[i],
                    item:     item,
                    isActive: isActive,
                    isDark:   isDark,
                    onTap:    () => item.routeName == 'passengerSettings'
                        ? null  // settings not yet implemented
                        : widget.onNavigate(item.routeName),
                  );
                },
              ),
            ),

            // ── Bottom section ───────────────────────────────────────────
            Divider(height: 1, color: divCol, indent: 20, endIndent: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                children: List.generate(_bottomItems.length, (i) {
                  final item = _bottomItems[i];
                  final isLogout = item.routeName == 'logout';
                  return _AnimatedNavTile(
                    anim:        _itemAnims[_navItems.length + i],
                    item:        item,
                    isActive:    false,
                    isDark:      isDark,
                    isDestructive: isLogout,
                    onTap: () {
                      if (isLogout) {
                        widget.onClose();
                      } else {
                        widget.onNavigate(item.routeName);
                      }
                    },
                  );
                }),
              ),
            ),

            // ── Footer branding ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20, 6, 20, botPad + 16),
              child: Row(children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: _kRed.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: _kRed.withValues(alpha: 0.20), width: 1)),
                  child: const Icon(Icons.directions_bus_rounded,
                      color: _kRed, size: 17),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('LouageGo', style: TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                    Text('Voyagez malin en Tunisie 🇹🇳', style: TextStyle(
                      fontSize: 10, color: isDark
                          ? Colors.white38 : Colors.grey.shade400)),
                  ],
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sidebar header ──────────────────────────────────────────────────────────
class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({
    required this.greeting,
    required this.topPad,
    required this.onClose,
    required this.isDark,
  });
  final String greeting;
  final double topPad;
  final VoidCallback onClose;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Extract first name and role hint
    final parts    = greeting.replaceFirst(RegExp(r'^[^,]+,\s*'), '');
    final name     = parts.isNotEmpty ? parts : greeting;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 12, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _kRed.withValues(alpha: isDark ? 0.30 : 0.08),
            _kRed.withValues(alpha: isDark ? 0.10 : 0.02),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar circle with red gradient
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kRed, Color(0xFFFF2D4A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _kRed.withValues(alpha: 0.38),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.person_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),

          // Name + badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                Text(name,
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.5, fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    height: 1.2, letterSpacing: -0.2)),
                const SizedBox(height: 6),
                // LouageGo badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kRed,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(
                      color: _kRed.withValues(alpha: 0.30),
                      blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🇹🇳', style: TextStyle(fontSize: 10.5)),
                      SizedBox(width: 4),
                      Text('LouageGo', style: TextStyle(
                        color: Colors.white, fontSize: 10,
                        fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Close button
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 36, height: 36,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.10),
                  width: 1),
              ),
              child: Icon(Icons.close_rounded,
                color: isDark ? Colors.white70 : const Color(0xFF555555),
                size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated nav tile ────────────────────────────────────────────────────────
class _AnimatedNavTile extends StatefulWidget {
  const _AnimatedNavTile({
    required this.anim,
    required this.item,
    required this.isActive,
    required this.isDark,
    required this.onTap,
    this.isDestructive = false,
  });
  final Animation<double> anim;
  final _NavItem item;
  final bool   isActive, isDark, isDestructive;
  final VoidCallback? onTap;

  @override
  State<_AnimatedNavTile> createState() => _AnimatedNavTileState();
}

class _AnimatedNavTileState extends State<_AnimatedNavTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 90));
    _scale = Tween<double>(begin: 1.0, end: 0.965)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeOut));
  }

  @override
  void dispose() { _press.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final accent = widget.isDestructive ? const Color(0xFFD32F2F) : _kRed;

    final iconBg = widget.isActive
        ? _kRed.withValues(alpha: 0.10)
        : widget.isDark
            ? Colors.white.withValues(alpha: 0.06)
            : const Color(0xFFF5F5F5);

    final iconColor = widget.isActive
        ? _kRed
        : widget.isDestructive
            ? accent
            : widget.isDark
                ? Colors.white.withValues(alpha: 0.60)
                : const Color(0xFF666666);

    final labelColor = widget.isActive
        ? _kRed
        : widget.isDestructive
            ? accent
            : widget.isDark
                ? Colors.white.withValues(alpha: 0.85)
                : const Color(0xFF1A1A1A);

    return FadeTransition(
      opacity: widget.anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.12, 0), end: Offset.zero).animate(widget.anim),
        child: ScaleTransition(
          scale: _scale,
          child: GestureDetector(
            onTapDown:   (_) => _press.forward(),
            onTapUp:     (_) => _press.reverse(),
            onTapCancel: () => _press.reverse(),
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: widget.isActive
                    ? _kRed.withValues(alpha: 0.07)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: widget.isActive
                    ? Border.all(
                        color: _kRed.withValues(alpha: 0.18), width: 1)
                    : null,
              ),
              child: Row(children: [
                // Icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                    border: widget.isActive
                        ? Border.all(
                            color: _kRed.withValues(alpha: 0.22), width: 1)
                        : null,
                  ),
                  child: Icon(widget.item.icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 13),

                // Label
                Expanded(child: Text(widget.item.label, style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: widget.isActive
                      ? FontWeight.w700 : FontWeight.w400,
                  color: labelColor,
                  letterSpacing: 0.1))),

                // Active indicator bar
                if (widget.isActive)
                  Container(
                    width: 4, height: 20,
                    decoration: BoxDecoration(
                      color: _kRed,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Nav item data ────────────────────────────────────────────────────────────
class _NavItem {
  const _NavItem(this.routeName, this.icon, this.label);
  final String   routeName;
  final IconData icon;
  final String   label;
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child, required this.isDark});
  final Widget child;
  final bool   isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surfaceContainerLow
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: _kRed.withValues(alpha: 0.10),
              blurRadius: 28, spreadRadius: 2, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.05),
              blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 4, height: 18,
        decoration: BoxDecoration(
          color: _kRed, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700, letterSpacing: -0.2)),
    ]);
  }
}

class _RouteChip extends StatelessWidget {
  const _RouteChip({required this.label, required this.onTap,
      this.isFavorite = false});
  final String label;
  final VoidCallback onTap;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A1A1E) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _kRed.withValues(alpha: 0.22), width: 1.2),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(isFavorite ? Icons.favorite_rounded : Icons.history_rounded,
              size: 14, color: _kRed),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
        ]),
      ),
    );
  }
}

class _PopularRouteCard extends StatelessWidget {
  const _PopularRouteCard({required this.route, required this.onTap});
  final _PopularRoute route;
  final VoidCallback  onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n   = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kRed.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(color: _kRed.withValues(alpha: 0.06),
                blurRadius: 16, offset: const Offset(0, 4)),
            BoxShadow(color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 36, height: 36,
              decoration: BoxDecoration(
                color: _kRed.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.route_rounded, size: 18, color: _kRed)),
            const Spacer(),
            Container(width: 28, height: 28,
              decoration: BoxDecoration(
                color: _kRed.withValues(alpha: 0.07), shape: BoxShape.circle),
              child: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                size: 14, color: _kRed)),
          ]),
          const Spacer(),
          Text(route.fromLabel, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12,
              color: isDark ? Colors.white60 : const Color(0xFF666666))),
          Row(children: [
            Icon(Icons.arrow_downward_rounded, size: 12, color: _kRed),
            const SizedBox(width: 2),
            Expanded(child: Text(route.toLabel, maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A)))),
          ]),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _kRed.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(20)),
            child: Text(l10n.searchPricePerSeat(_formatPrice(route.price)),
              style: const TextStyle(color: _kRed, fontSize: 12,
                  fontWeight: FontWeight.w700))),
        ]),
      ),
    );
  }
}

// ─── Data classes ──────────────────────────────────────────────────────────
class _PopularRoute {
  const _PopularRoute({required this.from, required this.to,
      required this.fromLabel, required this.toLabel, required this.price});
  final String from, to, fromLabel, toLabel;
  final double price;
}

// ─── Helpers ───────────────────────────────────────────────────────────────
String _formatPrice(double price) =>
    price == price.roundToDouble()
        ? price.toStringAsFixed(0)
        : price.toStringAsFixed(2);

String _localizedCity(BuildContext context, String city,
    List<Station> stations) {
  final s = stations.where((s) => s.city == city).firstOrNull;
  return s?.localizedCity(Localizations.localeOf(context)) ?? city;
}
