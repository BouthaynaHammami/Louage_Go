import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../features/search/presentation/providers/trip_search_results_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../presentation/providers/booking_provider.dart';
import '../widgets/louage_seat_layout.dart';
import '../widgets/booking_success_sheet.dart';

// ─── Palette ────────────────────────────────────────────────────────────────
const _kRed = Color(0xFFD71935);
const _kRedLight = Color(0xFFFFF0F2);
const _kBg = Color(0xFFF7F8FA);

class BookingFlowScreen extends ConsumerStatefulWidget {
  const BookingFlowScreen({super.key, required this.tripId});
  final String tripId;

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  final _selected = <int>{};
  String _payment = 'cash';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ref
        .watch(louageDetailDataProvider(widget.tripId))
        .when(
          loading: () => const Scaffold(
            backgroundColor: _kBg,
            body: Center(child: CircularProgressIndicator(color: _kRed)),
          ),
          error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
          data: (detail) {
            if (detail == null ||
                detail.route == null ||
                detail.louage == null) {
              return AppScaffold(
                body: Center(child: Text(l10n.louageNotFound)),
              );
            }

            final trip = detail.trip;
            final price = trip.effectivePrice(detail.route);
            final from = detail.fromStation?.name ?? '';
            final to = detail.toStation?.name ?? '';
            final total = (_selected.length * price).toStringAsFixed(2);

            return Scaffold(
              backgroundColor: isDark
                  ? Theme.of(context).colorScheme.surface
                  : _kBg,

              // ── AppBar ────────────────────────────────────────────────────
              appBar: AppBar(
                backgroundColor: _kRed,
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                iconTheme: const IconThemeData(color: Colors.white),
                title: Text(
                  l10n.searchReservation,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ),

              // ── Body ──────────────────────────────────────────────────────
              body: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                children: [
                  // ── Route header card ─────────────────────────────────────
                  _RouteCard(from: from, to: to, price: price),

                  const SizedBox(height: 16),

                  // ── Seat selector ─────────────────────────────────────────
                  ref
                      .watch(occupiedSeatNumbersProvider(widget.tripId))
                      .when(
                        data: (occupied) => LouageSeatLayout(
                          totalSeats: trip.totalSeats,
                          occupiedSeats: occupied,
                          selectedSeats: _selected,
                          onSeatChanged: (seat, sel) {
                            HapticFeedback.selectionClick();
                            setState(
                              () => sel
                                  ? _selected.add(seat)
                                  : _selected.remove(seat),
                            );
                          },
                        ),
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(color: _kRed),
                          ),
                        ),
                        error: (e, _) => Text('$e'),
                      ),

                  const SizedBox(height: 16),

                  // ── Summary card ──────────────────────────────────────────
                  _SummaryCard(
                    count: _selected.length,
                    total: total,
                    payment: _payment,
                    l10n: l10n,
                    onPaymentChanged: (v) =>
                        setState(() => _payment = v ?? 'cash'),
                  ),

                  const SizedBox(height: 20),

                  // ── Confirm button ────────────────────────────────────────
                  _ConfirmButton(
                    enabled: _selected.isNotEmpty,
                    label: l10n.bookingReviewAction,
                    onTap: _selected.isEmpty ? null : _confirm,
                  ),
                ],
              ),
            );
          },
        );
  }

  // ── Confirm dialog + booking ───────────────────────────────────────────
  Future<void> _confirm() async {
    final l10n = AppLocalizations.of(context)!;
    final detail = await ref.read(
      louageDetailDataProvider(widget.tripId).future,
    );
    final price = detail?.trip.effectivePrice(detail.route) ?? 0;
    if (!mounted) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        seats: _selected.toList()..sort(),
        total: (_selected.length * price).toStringAsFixed(2),
        payment: _payment,
        l10n: l10n,
      ),
    );
    if (ok != true || !mounted) return;

    final user = await ref.read(currentUserProvider.future);
    if (user == null || !mounted) return;

    try {
      final booking = await ref
          .read(bookingRepositoryProvider)
          .create(
            userId: user.id,
            tripId: widget.tripId,
            seats: _selected.toList(),
            paymentMethod: _payment,
          );
      if (!mounted) return;
      await showBookingSuccess(
        context,
        booking: booking,
        onViewTrips: () => context.go('/passenger/trips'),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ROUTE HEADER CARD
// ═══════════════════════════════════════════════════════════════════════════
class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.from, required this.to, required this.price});
  final String from, to;
  final double price;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // From → To
          Row(
            children: [
              Expanded(
                child: _StationPill(
                  icon: Icons.trip_origin_rounded,
                  color: _kRed,
                  label: from.isEmpty ? 'Départ' : from,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.grey.shade400,
                  size: 18,
                ),
              ),
              Expanded(
                child: _StationPill(
                  icon: Icons.location_on_rounded,
                  color: const Color(0xFF1B8C5A),
                  label: to.isEmpty ? 'Arrivée' : to,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Price
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _kRedLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _kRed.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.payments_rounded, color: _kRed, size: 15),
                    const SizedBox(width: 6),
                    Text(
                      '${price.toStringAsFixed(2)} DT / place',
                      style: const TextStyle(
                        color: _kRed,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StationPill extends StatelessWidget {
  const _StationPill({
    required this.icon,
    required this.color,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.18), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUMMARY CARD
// ═══════════════════════════════════════════════════════════════════════════
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.count,
    required this.total,
    required this.payment,
    required this.l10n,
    required this.onPaymentChanged,
  });
  final int count;
  final String total, payment;
  final AppLocalizations l10n;
  final ValueChanged<String?> onPaymentChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: _kRed, size: 18),
              const SizedBox(width: 8),
              Text(
                l10n.bookingSummary(count),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Total amount
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _kRedLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                Text(
                  '$total DT',
                  style: const TextStyle(
                    color: _kRed,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Payment method
          Text(
            l10n.bookingPaymentSimulation,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 10),

          // Payment chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PayChip(
                value: 'cash',
                current: payment,
                icon: Icons.payments_outlined,
                label: l10n.bookingPayOnBoarding,
                onSelect: onPaymentChanged,
              ),
              _PayChip(
                value: 'card',
                current: payment,
                icon: Icons.credit_card_rounded,
                label: l10n.bookingCardSimulation,
                onSelect: onPaymentChanged,
              ),
              _PayChip(
                value: 'mobile',
                current: payment,
                icon: Icons.phone_iphone_rounded,
                label: l10n.bookingMobileSimulation,
                onSelect: onPaymentChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayChip extends StatelessWidget {
  const _PayChip({
    required this.value,
    required this.current,
    required this.icon,
    required this.label,
    required this.onSelect,
  });
  final String value, current, label;
  final IconData icon;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final on = value == current;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: on ? _kRed : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: on ? _kRed : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: on
              ? [
                  BoxShadow(
                    color: _kRed.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: on ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: on ? FontWeight.w700 : FontWeight.w400,
                color: on ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CONFIRM BUTTON
// ═══════════════════════════════════════════════════════════════════════════
class _ConfirmButton extends StatefulWidget {
  const _ConfirmButton({
    required this.enabled,
    required this.label,
    required this.onTap,
  });
  final bool enabled;
  final String label;
  final VoidCallback? onTap;

  @override
  State<_ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<_ConfirmButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: widget.enabled ? (_) => _ctrl.forward() : null,
        onTapUp: widget.enabled ? (_) => _ctrl.reverse() : null,
        onTapCancel: widget.enabled ? () => _ctrl.reverse() : null,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            gradient: widget.enabled
                ? const LinearGradient(
                    colors: [_kRed, Color(0xFFAA0F28)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.enabled ? null : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color: _kRed.withValues(alpha: 0.32),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: widget.enabled ? Colors.white : Colors.grey.shade500,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.enabled ? Colors.white : Colors.grey.shade500,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CONFIRM DIALOG
// ═══════════════════════════════════════════════════════════════════════════
class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.seats,
    required this.total,
    required this.payment,
    required this.l10n,
  });
  final List<int> seats;
  final String total, payment;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _kRedLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: _kRed,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.bookingReviewTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DialogRow(
            icon: Icons.event_seat_rounded,
            label: l10n.bookingSeats,
            value: seats.join(', '),
          ),
          const SizedBox(height: 10),
          _DialogRow(
            icon: Icons.payments_rounded,
            label: l10n.bookingTotal,
            value: '$total DT',
            valueColor: _kRed,
          ),
          const SizedBox(height: 10),
          _DialogRow(
            icon: Icons.credit_card_rounded,
            label: l10n.bookingPayment,
            value: payment,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kRed,
                    side: const BorderSide(color: _kRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(l10n.authCancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    l10n.bookingConfirmAction,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DialogRow extends StatelessWidget {
  const _DialogRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
  final IconData icon;
  final String label, value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _kRed, size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: valueColor ?? const Color(0xFF1A1A1A),
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
