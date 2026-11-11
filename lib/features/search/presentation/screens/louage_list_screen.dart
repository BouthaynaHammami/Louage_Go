import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/favorite_button.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/trip_search_criteria.dart';
import '../../domain/trip_filter.dart';
import '../providers/trip_search_results_provider.dart';

// ─── Palette ────────────────────────────────────────────────────────────────
const _kRed      = Color(0xFFD71935);
const _kRedLight = Color(0xFFFFF0F2);
const _kBg       = Color(0xFFF7F8FA);
const _kGreen    = Color(0xFF1B8C5A);
const _kAmber    = Color(0xFFFF8C00);

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
    return List.generate(7, (i) => today.add(Duration(days: i)));
  }

  Future<void> _openFilters(List<TripSearchResult> results) async {
    final maxP = results.fold<double>(
        0, (cur, r) => r.price > cur ? r.price : cur);
    final updated = await showModalBottomSheet<_TripFilters>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TripFiltersSheet(
        initialPrice:        _maximumPrice,
        maxPrice:            maxP > 0 ? maxP : 100,
        initialMinimumSeats: _minimumSeats,
        initialTimeRange:    _timeRange,
        initialHideFull:     _hideFull,
      ),
    );
    if (updated == null || !mounted) return;
    setState(() {
      _maximumPrice = updated.maximumPrice;
      _minimumSeats = updated.minimumSeats;
      _timeRange    = updated.timeRange;
      _hideFull     = updated.hideFull;
    });
  }

  void _resetFilters() => setState(() {
    _maximumPrice = null;
    _minimumSeats = 1;
    _timeRange    = const RangeValues(0, 1440);
    _hideFull     = false;
  });

  List<TripSearchResult> _visible(List<TripSearchResult> all) =>
      filterTripResults(all, TripFilterOptions(
        selectedDate:  _selectedDate,
        maximumPrice:  _maximumPrice,
        minimumSeats:  _minimumSeats,
        timeRange:     _timeRange,
        hideFull:      _hideFull,
        sortMode:      _sort,
      ));

  DateTime _requestedDT(DateTime day) => DateTime(
    day.year, day.month, day.day,
    widget.criteria.time.hour, widget.criteria.time.minute,
  );

  @override
  Widget build(BuildContext context) {
    final l10n        = AppLocalizations.of(context)!;
    final resultsAsync = ref.watch(tripSearchResultsProvider(widget.criteria));
    final isDark      = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).colorScheme.surface : _kBg,

      // ── AppBar ────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _kRed,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.searchRoutePair(
                  widget.criteria.from, widget.criteria.to),
              style: const TextStyle(
                color: Colors.white, fontSize: 16,
                fontWeight: FontWeight.w700),
            ),
            Text('Recherche de trajets',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 11.5)),
          ],
        ),
        actions: [
          if (resultsAsync.asData?.value.isNotEmpty ?? false)
            FavoriteButton.route(
              routeId: resultsAsync.asData!.value.first.route.id,
            ),
          IconButton(
            tooltip: l10n.searchFilterButton,
            onPressed: () => resultsAsync.whenData(_openFilters),
            icon: Badge(
              isLabelVisible: _activeFilterCount > 0,
              label: Text('$_activeFilterCount'),
              backgroundColor: Colors.white,
              textColor: _kRed,
              child: Icon(
                Icons.tune_rounded,
                color: _activeFilterCount > 0
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.85)),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),

      body: SafeArea(
        top: false,
        child: Column(children: [

          // ── Day picker band ─────────────────────────────────────────────
          _DayBand(
            days:         _days,
            selectedDate: _selectedDate,
            isDark:       isDark,
            onSelect:     (d) => setState(() => _selectedDate = d),
          ),

          // ── Sort bar ────────────────────────────────────────────────────
          _SortBar(
            sort:   _sort,
            isDark: isDark,
            hasFilters: _activeFilterCount > 0,
            l10n:   l10n,
            onSort: (v) { if (v != null) setState(() => _sort = v); },
            onReset: _activeFilterCount > 0 ? _resetFilters : null,
          ),

          // ── List ────────────────────────────────────────────────────────
          Expanded(
            child: resultsAsync.when(
              loading: () => _buildSkeletons(isDark),
              error:   (_, _) => _buildError(context, l10n),
              data:    (all) => _buildList(context, _visible(all)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildSkeletons(bool isDark) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
    itemCount: 3,
    separatorBuilder: (_, _) => const SizedBox(height: 12),
    itemBuilder: (_, _) => Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: const [
          SkeletonBox(width: 90, height: 32),
          Spacer(),
          SkeletonBox(width: 90, height: 28),
        ]),
        const SizedBox(height: 12),
        const SkeletonBox(width: double.infinity, height: 14),
        const SizedBox(height: 8),
        const SkeletonBox(width: 160, height: 12),
        const SizedBox(height: 16),
        Row(children: const [
          Expanded(child: SkeletonBox(height: 16)),
          SizedBox(width: 16),
          SkeletonBox(width: 80, height: 20),
        ]),
        const SizedBox(height: 14),
        const SkeletonBox(height: 50),
      ]),
    ),
  );

  Widget _buildError(BuildContext ctx, AppLocalizations l10n) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          color: _kRedLight, shape: BoxShape.circle),
        child: const Icon(Icons.cloud_off_rounded, color: _kRed, size: 30)),
      const SizedBox(height: 14),
      Text(l10n.searchLoadError,
        textAlign: TextAlign.center,
        style: Theme.of(ctx).textTheme.titleMedium),
      const SizedBox(height: 16),
      AppButton(
        label: l10n.searchRetry,
        variant: AppButtonVariant.secondary,
        onPressed: () =>
            ref.invalidate(tripSearchResultsProvider(widget.criteria))),
    ]),
  );

  Widget _buildList(BuildContext ctx, List<TripSearchResult> trips) {
    if (trips.isEmpty) {
      return EmptyState(
        icon:  Icons.route_outlined,
        title: AppLocalizations.of(ctx)!.searchNoLouage);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: trips.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final r = trips[i];
        return _TripCard(
          key:    ValueKey(r.trip.id),
          index:  i,
          result: r,
          afterRequested: !r.departure.isBefore(_requestedDT(_selectedDate)),
          onDetails: () => ctx.pushNamed('passengerLouageDetail',
            pathParameters: {'tripId': r.trip.id}),
          onReserve: () => ctx.pushNamed('passengerBook',
            pathParameters: {'tripId': r.trip.id}),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DAY PICKER BAND
// ═══════════════════════════════════════════════════════════════════════════
class _DayBand extends StatelessWidget {
  const _DayBand({
    required this.days,
    required this.selectedDate,
    required this.isDark,
    required this.onSelect,
  });
  final List<DateTime> days;
  final DateTime       selectedDate;
  final bool           isDark;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14141F) : Colors.white,
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final day      = days[i];
          final selected = DateUtils.isSameDay(day, selectedDate);
          final label    = i == 0
              ? l10n.searchDayToday
              : i == 1
              ? l10n.searchDayTomorrow
              : '+${i - 1}';
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelect(day);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              decoration: BoxDecoration(
                color: selected ? _kRed : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? _kRed
                      : isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.grey.shade200,
                  width: 1.5),
                boxShadow: selected ? [
                  BoxShadow(color: _kRed.withValues(alpha: 0.28),
                      blurRadius: 8, offset: const Offset(0, 3))] : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (selected)
                    const Icon(Icons.check_rounded,
                        color: Colors.white, size: 12)
                  else
                    Text(label, style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : Colors.grey.shade500)),
                  Text('${day.day}/${day.month}', style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    color: selected
                        ? Colors.white
                        : isDark ? Colors.white : const Color(0xFF1A1A1A))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SORT BAR
// ═══════════════════════════════════════════════════════════════════════════
class _SortBar extends StatelessWidget {
  const _SortBar({
    required this.sort,
    required this.isDark,
    required this.hasFilters,
    required this.l10n,
    required this.onSort,
    required this.onReset,
  });
  final TripSortMode   sort;
  final bool           isDark, hasFilters;
  final AppLocalizations l10n;
  final ValueChanged<TripSortMode?> onSort;
  final VoidCallback?  onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      color: isDark ? const Color(0xFF1A1A2E) : _kBg,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        Icon(Icons.swap_vert_rounded, size: 17,
            color: isDark ? Colors.white54 : Colors.grey.shade500),
        const SizedBox(width: 6),
        Text(l10n.searchSortLabel,
          style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500,
            color: isDark ? Colors.white54 : Colors.grey.shade500)),
        const Spacer(),
        if (hasFilters)
          GestureDetector(
            onTap: onReset,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: _kRedLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _kRed.withValues(alpha: 0.25), width: 1)),
              child: const Text('Effacer filtres',
                style: TextStyle(
                  fontSize: 11, color: _kRed,
                  fontWeight: FontWeight.w600)),
            ),
          ),
        Theme(
          data: Theme.of(context).copyWith(
            canvasColor: isDark ? const Color(0xFF1E1E2E) : Colors.white),
          child: DropdownButton<TripSortMode>(
            value: sort,
            underline: const SizedBox.shrink(),
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                color: isDark ? Colors.white60 : Colors.grey.shade600, size: 18),
            style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
            onChanged: onSort,
            items: [
              DropdownMenuItem(value: TripSortMode.time,
                  child: Text(l10n.searchSortTime)),
              DropdownMenuItem(value: TripSortMode.price,
                  child: Text(l10n.searchSortPrice)),
              DropdownMenuItem(value: TripSortMode.seats,
                  child: Text(l10n.searchSortSeats)),
            ],
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TRIP CARD — premium redesign
// ═══════════════════════════════════════════════════════════════════════════
class _TripCard extends StatefulWidget {
  const _TripCard({
    super.key,
    required this.index,
    required this.result,
    required this.afterRequested,
    required this.onDetails,
    required this.onReserve,
  });
  final int             index;
  final TripSearchResult result;
  final bool            afterRequested;
  final VoidCallback    onDetails, onReserve;

  @override
  State<_TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<_TripCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  Timer? _timer;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 380));
    _timer = Timer(Duration(milliseconds: widget.index * 65), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context)!;
    final r      = widget.result;
    final full   = r.isFull;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context);

    final fromLabel = _stationLabel(
      r.fromStation.localizedName(locale),
      r.fromStation.localizedCity(locale));
    final toLabel = _stationLabel(
      r.toStation.localizedName(locale),
      r.toStation.localizedCity(locale));

    final timeStr = TimeOfDay.fromDateTime(r.departure).format(context);
    final priceStr = _formatTripPrice(r.price);

    return FadeTransition(
      opacity: CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06), end: Offset.zero)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic)),
        child: Opacity(
          opacity: full ? 0.65 : 1.0,
          child: GestureDetector(
            onTapDown:   (_) => setState(() => _pressed = true),
            onTapUp:     (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            onTap: widget.onDetails,
            child: AnimatedScale(
              scale: _pressed ? 0.985 : 1.0,
              duration: const Duration(milliseconds: 90),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.grey.shade200,
                    width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
                      blurRadius: 14, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // ── Top stripe — heure + status + favori ─────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 14, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Heure
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(timeStr,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0E0E0E),
                                  height: 1.0)),
                              if (widget.afterRequested)
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.schedule_rounded,
                                        size: 11, color: _kAmber),
                                      const SizedBox(width: 3),
                                      Text(l10n.searchAfterRequestedTime,
                                        style: const TextStyle(
                                          fontSize: 10.5, color: _kAmber,
                                          fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          // Status chip
                          _StatusBadge(status: full ? 'full' : r.trip.status),
                          const SizedBox(width: 8),
                          // Favori
                          FavoriteButton.offer(
                            louageId:    r.louage.id,
                            departureHm: _departureHm(r.departure),
                            routeId:     r.route.id,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Divider(
                        height: 1,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.07)
                            : Colors.grey.shade100)),

                    // ── Infos route + prix ───────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Route
                                Row(children: [
                                  Icon(Icons.route_rounded,
                                    size: 14, color: _kRed),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      l10n.searchRoutePair(fromLabel, toLabel),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1A1A1A)))),
                                ]),
                                const SizedBox(height: 5),
                                // Matricule
                                _InfoRow(
                                  icon: Icons.directions_car_rounded,
                                  text: r.louage.matricule.isEmpty
                                      ? '—'
                                      : r.louage.matricule,
                                  isDark: isDark),
                                if (r.louage.modele.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  _InfoRow(
                                    icon: Icons.category_rounded,
                                    text: r.louage.modele,
                                    isDark: isDark),
                                ],
                                const SizedBox(height: 5),
                                // Rating
                                Row(children: [
                                  Icon(Icons.star_rounded,
                                    size: 14, color: _kAmber),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.louageDriverRating(
                                      r.driverReviewCount == 0
                                          ? '—'
                                          : r.driverRatingAverage.toStringAsFixed(1)),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.grey.shade500)),
                                ]),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Prix
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _kRedLight,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _kRed.withValues(alpha: 0.20), width: 1)),
                            child: Column(children: [
                              Text('$priceStr DT',
                                style: const TextStyle(
                                  color: _kRed, fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5)),
                              Text('/ place', style: TextStyle(
                                color: _kRed.withValues(alpha: 0.70),
                                fontSize: 10.5, fontWeight: FontWeight.w500)),
                            ]),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Seat bar ─────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: _SeatBar(
                        free:  r.freeSeats,
                        total: r.totalSeats,
                        isDark: isDark,
                        l10n:  l10n),
                    ),

                    const SizedBox(height: 14),

                    // ── Réserver button ──────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: _ReserveButton(
                        full:     full,
                        label:    l10n.searchReservation,
                        onPressed: full ? null : widget.onReserve),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Info row ──────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, required this.isDark});
  final IconData icon;
  final String   text;
  final bool     isDark;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 12,
          color: isDark ? Colors.white38 : Colors.grey.shade400),
      const SizedBox(width: 5),
      Expanded(child: Text(text,
        maxLines: 1, overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11.5,
          color: isDark ? Colors.white54 : Colors.grey.shade500))),
    ]);
  }
}

