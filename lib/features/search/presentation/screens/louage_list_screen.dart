import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/favorite_button.dart';
import '../../../../core/widgets/seat_dots.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/trip_search_criteria.dart';
import '../../domain/trip_filter.dart';
import '../providers/trip_search_results_provider.dart';

class LouageListScreen extends ConsumerStatefulWidget {
  final TripSearchCriteria criteria;

  const LouageListScreen({super.key, required this.criteria});

  @override
  ConsumerState<LouageListScreen> createState() => _LouageListScreenState();
}

class _LouageListScreenState extends ConsumerState<LouageListScreen> {
  late DateTime _selectedDate;
  TripSortMode _sort = TripSortMode.time;
  double? _maximumPrice;
  int _minimumSeats = 1;
  RangeValues _timeRange = const RangeValues(0, 1440);
  bool _hideFull = false;

  int get _activeFilterCount =>
      (_maximumPrice == null ? 0 : 1) +
      (_minimumSeats != 1 ? 1 : 0) +
      (_timeRange.start > 0 || _timeRange.end < 1440 ? 1 : 0) +
      (_hideFull ? 1 : 0);

  @override
  void initState() {
    super.initState();
    _selectedDate = DateUtils.dateOnly(widget.criteria.date);
  }

  List<DateTime> get _days {
    final today = DateUtils.dateOnly(DateTime.now());
    return List.generate(7, (index) => today.add(Duration(days: index)));
  }

