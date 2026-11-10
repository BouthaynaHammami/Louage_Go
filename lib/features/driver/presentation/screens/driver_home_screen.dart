import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/animated_background.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/home_greeting_header.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../features/notifications/presentation/providers/notifications_provider.dart';
import '../../../../features/driver/domain/entities/driver_dashboard_data.dart';
import '../../../../features/driver/presentation/providers/driver_home_provider.dart';
import '../../../../features/driver/presentation/providers/louage_provider.dart';
import '../widgets/driver_dashboard_stats.dart';
import '../widgets/driver_seat_map_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/app_user.dart';
import '../../../../models/booking.dart';
import '../../../../models/louage.dart';
import '../../../../models/station.dart';
import '../../../../models/trip.dart';

// ═════════════════════════════════════════════════════════════════════════════
// DriverHomeScreen — root widget
// ═════════════════════════════════════════════════════════════════════════════

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
          error: (error, _) => Scaffold(
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
                      error: (error, _) => Scaffold(
                        body: EmptyState(
                          icon: Icons.error_outline,
                          title: l10n.driverProfileUnavailable,
                        ),
                      ),
                      data: (dashboard) =>
                          _DriverDashboard(user: user, dashboard: dashboard),
                    ),
        );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// _DriverDashboard — decides pending vs validated view
// ═════════════════════════════════════════════════════════════════════════════

class _DriverDashboard extends ConsumerWidget {
  const _DriverDashboard({required this.user, required this.dashboard});

  final AppUser user;
  final DriverDashboardData dashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = dashboard.profile;
    final status = profile.validationStatus.toLowerCase();
    final validated = const {'approved', 'validated'}.contains(status);
    final rejected = const {'rejected', 'declined'}.contains(status);