// ── Status badge ──────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final norm = status.toLowerCase();

    final (label, icon, fg, bg) = switch (norm) {
      'full' => (l10n.statusFull, Icons.event_busy_rounded,
          const Color(0xFFFF3B3B), const Color(0xFFFFEEEE)),
      'cancelled' => (l10n.statusCancelled, Icons.cancel_rounded,
          const Color(0xFFFF3B3B), const Color(0xFFFFEEEE)),
      'confirmed' => (l10n.statusConfirmed, Icons.verified_rounded,
          _kGreen, const Color(0xFFEDF9F2)),
      'departed' => (l10n.statusDeparted, Icons.directions_bus_rounded,
          const Color(0xFF1565C0), const Color(0xFFE8F0FE)),
      'arrived' => (l10n.statusArrived, Icons.check_circle_rounded,
          _kGreen, const Color(0xFFEDF9F2)),
      _ => (l10n.statusWaiting, Icons.schedule_rounded,
          _kAmber, const Color(0xFFFFF8E1)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.25), width: 1)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: fg),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
      ]),
    );
  }
}

// ── Seat bar ──────────────────────────────────────────────────────────────
class _SeatBar extends StatelessWidget {
  const _SeatBar({
    required this.free,
    required this.total,
    required this.isDark,
    required this.l10n,
  });
  final int   free, total;
  final bool  isDark;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final seats    = total.clamp(0, 8);
    final occupied = (seats - free.clamp(0, seats)).clamp(0, seats);
    final fraction = seats > 0 ? free.clamp(0, seats) / seats : 0.0;

