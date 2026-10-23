import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../features/notifications/presentation/providers/notifications_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/booking.dart';
import '../../../../models/station.dart';
import '../../../../models/trip.dart';
import '../widgets/driver_app_bar.dart';
import '../providers/driver_home_provider.dart';

// ═════════════════════════════════════════════════════════════════════════════
// DriverActionsScreen — Phase 5 bonus
// Contains: announce delay · report problem · navigate to station
// ═════════════════════════════════════════════════════════════════════════════

class DriverActionsScreen extends ConsumerWidget {
  const DriverActionsScreen({super.key, this.tripId});
  final String? tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return ref
        .watch(currentUserProvider)
        .when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (err, _) => Scaffold(
            appBar: driverAppBar(context, l10n.driverHomeTitle),
            body: Center(child: Text(l10n.driverProfileUnavailable)),
          ),
          data: (user) {
            if (user == null) {
              return Scaffold(
                appBar: driverAppBar(context, l10n.driverHomeTitle),
                body: Center(child: Text(l10n.sessionExpired)),
              );
            }
            return ref
                .watch(driverDashboardProvider(user.id))
                .when(
                  loading: () => const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => Scaffold(
                    appBar: driverAppBar(context, l10n.driverHomeTitle),
                    body: Center(child: Text(l10n.driverProfileUnavailable)),
                  ),
                  data: (dashboard) {
                    final trips = dashboard.trips;
                    final station = dashboard.station;
                    final nextTrip = tripId != null
                        ? trips.firstWhere(
                            (t) => t.id == tripId,
                            orElse: () =>
                                trips.isEmpty ? const Trip() : trips.first,
                          )
                        : trips.isEmpty
                        ? null
                        : _selectNext(trips);

                    return Scaffold(
                      appBar: driverAppBar(context, l10n.driverHomeTitle),
                      body: ListView(
                        padding: const EdgeInsetsDirectional.all(20),
                        children: [
                          // 1. Announce delay
                          if (nextTrip != null)
                            _DelayCard(
                              trip: nextTrip,
                              driverId: user.id,
                              bookings: dashboard.bookings,
                            ),
                          const SizedBox(height: 14),

                          // 2. Report a problem
                          if (nextTrip != null)
                            _ReportCard(
                              trip: nextTrip,
                              driverId: user.id,
                              bookings: dashboard.bookings,
                            ),
                          const SizedBox(height: 14),

                          // 3. Navigate to station
                          _NavigateCard(station: station),
                        ],
                      ),
                    );
                  },
                );
          },
        );
  }

  Trip? _selectNext(List<Trip> trips) {
    final now = DateTime.now();
    for (final t in trips) {
      final dep = DateTime.tryParse(t.departureTime);
      if (dep != null && dep.isAfter(now)) return t;
    }
    return trips.last;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Announce delay card
// ─────────────────────────────────────────────────────────────────────────────

class _DelayCard extends ConsumerStatefulWidget {
  const _DelayCard({
    required this.trip,
    required this.driverId,
    required this.bookings,
  });

  final Trip trip;
  final String driverId;
  final List<Booking> bookings;

  @override
  ConsumerState<_DelayCard> createState() => _DelayCardState();
}

class _DelayCardState extends ConsumerState<_DelayCard> {
  TimeOfDay? _newTime;
  final _reasonCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final dep = DateTime.tryParse(widget.trip.departureTime);
    final depTime = dep == null ? null : TimeOfDay.fromDateTime(dep);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.alarm_rounded, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                l10n.driverDelayTitle,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (dep != null)
            Text(
              '${l10n.bookingDeparture} : ${depTime?.format(context) ?? '—'}',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.access_time_rounded),
            label: Text(
              _newTime == null
                  ? l10n.driverDelayNewTime
                  : _newTime!.format(context),
            ),
            onPressed: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: depTime ?? TimeOfDay.now(),
              );
              if (picked != null) setState(() => _newTime = picked);
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reasonCtrl,
            decoration: InputDecoration(
              labelText: l10n.driverDelayReason,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: l10n.driverDelayConfirm,
            icon: Icons.send_rounded,
            isLoading: _sending,
            onPressed: _newTime == null ? null : () => _send(context, l10n),
          ),
        ],
      ),
    );
  }

  Future<void> _send(BuildContext context, AppLocalizations l10n) async {
    setState(() => _sending = true);
    // Capture context-dependent values BEFORE any await gap
    final timeLabel = _newTime?.format(context) ?? '';
    final messenger = ScaffoldMessenger.of(context);
    final reason = _reasonCtrl.text.trim();

    try {
      final notifRepo = ref.read(notificationRepositoryProvider);
      final passengerIds = widget.bookings
          .where(
            (b) =>
                b.tripId == widget.trip.id &&
                !const {'cancelled', 'rejected'}.contains(b.status),
          )
          .map((b) => b.userId)
          .toSet();

      final msg = reason.isEmpty
          ? '${l10n.driverDelayTitle} : $timeLabel'
          : '${l10n.driverDelayTitle} : $timeLabel — $reason';

      for (final uid in passengerIds) {
        await notifRepo.create(
          userId: uid,
          title: l10n.driverDelayTitle,
          message: msg,
          type: 'trip_delay',
          route: '/passenger/trips',
          messageId:
              'delay-${widget.trip.id}-$uid-${DateTime.now().millisecondsSinceEpoch}',
        );
      }

      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.driverDelaySuccess)));
      setState(() => _newTime = null);
      _reasonCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.driverOperationFailed)),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Report a problem card
