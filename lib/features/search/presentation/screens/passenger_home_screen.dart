import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/hive_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/favorite.dart';
import '../../../../models/route_line.dart';
import '../../../../models/station.dart';
import '../../domain/trip_search_criteria.dart';

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
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  late final AnimationController _swapController;
  late final Animation<double> _swapTurns;

  List<Station> get _stations => HiveService.stations.values
      .map(Station.fromMap)
      .where((station) => station.city.isNotEmpty)
      .toList();

  List<RouteLine> get _routes => HiveService.routes.values
      .map(RouteLine.fromMap)
      .where(
        (route) =>
            route.fromStationId.isNotEmpty && route.toStationId.isNotEmpty,
      )
      .toList();

  @override
  void initState() {
    super.initState();
    _swapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
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

  Future<void> _pickCity({required bool isFrom}) async {
    final city = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _StationPicker(stations: _stations),
    );
    if (city == null || !mounted) return;
    setState(() => isFrom ? _from = city : _to = city);
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
    });
    _swapController.forward(from: 0);
  }

  Future<void> _search() async {
    final l10n = AppLocalizations.of(context)!;
    if (_from == null || _to == null) {
      _message(l10n.searchChooseBothCities);
      return;
    }
    if (_from == _to) {
      _message(l10n.searchCitiesMustDiffer);
      return;
    }

    await _rememberSearch(_from!, _to!);
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
  }

  Future<void> _rememberSearch(String from, String to) async {
    final stored = HiveService.session.get('lastTrips')?['items'];
    final recent = <Map<String, String>>[];
    if (stored is Iterable) {
      for (final item in stored) {
        if (item is Map && item['from'] is String && item['to'] is String) {
          final oldFrom = item['from'] as String;
          final oldTo = item['to'] as String;
          if (oldFrom != from || oldTo != to) {
            recent.add({'from': oldFrom, 'to': oldTo});
          }
        }
      }
    }
    recent.insert(0, {'from': from, 'to': to});
    await HiveService.session.put('lastTrips', {
      'items': recent.take(5).toList(),
    });
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
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref
        .watch(currentUserProvider)
        .maybeWhen(data: (user) => user, orElse: () => null);
    final firstName = user?.name.trim().split(RegExp(r'\s+')).firstOrNull;
    final stations = _stations;
    final stationById = {for (final station in stations) station.id: station};
    final routes = _routes;
    final lastTrips = _readLastTrips();
    final favorites = _readFavorites(user?.id, routes, stationById);

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
              child: Transform.translate(
                offset: const Offset(0, -42),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 18, 28),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      padding: const EdgeInsetsDirectional.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CityField(
            icon: Icons.trip_origin,
            label: l10n.searchDeparture,
            value: _from,
            onTap: () => _pickCity(isFrom: true),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: RotationTransition(
              turns: _swapTurns,
              child: IconButton.filledTonal(
                tooltip: l10n.searchSwapRoute,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: _swapCities,
                icon: const Icon(Icons.swap_vert),
              ),
            ),
          ),
          _CityField(
            icon: Icons.location_on_outlined,
            label: l10n.searchDestination,
            value: _to,
            onTap: () => _pickCity(isFrom: false),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DateTimeField(
                  label: l10n.searchDate,
                  value: MaterialLocalizations.of(context)
                      .formatShortDate(_date),
                  icon: Icons.calendar_today_outlined,
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateTimeField(
                  label: l10n.searchTime,
                  value: _time.format(context),
                  icon: Icons.access_time,
                  onTap: _pickTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AppButton(
            label: l10n.searchSubmit,
            icon: Icons.search,
            onPressed: _search,
          ),
        ],
      ),
    );
  }

  Widget _buildRouteChips(List<_RouteShortcut> shortcuts) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final shortcut in shortcuts)
        ActionChip(
          avatar: Icon(
            shortcut.isFavorite ? Icons.favorite : Icons.history,
            size: 16,
          ),
          label: Text(
            AppLocalizations.of(context)!
                .searchRoutePair(shortcut.from, shortcut.to),
          ),
          onPressed: () => _selectRoute(shortcut.from, shortcut.to),
        ),
    ],
  );

  List<_RouteShortcut> _readLastTrips() {
    final items = HiveService.session.get('lastTrips')?['items'];
    if (items is! Iterable) return const [];
    return [
      for (final item in items)
        if (item is Map && item['from'] is String && item['to'] is String)
          _RouteShortcut(
            from: item['from'] as String,
            to: item['to'] as String,
          ),
    ];
  }

  List<_RouteShortcut> _readFavorites(
    String? userId,
    List<RouteLine> routes,
    Map<String, Station> stations,
  ) {
    if (userId == null) return const [];
    final routesById = {for (final route in routes) route.id: route};
    final shortcuts = <_RouteShortcut>[];
    for (final raw in HiveService.favorites.values) {
      final favorite = Favorite.fromMap(raw);
      if (favorite.userId != userId) continue;
      final route = routesById[favorite.routeId];
      final from = route == null ? null : stations[route.fromStationId]?.city;
      final to = route == null ? null : stations[route.toStationId]?.city;
      if (from != null && to != null) {
        shortcuts.add(_RouteShortcut(from: from, to: to, isFavorite: true));
      }
    }
    return shortcuts;
  }

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
        height: 126,
        child: Center(
          child: Text(AppLocalizations.of(context)!.searchNoPopularTrips),
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
          return SizedBox(
            width: 220,
            child: AppCard(
              onTap: () => _selectRoute(route.from, route.to),
              padding: const EdgeInsetsDirectional.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.route_outlined,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const Spacer(),
                  Text(
                    AppLocalizations.of(context)!
                        .searchRoutePair(route.from, route.to),
                    maxLines: 1,
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
    final onPrimary = colorScheme.onPrimary;
    return Container(
      height: 258,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadiusDirectional.only(
          bottomStart: Radius.circular(36),
          bottomEnd: Radius.circular(36),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: IconButton(
                  tooltip: l10n.profileTitle,
                  onPressed: onProfile,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    foregroundColor: onPrimary,
                    backgroundColor: onPrimary.withValues(alpha: 0.12),
                  ),
                  icon: const Icon(Icons.person_outline),
                ),
              ),
              const Spacer(),
              Text(
                l10n.greetingPassenger(firstName),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(color: onPrimary, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.searchPrompt,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: onPrimary.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CityField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _CityField({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(14),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.secondary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 2),
                    Text(
                      value ?? l10n.searchChooseCity,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              Icon(Icons.expand_more, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateTimeField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _DateTimeField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.labelSmall),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteShortcut {
  final String from;
  final String to;
  final bool isFavorite;

  const _RouteShortcut({
    required this.from,
    required this.to,
    this.isFavorite = false,
  });
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
