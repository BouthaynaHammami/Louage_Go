import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/home_greeting_header.dart';
import '../../../../core/widgets/section_header.dart';
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

class PassengerHomeScreen extends ConsumerStatefulWidget {
  const PassengerHomeScreen({super.key, this.initialFromStationId});

  final String? initialFromStationId;

  @override
  ConsumerState<PassengerHomeScreen> createState() =>
      _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends ConsumerState<PassengerHomeScreen>
    with SingleTickerProviderStateMixin {
  String? _from;
  String? _to;
  Station? _fromStation;
  Station? _toStation;
  bool _showLocationError = false;
  bool _isSearching = false;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  late final AnimationController _swapController;
  late final Animation<double> _swapTurns;

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
  }

  @override
  void didUpdateWidget(covariant PassengerHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFromStationId != widget.initialFromStationId) {
      _fromStation = widget.initialFromStationId == null
          ? null
          : ref
                .read(searchRepositoryProvider)
                .getStation(widget.initialFromStationId!);
      _from = _fromStation?.city;
      _toStation = null;
      _to = null;
    }
  }

  @override
  void dispose() {
    _swapController.dispose();
    super.dispose();
  }

  Future<void> _pickCity({required bool isFrom}) async {
    final station = await showStationPicker(
      context,
      title: AppLocalizations.of(context)!.searchCityPickerTitle,
    );
    if (station == null || !mounted) return;
    setState(() {
      if (isFrom) {
        _fromStation = station;
        _from = station.city;
      } else {
        _toStation = station;
        _to = station.city;
      }
      if (_from != null && _to != null) _showLocationError = false;
    });
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 6)),
    );
    if (selected != null && mounted) setState(() => _date = selected);
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(context: context, initialTime: _time);
    if (selected != null && mounted) setState(() => _time = selected);
  }

  void _swapCities() {
    setState(() {
      final previousFrom = _from;
      final previousFromStation = _fromStation;
      _from = _to;
      _to = previousFrom;
      _fromStation = _toStation;
      _toStation = previousFromStation;
      if (_from != null && _to != null) _showLocationError = false;
    });
    _swapController.forward(from: 0);
  }

  Future<void> _search() async {
    final l10n = AppLocalizations.of(context)!;
    if (_from == null || _to == null) {
      setState(() => _showLocationError = true);
      _message(l10n.searchChooseBothCities);
      return;
    }
    if ((_fromStation != null &&
            _toStation != null &&
            _fromStation!.id == _toStation!.id) ||
        (_fromStation == null && _toStation == null && _from == _to)) {
      _message(l10n.searchCitiesMustDiffer);
      return;
    }

    setState(() => _isSearching = true);
    try {
      await ref.read(searchRepositoryProvider).rememberSearch(_from!, _to!);
      if (!mounted) return;
      context.pushNamed(
        'passengerSearchResults',
        extra: TripSearchCriteria(
          from: _from!,
          to: _to!,
          date: _date,
          time: _time,
          fromStationId: _fromStation?.id,
          toStationId: _toStation?.id,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _selectRoute(String from, String to) {
    setState(() {
      _from = from;
      _to = to;
      _fromStation = null;
      _toStation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      loading: () => _buildLoading(context),
      error: (error, stackTrace) => Scaffold(
        body: EmptyState(
          icon: Icons.error_outline,
          title: l10n.searchLoadError,
        ),
      ),
      data: (user) {
        final dataAsync = ref.watch(passengerHomeDataProvider(user?.id));
        final firstName = user?.name.trim().split(RegExp(r'\s+')).firstOrNull;
        return dataAsync.when(
          loading: () => _buildLoading(context),
          error: (error, stackTrace) => Scaffold(
            body: EmptyState(
              icon: Icons.error_outline,
              title: l10n.searchLoadError,
            ),
          ),
          data: (data) => _buildHome(context, data, firstName, user?.id),
        );
      },
    );
  }

  Widget _buildLoading(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsetsDirectional.all(18),
        children: const [
          SkeletonBox(height: 210),
          SizedBox(height: 20),
          SkeletonBox(height: 320),
          SizedBox(height: 20),
          SkeletonBox(height: 150),
        ],
      ),
    ),
  );

  Widget _buildHome(
    BuildContext context,
    PassengerHomeData data,
    String? firstName,
    String? userId,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final stations = data.stations;
    final stationById = {for (final station in stations) station.id: station};
    final routes = data.routes;
    final lastTrips = data.recentTrips;
    final favorites = userId == null
        ? null
        : ref.watch(favoritesProvider(userId)).asData?.value;
    final unreadCount = userId == null
        ? 0
        : ref.watch(unreadNotificationCountProvider(userId)).asData?.value ?? 0;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: HomeGreetingHeader(
                greeting: l10n.greetingPassenger(
                  firstName == null || firstName.isEmpty
                      ? l10n.profilePassengerFallback
                      : firstName,
                ),
                subtitle: l10n.searchPrompt,
                profileTooltip: l10n.profileTitle,
                notificationsTooltip: l10n.adminNavNotifications,
                unreadCount: unreadCount,
                onNotifications: () => context.pushNamed('notifications'),
                onProfile: () => context.goNamed('passengerProfile'),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSearchCard(context),
                        const SizedBox(height: 28),
                        if (lastTrips.isNotEmpty) ...[
                          SectionHeader(title: l10n.searchLastTrips),
                          const SizedBox(height: 12),
                          _buildRouteChips(lastTrips, stations),
                          const SizedBox(height: 24),
                        ],
                        if (favorites != null &&
                            favorites.routes.isNotEmpty) ...[
                          SectionHeader(title: l10n.searchFavorites),
                          const SizedBox(height: 12),
                          _buildRouteChips(
                            favorites.routes
                                .map(
                                  (favorite) => SearchRouteShortcut(
                                    from: favorite.from,
                                    to: favorite.to,
                                    isFavorite: true,
                                  ),
                                )
                                .toList(growable: false),
                            stations,
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (favorites != null &&
                            favorites.offers.isNotEmpty) ...[
                          SectionHeader(title: l10n.favoritesMyOffers),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final offer in favorites.offers)
                                ActionChip(
                                  avatar: Icon(
                                    Icons.schedule_rounded,
                                    size: 16,
                                    color: colorScheme.primary,
                                  ),
                                  label: Text(
                                    '${offer.favorite.departureHm} · '
                                    '${offer.favorite.matricule.isEmpty ? offer.louage.matricule : offer.favorite.matricule}',
                                  ),
                                  onPressed: () => context.pushNamed(
                                    'passengerSearchResults',
                                    extra: TripSearchCriteria(
                                      from: offer.fromStation.city,
                                      to: offer.toStation.city,
                                      date: DateUtils.dateOnly(DateTime.now()),
                                      time: _favoriteTime(
                                        offer.favorite.departureHm,
                                      ),
                                      fromStationId: offer.fromStation.id,
                                      toStationId: offer.toStation.id,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                        SectionHeader(title: l10n.searchPopularTrips),
                        const SizedBox(height: 12),
                        _buildPopularRoutes(routes, stationById),
                        const SizedBox(height: 24),
                        NearestStationCard(stations: stations),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TimeOfDay _favoriteTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts.first) ?? 0,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
  }

  Widget _buildSearchCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    return SearchCard(
      departureLabel: l10n.searchDeparture,
      destinationLabel: l10n.searchDestination,
      chooseCityLabel: l10n.searchChooseCity,
      dateLabel: l10n.searchDate,
      dateValue: MaterialLocalizations.of(context).formatShortDate(_date),
      timeLabel: l10n.searchTime,
      timeValue: _time.format(context),
      swapTooltip: l10n.searchSwapRoute,
      searchLabel: l10n.searchSubmit,
      departure: _fromStation?.localizedCity(locale) ?? _from,
      destination: _toStation?.localizedCity(locale) ?? _to,
      swapAnimation: _swapTurns,
      departureError: _showLocationError && _from == null,
      destinationError: _showLocationError && _to == null,
      isLoading: _isSearching,
      onDepartureTap: () => _pickCity(isFrom: true),
      onDestinationTap: () => _pickCity(isFrom: false),
      onSwap: _swapCities,
      onDateTap: _pickDate,
      onTimeTap: _pickTime,
      onSearch: _search,
    );
  }

  Widget _buildRouteChips(
    List<SearchRouteShortcut> shortcuts,
    List<Station> stations,
  ) => SizedBox(
    height: 52,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 2),
      itemCount: shortcuts.length,
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final shortcut = shortcuts[index];
        return ActionChip(
          avatar: Icon(
            shortcut.isFavorite ? Icons.favorite : Icons.history,
            size: 16,
          ),
          label: Text(
            AppLocalizations.of(context)!.searchRoutePair(
              _localizedCity(context, shortcut.from, stations),
              _localizedCity(context, shortcut.to, stations),
            ),
          ),
          onPressed: () => _selectRoute(shortcut.from, shortcut.to),
        );
      },
    ),
  );

  Widget _buildPopularRoutes(
    List<RouteLine> routes,
    Map<String, Station> stations,
  ) {
    final popular = routes
        .map((route) {
          final from = stations[route.fromStationId];
          final to = stations[route.toStationId];
          if (from == null || to == null) return null;
          return _PopularRoute(
            from: from.city,
            to: to.city,
            fromLabel: from.localizedCity(Localizations.localeOf(context)),
            toLabel: to.localizedCity(Localizations.localeOf(context)),
            price: route.pricePerSeat,
          );
        })
        .whereType<_PopularRoute>()
        .toList();

    if (popular.isEmpty) {
      return SizedBox(
        height: 184,
        child: Center(
          child: EmptyState(
            icon: Icons.route_outlined,
            title: AppLocalizations.of(context)!.searchNoPopularTrips,
          ),
        ),
      );
    }

    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: popular.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final route = popular[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            builder: (context, progress, child) => Opacity(
              opacity: progress,
              child: Transform.translate(
                offset: Offset(0, 8 * (1 - progress)),
                child: child,
              ),
            ),
            child: SizedBox(
              width: 220,
              child: AppCard(
                onTap: () => _selectRoute(route.from, route.to),
                padding: const EdgeInsetsDirectional.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.route_outlined,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const Spacer(),
                        Icon(
                          Directionality.of(context) == TextDirection.rtl
                              ? Icons.arrow_back_rounded
                              : Icons.arrow_forward_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      AppLocalizations.of(context)!
                          .searchRoutePair(route.fromLabel, route.toLabel),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!
                          .searchPricePerSeat(_formatPrice(route.price)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PopularRoute {
  final String from;
  final String to;
  final String fromLabel;
  final String toLabel;
  final double price;

  const _PopularRoute({
    required this.from,
    required this.to,
    required this.fromLabel,
    required this.toLabel,
    required this.price,
  });
}

String _formatPrice(double price) => price == price.roundToDouble()
    ? price.toStringAsFixed(0)
    : price.toStringAsFixed(2);

String _localizedCity(
  BuildContext context,
  String city,
  List<Station> stations,
) {
  final station = stations.where((station) => station.city == city).firstOrNull;
  return station?.localizedCity(Localizations.localeOf(context)) ?? city;
}
