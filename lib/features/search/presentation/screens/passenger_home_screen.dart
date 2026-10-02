import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/route_line.dart';
import '../../../../models/station.dart';
import '../../domain/trip_search_criteria.dart';
import '../providers/trip_search_results_provider.dart';
import '../widgets/search_card.dart';

class PassengerHomeScreen extends ConsumerStatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  ConsumerState<PassengerHomeScreen> createState() =>
      _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends ConsumerState<PassengerHomeScreen>
    with SingleTickerProviderStateMixin {
  String? _from;
  String? _to;
  bool _showLocationError = false;
  bool _isSearching = false;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  late final AnimationController _swapController;
  late final Animation<double> _swapTurns;

  @override
  void initState() {
    super.initState();
    _swapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _swapTurns = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _swapController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _swapController.dispose();
    super.dispose();
  }

  Future<void> _pickCity({
    required bool isFrom,
    required List<Station> stations,
  }) async {
    final city = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _StationPicker(stations: stations),
    );
    if (city == null || !mounted) return;
    setState(() {
      if (isFrom) {
        _from = city;
      } else {
        _to = city;
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
      _from = _to;
      _to = previousFrom;
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
    if (_from == _to) {
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
          data: (data) => _buildHome(context, data, firstName),
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
  ) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final stations = data.stations;
    final stationById = {for (final station in stations) station.id: station};
    final routes = data.routes;
    final lastTrips = data.recentTrips;
    final favorites = data.favorites;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _GreetingHeader(
                firstName: firstName == null || firstName.isEmpty
                    ? l10n.profilePassengerFallback
                    : firstName,
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
                        _buildSearchCard(context, stations),
                        const SizedBox(height: 28),
                        if (lastTrips.isNotEmpty) ...[
                          SectionHeader(title: l10n.searchLastTrips),
                          const SizedBox(height: 12),
                          _buildRouteChips(lastTrips),
                          const SizedBox(height: 24),
                        ],
                        if (favorites.isNotEmpty) ...[
                          SectionHeader(title: l10n.searchFavorites),
                          const SizedBox(height: 12),
                          _buildRouteChips(favorites),
                          const SizedBox(height: 24),
                        ],
                        SectionHeader(title: l10n.searchPopularTrips),
                        const SizedBox(height: 12),
                        _buildPopularRoutes(routes, stationById),
                        const SizedBox(height: 24),
                        _buildNearestStation(context),
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

  Widget _buildSearchCard(BuildContext context, List<Station> stations) {
    final l10n = AppLocalizations.of(context)!;
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
      departure: _from,
      destination: _to,
      swapAnimation: _swapTurns,
      departureError: _showLocationError && _from == null,
      destinationError: _showLocationError && _to == null,
      isLoading: _isSearching,
      onDepartureTap: () => _pickCity(isFrom: true, stations: stations),
      onDestinationTap: () => _pickCity(isFrom: false, stations: stations),
      onSwap: _swapCities,
      onDateTap: _pickDate,
      onTimeTap: _pickTime,
      onSearch: _search,
    );
  }

  Widget _buildRouteChips(List<SearchRouteShortcut> shortcuts) => SizedBox(
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
            AppLocalizations.of(context)!
                .searchRoutePair(shortcut.from, shortcut.to),
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
                          .searchRoutePair(route.from, route.to),
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

  Widget _buildNearestStation(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Row(
        children: [
          Icon(Icons.my_location, color: colorScheme.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.searchNearestStation,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.searchLocationPlaceholder,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StationPicker extends StatefulWidget {
  final List<Station> stations;

  const _StationPicker({required this.stations});

  @override
  State<_StationPicker> createState() => _StationPickerState();
}

class _StationPickerState extends State<_StationPicker> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final media = MediaQuery.of(context);
    final query = _query.trim().toLowerCase();
    final cities =
        widget.stations
            .map((station) => station.city)
            .toSet()
            .where((city) => city.toLowerCase().contains(query))
            .toList()
          ..sort();

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 16),
      child: SizedBox(
        height: (media.size.height - media.viewInsets.bottom - 48).clamp(
          220.0,
          media.size.height * 0.78,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.searchCityPickerTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                labelText: l10n.searchCitySearch,
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: cities.isEmpty
                  ? Center(child: Text(l10n.searchNoCityFound))
                  : ListView.builder(
                      itemCount: cities.length,
                      itemBuilder: (context, index) {
                        final city = cities[index];
                        return ListTile(
                          minVerticalPadding: 8,
                          leading: const Icon(Icons.location_city),
                          title: Text(city),
                          onTap: () => Navigator.of(context).pop(city),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final String firstName;
  final VoidCallback onProfile;

  const _GreetingHeader({required this.firstName, required this.onProfile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const AppLogoMark(size: 72, showBackground: false),
                const Spacer(),
                Tooltip(
                  message: l10n.adminNavNotifications,
                  child: Semantics(
                    label: l10n.adminNavNotifications,
                    child: SizedBox.square(
                      dimension: 48,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: AlignmentDirectional.center,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox.square(
                              dimension: 48,
                              child: Icon(
                                Icons.notifications_none_rounded,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          PositionedDirectional(
                            top: 8,
                            end: 8,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: colorScheme.secondary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                              child: const SizedBox.square(dimension: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: l10n.profileTitle,
                  onPressed: onProfile,
                  constraints: const BoxConstraints.tightFor(
                    width: 48,
                    height: 48,
                  ),
                  style: IconButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    foregroundColor: colorScheme.onSurface,
                  ),
                  icon: const Icon(Icons.person_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.greetingPassenger(firstName),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.searchPrompt,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularRoute {
  final String from;
  final String to;
  final double price;

  const _PopularRoute({
    required this.from,
    required this.to,
    required this.price,
  });
}

String _formatPrice(double price) => price == price.roundToDouble()
    ? price.toStringAsFixed(0)
    : price.toStringAsFixed(2);
