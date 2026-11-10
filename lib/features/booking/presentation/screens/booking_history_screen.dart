import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/booking.dart';
import '../../data/ticket_pdf_service.dart';
import '../providers/booking_provider.dart';

// ─── Palette ────────────────────────────────────────────────────────────────
const _kRed      = Color(0xFFD71935);
const _kRedLight = Color(0xFFFFF0F2);
const _kBg       = Color(0xFFF7F8FA);
const _kGreen    = Color(0xFF1B8C5A);
const _kAmber    = Color(0xFFFF8C00);

// ─── Status helpers ──────────────────────────────────────────────────────────
(String, IconData, Color, Color) _statusStyle(
    String status, AppLocalizations l10n) =>
    switch (status.toLowerCase()) {
      'confirmed' => (l10n.statusConfirmed, Icons.verified_rounded,
          _kGreen, const Color(0xFFEDF9F2)),
      'cancelled' => (l10n.statusCancelled, Icons.cancel_rounded,
          const Color(0xFFFF3B3B), const Color(0xFFFFEEEE)),
      'departed' => (l10n.statusDeparted, Icons.directions_bus_rounded,
          const Color(0xFF1565C0), const Color(0xFFE8F0FE)),
      'arrived' => (l10n.statusArrived, Icons.check_circle_rounded,
          _kGreen, const Color(0xFFEDF9F2)),
      _ => (l10n.statusWaiting, Icons.schedule_rounded,
          _kAmber, const Color(0xFFFFF8E1)),
    };

// ═══════════════════════════════════════════════════════════════════════════
class BookingHistoryScreen extends ConsumerWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n   = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).colorScheme.surface : _kBg,

      // ── AppBar ────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _kRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.passengerNavTrips,
              style: const TextStyle(
                color: Colors.white, fontSize: 17,
                fontWeight: FontWeight.w800)),
            Text('Historique de vos réservations',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75), fontSize: 11.5)),
          ],
        ),
      ),

      // ── Body ──────────────────────────────────────────────────────────
      body: ref.watch(userBookingsProvider).when(
        loading: () => _Skeleton(isDark: isDark),
        error:   (e, _) => Center(child: Text('$e')),
        data:    (bookings) => bookings.isEmpty
            ? EmptyState(
                icon:        Icons.luggage_outlined,
                title:       l10n.bookingEmpty,
                description: 'Vos futures réservations apparaîtront ici.')
            : _BookingList(
                bookings: bookings.whereType<Booking>().toList(),
                isDark:   isDark,
                l10n:     l10n,
                ref:      ref,
              ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LIST
// ═══════════════════════════════════════════════════════════════════════════
class _BookingList extends StatelessWidget {
  const _BookingList({
    required this.bookings,
    required this.isDark,
    required this.l10n,
    required this.ref,
  });
  final List<Booking>    bookings;
  final bool             isDark;
  final AppLocalizations l10n;
  final WidgetRef        ref;

  @override
  Widget build(BuildContext context) {
    // Stats
    final total    = bookings.length;
    final active   = bookings.where((b) =>
      b.status != 'cancelled').length;
    final totalDT  = bookings.fold(0.0,
      (sum, b) => b.status != 'cancelled' ? sum + b.totalPrice : sum);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: bookings.length + 1, // +1 for stats header
      itemBuilder: (context, i) {
        if (i == 0) {
          return _StatsHeader(
            total: total, active: active,
            totalDT: totalDT, isDark: isDark);
        }
        final b = bookings[i - 1];
        return _BookingCard(
          key:    ValueKey(b.id),
          index:  i - 1,
          booking: b,
          isDark:  isDark,
          l10n:    l10n,
          onTap:   () => _showDetails(context, ref, b, l10n, isDark),
          onCancel: b.status == 'cancelled'
              ? null
              : () => _confirmCancel(context, ref, b.id, l10n),
        );
      },
    );
  }

  Future<void> _showDetails(BuildContext context, WidgetRef ref,
      Booking b, AppLocalizations l10n, bool isDark) async {
    HapticFeedback.lightImpact();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.50),
      builder: (_) => _DetailsSheet(booking: b, l10n: l10n, isDark: isDark,
        onCancel: b.status == 'cancelled'
            ? null
            : () {
                Navigator.pop(context);
                _confirmCancel(context, ref, b.id, l10n);
              }),
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref,
      String id, AppLocalizations l10n) async {
    HapticFeedback.mediumImpact();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _CancelDialog(l10n: l10n));
    if (ok != true || !context.mounted) return;
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) throw StateError('Connexion requise');
      await ref.read(bookingRepositoryProvider)
          .cancel(bookingId: id, userId: user.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Réservation annulée avec succès')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STATS HEADER
// ═══════════════════════════════════════════════════════════════════════════
class _StatsHeader extends StatelessWidget {
  const _StatsHeader({
    required this.total,
    required this.active,
    required this.totalDT,
    required this.isDark,
  });
  final int    total, active;
  final double totalDT;
  final bool   isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kRed, Color(0xFFAA0F28)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: _kRed.withValues(alpha: 0.28),
          blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: Row(children: [
        Expanded(child: _StatItem(
          value: '$total', label: 'Réservations',
          icon: Icons.confirmation_number_rounded)),
        Container(width: 1, height: 40,
            color: Colors.white.withValues(alpha: 0.25)),
        Expanded(child: _StatItem(
          value: '$active', label: 'Actives',
          icon: Icons.check_circle_rounded)),
        Container(width: 1, height: 40,
            color: Colors.white.withValues(alpha: 0.25)),
        Expanded(child: _StatItem(
          value: '${totalDT.toStringAsFixed(0)} DT',
          label: 'Dépensé',
          icon: Icons.payments_rounded)),
      ]),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });
  final String   value, label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: Colors.white.withValues(alpha: 0.80), size: 18),
      const SizedBox(height: 5),
      Text(value, style: const TextStyle(
        color: Colors.white, fontSize: 16,
        fontWeight: FontWeight.w900, letterSpacing: -0.3)),
      Text(label, style: TextStyle(
        color: Colors.white.withValues(alpha: 0.70),
        fontSize: 10.5, fontWeight: FontWeight.w500)),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BOOKING CARD