    // Color: green ≥50%, amber 25-50%, red <25%
    final barColor = fraction >= 0.5
        ? _kGreen
        : fraction >= 0.25 ? _kAmber : _kRed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seat dots
        Semantics(
          label: l10n.searchSeatsAvailableSemantics(
            free.toString(), seats.toString()),
          child: ExcludeSemantics(
            child: Wrap(
              spacing: 6, runSpacing: 4,
              children: [
                for (var i = 0; i < seats; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < occupied
                          ? _kRed
                          : isDark
                              ? Colors.white.withValues(alpha: 0.15)
                              : Colors.grey.shade200,
                      border: Border.all(
                        color: i < occupied
                            ? _kRed.withValues(alpha: 0.50)
                            : isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.grey.shade300,
                        width: 1))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Progress bar
        Row(children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction.toDouble(),
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(barColor),
                minHeight: 5)),
          ),
          const SizedBox(width: 10),
          Text(l10n.searchSeatsFree(free.toString()),
            style: TextStyle(
              fontSize: 11.5, fontWeight: FontWeight.w600,
              color: barColor)),
        ]),
      ],
    );
  }
}

// ── Reserve button ────────────────────────────────────────────────────────
class _ReserveButton extends StatefulWidget {
  const _ReserveButton({
    required this.full,
    required this.label,
    required this.onPressed,
  });
  final bool         full;
  final String       label;
  final VoidCallback? onPressed;

