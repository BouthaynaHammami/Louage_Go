import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/hive_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/route_line.dart';
import '../../../../models/station.dart';
import '../../domain/louage_repository.dart';
import '../providers/louage_provider.dart';

class DriverCreateTripScreen extends ConsumerStatefulWidget {
  const DriverCreateTripScreen({super.key});

  @override
  ConsumerState<DriverCreateTripScreen> createState() =>
      _DriverCreateTripScreenState();
}

class _DriverCreateTripScreenState
    extends ConsumerState<DriverCreateTripScreen> {
  String? _fromStationId;
  String? _toStationId;
  DateTime _departureTime = DateTime.now().add(const Duration(hours: 1));
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.driverCreateTripTitle)),
        body: Center(child: Text(l10n.driverOperationFailed)),
      ),
      data: (user) {
        if (user == null || user.role != 'driver') {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.driverCreateTripTitle)),
            body: Center(child: Text(l10n.sessionExpired)),
          );
        }

        final louageAsync = ref.watch(driverLouageProvider(user.id));
        return louageAsync.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (_, _) => Scaffold(
            appBar: AppBar(title: Text(l10n.driverCreateTripTitle)),
            body: Center(child: Text(l10n.driverOperationFailed)),
          ),
          data: (louage) {
            final stations = HiveService.stations.values
                .map(Station.fromMap)
                .where((station) => station.id.isNotEmpty)
                .toList();
            if (stations.isEmpty) {
              return Scaffold(
                appBar: AppBar(title: Text(l10n.driverCreateTripTitle)),
                body: Center(child: Text(l10n.driverOperationFailed)),
              );
            }

            final louageStation = louage?.stationActuelle;
            final fallbackFrom =
                stations.any((station) => station.id == louageStation)
                ? louageStation!
                : stations.first.id;
            if (_fromStationId == null ||
                !stations.any((s) => s.id == _fromStationId)) {
              _fromStationId = fallbackFrom;
            }
            final destinationOptions = stations
                .where((station) => station.id != _fromStationId)
                .toList();
            if (_toStationId == null ||
                !destinationOptions.any(
                  (station) => station.id == _toStationId,
                )) {
              _toStationId = destinationOptions.isEmpty
                  ? _fromStationId
                  : destinationOptions.first.id;
            }

            final route = _routeFor(_fromStationId, _toStationId);

            return Scaffold(
              appBar: AppBar(title: Text(l10n.driverCreateTripTitle)),
              body: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: ListView(
                      padding: const EdgeInsetsDirectional.all(20),
                      children: [
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.driverCreateTripSubtitle,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 20),
                              _StationField(
                                label: l10n.driverCurrentStation,
                                value: _fromStationId,
                                stations: stations,
                                onChanged: (value) => setState(() {
                                  _fromStationId = value;
                                  if (_toStationId == value) {
                                    final next = stations
                                        .where((station) => station.id != value)
                                        .toList();
                                    _toStationId = next.isEmpty
                                        ? value
                                        : next.first.id;
                                  }
                                  _errorMessage = null;
                                }),
                              ),
                              const SizedBox(height: 14),
                              _StationField(
                                label: l10n.driverDestination,
                                value: _toStationId,
                                stations: stations
                                    .where(
                                      (station) => station.id != _fromStationId,
                                    )
                                    .toList(),
                                onChanged: (value) => setState(() {
                                  _toStationId = value;
                                  _errorMessage = null;
                                }),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: _DateTimeTile(
                                      label: l10n.driverDepartureDate,
                                      value: _departureTime,
                                      icon: Icons.calendar_today_rounded,
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: _departureTime,
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now().add(
                                            const Duration(days: 365),
                                          ),
                                        );
                                        if (picked == null) return;
                                        setState(() {
                                          _departureTime = DateTime(
                                            picked.year,
                                            picked.month,
                                            picked.day,
                                            _departureTime.hour,
                                            _departureTime.minute,
                                          );
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _DateTimeTile(
                                      label: l10n.driverDepartureTime(
                                        MaterialLocalizations.of(context)
                                            .formatTimeOfDay(
                                              TimeOfDay.fromDateTime(
                                                _departureTime,
                                              ),
                                            ),
                                      ),
                                      value: _departureTime,
                                      icon: Icons.access_time_rounded,
                                      onTap: () async {
                                        final picked = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.fromDateTime(
                                            _departureTime,
                                          ),
                                        );
                                        if (picked == null) return;
                                        setState(() {
                                          _departureTime = DateTime(
                                            _departureTime.year,
                                            _departureTime.month,
                                            _departureTime.day,
                                            picked.hour,
                                            picked.minute,
                                          );
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              if (route != null) ...[
                                Container(
                                  padding: const EdgeInsetsDirectional.all(14),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest
                                        .withValues(alpha: 0.24),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              l10n.driverTripPreview,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelLarge,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '${l10n.driverTripPrice}: ${route.pricePerSeat.toStringAsFixed(0)} DT',
                                            ),
                                            Text(
                                              '${l10n.driverTripDuration}: ${route.durationMin} min',
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.route_rounded,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 14),
                              if (_errorMessage != null)
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    bottom: 10,
                                  ),
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error,
                                    ),
                                  ),
                                ),
                              AppButton(
                                label: l10n.driverPublishTrip,
                                icon: Icons.publish_rounded,
                                isLoading: _isSubmitting,
                                onPressed: _isSubmitting ? null : _submit,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_fromStationId == null || _toStationId == null) {
      setState(() => _errorMessage = l10n.driverStationRequired);
      return;
    }
    if (_fromStationId == _toStationId) {
      setState(() => _errorMessage = l10n.driverTripSameStation);
      return;
    }

    final user = switch (ref.read(currentUserProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (user == null || user.role != 'driver') {
      setState(() => _errorMessage = l10n.sessionExpired);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(createDriverTripControllerProvider.notifier)
          .createTrip(
            driverId: user.id,
            fromStationId: _fromStationId!,
            toStationId: _toStationId!,
            departureTime: _departureTime,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.driverTripPublished)));
      context.pop();
    } on DriverTripException catch (error) {
      if (!mounted) return;
      setState(
        () => _errorMessage = switch (error.failure) {
          DriverTripFailure.louageMissing => l10n.driverLouageMissing,
          DriverTripFailure.louageOutOfService => l10n.driverLouageOutOfService,
          DriverTripFailure.stationRequired => l10n.driverStationRequired,
          DriverTripFailure.sameStation => l10n.driverTripSameStation,
          DriverTripFailure.departureInPast => l10n.driverDepartureInPast,
          DriverTripFailure.duplicateDeparture => l10n.driverDuplicateDeparture,
          DriverTripFailure.tripMissing => l10n.driverTripMissing,
          DriverTripFailure.tripNotWaiting => l10n.driverTripNotWaiting,
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = l10n.driverTripCreationError);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  RouteLine? _routeFor(String? fromStationId, String? toStationId) {
    if (fromStationId == null ||
        toStationId == null ||
        fromStationId.isEmpty ||
        toStationId.isEmpty ||
        fromStationId == toStationId) {
      return null;
    }
    for (final map in HiveService.routes.values) {
      final route = RouteLine.fromMap(map);
      if (route.fromStationId == fromStationId &&
          route.toStationId == toStationId) {
        return route;
      }
    }
    return null;
  }
}

class _StationField extends StatelessWidget {
  const _StationField({
    required this.label,
    required this.value,
    required this.stations,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<Station> stations;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.location_on_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      items: [
        for (final station in stations)
          DropdownMenuItem<String>(
            value: station.id,
            child: Text(
              station.nameAr.isNotEmpty && currentLocale.languageCode == 'ar'
                  ? station.nameAr
                  : station.name,
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _DateTimeTile extends StatelessWidget {
  const _DateTimeTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final DateTime value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatted = MaterialLocalizations.of(context).formatFullDate(value);
    final time = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(value));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsetsDirectional.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 4),
                  Text('$formatted · $time'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