// ═══════════════════════════════════════════════════════════════════════════
class _BookingCard extends StatefulWidget {
  const _BookingCard({
    super.key,
    required this.index,
    required this.booking,
    required this.isDark,
    required this.l10n,
    required this.onTap,
    required this.onCancel,
  });
  final int             index;
  final Booking         booking;
  final bool            isDark;
  final AppLocalizations l10n;
  final VoidCallback    onTap;
  final VoidCallback?   onCancel;

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 380));
    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final b      = widget.booking;
    final isDark = widget.isDark;
    final l10n   = widget.l10n;
    final cancelled = b.status == 'cancelled';
    final (statusLabel, statusIcon, statusFg, statusBg) =
        _statusStyle(b.status, l10n);

    final hasRoute = b.fromCity.isNotEmpty && b.toCity.isNotEmpty;
    final routeLabel = hasRoute
        ? '${b.fromCity} → ${b.toCity}'
        : l10n.bookingReference;

    // Format date
    final dateStr = _formatDate(b.createdAt);
    final timeStr = _extractTime(b.departureTime);
    final priceStr = b.totalPrice.toStringAsFixed(2);
    final ref     = _refId(b.id);

    return FadeTransition(
      opacity: CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05), end: Offset.zero)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic)),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTapDown:   (_) => setState(() => _pressed = true),
            onTapUp:     (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            onTap: widget.onTap,
            child: AnimatedScale(
              scale: _pressed ? 0.985 : 1.0,
              duration: const Duration(milliseconds: 90),
              child: Opacity(
                opacity: cancelled ? 0.65 : 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.grey.shade200,
                      width: 1),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
                      blurRadius: 14, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      // ── Top: route + status ────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 14, 0),
                        child: Row(children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: _kRedLight,
                              borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.confirmation_number_rounded,
                                color: _kRed, size: 18)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(routeLabel,
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.5, fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1A1A1A))),
                                Text(ref,
                                  style: TextStyle(
                                    fontSize: 11, color: isDark
                                        ? Colors.white38
                                        : Colors.grey.shade400)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: statusFg.withValues(alpha: 0.25),
                                width: 1)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(statusIcon, size: 12, color: statusFg),
                              const SizedBox(width: 4),
                              Text(statusLabel, style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700,
                                color: statusFg)),
                            ]),
                          ),
                        ]),
                      ),

                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.07)
                              : Colors.grey.shade100)),
                      const SizedBox(height: 12),

                      // ── Middle: details grid ───────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(children: [
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _DetailChip(
                                icon:  Icons.calendar_today_rounded,
                                label: dateStr, isDark: isDark),
                              const SizedBox(height: 6),
                              _DetailChip(
                                icon:  Icons.access_time_rounded,
                                label: timeStr.isNotEmpty ? timeStr : '--:--',
                                isDark: isDark),
                              const SizedBox(height: 6),
                              _DetailChip(
                                icon:  Icons.event_seat_rounded,
                                label: b.selectedSeats.isEmpty
                                    ? l10n.bookingSeats
                                    : 'Siège(s) ${b.selectedSeats.join(', ')}',
                                isDark: isDark),
                            ],
                          )),
                          const SizedBox(width: 12),
                          // Price
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: _kRedLight,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _kRed.withValues(alpha: 0.20), width: 1)),
                            child: Column(children: [
                              Text('$priceStr DT',
                                style: const TextStyle(
                                  color: _kRed, fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5)),
                              Text('total', style: TextStyle(
                                color: _kRed.withValues(alpha: 0.65),
                                fontSize: 10.5)),
                            ]),
                          ),
                        ]),
                      ),

                      const SizedBox(height: 14),

                      // ── Bottom actions ─────────────────────────────────
                      if (!cancelled)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                          child: Row(children: [
                            Expanded(
                              child: _OutlineAction(
                                icon:  Icons.info_outline_rounded,
                                label: 'Détails',
                                onTap: widget.onTap)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _OutlineAction(
                                icon:    Icons.cancel_outlined,
                                label:   l10n.bookingCancel,
                                color:   const Color(0xFFFF3B3B),
                                onTap:   widget.onCancel)),
                          ]),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEEEE),
                              borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.cancel_rounded,
                                    color: Color(0xFFFF3B3B), size: 14),
                                const SizedBox(width: 6),
                                Text(l10n.statusCancelled,
                                  style: const TextStyle(
                                    color: Color(0xFFFF3B3B),
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Detail chip ────────────────────────────────────────────────────────────
class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label, required this.isDark});
  final IconData icon;
  final String   label;
  final bool     isDark;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 13,
          color: isDark ? Colors.white38 : Colors.grey.shade400),
      const SizedBox(width: 6),
      Expanded(child: Text(label,
        maxLines: 1, overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500,
          color: isDark ? Colors.white70 : const Color(0xFF555555)))),
    ]);
  }
}