// ─────────────────────────────────────────────────────────────────────────────

class _ReportCard extends ConsumerStatefulWidget {
  const _ReportCard({
    required this.trip,
    required this.driverId,
    required this.bookings,
  });

  final Trip trip;
  final String driverId;
  final List<Booking> bookings;

  @override
  ConsumerState<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends ConsumerState<_ReportCard> {
  String _type = 'delay';
  final _detailCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _detailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    final types = [
      ('breakdown', l10n.driverReportBreakdown, Icons.car_crash_outlined),
      ('delay', l10n.driverReportDelay, Icons.alarm_off_outlined),
      ('other', l10n.driverReportOther, Icons.report_outlined),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.report_problem_outlined, color: colors.error),
              const SizedBox(width: 8),
              Text(
                l10n.driverReportTitle,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Type selector chips
          Wrap(
            spacing: 8,
            children: [
              for (final (id, label, icon) in types)
                ChoiceChip(
                  selected: _type == id,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 16),
                      const SizedBox(width: 4),
                      Text(label),
                    ],
                  ),
                  onSelected: (_) => setState(() => _type = id),
                ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _detailCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l10n.driverDelayReason,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: l10n.driverReportSend,
            icon: Icons.send_rounded,
            variant: AppButtonVariant.secondary,
            isLoading: _sending,
            onPressed: () => _send(context, l10n),
          ),
        ],
      ),
    );
  }

  Future<void> _send(BuildContext context, AppLocalizations l10n) async {
    setState(() => _sending = true);
    // Capture context-dependent values BEFORE any await gap
    final messenger = ScaffoldMessenger.of(context);
    final detail = _detailCtrl.text.trim();

    try {
      final notifRepo = ref.read(notificationRepositoryProvider);
      final passengerIds = widget.bookings
          .where(
            (b) =>
                b.tripId == widget.trip.id &&
                !const {'cancelled', 'rejected'}.contains(b.status),
          )
          .map((b) => b.userId)
          .toSet();

      final typeLabel = switch (_type) {
        'breakdown' => l10n.driverReportBreakdown,
        'delay' => l10n.driverReportDelay,
        _ => l10n.driverReportOther,
      };
      final msg = detail.isEmpty ? typeLabel : '$typeLabel : $detail';

      for (final uid in passengerIds) {
        await notifRepo.create(
          userId: uid,
          title: l10n.driverReportTitle,
          message: msg,
          type: 'trip_problem',
          route: '/passenger/trips',
          messageId:
              'report-${widget.trip.id}-$uid-${DateTime.now().millisecondsSinceEpoch}',
        );
      }

      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.driverReportSuccess)));
      _detailCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.driverOperationFailed)),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Navigate to station card
// ─────────────────────────────────────────────────────────────────────────────

class _NavigateCard extends StatelessWidget {
  const _NavigateCard({required this.station});
  final Station? station;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);
    final st = station;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.navigation_rounded, color: colors.tertiary),
              const SizedBox(width: 8),
              Text(
                l10n.driverNavigateTitle,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (st != null) ...[
            Text(
              st.localizedName(locale),
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            if (st.address.isNotEmpty)
              Text(
                st.address,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
          ] else
            Text(
              l10n.driverStationUnavailable,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Google Maps',
                  icon: Icons.map_outlined,
                  onPressed: st != null && st.lat != 0
                      ? () => _openMaps(context, l10n, st, 'google')
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: 'Waze',
                  icon: Icons.navigation_outlined,
                  variant: AppButtonVariant.secondary,
                  onPressed: st != null && st.lat != 0
                      ? () => _openMaps(context, l10n, st, 'waze')
                      : null,
                ),
              ),
            ],
          ),
          if (st == null || st.lat == 0) ...[
            const SizedBox(height: 8),
            Text(
              l10n.driverNavigateNoCoords,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: colors.error),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openMaps(
    BuildContext context,
    AppLocalizations l10n,
    Station station,
    String app,
  ) async {
    final lat = station.lat;
    final lng = station.lng;
    final uri = app == 'waze'
        ? Uri.parse('https://waze.com/ul?ll=$lat,$lng&navigate=yes')
        : Uri.parse(
            'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
          );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.supportContactUnavailable)));
      }
    }
  }
}