    if (!validated) {
      return _PendingDashboard(
        user: user,
        rejected: rejected,
        documentsSubmitted: status == 'documentssubmitted',
      );
    }
    return _ValidatedDashboard(user: user, dashboard: dashboard);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Greeting header (shared)
// ═════════════════════════════════════════════════════════════════════════════

class _GreetingHeader extends ConsumerWidget {
  const _GreetingHeader({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final rawFirst = user.name.trim().split(RegExp(r'\s+')).firstOrNull ?? '';
    final firstName = _capitalize(rawFirst);
    final unreadCount =
        ref.watch(unreadNotificationCountProvider(user.id)).asData?.value ?? 0;
    return HomeGreetingHeader(
      greeting: l10n.driverHomeGreeting(
        firstName.isEmpty ? l10n.profileDriverFallback : firstName,
      ),
      subtitle: l10n.driverHomeSubtitle,
      profileTooltip: l10n.profileTitle,
      notificationsTooltip: l10n.adminNavNotifications,
      unreadCount: unreadCount,
      dark: true,
      compact: true,
      onNotifications: () => context.pushNamed('notifications'),
      onProfile: () => context.goNamed('driverProfile'),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PENDING DASHBOARD
// ═════════════════════════════════════════════════════════════════════════════

class _PendingDashboard extends StatelessWidget {
  const _PendingDashboard({
    required this.user,
    required this.rejected,
    required this.documentsSubmitted,
  });

  final AppUser user;
  final bool rejected;
  final bool documentsSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Stack(
      children: [
        const AnimatedBackground(intensity: BackgroundIntensity.subtle),
        Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _GreetingHeader(user: user)),
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
                              : documentsSubmitted
                              ? _ValidationStatus.submitted
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
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// VALIDATED DASHBOARD  ← Phase 3
// ═════════════════════════════════════════════════════════════════════════════

class _ValidatedDashboard extends ConsumerWidget {
  const _ValidatedDashboard({required this.user, required this.dashboard});

  final AppUser user;
  final DriverDashboardData dashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final louage = dashboard.louage;
    final station = dashboard.station;
    final trips = dashboard.trips;
    final nextTrip = trips.isEmpty ? null : _selectNextTrip(trips);

    return Stack(
      children: [
        const AnimatedBackground(intensity: BackgroundIntensity.subtle),
        Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _GreetingHeader(user: user)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── 1. Louage card ──────────────────────────────
                        _LouageInfoCard(louage: louage, station: station),
                        const SizedBox(height: 16),

                        // ── 2. Status switcher ──────────────────────────
                        if (louage != null) _StatusSwitcher(louage: louage),
                        const SizedBox(height: 20),

                        // ── 3. Next departure card ──────────────────────
                        SectionHeader(
                          title: l10n.driverCurrentTrip,
                          trailing: nextTrip == null
                              ? null
                              : StatusChip(status: nextTrip.status),
                        ),
                        const SizedBox(height: 8),
                        _NextDepartureCard(
                          trip: nextTrip,
                          louage: louage,
                          bookings: dashboard.bookings,
                        ),
                        const SizedBox(height: 20),

                        // ── 4. Quick actions ────────────────────────────
                        SectionHeader(title: l10n.driverMyLouage),
                        const SizedBox(height: 8),
                        _QuickActions(
                          tripId: nextTrip?.id,
                          louageId: louage?.id,
                        ),
                        const SizedBox(height: 20),

                        // ── 5. Statistics ───────────────────────────────
                        DriverDashboardStats(
                          driverId: user.id,
                          bookings: dashboard.bookings,
                        ),
                        const SizedBox(height: 20),

                        // ── 6. Seat map ─────────────────────────────────
                        if (nextTrip != null) ...[
                          SectionHeader(title: l10n.driverPassengersReserved),
                          const SizedBox(height: 8),
                          DriverSeatMapCard(
                            trip: nextTrip,
                            bookings: dashboard.bookings,
                            passengers: dashboard.passengers,
                          ),
                          const SizedBox(height: 20),
                        ],

                        // ── 7. Queue toggle ─────────────────────────────
                        _QueueToggle(louage: louage),
                        const SizedBox(height: 12),

                        // ── Shortcuts ───────────────────────────────────
                        _Shortcuts(),
                        const SizedBox(height: 12),

                        // ── Phase 5: Actions bonus ───────────────────────
                        OutlinedButton(
                          onPressed: () => context.pushNamed(
                            'driverActions',
                            queryParameters: nextTrip != null
                                ? {'tripId': nextTrip.id}
                                : {},
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.more_horiz_rounded),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Annonce / Signalement / Itinéraire',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
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
        ),
      ],
    );
  }

  Trip? _selectNextTrip(List<Trip> trips) {
    final now = DateTime.now();
    for (final t in trips) {
      final dep = DateTime.tryParse(t.departureTime);
      if (dep != null && dep.isAfter(now)) return t;
    }
    return trips.last;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Louage info card
// ─────────────────────────────────────────────────────────────────────────────

class _LouageInfoCard extends StatelessWidget {
  const _LouageInfoCard({required this.louage, required this.station});

  final Louage? louage;
  final Station? station;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.airport_shuttle_rounded,
              color: colors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  louage?.matricule.isEmpty != false
                      ? l10n.driverNoLouage
                      : louage!.matricule,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (louage?.modele.isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  Text(
                    louage!.modele,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        station?.localizedName(locale) ??
                            l10n.driverStationUnavailable,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colors.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (louage != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${louage!.placesTotal}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  l10n.driverSeatWord,
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Status switcher
// ─────────────────────────────────────────────────────────────────────────────

class _StatusSwitcher extends ConsumerWidget {
  const _StatusSwitcher({required this.louage});

  final Louage louage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final current = louage.statut;

    final statuses = [
      (
        LouageStatus.disponible,
        l10n.driverStatusAvailable,
        Icons.check_circle_outline,
      ),
      (
        LouageStatus.enAttente,
        l10n.driverStatusWaiting,
        Icons.hourglass_top_rounded,
      ),
      (
        LouageStatus.enDeplacement,
        l10n.driverStatusInTransit,
        Icons.directions_car_rounded,
      ),
      (
        LouageStatus.horsService,
        l10n.driverStatusOutOfService,
        Icons.cancel_outlined,
      ),
    ];

    Color chipColor(LouageStatus s) => switch (s) {
      LouageStatus.disponible => colors.tertiary,
      LouageStatus.enAttente => colors.secondary,
      LouageStatus.enDeplacement => colors.primary,
      LouageStatus.horsService => colors.error,
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.driverChangeStatus,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (status, label, icon) in statuses)
                FilterChip(
                  selected: current == status,
                  avatar: Icon(icon, size: 16),
                  label: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  selectedColor: chipColor(status).withValues(alpha: 0.18),
                  checkmarkColor: chipColor(status),
                  side: BorderSide(
                    color: current == status
                        ? chipColor(status)
                        : colors.outlineVariant,
                  ),
                  onSelected: (_) => _confirmChange(context, ref, status),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmChange(
    BuildContext context,
    WidgetRef ref,
    LouageStatus newStatus,
  ) async {
    if (newStatus == louage.statut) return;
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.driverConfirmStatus),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.authCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.driverChangeStatus),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref
          .read(louageRepositoryProvider)
          .updateStatus(louage.id, newStatus);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.driverStatusUpdated)));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.driverStatusUpdateFailed)));
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Next departure card with countdown
// ─────────────────────────────────────────────────────────────────────────────

class _NextDepartureCard extends StatefulWidget {
  const _NextDepartureCard({
    required this.trip,
    required this.louage,
    required this.bookings,
  });

  final Trip? trip;
  final Louage? louage;
  final List<Booking> bookings;

  @override
  State<_NextDepartureCard> createState() => _NextDepartureCardState();
}

class _NextDepartureCardState extends State<_NextDepartureCard> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  void _update() {
    final dep = widget.trip == null
        ? null
        : DateTime.tryParse(widget.trip!.departureTime);
    if (dep == null || !mounted) return;
    final diff = dep.difference(DateTime.now());
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final trip = widget.trip;

    if (trip == null) {
      return AppCard(
        child: EmptyState(
          icon: Icons.route_outlined,
          title: l10n.driverNoActiveTrip,
          description: l10n.driverFillUpdatesNextTrip,
        ),
      );
    }

    final dep = DateTime.tryParse(trip.departureTime);
    final reserved = trip.reservedSeats;
    final total = trip.totalSeats;
    final tripBookings = widget.bookings
        .where(
          (b) =>
              b.tripId == trip.id &&
              !const {'cancelled', 'rejected'}.contains(b.status),
        )
        .toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Departure time
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule_rounded, color: colors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    dep == null
                        ? l10n.louageDepartureUnavailable
                        : TimeOfDay.fromDateTime(dep).format(context),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              StatusChip(status: trip.status),
            ],
          ),
          if (dep != null) ...[
            const SizedBox(height: 4),
            Text(
              MaterialLocalizations.of(context).formatFullDate(dep),
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 12),

          // Seats progress
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: total > 0 ? reserved / total : 0,
                  backgroundColor: colors.outlineVariant,
                  color: reserved == total ? colors.error : colors.primary,
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 8,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$reserved/$total',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.driverSeatCounts(
              reserved.toString(),
              trip.freeSeats.toString(),
            ),
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),

          // Countdown
          if (_remaining > Duration.zero) ...[
            _CountdownBadge(remaining: _remaining),
            const SizedBox(height: 8),
          ],

          // Passengers list (compact)
          if (tripBookings.isNotEmpty) ...[
            const Divider(height: 16),
            Text(
              l10n.driverPassengersReserved,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            for (final b in tripBookings.take(3))
              Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 2),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        b.driverName.isEmpty ? '—' : b.driverName,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${b.seats} pl.',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            if (tripBookings.length > 3)
              TextButton(
                onPressed: () => context.pushNamed(
                  'driverTripDetail',
                  pathParameters: {'tripId': trip.id},
                ),
                child: Text('+${tripBookings.length - 3} autres'),
              ),
          ],
        ],
      ),
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  const _CountdownBadge({required this.remaining});
  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final h = remaining.inHours;
    final m = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    final label = h > 0 ? '${h}h $m min' : '$m:$s';
    final urgent = remaining.inMinutes < 15;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: urgent
            ? colors.error.withValues(alpha: 0.10)
            : colors.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 16,
            color: urgent ? colors.error : colors.onPrimaryContainer,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: urgent ? colors.error : colors.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Quick actions grid
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.tripId, required this.louageId});