// ── Outline action button ──────────────────────────────────────────────────
class _OutlineAction extends StatelessWidget {
  const _OutlineAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData     icon;
  final String       label;
  final VoidCallback? onTap;
  final Color?       color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? _kRed;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.withValues(alpha: 0.25), width: 1)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 15, color: c),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(
            fontSize: 12.5, fontWeight: FontWeight.w600, color: c)),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DETAILS SHEET
// ═══════════════════════════════════════════════════════════════════════════
class _DetailsSheet extends StatelessWidget {
  const _DetailsSheet({
    required this.booking,
    required this.l10n,
    required this.isDark,
    required this.onCancel,
  });
  final Booking         booking;
  final AppLocalizations l10n;
  final bool            isDark;
  final VoidCallback?   onCancel;

  @override
  Widget build(BuildContext context) {
    final b   = booking;
    final ref = _refId(b.id);
    final dateStr = _formatDate(b.createdAt);
    final timeStr = _extractTime(b.departureTime);
    final (_, __, statusFg, statusBg) = _statusStyle(b.status, l10n);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(24)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          const SizedBox(height: 10),
          Center(child: Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _kRedLight, shape: BoxShape.circle),
                child: const Icon(Icons.receipt_long_rounded,
                    color: _kRed, size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.bookingDetails,
                    style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                  Text(ref, style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.grey.shade400)),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBg, borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: statusFg.withValues(alpha: 0.25), width: 1)),
                child: Text(b.status, style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: statusFg))),
            ]),
          ),

          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.grey.shade100)),
          const SizedBox(height: 16),

          // Info rows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              if (b.fromCity.isNotEmpty || b.toCity.isNotEmpty)
                _SheetRow(icon: Icons.route_rounded, isDark: isDark,
                  label: 'Trajet',
                  value: '${b.fromCity.isEmpty ? "?" : b.fromCity} → '
                      '${b.toCity.isEmpty ? "?" : b.toCity}'),
              _SheetRow(icon: Icons.calendar_today_rounded, isDark: isDark,
                label: 'Date', value: dateStr),
              _SheetRow(icon: Icons.access_time_rounded, isDark: isDark,
                label: 'Départ', value: timeStr.isNotEmpty ? timeStr : '--:--'),
              _SheetRow(icon: Icons.event_seat_rounded, isDark: isDark,
                label: l10n.bookingSeats,
                value: b.selectedSeats.isEmpty ? '—' : b.selectedSeats.join(', ')),
              if (b.driverName.isNotEmpty)
                _SheetRow(icon: Icons.person_rounded, isDark: isDark,
                  label: l10n.bookingDriver, value: b.driverName),
              if (b.matricule.isNotEmpty)
                _SheetRow(icon: Icons.directions_car_rounded, isDark: isDark,
                  label: l10n.bookingMatricule, value: b.matricule),
              _SheetRow(icon: Icons.payments_rounded, isDark: isDark,
                label: l10n.bookingTotal,
                value: '${b.totalPrice.toStringAsFixed(2)} DT',
                valueColor: _kRed),
            ]),
          ),

          const SizedBox(height: 16),

          // Actions
          Padding(
            padding: EdgeInsets.fromLTRB(
              20, 0, 20, MediaQuery.viewPaddingOf(context).bottom + 16),
            child: Column(children: [
              // Download PDF
              _SheetButton(
                icon:  Icons.picture_as_pdf_rounded,
                label: l10n.bookingDownloadTicket,
                onTap: () async {
                  try {
                    await TicketPdfService.share(b);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('$e')));
                    }
                  }
                }),
              // Cancel
              if (onCancel != null) ...[
                const SizedBox(height: 8),
                _SheetButton(
                  icon:    Icons.cancel_outlined,
                  label:   l10n.bookingCancel,
                  color:   const Color(0xFFFF3B3B),
                  onTap:   onCancel),
              ],
            ]),
          ),
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });
  final IconData icon;
  final String   label, value;
  final bool     isDark;
  final Color?   valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(icon, size: 15, color: _kRed),
        const SizedBox(width: 10),
        Text('$label :',
          style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500,
            color: isDark ? Colors.white54 : Colors.grey.shade500)),
        const Spacer(),
        Text(value,
          style: TextStyle(
            fontSize: 13.5, fontWeight: FontWeight.w700,
            color: valueColor
                ?? (isDark ? Colors.white : const Color(0xFF1A1A1A)))),
      ]),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData     icon;
  final String       label;
  final VoidCallback? onTap;
  final Color?       color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? _kRed;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: c.withValues(alpha: 0.22), width: 1)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: c),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, color: c)),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CANCEL DIALOG
