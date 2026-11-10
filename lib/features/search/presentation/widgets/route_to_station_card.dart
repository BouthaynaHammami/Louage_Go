import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/osrm_service.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/station.dart';
import '../providers/route_to_station_provider.dart';
import '../providers/trip_search_results_provider.dart';

class RouteToStationCard extends ConsumerStatefulWidget {
  const RouteToStationCard({required this.station, super.key});

  final Station station;

  @override
  ConsumerState<RouteToStationCard> createState() => _RouteToStationCardState();
}

class _RouteToStationCardState extends ConsumerState<RouteToStationCard>
    with WidgetsBindingObserver {
  static const _refreshInterval = Duration(seconds: 30);

  late RouteToStationQuery _query;
  Timer? _refreshTimer;
  bool _isForeground = true;

  @override
  void initState() {
    super.initState();
    _query = RouteToStationQuery(
      station: widget.station,
      requestConsent: _requestConsent,
    );
    _isForeground =
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (_isForeground &&
          mounted &&
          (ModalRoute.of(context)?.isCurrent ?? true)) {
        ref.invalidate(routeToStationProvider(_query));
      }
    });
  }

  @override
  void didUpdateWidget(covariant RouteToStationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.station.id != widget.station.id ||
        oldWidget.station.lat != widget.station.lat ||
        oldWidget.station.lng != widget.station.lng) {
      _query = RouteToStationQuery(
        station: widget.station,
        requestConsent: _requestConsent,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isForeground = state == AppLifecycleState.resumed;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<bool> _requestConsent() async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.locationConsentTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.locationConsentMessage),
                TextButton(
                  onPressed: () =>
                      GoRouter.of(context).pushNamed('legalPrivacy'),
                  child: Text(l10n.locationConsentPrivacyLink),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  MaterialLocalizations.of(context).cancelButtonLabel,
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.locationConsentAccept),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final colors = Theme.of(context).colorScheme;
    final route = ref.watch(routeToStationProvider(_query));

    return AppCard(
      child: Semantics(
        container: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.directions_car_outlined, color: colors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.routeToStationTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: l10n.routeRefresh,
                  onPressed: () =>
                      ref.invalidate(routeToStationProvider(_query)),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            route.when(
              loading: () => const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 230, height: 18),
                  SizedBox(height: 10),
                  SkeletonBox(width: 150, height: 16),
                ],
              ),
              data: (info) => _buildRouteInfo(context, info, locale, l10n),
              error: (error, stackTrace) => _buildError(context, error, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteInfo(
    BuildContext context,
    RouteInfo info,
    Locale locale,
    AppLocalizations l10n,
  ) {
    if (info.distanceMeters < 100) {
      return Semantics(
        liveRegion: true,
        child: Text(
          l10n.routeArrivedAtStation,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }
    final distance = info.distanceMeters < 1000
        ? l10n.routeDistanceMeters(info.distanceMeters.round().toString())
        : l10n.routeDistanceKilometers(
            NumberFormat(
              '0.0',
              locale.toString(),
            ).format(info.distanceMeters / 1000),
          );
    final duration = info.roundedDurationMinutes < 60
        ? l10n.routeDurationMinutes(info.roundedDurationMinutes.toString())
        : l10n.routeDurationHours(
            info.durationHours.toString(),
            info.remainingDurationMinutes.toString().padLeft(2, '0'),
          );

    return Semantics(
      liveRegion: true,
      label:
          '${l10n.routeDistanceFromStation(distance)} · '
          '${l10n.routeDurationByCar(duration)}',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.routeDistanceFromStation(distance),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.routeDurationByCar(duration),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    Object error,
    AppLocalizations l10n,
  ) {
    final type = error is RouteException
        ? error.type
        : RouteExceptionType.locationUnavailable;
    final message = switch (type) {
      RouteExceptionType.network => l10n.routeErrorNetwork,
      RouteExceptionType.timeout => l10n.routeErrorTimeout,
      RouteExceptionType.noRoute => l10n.routeErrorNoRoute,
      RouteExceptionType.invalidResponse => l10n.routeErrorInvalidResponse,
      RouteExceptionType.locationDenied => l10n.locationDenied,
      RouteExceptionType.locationDeniedForever => l10n.locationDeniedForever,
      RouteExceptionType.locationServiceDisabled =>
        l10n.locationServiceDisabled,
      RouteExceptionType.locationUnavailable => l10n.locationError,
    };
    final canOpenSettings =
        type == RouteExceptionType.locationDenied ||
        type == RouteExceptionType.locationDeniedForever;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(liveRegion: true, child: Text(message)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(routeToStationProvider(_query)),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.routeRetry),
            ),
            if (canOpenSettings)
              TextButton(
                onPressed: () =>
                    ref.read(locationServiceProvider).openAppSettings(),
                child: Text(l10n.locationOpenSettings),
              ),
          ],
        ),
      ],
    );
  }
}
