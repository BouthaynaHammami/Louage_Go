import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/station.dart';
import '../../domain/nearest_stations.dart';
import '../providers/trip_search_results_provider.dart';

class NearestStationCard extends ConsumerStatefulWidget {
  const NearestStationCard({required this.stations, super.key});

  final List<Station> stations;

  @override
  ConsumerState<NearestStationCard> createState() => _NearestStationCardState();
}

class _NearestStationCardState extends ConsumerState<NearestStationCard> {
  NearestStation? _nearest;
  bool _loading = false;

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

  Future<void> _useLocation() async {
    setState(() => _loading = true);
    try {
      final result = await ref
          .read(locationServiceProvider)
          .getCurrentLocation(requestConsent: _requestConsent);
      if (!mounted) return;
      switch (result.status) {
        case LocationResultStatus.ok:
          final position = result.position;
          if (position == null) {
            _showMessage(AppLocalizations.of(context)!.locationError);
            return;
          }
          final nearest = ref.read(
            nearestStationsProvider((
              position: position,
              stations: widget.stations,
            )),
          );
          if (nearest.isEmpty) {
            _showMessage(AppLocalizations.of(context)!.locationNearestEmpty);
          } else {
            setState(() => _nearest = nearest.first);
          }
        case LocationResultStatus.denied:
          _showMessage(AppLocalizations.of(context)!.locationDenied);
        case LocationResultStatus.deniedForever:
          _showMessage(
            AppLocalizations.of(context)!.locationDeniedForever,
            actionLabel: AppLocalizations.of(context)!.locationOpenSettings,
            onAction: () => ref.read(locationServiceProvider).openAppSettings(),
          );
        case LocationResultStatus.serviceDisabled:
          _showMessage(AppLocalizations.of(context)!.locationServiceDisabled);
        case LocationResultStatus.error:
          _showMessage(AppLocalizations.of(context)!.locationError);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(
    String message, {
    String? actionLabel,
    Future<bool> Function()? onAction,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: actionLabel == null
              ? null
              : SnackBarAction(
                  label: actionLabel,
                  onPressed: () => onAction?.call(),
                ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.near_me_outlined, color: colorScheme.secondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.searchNearestStation,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: l10n.stationsMapTitle,
                onPressed: () => context.pushNamed('passengerStationsMap'),
                icon: const Icon(Icons.map_outlined),
              ),
            ],
          ),
          if (_nearest case final nearest?) ...[
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => context.pushNamed(
                'passengerStationsMap',
                queryParameters: {'stationId': nearest.station.id},
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nearest.station.localizedName(locale),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(_formatDistance(nearest.distanceMeters, locale)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.stationsMapTitle,
                      onPressed: () => context.pushNamed(
                        'passengerStationsMap',
                        queryParameters: {'stationId': nearest.station.id},
                      ),
                      icon: const Icon(Icons.map_outlined),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.goNamed(
                'passengerHome',
                queryParameters: {'fromStationId': nearest.station.id},
              ),
              icon: const Icon(Icons.search_rounded),
              label: Text(l10n.stationsSearchFrom),
            ),
          ],
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: _loading ? null : _useLocation,
            icon: _loading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_rounded),
            label: Text(l10n.locationUseMyPosition),
          ),
        ],
      ),
    );
  }

  String _formatDistance(double meters, Locale locale) {
    if (meters < 1000) return '${meters.round()} m';
    final number = NumberFormat('0.0', locale.toString()).format(meters / 1000);
    return '$number km';
  }
}