// ═══════════════════════════════════════════════════════════════════════════
class _CancelDialog extends StatelessWidget {
  const _CancelDialog({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFFFEEEE), shape: BoxShape.circle),
          child: const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFFF3B3B), size: 20)),
        const SizedBox(width: 10),
        Expanded(child: Text(l10n.bookingCancelTitle,
          style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A)))),
      ]),
      content: Text(l10n.bookingCancelMessage,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13.5)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.authCancel,
            style: TextStyle(color: Colors.grey.shade600))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF3B3B),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.bookingCancel,
            style: const TextStyle(fontWeight: FontWeight.w700))),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SKELETON
// ═══════════════════════════════════════════════════════════════════════════
class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        height: 140,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12, offset: const Offset(0, 4))]),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: const [
              SkeletonBox(width: 36, height: 36),
              SizedBox(width: 10),
              Expanded(child: SkeletonBox(height: 16)),
              SizedBox(width: 10),
              SkeletonBox(width: 80, height: 28),
            ]),
            const SizedBox(height: 14),
            const SkeletonBox(width: double.infinity, height: 12),
            const SizedBox(height: 8),
            const SkeletonBox(width: 160, height: 12),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────
String _refId(String id) {
  final clean = id.replaceAll(RegExp(r'[^0-9]'), '');
  final num   = clean.length > 5 ? clean.substring(0, 5) : clean.padLeft(5, '0');
  return 'LG-$num';
}

String _formatDate(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  const months = ['Jan','Fév','Mar','Avr','Mai','Jun',
                  'Jul','Aoû','Sep','Oct','Nov','Déc'];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

String _extractTime(String raw) {
  if (raw.isEmpty) return '';
  final d = DateTime.tryParse(raw);
  if (d != null) {
    return '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
  }
  if (raw.contains(':')) return raw.substring(0, 5);
  return raw;
}
