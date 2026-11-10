import 'package:flutter/services.dart';
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
import '../providers/driver_home_provider.dart';

class DriverCreateTripScreen extends ConsumerStatefulWidget {
  const DriverCreateTripScreen({super.key});

  @override
  ConsumerState<DriverCreateTripScreen> createState() =>
      _DriverCreateTripScreenState();
}

class _DriverCreateTripScreenState
    extends ConsumerState<DriverCreateTripScreen> {
  final _priceController = TextEditingController();
  String? _fromStationId;
  String? _toStationId;
  DateTime _departureTime = DateTime.now().add(const Duration(hours: 1));
  bool _isSubmitting = false;
  bool _priceWasEdited = false;
  bool _priceSuggestionInitialized = false;
  String? _errorMessage;
  String? _priceError;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

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

        ref.watch(driverDashboardProvider(user.id));
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
            if (!_priceSuggestionInitialized) {
              _updatePriceSuggestion(_fromStationId, _toStationId);
              _priceSuggestionInitialized = true;
            }
            _priceError ??= _validatePrice(_priceController.text, l10n);

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
                                  _updatePriceSuggestion(
                                    _fromStationId,
                                    _toStationId,
                                  );
                                  _priceError = _validatePrice(
                                    _priceController.text,
                                    l10n,
                                  );
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
                                  _updatePriceSuggestion(
                                    _fromStationId,
                                    _toStationId,
                                  );
                                  _priceError = _validatePrice(
                                    _priceController.text,
                                    l10n,
                                  );
                                  _errorMessage = null;
                                }),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _priceController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*([,.]\d{0,2})?$'),
                                  ),
                                ],
                                decoration: InputDecoration(
                                  labelText: l10n.driverTripPrice,
                                  suffixText: l10n.driverCurrencyDt,
                                  errorText: _priceError,
                                ),
                                onChanged: (value) => setState(() {
                                  _priceWasEdited = true;
                                  _priceError = _validatePrice(value, l10n);
                                }),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: _DateTimeTile(
                                      label: l10n.driverDepartureDate,
                                      value: _departureTime,
                                      showTimeOnly: false,
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
                                      label: l10n.driverDepartureTimeLabel,
                                      value: _departureTime,
                                      showTimeOnly: true,
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
                                          if (route != null)
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
                                onPressed: _isSubmitting || _priceError != null
                                    ? null
                                    : _submit,
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
    final priceError = _validatePrice(_priceController.text, l10n);
    if (priceError != null) {
      setState(() => _priceError = priceError);
      return;
    }
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
      final dashboard = ref
          .read(driverDashboardProvider(user.id))
          .asData
          ?.value;
      if (dashboard == null) {
        setState(() => _errorMessage = l10n.driverOperationFailed);
        return;
      }
      if (!const {
        'approved',
        'validated',
      }.contains(dashboard.profile.validationStatus.toLowerCase())) {
        setState(() => _errorMessage = l10n.driverAccountNotValidated);
        return;
      }
      await ref
          .read(createDriverTripControllerProvider.notifier)
          .createTrip(
            driverId: user.id,
            fromStationId: _fromStationId!,
            toStationId: _toStationId!,
            departureTime: _departureTime,
            pricePerSeat: double.parse(
              _priceController.text.trim().replaceAll(',', '.'),
            ),
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
          DriverTripFailure.invalidPrice => l10n.driverTripPriceInvalid,
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

  String? _validatePrice(String value, AppLocalizations l10n) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return l10n.driverTripPriceRequired;
    final price = double.tryParse(normalized);
    if (price == null || !price.isFinite || price <= 0) {
      return l10n.driverTripPriceInvalid;
    }
    if (price > 100) return l10n.driverTripPriceTooHigh;
    if ((price * 100 - (price * 100).round()).abs() > 1e-8) {
      return l10n.driverTripPriceDecimals;
    }
    return null;
  }

  void _updatePriceSuggestion(String? fromStationId, String? toStationId) {
    if (_priceWasEdited) return;
    final route = _routeFor(fromStationId, toStationId);
    _priceController.text = route?.pricePerSeat.toStringAsFixed(2) ?? '';
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
    required this.showTimeOnly,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final DateTime value;
  final bool showTimeOnly;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final displayValue = showTimeOnly
        ? '${value.hour.toString().padLeft(2, '0')}:'
              '${value.minute.toString().padLeft(2, '0')}'
        : MaterialLocalizations.of(context).formatMediumDate(value);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minHeight: 88),
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
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayValue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