  Future<void> _openFilters(List<TripSearchResult> results) async {
    final highestPrice = results.fold<double>(
      0,
      (current, result) => result.price > current ? result.price : current,
    );
    final updated = await showModalBottomSheet<_TripFilters>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _TripFiltersSheet(
        initialPrice: _maximumPrice,
        maxPrice: highestPrice > 0 ? highestPrice : 100,
        initialMinimumSeats: _minimumSeats,
        initialTimeRange: _timeRange,
        initialHideFull: _hideFull,
      ),
    );
    if (updated == null || !mounted) return;
    setState(() {
      _maximumPrice = updated.maximumPrice;
      _minimumSeats = updated.minimumSeats;
      _timeRange = updated.timeRange;
      _hideFull = updated.hideFull;
    });
  }

  void _resetFilters() {
    setState(() {
      _maximumPrice = null;
      _minimumSeats = 1;
      _timeRange = const RangeValues(0, 1440);
      _hideFull = false;
    });
  }

  List<TripSearchResult> _visibleTrips(List<TripSearchResult> results) {
    return filterTripResults(
      results,
      TripFilterOptions(
        selectedDate: _selectedDate,
        maximumPrice: _maximumPrice,
        minimumSeats: _minimumSeats,
        timeRange: _timeRange,
        hideFull: _hideFull,
        sortMode: _sort,
      ),
    );
  }

  DateTime _requestedDateTime(DateTime day) => DateTime(
    day.year,
    day.month,
    day.day,
    widget.criteria.time.hour,
    widget.criteria.time.minute,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final resultsAsync = ref.watch(tripSearchResultsProvider(widget.criteria));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.searchRoutePair(widget.criteria.from, widget.criteria.to),
        ),
        actions: [
          if (resultsAsync.asData?.value.isNotEmpty ?? false)
            FavoriteButton.route(
              routeId: resultsAsync.asData!.value.first.route.id,
            ),
          if (_activeFilterCount > 0)
            TextButton(
              onPressed: _resetFilters,
              child: Text(l10n.searchResetFilters),
            ),
          IconButton(
            tooltip: l10n.searchFilterButton,
            onPressed: () => resultsAsync.whenData(_openFilters),
            icon: Badge(
              isLabelVisible: _activeFilterCount > 0,
              label: Text('$_activeFilterCount'),
              child: const Icon(Icons.tune),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildDayBand(context),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.swap_vert, size: 18, color: colorScheme.secondary),
                  const SizedBox(width: 8),
                  Text(
                    l10n.searchSortLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const Spacer(),
                  DropdownButton<TripSortMode>(
                    value: _sort,
                    onChanged: (value) {
                      if (value != null) setState(() => _sort = value);
                    },
                    items: [
                      DropdownMenuItem(
                        value: TripSortMode.time,
                        child: Text(l10n.searchSortTime),
                      ),
                      DropdownMenuItem(
                        value: TripSortMode.price,
                        child: Text(l10n.searchSortPrice),
                      ),
                      DropdownMenuItem(
                        value: TripSortMode.seats,
                        child: Text(l10n.searchSortSeats),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: resultsAsync.when(
                loading: _buildSkeletons,
                error: (error, stackTrace) => _buildError(context),
                data: (results) =>
                    _buildTripList(context, _visibleTrips(results)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayBand(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 8),
        itemCount: _days.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final l10n = AppLocalizations.of(context)!;
          final day = _days[index];
          final selected = DateUtils.isSameDay(day, _selectedDate);
          final label = index == 0
              ? l10n.searchDayToday
              : index == 1
              ? l10n.searchDayTomorrow
              : '+${index - 1}';
          return ChoiceChip(
            selected: selected,
            onSelected: (_) => setState(() => _selectedDate = day),
            label: Column(
              mainAxisSize: MainAxisSize.min,
              children: [Text(label), Text('${day.day}/${day.month}')],
            ),
            labelStyle: TextStyle(
              color: selected
                  ? Theme.of(context).colorScheme.onSecondary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletons() => ListView.separated(
    padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 24),
    itemCount: 3,
    separatorBuilder: (context, index) => const SizedBox(height: 12),
    itemBuilder: (context, index) => AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SkeletonBox(width: 112, height: 28),
          const SizedBox(height: 12),
          const SkeletonBox(width: 180, height: 16),
          const SizedBox(height: 18),
          Row(
            children: const [
              Expanded(child: SkeletonBox(height: 18)),
              SizedBox(width: 20),
              SkeletonBox(width: 72, height: 24),
            ],
          ),
          const SizedBox(height: 14),
          const SkeletonBox(height: 48),
        ],
      ),
    ),
  );

  Widget _buildError(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsetsDirectional.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 44,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.searchLoadError,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          AppButton(
            label: AppLocalizations.of(context)!.searchRetry,
            variant: AppButtonVariant.secondary,
            onPressed: () =>
                ref.invalidate(tripSearchResultsProvider(widget.criteria)),
          ),
        ],
      ),
    ),
  );

  Widget _buildTripList(BuildContext context, List<TripSearchResult> trips) {
    if (trips.isEmpty) {
      return EmptyState(
        icon: Icons.route_outlined,
        title: AppLocalizations.of(context)!.searchNoLouage,
      );
    }

    return ListView.separated(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
      itemCount: trips.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final result = trips[index];
        return _StaggeredTripCard(
          index: index,
          result: result,
          afterRequestedTime: !result.departure.isBefore(
            _requestedDateTime(_selectedDate),
          ),
          onReserve: () => context.pushNamed(
            'passengerLouageDetail',
            pathParameters: {'tripId': result.trip.id},
          ),
        );
      },
    );
  }
}

class _TripFilters {
  final double? maximumPrice;
  final int minimumSeats;
  final RangeValues timeRange;
  final bool hideFull;

  const _TripFilters({
    required this.maximumPrice,
    required this.minimumSeats,
    required this.timeRange,
    required this.hideFull,
  });
}

class _TripFiltersSheet extends StatefulWidget {
  final double maxPrice;
  final double? initialPrice;
  final int initialMinimumSeats;
  final RangeValues initialTimeRange;
  final bool initialHideFull;

  const _TripFiltersSheet({
    required this.maxPrice,
    required this.initialPrice,
    required this.initialMinimumSeats,
    required this.initialTimeRange,
    required this.initialHideFull,
  });

  @override
  State<_TripFiltersSheet> createState() => _TripFiltersSheetState();
}

class _TripFiltersSheetState extends State<_TripFiltersSheet> {
  late double _maximumPrice;
  late int _minimumSeats;
  late RangeValues _timeRange;
  late bool _priceEnabled;
  late bool _hideFull;

  @override
  void initState() {
    super.initState();
    _maximumPrice = (widget.initialPrice ?? widget.maxPrice).clamp(
      0,
      widget.maxPrice,
    );
    _minimumSeats = widget.initialMinimumSeats.clamp(0, 8);
    _timeRange = widget.initialTimeRange;
    _priceEnabled = widget.initialPrice != null;
    _hideFull = widget.initialHideFull;
  }

  String _timeLabel(double minuteValue) {
    final minute = minuteValue.round().clamp(0, 1439);
    return '${(minute ~/ 60).toString().padLeft(2, '0')}:${(minute % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        20,
        16,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.searchFilterTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.searchHideFull),
              value: _hideFull,
              onChanged: (value) => setState(() => _hideFull = value),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.searchUseMaximumPrice),
              value: _priceEnabled,
              onChanged: (value) => setState(() => _priceEnabled = value),
            ),
            Text(l10n.searchMaxPrice(_maximumPrice.round().toString())),
            Slider(
              value: _maximumPrice,
              min: 0,
              max: widget.maxPrice,
              divisions: 20,
              label: '${_maximumPrice.round()} DT',
              onChanged: _priceEnabled
                  ? (value) => setState(() => _maximumPrice = value)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(l10n.searchMinimumSeats(_minimumSeats.toString())),
            Slider(
              value: _minimumSeats.toDouble(),
              min: 0,
              max: 8,
              divisions: 8,
              label: '$_minimumSeats',
              onChanged: (value) =>
                  setState(() => _minimumSeats = value.round()),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.searchTimeRange(
                _timeLabel(_timeRange.start),
                _timeLabel(_timeRange.end),
              ),
            ),
            RangeSlider(
              values: _timeRange,
              min: 0,
              max: 1440,
              divisions: 48,
              labels: RangeLabels(
                _timeLabel(_timeRange.start),
                _timeLabel(_timeRange.end),
              ),
              onChanged: (values) => setState(() => _timeRange = values),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: l10n.searchResetFilters,
              variant: AppButtonVariant.secondary,
              onPressed: () => setState(() {
                _maximumPrice = widget.maxPrice;
                _minimumSeats = 1;
                _timeRange = const RangeValues(0, 1440);
                _priceEnabled = false;
                _hideFull = false;
              }),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: l10n.searchApplyFilters,
              onPressed: () => Navigator.of(context).pop(
                _TripFilters(
                  maximumPrice: _priceEnabled ? _maximumPrice : null,
                  minimumSeats: _minimumSeats,
                  timeRange: _timeRange,
                  hideFull: _hideFull,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaggeredTripCard extends StatefulWidget {
  final int index;
  final TripSearchResult result;
  final bool afterRequestedTime;
  final VoidCallback onReserve;

  const _StaggeredTripCard({
    required this.index,
    required this.result,
    required this.afterRequestedTime,
    required this.onReserve,
  });

  @override
  State<_StaggeredTripCard> createState() => _StaggeredTripCardState();
}

class _StaggeredTripCardState extends State<_StaggeredTripCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _staggerTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _staggerTimer = Timer(Duration(milliseconds: widget.index * 70), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _staggerTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final result = widget.result;
    final full = result.isFull;
    final colorScheme = Theme.of(context).colorScheme;
    final priceColor = colorScheme.primary;

    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
        child: AppCard(
          padding: const EdgeInsetsDirectional.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FavoriteButton.offer(
                    louageId: result.louage.id,
                    departureHm: _departureHm(result.departure),
                    routeId: result.route.id,
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      TimeOfDay.fromDateTime(result.departure).format(context),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
                    ),
                  ),
                  StatusChip(status: full ? 'full' : result.trip.status),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.route_outlined,
                    size: 18,
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.searchRoutePair(
                        result.fromStation.localizedCity(
                          Localizations.localeOf(context),
                        ),
                        result.toStation.localizedCity(
                          Localizations.localeOf(context),
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                result.louage.matricule,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              if (widget.afterRequestedTime) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: colorScheme.tertiary),
                    const SizedBox(width: 6),
                    Text(
                      l10n.searchAfterRequestedTime,
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(color: colorScheme.tertiary),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SeatDots(
                      freeSeats: result.freeSeats,
                      totalSeats: result.totalSeats,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_formatTripPrice(result.price)} DT',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: priceColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppButton(
                label: l10n.searchReservation,
                icon: Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_back
                    : Icons.arrow_forward,
                onPressed: full ? null : widget.onReserve,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatTripPrice(double price) => price == price.roundToDouble()
    ? price.toStringAsFixed(0)
    : price.toStringAsFixed(2);

String _departureHm(DateTime departure) =>
    '${departure.hour.toString().padLeft(2, '0')}:${departure.minute.toString().padLeft(2, '0')}';
