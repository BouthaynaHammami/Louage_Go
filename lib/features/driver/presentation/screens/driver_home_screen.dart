import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/home_greeting_header.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../features/notifications/presentation/providers/notifications_provider.dart';
import '../../../../features/driver/domain/entities/driver_dashboard_data.dart';
import '../../../../features/driver/domain/entities/driver_passenger.dart';
import '../../../../features/driver/presentation/providers/driver_home_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/app_user.dart';
import '../../../../models/booking.dart';
import '../../../../models/louage.dart';
import '../../../../models/station.dart';
import '../../../../models/trip.dart';

class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ref
        .watch(currentUserProvider)
        .when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) => Scaffold(
            body: EmptyState(
              icon: Icons.error_outline,
              title: l10n.driverProfileUnavailable,
            ),
          ),
          data: (user) => user == null
              ? Scaffold(
                  body: EmptyState(
                    icon: Icons.person_outline,
                    title: l10n.sessionExpired,
                  ),
                )
              : ref
                    .watch(driverDashboardProvider(user.id))
                    .when(
                      loading: () => const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, stackTrace) => Scaffold(
                        body: EmptyState(
                          icon: Icons.error_outline,
                          title: l10n.driverProfileUnavailable,
                        ),
                      ),
                      data: (dashboard) =>
                          _buildDashboard(context, user, dashboard),
                    ),
        );
  }

  Widget _buildDashboard(
    BuildContext context,
    AppUser user,
    DriverDashboardData dashboard,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final profile = dashboard.profile;
    final validated = const {
      'approved',
      'validated',
    }.contains(profile.validationStatus.toLowerCase());
    final rejected = const {
      'rejected',
      'declined',
    }.contains(profile.validationStatus.toLowerCase());

    if (!validated) {
      return _buildPendingDashboard(context, user, rejected);
    }

    final louage = dashboard.louage;
    final station = dashboard.station;
    final trips = dashboard.trips;
    final trip = trips.isEmpty ? null : _selectTrip(trips);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildGreetingHeader(context, user, l10n),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _ValidationBanner(
                          status: _ValidationStatus.validated,
                        ),
                        const SizedBox(height: 24),
                        SectionHeader(title: l10n.driverMyLouage),
                        const SizedBox(height: 12),
                        _LouageCard(louage: louage, station: station),
                        const SizedBox(height: 28),
                        SectionHeader(
                          title: l10n.driverSeatFill,
                          trailing: trip == null
                              ? null
                              : StatusChip(status: trip.status),
                        ),
                        const SizedBox(height: 12),
                        _SeatFillCard(trip: trip, louage: louage),
                        const SizedBox(height: 16),
                        _DriverQueueActions(louage: louage),
                        const SizedBox(height: 28),
                        SectionHeader(title: l10n.driverPassengersReserved),
                        const SizedBox(height: 12),
                        if (trip == null)
                          EmptyState(
                            icon: Icons.event_seat_outlined,
                            title: l10n.driverNoBookings,
                            description: l10n.driverBookingsAppearHere,
                          )
                        else
                          _PassengerReservations(
                            trip: trip,
                            bookings: dashboard.bookings,
                            passengers: dashboard.passengers,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingDashboard(
    BuildContext context,
    AppUser user,
    bool rejected,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildGreetingHeader(context, user, l10n),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ValidationBanner(
                          status: rejected
                              ? _ValidationStatus.rejected
                              : _ValidationStatus.pending,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          rejected
                              ? l10n.driverDocumentsRejectedBody
                              : l10n.driverDocumentsPendingBody,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          label: l10n.driverDocumentsSubmit,
                          icon: Icons.upload_file_outlined,
                          onPressed: () => context.goNamed('driverDocuments'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingHeader(
    BuildContext context,
    AppUser user,
    AppLocalizations l10n,
  ) {
    final firstName = user.name.trim().split(RegExp(r'\s+')).firstOrNull;
    return Consumer(
      builder: (context, ref, child) {
        final unreadCount =
            ref.watch(unreadNotificationCountProvider(user.id)).asData?.value ??
            0;
        return HomeGreetingHeader(
          greeting: l10n.driverHomeGreeting(
            firstName == null || firstName.isEmpty
                ? l10n.profileDriverFallback
                : firstName,
          ),
          subtitle: l10n.driverHomeSubtitle,
          profileTooltip: l10n.profileTitle,
          notificationsTooltip: l10n.adminNavNotifications,
          unreadCount: unreadCount,
          onNotifications: () => context.pushNamed('notifications'),
          onProfile: () => context.goNamed('driverProfile'),
        );
      },
    );
  }

  Trip? _selectTrip(List<Trip> trips) {
    final now = DateTime.now();
    for (final trip in trips) {
      final departure = DateTime.tryParse(trip.departureTime);
      if (departure != null && departure.isAfter(now)) return trip;
    }
    return trips.isEmpty ? null : trips.last;
  }
}

enum _ValidationStatus { pending, validated, rejected }

class _LouageCard extends StatelessWidget {
  const _LouageCard({required this.louage, required this.station});

  final Louage? louage;
  final Station? station;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.airport_shuttle_outlined,
              color: colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  louage?.matricule ?? l10n.driverNoLouage,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  station?.localizedName(locale) ??
                      l10n.driverStationUnavailable,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeatFillCard extends StatelessWidget {
  const _SeatFillCard({required this.trip, required this.louage});

  final Trip? trip;
  final Louage? louage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeTrip = trip;
    final reserved = activeTrip?.reservedSeats ?? 0;
    final capacity = activeTrip?.totalSeats ?? louage?.capacity ?? 8;
    final departure = activeTrip == null
        ? null
        : DateTime.tryParse(activeTrip.departureTime);

    return AppCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 400;
          final gauge = _SeatFillGauge(reserved: reserved, capacity: capacity);
          final details = Column(
            crossAxisAlignment: narrow
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Text(
                activeTrip == null
                    ? l10n.driverNoActiveTrip
                    : l10n.driverCurrentTrip,
                textAlign: narrow ? TextAlign.center : TextAlign.start,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (activeTrip == null)
                Text(
                  l10n.driverFillUpdatesNextTrip,
                  textAlign: narrow ? TextAlign.center : TextAlign.start,
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else ...[
                Text(
                  l10n.driverSeatCounts(
                    reserved.toString(),
                    activeTrip.freeSeats.toString(),
                  ),
                  textAlign: narrow ? TextAlign.center : TextAlign.start,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (departure != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.driverDepartureTime(
                      MaterialLocalizations.of(context)
                          .formatTimeOfDay(TimeOfDay.fromDateTime(departure)),
                    ),
                    textAlign: narrow ? TextAlign.center : TextAlign.start,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ],
          );
          if (narrow) {
            return Column(
              children: [
                Center(child: gauge),
                const SizedBox(height: 16),
                details,
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: Center(child: gauge)),
              const SizedBox(width: 20),
              Expanded(child: details),
            ],
          );
        },
      ),
    );
  }
}

class _ValidationBanner extends StatelessWidget {
  final _ValidationStatus status;

  const _ValidationBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final (label, icon, color) = switch (status) {
      _ValidationStatus.pending => (
        l10n.driverStatusPending,
        Icons.hourglass_top_rounded,
        scheme.secondary,
      ),
      _ValidationStatus.validated => (
        l10n.driverStatusApproved,
        Icons.verified_outlined,
        scheme.tertiary,
      ),
      _ValidationStatus.rejected => (
        l10n.driverStatusRejected,
        Icons.error_outline,
        scheme.error,
      ),
    };
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverQueueActions extends ConsumerWidget {
  final Louage? louage;

  const _DriverQueueActions({required this.louage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLouage = louage;
    final queued = currentLouage?.isQueued ?? false;
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        label: queued ? l10n.driverLeaveQueue : l10n.driverJoinQueue,
        icon: queued ? Icons.logout : Icons.queue_play_next,
        variant: queued ? AppButtonVariant.secondary : AppButtonVariant.primary,
        onPressed: currentLouage == null
            ? null
            : () async {
                await ref
                    .read(driverRepositoryProvider)
                    .toggleQueue(currentLouage.id);
                if (!context.mounted) return;
                context.goNamed('driverQueue');
              },
      ),
    );
  }
}

class _PassengerReservations extends StatelessWidget {
  final Trip trip;
  final List<Booking> bookings;
  final Map<String, DriverPassenger> passengers;

  const _PassengerReservations({
    required this.trip,
    required this.bookings,
    required this.passengers,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tripBookings = bookings
        .where(
          (booking) =>
              booking.tripId == trip.id &&
              !const {'cancelled', 'rejected'}.contains(booking.status),
        )
        .toList();

    if (tripBookings.isEmpty) {
      return EmptyState(
        icon: Icons.event_seat_outlined,
        title: l10n.driverNoBookings,
        description: l10n.driverBookingsAppearHere,
      );
    }

    return AppCard(
      padding: EdgeInsetsDirectional.zero,
      child: Column(
        children: [
          for (var index = 0; index < tripBookings.length; index++) ...[
            if (index > 0) const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              minVerticalPadding: 8,
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(
                passengers[tripBookings[index].userId]?.name ??
                    l10n.driverPassengerFallback,
              ),
              subtitle: Text(
                passengers[tripBookings[index].userId]?.phone ?? '',
              ),
              trailing: Text(
                l10n.driverBookingSeatCount(
                  tripBookings[index].seats.toString(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SeatFillGauge extends StatelessWidget {
  final int reserved;
  final int capacity;

  const _SeatFillGauge({required this.reserved, required this.capacity});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final safeCapacity = capacity <= 0 ? 8 : capacity;
    final safeReserved = reserved.clamp(0, safeCapacity);
    final color = safeReserved == safeCapacity
        ? colorScheme.error
        : colorScheme.secondary;
    return SizedBox.square(
      dimension: 142,
      child: CustomPaint(
        painter: _SeatFillPainter(
          progress: safeReserved / safeCapacity,
          trackColor: Theme.of(context).colorScheme.outlineVariant,
          progressColor: color,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$safeReserved/$safeCapacity',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              AppLocalizations.of(context)!.driverSeatWord,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _SeatFillPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  const _SeatFillPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 10.0;
    final rect = Offset.zero & size;
    final circleRect = rect.deflate(strokeWidth / 2);
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(circleRect, -1.5708, 6.2832, false, trackPaint);
    if (progress > 0) {
      canvas.drawArc(
        circleRect,
        -1.5708,
        6.2832 * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SeatFillPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      trackColor != oldDelegate.trackColor ||
      progressColor != oldDelegate.progressColor;
}
