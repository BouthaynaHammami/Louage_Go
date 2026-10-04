import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/hive_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/louage.dart';
import '../../../../models/route_line.dart';
import '../../../../models/station.dart';
import '../../../../models/trip.dart';
import '../providers/louage_provider.dart';

class DriverTripDetailScreen extends ConsumerWidget {
  const DriverTripDetailScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ref.watch(currentUserProvider).when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.driverTripDetail)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: Text(l10n.driverTripDetail)),
        body: EmptyState(icon: Icons.error_outline, title: l10n.driverOperationFailed),
      ),
      data: (user) {
        if (user == null || user.role != 'driver') {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.driverTripDetail)),
            body: EmptyState(icon: Icons.person_off_outlined, title: l10n.sessionExpired),
          );
        }
        return ref.watch(driverTripsProvider(user.id)).when(
          loading: () => Scaffold(
            appBar: AppBar(title: Text(l10n.driverTripDetail)),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Scaffold(
            appBar: AppBar(title: Text(l10n.driverTripDetail)),
            body: EmptyState(icon: Icons.error_outline, title: l10n.driverOperationFailed),
          ),
          data: (trips) {
            final matches = trips.where((trip) => trip.id == tripId);
            if (matches.isEmpty) {
              return Scaffold(
                appBar: AppBar(title: Text(l10n.driverTripDetail)),
                body: EmptyState(
                  icon: Icons.route_outlined,
                  title: l10n.louageNotFound,
                ),
              );
            }
            final trip = matches.first;
            final louageAsync = ref.watch(driverLouageProvider(user.id));
            return Scaffold(
              appBar: AppBar(title: Text(l10n.driverTripDetail)),
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: ListView(
                    padding: const EdgeInsetsDirectional.all(16),
                    children: [
                      _TripSummary(trip: trip),
                      const SizedBox(height: 12),
                      louageAsync.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (error, stackTrace) => Text(
                          l10n.driverOperationFailed,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        data: (louage) => louage == null
                            ? Text(l10n.driverNoLouage)
                            : _SeatsControl(louage: louage),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: l10n.driverScanTitle,
                        icon: Icons.qr_code_scanner,
                        onPressed: () => context.pushNamed(
                          'driverScan',
                          queryParameters: {'tripId': trip.id},
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.driverBookingsTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      ref.watch(driverTripBookingsProvider(trip.id)).when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, stackTrace) => EmptyState(
                          icon: Icons.error_outline,
                          title: l10n.driverOperationFailed,
                        ),
                        data: (bookings) {
                          if (bookings.isEmpty) {
                            return EmptyState(
                              icon: Icons.event_seat_outlined,
                              title: l10n.driverNoBookings,
                              description: l10n.driverBookingsAppearHere,
                            );
                          }
                          return Column(
                            children: [
                              for (final item in bookings)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: AppCard(
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const CircleAvatar(
                                        child: Icon(Icons.person_outline),
                                      ),
                                      title: Text(
                                        item.passenger?.name.isNotEmpty == true
                                            ? item.passenger!.name
                                            : l10n.driverPassengerFallback,
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.driverBookingPayment(
                                              _paymentLabel(
                                                l10n,
                                                item.booking.paymentStatus,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            l10n.driverBookingStatus(
                                              _bookingLabel(
                                                l10n,
                                                item.booking.status,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Text(
                                        l10n.driverBookingSeatCount(
                                          item.booking.seats.toString(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _paymentLabel(AppLocalizations l10n, String status) => switch (status) {
    'paid' => l10n.driverPaymentPaid,
    'cashOnBoard' => l10n.driverPaymentCash,
    _ => l10n.driverPaymentPending,
  };

  String _bookingLabel(AppLocalizations l10n, String status) => switch (status) {
    'confirmed' => l10n.driverBookingConfirmed,
    'validated' => l10n.driverBookingValidated,
    'cancelled' => l10n.driverBookingCancelled,
    'rejected' => l10n.driverBookingRejected,
    _ => status,
  };
}

class _TripSummary extends StatelessWidget {
  const _TripSummary({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final routeMap = HiveService.routes.get(trip.routeId);
    final route = routeMap == null ? null : RouteLine.fromMap(routeMap);
    final fromMap = route == null
        ? null
        : HiveService.stations.get(route.fromStationId);
    final toMap = route == null
        ? null
        : HiveService.stations.get(route.toStationId);
    final locale = Localizations.localeOf(context);
    final from = fromMap == null
        ? l10n.driverStationUnavailable
        : Station.fromMap(fromMap).localizedName(locale);
    final to = toMap == null
        ? l10n.driverStationUnavailable
        : Station.fromMap(toMap).localizedName(locale);
    final departure = DateTime.tryParse(trip.departureTime);
    final departureText = departure == null
        ? l10n.louageDepartureUnavailable
        : MaterialLocalizations.of(context).formatFullDate(departure);
    final timeText = departure == null
        ? ''
        : MaterialLocalizations.of(context).formatTimeOfDay(
            TimeOfDay.fromDateTime(departure),
          );
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('$from → $to', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('${l10n.driverTripDateTime} : $departureText $timeText'),
          Text('${l10n.driverTripPrice} : ${route?.pricePerSeat ?? 0} DT'),
          Text(
            l10n.driverTripSeatsAvailable(
              trip.freeSeats.toString(),
              trip.totalSeats.toString(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeatsControl extends ConsumerWidget {
  const _SeatsControl({required this.louage});

  final Louage louage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${l10n.driverAvailableSeats} : ${louage.placesDisponibles} / ${louage.placesTotal}',
              style: theme.textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: l10n.driverAvailableSeats,
            onPressed: louage.placesDisponibles == 0
                ? null
                : () => _update(ref, context, louage, -1),
            icon: const Icon(Icons.remove_circle_outline),
          ),
          IconButton(
            tooltip: l10n.driverUpdateSeats,
            onPressed: louage.placesDisponibles >= louage.placesTotal
                ? null
                : () => _update(ref, context, louage, 1),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }

  Future<void> _update(
    WidgetRef ref,
    BuildContext context,
    Louage louage,
    int delta,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(louageRepositoryProvider)
          .updateAvailableSeats(
            louage.id,
            louage.placesDisponibles + delta,
          );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.driverOperationFailed)),
      );
    }
  }
}