  @override
  State<_ReserveButton> createState() => _ReserveButtonState();
}

class _ReserveButtonState extends State<_ReserveButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 80));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final enabled = !widget.full && widget.onPressed != null;
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown:   enabled ? (_) => _ctrl.forward() : null,
        onTapUp:     enabled ? (_) => _ctrl.reverse() : null,
        onTapCancel: enabled ? () => _ctrl.reverse() : null,
        onTap:       widget.onPressed,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: enabled
                ? const LinearGradient(
                    colors: [_kRed, Color(0xFFAA0F28)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight)
                : null,
            color: enabled ? null : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(14),
            boxShadow: enabled ? [
              BoxShadow(color: _kRed.withValues(alpha: 0.28),
                  blurRadius: 10, offset: const Offset(0, 4)),
            ] : [],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(
              enabled ? Icons.arrow_forward_rounded : Icons.block_rounded,
              color: enabled ? Colors.white : Colors.grey.shade400, size: 18),
            const SizedBox(width: 8),
            Text(widget.label,
              style: TextStyle(
                fontSize: 14.5, fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                color: enabled ? Colors.white : Colors.grey.shade400)),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FILTER SHEET
// ═══════════════════════════════════════════════════════════════════════════
class _TripFilters {
  const _TripFilters({
    required this.maximumPrice,
    required this.minimumSeats,
    required this.timeRange,
    required this.hideFull,
  });
  final double? maximumPrice;
  final int     minimumSeats;
  final RangeValues timeRange;
  final bool    hideFull;
}

class _TripFiltersSheet extends StatefulWidget {
  const _TripFiltersSheet({
    required this.maxPrice,
    required this.initialPrice,
    required this.initialMinimumSeats,
    required this.initialTimeRange,
    required this.initialHideFull,
  });
  final double  maxPrice;
  final double? initialPrice;
  final int     initialMinimumSeats;
  final RangeValues initialTimeRange;
  final bool    initialHideFull;

  @override
  State<_TripFiltersSheet> createState() => _TripFiltersSheetState();
}

class _TripFiltersSheetState extends State<_TripFiltersSheet> {
  late double _maxPrice;
  late int    _minSeats;
  late RangeValues _timeRange;
  late bool   _priceEnabled, _hideFull;

  @override
  void initState() {
    super.initState();
    _maxPrice     = (widget.initialPrice ?? widget.maxPrice).clamp(0, widget.maxPrice);
    _minSeats     = widget.initialMinimumSeats.clamp(0, 8);
    _timeRange    = widget.initialTimeRange;
    _priceEnabled = widget.initialPrice != null;
    _hideFull     = widget.initialHideFull;
  }

  String _tl(double v) {
    final m = v.round().clamp(0, 1439);
    return '${(m ~/ 60).toString().padLeft(2,'0')}:${(m % 60).toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: EdgeInsets.fromLTRB(
        20, 16, 20,
        MediaQuery.viewInsetsOf(context).bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),

            // Title
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: _kRedLight, shape: BoxShape.circle),
                child: const Icon(Icons.tune_rounded, color: _kRed, size: 18)),
              const SizedBox(width: 10),
              Text(l10n.searchFilterTitle,
                style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A))),
            ]),

            const SizedBox(height: 20),

            _FilterToggle(
              label: l10n.searchHideFull,
              value: _hideFull,
              onChanged: (v) => setState(() => _hideFull = v)),
            const SizedBox(height: 12),
            _FilterToggle(
              label: l10n.searchUseMaximumPrice,
              value: _priceEnabled,
              onChanged: (v) => setState(() => _priceEnabled = v)),

            // Price slider
            _SliderSection(
              label: l10n.searchMaxPrice(_maxPrice.round().toString()),
              icon: Icons.payments_rounded,
              child: Slider(
                value: _maxPrice,
                min: 0, max: widget.maxPrice,
                divisions: 20,
                label: '${_maxPrice.round()} DT',
                activeColor: _kRed,
                onChanged: _priceEnabled
                    ? (v) => setState(() => _maxPrice = v)
                    : null)),

            _SliderSection(
              label: l10n.searchMinimumSeats(_minSeats.toString()),
              icon: Icons.event_seat_rounded,
              child: Slider(
                value: _minSeats.toDouble(),
                min: 0, max: 8, divisions: 8,
                label: '$_minSeats',
                activeColor: _kRed,
                onChanged: (v) => setState(() => _minSeats = v.round()))),

            _SliderSection(
              label: l10n.searchTimeRange(_tl(_timeRange.start), _tl(_timeRange.end)),
              icon: Icons.access_time_rounded,
              child: RangeSlider(
                values: _timeRange,
                min: 0, max: 1440, divisions: 48,
                labels: RangeLabels(_tl(_timeRange.start), _tl(_timeRange.end)),
                activeColor: _kRed,
                onChanged: (v) => setState(() => _timeRange = v))),

            const SizedBox(height: 16),

            // Actions
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _maxPrice     = widget.maxPrice;
                    _minSeats     = 1;
                    _timeRange    = const RangeValues(0, 1440);
                    _priceEnabled = false;
                    _hideFull     = false;
                  }),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kRed,
                    side: const BorderSide(color: _kRed),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 13)),
                  child: Text(l10n.searchResetFilters))),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_TripFilters(
                    maximumPrice: _priceEnabled ? _maxPrice : null,
                    minimumSeats: _minSeats,
                    timeRange:    _timeRange,
                    hideFull:     _hideFull,
                  )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 13)),
                  child: Text(l10n.searchApplyFilters,
                    style: const TextStyle(fontWeight: FontWeight.w700)))),
            ]),
          ],
        ),
      ),
    );
  }
}

class _FilterToggle extends StatelessWidget {
  const _FilterToggle({required this.label, required this.value, required this.onChanged});
  final String label;
  final bool   value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Text(label,
        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A)))),
      Switch(activeThumbColor: _kRed, value: value, onChanged: onChanged),
    ]);
  }
}

class _SliderSection extends StatelessWidget {
  const _SliderSection({required this.label, required this.icon, required this.child});
  final String   label;
  final IconData icon;
  final Widget   child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(children: [
          Icon(icon, size: 14, color: _kRed),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A))),
        ]),
        child,
      ],
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────
String _formatTripPrice(double price) =>
    price == price.roundToDouble()
        ? price.toStringAsFixed(0)
        : price.toStringAsFixed(2);

String _stationLabel(String name, String city) =>
    name.isEmpty || name == city ? city : '$name, $city';

String _departureHm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
