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
import '../../../../features/auth/auth_providers.dart';
import '../../../../features/search/domain/trip_search_criteria.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/favorite.dart';
import '../../domain/favorites_data.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final userAsync = ref.watch(currentUserProvider);
    final userId = userAsync.asData?.value?.id;
    final favoritesAsync = userId == null
        ? null
        : ref.watch(favoritesProvider(userId));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.passengerNavFavorites),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.favoritesTabOffers),
              Tab(text: l10n.favoritesRoutesTab),
              Tab(text: l10n.favoritesStationsTab),
            ],
          ),
        ),
        body: favoritesAsync == null
            ? const _FavoriteSkeleton()
            : favoritesAsync.when(
                loading: () => const _FavoriteSkeleton(),
                error: (error, stackTrace) => EmptyState(
                  icon: Icons.error_outline,
                  title: l10n.favoriteUpdateError,
                ),
                data: (favorites) => Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: TabBarView(
                      children: [
                        favorites.offers.isEmpty
                            ? EmptyState(
                                icon: Icons.schedule_outlined,
                                title: l10n.favoritesEmptyOffers,
                              )
                            : ListView.separated(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                  16,
                                  16,
                                  16,
                                  24,
                                ),
                                itemCount: favorites.offers.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = favorites.offers[index];
                                  final id = _favoriteId(
                                    item.favorite,
                                    'offer_${item.favorite.louageId}_${item.favorite.departureHm}',
                                  );
                                  return Dismissible(
                                    key: ValueKey(id),
                                    direction: DismissDirection.endToStart,
                                    background: _deleteBackground(context),
                                    onDismissed: (_) => _removeOffer(
                                      context,
                                      ref,
                                      userId!,
                                      item.favorite.louageId,
                                      item.favorite.departureHm,
                                      item.favorite.routeId,
                                    ),
                                    child: _offerCard(context, item),
                                  );
                                },
                              ),
                        favorites.routes.isEmpty
                            ? EmptyState(
                                icon: Icons.route_outlined,
                                title: l10n.favoritesEmptyRoutes,
                              )
                            : ListView.separated(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                  16,
                                  16,
                                  16,
                                  24,
                                ),
                                itemCount: favorites.routes.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = favorites.routes[index];
                                  final locale = Localizations.localeOf(
                                    context,
                                  );
                                  final id = _favoriteId(
                                    item.favorite,
                                    'route_${item.favorite.routeId}',
                                  );
                                  return Dismissible(
                                    key: ValueKey(id),
                                    direction: DismissDirection.endToStart,
                                    background: _deleteBackground(context),
                                    onDismissed: (_) => _removeRoute(
                                      context,
                                      ref,
                                      userId!,
                                      item.favorite.routeId,
                                    ),
                                    child: AppCard(
                                      onTap: () => context.pushNamed(
                                        'passengerSearchResults',
                                        extra: TripSearchCriteria(
                                          from: item.from,
                                          to: item.to,
                                          date: DateUtils.dateOnly(
                                            DateTime.now(),
                                          ),
                                          time: TimeOfDay.now(),
                                          fromStationId: item.fromStationId,
                                          toStationId: item.toStationId,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.route_outlined,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              l10n.searchRoutePair(
                                                locale.languageCode == 'ar' &&
                                                        item.fromAr.isNotEmpty
                                                    ? item.fromAr
                                                    : item.from,
                                                locale.languageCode == 'ar' &&
                                                        item.toAr.isNotEmpty
                                                    ? item.toAr
                                                    : item.to,
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                          ),
                                          FavoriteButton.route(
                                            routeId: item.favorite.routeId,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                        favorites.stations.isEmpty
                            ? EmptyState(
                                icon: Icons.location_on_outlined,
                                title: l10n.favoritesEmptyStations,
                              )
                            : ListView.separated(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                  16,
                                  16,
                                  16,
                                  24,
                                ),
                                itemCount: favorites.stations.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = favorites.stations[index];
                                  final id = _favoriteId(
                                    item.favorite,
                                    'station_${item.station.id}',
                                  );
                                  return Dismissible(
                                    key: ValueKey(id),
                                    direction: DismissDirection.endToStart,
                                    background: _deleteBackground(context),
                                    onDismissed: (_) => _removeStation(
                                      context,
                                      ref,
                                      userId!,
                                      item.station.id,
                                    ),
                                    child: AppCard(
                                      onTap: () => context.pushNamed(
                                        'passengerStationsMap',
                                        queryParameters: {
                                          'stationId': item.station.id,
                                        },
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              item.station.localizedName(
                                                Localizations.localeOf(context),
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                          ),
                                          FavoriteButton.station(
                                            stationId: item.station.id,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  String _favoriteId(Favorite favorite, String fallback) =>
      favorite.id.isNotEmpty ? favorite.id : '${favorite.userId}_$fallback';

  Widget _offerCard(BuildContext context, FavoriteOffer item) {
    final l10n = AppLocalizations.of(context)!;
    final trip = item.nextTrip;
    final departure = trip == null
        ? null
        : DateTime.tryParse(trip.departureTime);
    final hasAvailableSeat =
        trip != null && trip.freeSeats > 0 && trip.status != 'full';
    final route = item.route;
    final localizations = MaterialLocalizations.of(context);
    final departureLabel = departure == null
        ? l10n.favoritesNoDeparture
        : l10n.favoritesNextDeparture(
            DateUtils.isSameDay(departure, DateTime.now())
                ? l10n.searchDayToday
                : DateUtils.isSameDay(
                    departure,
                    DateUtils.dateOnly(
                      DateTime.now().add(const Duration(days: 1)),
                    ),
                  )
                ? l10n.searchDayTomorrow
                : localizations.formatShortDate(departure),
          );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.favorite.departureHm,
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              FavoriteButton.offer(
                louageId: item.favorite.louageId,
                departureHm: item.favorite.departureHm,
                routeId: item.favorite.routeId,
              ),
            ],
          ),
          Text(
            l10n.searchRoutePair(
              item.fromStation.localizedCity(Localizations.localeOf(context)),
              item.toStation.localizedCity(Localizations.localeOf(context)),
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            item.favorite.matricule.isEmpty
                ? item.louage.matricule
                : item.favorite.matricule,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.searchPricePerSeat(_formatPrice(route.pricePerSeat)),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(departureLabel, style: Theme.of(context).textTheme.bodyMedium),
          if (trip != null) ...[
            const SizedBox(height: 8),
            StatusChip(status: trip.status),
            const SizedBox(height: 8),
            SeatDots(freeSeats: trip.freeSeats, totalSeats: trip.totalSeats),
          ],
          if (!hasAvailableSeat && departure != null) ...[
            const SizedBox(height: 12),
            Text(
              l10n.favoritesNoDeparture,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 12),
          AppButton(
            label: l10n.searchReservation,
            onPressed: hasAvailableSeat
                ? () => context.pushNamed(
                    'passengerLouageDetail',
                    pathParameters: {'tripId': trip.id},
                  )
                : null,
          ),
          if (!hasAvailableSeat)
            TextButton(
              onPressed: () => context.pushNamed(
                'passengerSearchResults',
                extra: TripSearchCriteria(
                  from: item.fromStation.city,
                  to: item.toStation.city,
                  date: DateUtils.dateOnly(DateTime.now()),
                  time: _timeOfDay(item.favorite.departureHm),
                  fromStationId: item.fromStation.id,
                  toStationId: item.toStation.id,
                ),
              ),
              child: Text(l10n.favoritesOtherSchedules),
            ),
        ],
      ),
    );
  }

  TimeOfDay _timeOfDay(String value) {
    final parts = value.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts.first) ?? 0,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
  }

  String _formatPrice(double price) => price == price.roundToDouble()
      ? price.toStringAsFixed(0)
      : price.toStringAsFixed(2);

  Widget _deleteBackground(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsetsDirectional.only(end: 24),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.delete_outline, color: colors.onErrorContainer),
    );
  }

  Future<void> _removeRoute(
    BuildContext context,
    WidgetRef ref,
    String userId,
    String routeId,
  ) => _removeWithUndo(
    context,
    ref,
    action: () =>
        ref.read(favoritesRepositoryProvider).toggleRoute(userId, routeId),
  );

  Future<void> _removeStation(
    BuildContext context,
    WidgetRef ref,
    String userId,
    String stationId,
  ) => _removeWithUndo(
    context,
    ref,
    action: () =>
        ref.read(favoritesRepositoryProvider).toggleStation(userId, stationId),
  );

  Future<void> _removeOffer(
    BuildContext context,
    WidgetRef ref,
    String userId,
    String louageId,
    String departureHm,
    String routeId,
  ) => _removeWithUndo(
    context,
    ref,
    action: () => ref
        .read(favoritesRepositoryProvider)
        .toggleOffer(userId, louageId, departureHm, routeId),
  );

  Future<void> _removeWithUndo(
    BuildContext context,
    WidgetRef ref, {
    required Future<void> Function() action,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await action();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.favoriteUpdateError)));
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.favoritesRemoved),
          action: SnackBarAction(
            label: l10n.favoritesUndo,
            onPressed: () async {
              try {
                await action();
              } catch (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.favoriteUpdateError)),
                );
              }
            },
          ),
        ),
      );
  }
}

class _FavoriteSkeleton extends StatelessWidget {
  const _FavoriteSkeleton();

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: ListView(
        padding: const EdgeInsetsDirectional.all(16),
        children: const [
          SkeletonBox(height: 76),
          SizedBox(height: 12),
          SkeletonBox(height: 76),
          SizedBox(height: 12),
          SkeletonBox(height: 76),
        ],
      ),
    ),
  );
}
