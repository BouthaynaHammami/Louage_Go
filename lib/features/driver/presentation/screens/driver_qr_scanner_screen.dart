import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/trip.dart';
import '../../domain/entities/ticket_validation_result.dart';
import '../providers/louage_provider.dart';

class DriverQrScannerScreen extends ConsumerStatefulWidget {
  const DriverQrScannerScreen({super.key, this.initialTripId});

  final String? initialTripId;

  @override
  ConsumerState<DriverQrScannerScreen> createState() =>
      _DriverQrScannerScreenState();
}

class _DriverQrScannerScreenState extends ConsumerState<DriverQrScannerScreen> {
  String? _selectedTripId;
  TicketValidationResult? _result;
  String? _error;
  bool _validating = false;

  @override
  void initState() {
    super.initState();
    _selectedTripId = widget.initialTripId;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ref
        .watch(currentUserProvider)
        .when(
          loading: () => Scaffold(
            appBar: AppBar(title: Text(l10n.driverScanTitle)),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Scaffold(
            appBar: AppBar(title: Text(l10n.driverScanTitle)),
            body: EmptyState(
              icon: Icons.error_outline,
              title: l10n.driverOperationFailed,
            ),
          ),
          data: (user) {
            if (user == null || user.role != 'driver') {
              return Scaffold(
                appBar: AppBar(title: Text(l10n.driverScanTitle)),
                body: EmptyState(
                  icon: Icons.person_off_outlined,
                  title: l10n.sessionExpired,
                ),
              );
            }
            return ref
                .watch(driverTripsProvider(user.id))
                .when(
                  loading: () => Scaffold(
                    appBar: AppBar(title: Text(l10n.driverScanTitle)),
                    body: const Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stackTrace) => Scaffold(
                    appBar: AppBar(title: Text(l10n.driverScanTitle)),
                    body: EmptyState(
                      icon: Icons.error_outline,
                      title: l10n.driverOperationFailed,
                    ),
                  ),
                  data: (trips) => _scanner(context, user.id, trips),
                );
          },
        );
  }

  Widget _scanner(BuildContext context, String driverId, List<Trip> trips) {
    final l10n = AppLocalizations.of(context)!;
    if (trips.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.driverScanTitle)),
        body: EmptyState(
          icon: Icons.route_outlined,
          title: l10n.driverTripsEmpty,
        ),
      );
    }
    if (!trips.any((trip) => trip.id == _selectedTripId)) {
      _selectedTripId = trips.first.id;
    }
    final result = _result;
    final (message, icon, color) = switch (result?.status) {
      TicketValidationStatus.valid => (
        l10n.driverScanValid,
        Icons.check_circle_outline,
        Theme.of(context).colorScheme.tertiary,
      ),
      TicketValidationStatus.alreadyUsed => (
        l10n.driverScanUsed,
        Icons.history,
        Theme.of(context).colorScheme.error,
      ),
      TicketValidationStatus.invalid => (
        l10n.driverScanInvalid,
        Icons.cancel_outlined,
        Theme.of(context).colorScheme.error,
      ),
      null => (
        '',
        Icons.qr_code_scanner,
        Theme.of(context).colorScheme.primary,
      ),
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.driverScanTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsetsDirectional.all(20),
            children: [
              Text(
                l10n.driverScanInstructions,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedTripId,
                decoration: InputDecoration(
                  labelText: l10n.driverScanSelectTrip,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  for (final trip in trips)
                    DropdownMenuItem(
                      value: trip.id,
                      child: Text(_tripLabel(trip)),
                    ),
                ],
                onChanged: (value) => setState(() {
                  _selectedTripId = value;
                  _result = null;
                  _error = null;
                }),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 360,
                  child: _validating
                      ? const Center(child: CircularProgressIndicator())
                      : result != null || _error != null
                      ? ColoredBox(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          child: Center(
                            child: Icon(icon, size: 88, color: color),
                          ),
                        )
                      : MobileScanner(
                          onDetect: (capture) {
                            final rawValue = capture.barcodes
                                .map((barcode) => barcode.rawValue)
                                .whereType<String>()
                                .firstOrNull;
                            if (rawValue != null) {
                              _validate(driverId, rawValue);
                            }
                          },
                        ),
                ),
              ),
              if (result != null || _error != null) ...[
                const SizedBox(height: 12),
                AppCard(
                  child: Row(
                    children: [
                      Icon(
                        _error == null ? icon : Icons.error_outline,
                        color: _error == null
                            ? color
                            : Theme.of(context).colorScheme.error,
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error ?? message,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => setState(() {
                    _result = null;
                    _error = null;
                  }),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.searchRetry),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _tripLabel(Trip trip) =>
      '${trip.departureTime.isEmpty ? trip.id : trip.departureTime} · ${trip.id}';

  Future<void> _validate(String driverId, String qrPayload) async {
    if (_validating || _result != null || _selectedTripId == null) return;
    setState(() => _validating = true);
    try {
      final result = await ref
          .read(louageRepositoryProvider)
          .validateTicket(
            driverId: driverId,
            tripId: _selectedTripId!,
            qrPayload: qrPayload,
          );
      if (mounted) setState(() => _result = result);
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _error =
            '${AppLocalizations.of(context)!.driverOperationFailed} $error',
      );
    } finally {
      if (mounted) setState(() => _validating = false);
    }
  }
}
