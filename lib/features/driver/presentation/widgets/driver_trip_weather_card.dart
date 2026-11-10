import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/weather_service.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/route_line.dart';
import '../../../../models/station.dart';
import '../../../../models/trip.dart';
import '../providers/trip_weather_provider.dart';

class DriverTripWeatherCard extends ConsumerWidget {
  const DriverTripWeatherCard({
    super.key,
    required this.from,
    required this.to,
    this.departure,
    this.arrival,
    this.title,
    this.onTap,
  });

  final Station from;
  final Station to;
  final DateTime? departure;
  final DateTime? arrival;
  final String? title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if ((from.lat == 0 && from.lng == 0) && (to.lat == 0 && to.lng == 0)) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final departureQuery = TripWeatherQuery(
      lat: from.lat,
      lng: from.lng,
      at: departure,
    );
    final arrivalQuery = TripWeatherQuery(
      lat: to.lat,
      lng: to.lng,
      at: arrival,
    );
    final departureState = ref.watch(tripWeatherProvider(departureQuery));
    final arrivalState = ref.watch(tripWeatherProvider(arrivalQuery));
    final hasHazard =
        departureState.asData?.value.isHazardous == true ||
        arrivalState.asData?.value.isHazardous == true;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title ?? l10n.driverWeatherTitle,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _WeatherSection(
                  label: l10n.driverWeatherDeparture,
                  title: _stationCity(from, locale),
                  state: departureState,
                  onRetry: () =>
                      ref.invalidate(tripWeatherProvider(departureQuery)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WeatherSection(
                  label: l10n.driverWeatherArrival,
                  title: _stationCity(to, locale),
                  state: arrivalState,
                  onRetry: () =>
                      ref.invalidate(tripWeatherProvider(arrivalQuery)),
                ),
              ),
            ],
          ),
          if (hasHazard) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsetsDirectional.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.driverWeatherAlert,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            l10n.driverWeatherCredit,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

String _stationCity(Station station, Locale locale) {
  final city = station.localizedCity(locale);
  return city.isEmpty ? station.localizedName(locale) : city;
}

class _WeatherSection extends StatelessWidget {
  const _WeatherSection({
    required this.label,
    required this.title,
    required this.state,
    required this.onRetry,
  });

  final String label;
  final String title;
  final AsyncValue<WeatherInfo> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsetsDirectional.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.2),
      ),
      child: state.when(
        loading: () => _LoadingWeather(label: label, title: title),
        error: (_, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.driverWeatherUnavailable,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            TextButton(onPressed: onRetry, child: Text(l10n.routeRetry)),
          ],
        ),
        data: (weather) => _WeatherDetails(
          label: label,
          title: title,
          weather: weather,
          l10n: l10n,
        ),
      ),
    );
  }
}

class _LoadingWeather extends StatelessWidget {
  const _LoadingWeather({required this.label, required this.title});

  final String label;
  final String title;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 6),
      Text(
        title,
        style: Theme.of(context).textTheme.titleSmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 8),
      const SkeletonBox(width: 80, height: 18),
      const SizedBox(height: 8),
      const SkeletonBox(width: 110, height: 12),
    ],
  );
}

class _WeatherDetails extends StatelessWidget {
  const _WeatherDetails({
    required this.label,
    required this.title,
    required this.weather,
    required this.l10n,
  });

  final String label;
  final String title;
  final WeatherInfo weather;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final conditionLabel = switch (weather.condition) {
      WeatherCondition.clear => l10n.driverWeatherClear,
      WeatherCondition.cloudy => l10n.driverWeatherCloudy,
      WeatherCondition.fog => l10n.driverWeatherFog,
      WeatherCondition.rain => l10n.driverWeatherRain,
      WeatherCondition.storm => l10n.driverWeatherStorm,
      WeatherCondition.snow => l10n.driverWeatherSnow,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(
              _weatherIcon(weather.condition),
              color: _weatherColor(weather.condition),
            ),
            const SizedBox(width: 8),
            Text(
              '${weather.temperatureC.round()}°C',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(conditionLabel, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(
          '${weather.windKmh.round()} km/h'
          '${weather.precipitationProbability == null ? '' : ' · ${weather.precipitationProbability}%'}',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

IconData _weatherIcon(WeatherCondition condition) => switch (condition) {
  WeatherCondition.clear => Icons.wb_sunny_outlined,
  WeatherCondition.cloudy => Icons.cloud_outlined,
  WeatherCondition.fog => Icons.foggy,
  WeatherCondition.rain => Icons.grain,
  WeatherCondition.storm => Icons.thunderstorm_outlined,
  WeatherCondition.snow => Icons.ac_unit,
};

Color _weatherColor(WeatherCondition condition) => switch (condition) {
  WeatherCondition.clear => Colors.orange,
  WeatherCondition.cloudy => Colors.blueGrey,
  WeatherCondition.fog => Colors.grey,
  WeatherCondition.rain => Colors.blue,
  WeatherCondition.storm => Colors.deepPurple,
  WeatherCondition.snow => Colors.lightBlueAccent,
};

class DriverTripWeather extends StatelessWidget {
  const DriverTripWeather({
    super.key,
    required this.trip,
    this.title,
    this.onTap,
  });

  final Trip trip;
  final String? title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (trip.routeId.isEmpty) return const SizedBox.shrink();

    final routeMap = HiveService.routes.get(trip.routeId);
    if (routeMap == null) return const SizedBox.shrink();

    final route = RouteLine.fromMap(routeMap);
    final fromMap = HiveService.stations.get(route.fromStationId);
    final toMap = HiveService.stations.get(route.toStationId);
    if (fromMap == null || toMap == null) {
      return const SizedBox.shrink();
    }

    final from = Station.fromMap(fromMap);
    final to = Station.fromMap(toMap);
    if ((from.lat == 0 && from.lng == 0) && (to.lat == 0 && to.lng == 0)) {
      return const SizedBox.shrink();
    }

    final departure = DateTime.tryParse(trip.departureTime);
    final arrival =
        DateTime.tryParse(trip.arrivalTime) ??
        departure?.add(Duration(minutes: route.durationMin));

    return DriverTripWeatherCard(
      from: from,
      to: to,
      departure: departure,
      arrival: arrival,
      title: title,
      onTap: onTap,
    );
  }
}
