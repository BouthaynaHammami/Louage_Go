import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/widgets/favorite_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/station.dart';
import '../providers/trip_search_results_provider.dart';

class StationsMapScreen extends ConsumerStatefulWidget {
  const StationsMapScreen({super.key, this.stationId});

  final String? stationId;

  @override
  ConsumerState<StationsMapScreen> createState() => _StationsMapScreenState();
}

class _StationsMapScreenState extends ConsumerState<StationsMapScreen> {
  static const _tunisiaCenter = LatLng(34.0, 9.5);
  static const _userAgentPackageName = 'tn.louagego.app';

  final _mapController = MapController();
  Station? _focusedStation;
  Position? _userPosition;
  bool _offline = false;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    final id = widget.stationId;
    if (id != null) {
      _focusedStation = ref.read(searchRepositoryProvider).getStation(id);
    }
  }

  LatLng get _initialCenter {
    final station = _focusedStation;
    return station == null ? _tunisiaCenter : LatLng(station.lat, station.lng);
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

  Future<void> _showMyPosition() async {
    final result = await ref
        .read(locationServiceProvider)
        .getCurrentLocation(requestConsent: _requestConsent);
    if (!mounted) return;
    if (result.status == LocationResultStatus.ok && result.position != null) {
      final position = result.position!;
      setState(() => _userPosition = position);
      if (_mapReady) {
        _mapController.move(LatLng(position.latitude, position.longitude), 13);
      }
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final message = switch (result.status) {
      LocationResultStatus.ok => l10n.locationError,
      LocationResultStatus.denied => l10n.locationDenied,
      LocationResultStatus.deniedForever => l10n.locationDeniedForever,
      LocationResultStatus.serviceDisabled => l10n.locationServiceDisabled,
      LocationResultStatus.error => l10n.locationError,
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: result.status == LocationResultStatus.deniedForever
            ? SnackBarAction(
                label: l10n.locationOpenSettings,
                onPressed: () =>
                    ref.read(locationServiceProvider).openAppSettings(),
              )
            : null,
      ),
    );
  }

  void _showStation(Station station) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final repository = ref.read(searchRepositoryProvider);
    final routeCount = repository.countRoutesFromStation(station.id);
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    station.localizedName(locale),
                    style: Theme.of(sheetContext).textTheme.titleLarge,
                  ),
                ),
                FavoriteButton.station(stationId: station.id),
              ],
            ),
            const SizedBox(height: 6),
            Text(station.address),
            const SizedBox(height: 6),
            Text(l10n.stationsMapRouteCount(routeCount)),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                context.goNamed(
                  'passengerHome',
                  queryParameters: {'fromStationId': station.id},
                );
              },
              icon: const Icon(Icons.search_rounded),
              label: Text(l10n.stationsSearchFrom),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final groups = ref.watch(stationsByGovernorateProvider);
    final stations =
        groups.asData?.value
            .expand((group) => group.stations)
            .toList(growable: false) ??
        const <Station>[];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.stationsMapTitle)),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: _focusedStation == null ? 6 : 13,
              onMapReady: () => _mapReady = true,
            ),
            children: [
              if (Theme.of(context).brightness == Brightness.dark)
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.42),
                    BlendMode.darken,
                  ),
                  child: TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: _userAgentPackageName,
                    errorTileCallback: (tile, error, stackTrace) {
                      if (!_offline && mounted) {
                        setState(() => _offline = true);
                      }
                    },
                  ),
                )
              else
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: _userAgentPackageName,
                  errorTileCallback: (tile, error, stackTrace) {
                    if (!_offline && mounted) {
                      setState(() => _offline = true);
                    }
                  },
                ),
              MarkerLayer(
                markers: [
                  for (final station in stations)
                    Marker(
                      point: LatLng(station.lat, station.lng),
                      width: 44,
                      height: 48,
                      child: IconButton(
                        tooltip: station.localizedName(
                          Localizations.localeOf(context),
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () => _showStation(station),
                        icon: Icon(
                          Icons.location_on_rounded,
                          size: 40,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ),
                  if (_userPosition case final position?)
                    Marker(
                      point: LatLng(position.latitude, position.longitude),
                      width: 50,
                      height: 50,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.person_pin_circle_rounded,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (_offline)
            PositionedDirectional(
              top: 12,
              start: 12,
              end: 76,
              child: Material(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    l10n.stationsMapUnavailable,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
              ),
            ),
          PositionedDirectional(
            top: 12,
            end: 12,
            child: Column(
              children: [
                _MapControl(
                  tooltip: l10n.stationsMapRecenter,
                  icon: Icons.center_focus_strong_rounded,
                  onPressed: () => _mapController.move(
                    _initialCenter,
                    _focusedStation == null ? 6 : 13,
                  ),
                ),
                const SizedBox(height: 8),
                _MapControl(
                  tooltip: l10n.stationsMapMyPosition,
                  icon: Icons.my_location_rounded,
                  onPressed: _showMyPosition,
                ),
              ],
            ),
          ),
          PositionedDirectional(
            bottom: 8,
            start: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  '© OpenStreetMap contributors',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapControl extends StatelessWidget {
  const _MapControl({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 3,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