  final String? tripId;
  final String? louageId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    final actions = [
      (
        Icons.qr_code_scanner_rounded,
        l10n.driverScanTitle,
        colors.primary,
        () => context.pushNamed(
          'driverScan',
          queryParameters: tripId != null ? {'tripId': tripId!} : {},
        ),
      ),
      (
        Icons.people_outline,
        l10n.driverPassengersReserved,
        colors.secondary,
        () => tripId != null
            ? context.pushNamed(
                'driverTripDetail',
                pathParameters: {'tripId': tripId!},
              )
            : null,
      ),
      (
        Icons.route_outlined,
        l10n.driverTripsTitle,
        colors.tertiary,
        () => context.goNamed('driverQueue'),
      ),
      (
        Icons.history_rounded,
        l10n.profileDriverReviews,
        colors.onSurfaceVariant,
        () => context.goNamed('driverReviews'),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.0,
      children: [
        for (final (icon, label, color, onTap) in actions)
          _QuickActionTile(
            icon: icon,
            label: label,
            color: color,
            onTap: onTap,
          ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: color.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(color: colors.onSurface),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Queue toggle
// ─────────────────────────────────────────────────────────────────────────────

class _QueueToggle extends ConsumerWidget {
  const _QueueToggle({required this.louage});
  final Louage? louage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final queued = louage?.isQueued ?? false;
    return AppButton(
      label: queued ? l10n.driverLeaveQueue : l10n.driverJoinQueue,
      icon: queued ? Icons.logout : Icons.queue_play_next,
      variant: queued ? AppButtonVariant.secondary : AppButtonVariant.primary,
      onPressed: louage == null
          ? null
          : () async {
              await ref.read(driverRepositoryProvider).toggleQueue(louage!.id);
              if (!context.mounted) return;
              context.goNamed('driverQueue');
            },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shortcuts (history + reviews)
// ─────────────────────────────────────────────────────────────────────────────

class _Shortcuts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.history_rounded),
            label: Text(l10n.driverTripsTitle),
            onPressed: () => context.pushNamed('driverQueue'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.star_outline_rounded),
            label: Text(l10n.profileDriverReviews),
            onPressed: () => context.goNamed('driverReviews'),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Shared: Validation banner
// ═════════════════════════════════════════════════════════════════════════════

enum _ValidationStatus { pending, submitted, validated, rejected }

class _ValidationBanner extends StatelessWidget {
  const _ValidationBanner({required this.status});
  final _ValidationStatus status;

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
      _ValidationStatus.submitted => (
        l10n.docValidationStatusSubmitted,
        Icons.pending_outlined,
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

// ═════════════════════════════════════════════════════════════════════════════
// Utility
// ═════════════════════════════════════════════════════════════════════════════

String _capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}
