import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../l10n/generated/app_localizations.dart';

// ─── Palette ────────────────────────────────────────────────────────────────
const _kRed        = Color(0xFFD71935);
const _kOccupied   = Color(0xFFFF3B3B);
const _kSelected   = _kRed;

class LouageSeatLayout extends StatelessWidget {
  const LouageSeatLayout({
    required this.totalSeats,
    required this.occupiedSeats,
    required this.selectedSeats,
    required this.onSeatChanged,
    super.key,
  });

  final int totalSeats;
  final Set<int> occupiedSeats;
  final Set<int> selectedSeats;
  final void Function(int seat, bool selected) onSeatChanged;

  @override
  Widget build(BuildContext context) {
    final l10n     = AppLocalizations.of(context)!;
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final count    = totalSeats.clamp(0, 8);

    Widget seat(int n) => _Seat(
      number:   n,
      occupied: occupiedSeats.contains(n),
      selected: selectedSeats.contains(n),
      isDark:   isDark,
      onChanged: onSeatChanged,
    );

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [

            // ── Header ─────────────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_kRed, Color(0xFFAA0F28)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.directions_bus_rounded,
                    color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(l10n.bookingDriverSeat,
                  style: const TextStyle(
                    color: Colors.white, fontSize: 13.5,
                    fontWeight: FontWeight.w700, letterSpacing: 0.3)),
              ]),
            ),

            // ── Cabin ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: _Cabin(
                isDark: isDark,
                child: Column(children: [

                  // Row 1: driver + seat 1
                  Row(children: [
                    Expanded(child: _DriverBox(isDark: isDark, l10n: l10n)),
                    const SizedBox(width: 8),
                    if (count >= 1) Expanded(child: seat(1)),
                  ]),

                  if (count > 1) ...[
                    const SizedBox(height: 6),
                    _RowDivider(),
                    const SizedBox(height: 6),
                    _SeatRow(
                      seats: [2, 3].where((n) => n <= count).toList(),
                      seatBuilder: seat),
                  ],

                  if (count > 3) ...[
                    const SizedBox(height: 8),
                    _SeatRow(
                      seats: [4, 5].where((n) => n <= count).toList(),
                      seatBuilder: seat),
                  ],

                  if (count > 5) ...[
                    const SizedBox(height: 8),
                    _SeatRow(
                      seats: [6, 7, 8].where((n) => n <= count).toList(),
                      seatBuilder: seat),
                  ],
                ]),
              ),
            ),

            // ── Legend ─────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFF7F8FA),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.grey.shade200)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Legend(
                    bg: _kOccupied, iconColor: Colors.white,
                    icon: Icons.person_rounded, label: l10n.bookingTaken),
                  _Dot(),
                  _Legend(
                    bg: _kSelected, iconColor: Colors.white,
                    icon: Icons.check_rounded, label: l10n.bookingSelected),
                  _Dot(),
                  _Legend(
                    bg: Colors.white, iconColor: Colors.grey.shade400,
                    icon: Icons.event_seat_outlined, label: l10n.bookingFree,
                    border: Colors.grey.shade300),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cabin container ───────────────────────────────────────────────────────
class _Cabin extends StatelessWidget {
  const _Cabin({required this.child, required this.isDark});
  final Widget child;
  final bool   isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF7F8FA),
        borderRadius: const BorderRadius.vertical(
          top:    Radius.circular(36),
          bottom: Radius.circular(18),
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.shade200,
          width: 1.5),
      ),
      child: child,
    );
  }
}

// ── Driver box ────────────────────────────────────────────────────────────
class _DriverBox extends StatelessWidget {
  const _DriverBox({required this.isDark, required this.l10n});
  final bool             isDark;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.grey.shade200,
          width: 1.5)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.drive_eta_rounded,
          color: isDark ? Colors.white54 : Colors.grey.shade400, size: 22),
        const SizedBox(height: 3),
        Text(l10n.bookingDriverSeat,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w500,
            color: isDark ? Colors.white38 : Colors.grey.shade400)),
      ]),
    );
  }
}

// ── Row divider ───────────────────────────────────────────────────────────
class _RowDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: List.generate(14, (i) => Expanded(
      child: Container(
        height: 1.5,
        color: i.isEven ? Colors.grey.shade300 : Colors.transparent))));
  }
}

// ── Seat row ──────────────────────────────────────────────────────────────
class _SeatRow extends StatelessWidget {
  const _SeatRow({required this.seats, required this.seatBuilder});
  final List<int>             seats;
  final Widget Function(int) seatBuilder;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < seats.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: seatBuilder(seats[i])),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SEAT WIDGET
// ═══════════════════════════════════════════════════════════════════════════
class _Seat extends StatefulWidget {
  const _Seat({
    required this.number,
    required this.occupied,
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });
  final int    number;
  final bool   occupied, selected, isDark;
  final void Function(int, bool) onChanged;

  @override
  State<_Seat> createState() => _SeatState();
}

class _SeatState extends State<_Seat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    _scale = Tween<double>(begin: 1.0, end: 0.90)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _onTap() {
    if (widget.occupied) return;
    HapticFeedback.selectionClick();
    _ctrl.forward().then((_) => _ctrl.reverse());
    widget.onChanged(widget.number, !widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // State-dependent colors
    final Color bg;
    final Color fg;
    final Color border;
    final IconData icon;

    if (widget.occupied) {
      bg     = _kOccupied.withValues(alpha: 0.12);
      fg     = _kOccupied;
      border = _kOccupied.withValues(alpha: 0.35);
      icon   = Icons.person_rounded;
    } else if (widget.selected) {
      bg     = _kSelected;
      fg     = Colors.white;
      border = _kSelected;
      icon   = Icons.check_rounded;
    } else {
      bg     = widget.isDark
          ? Colors.white.withValues(alpha: 0.07)
          : Colors.white;
      fg     = widget.isDark ? Colors.white60 : Colors.grey.shade500;
      border = widget.isDark
          ? Colors.white.withValues(alpha: 0.12)
          : Colors.grey.shade200;
      icon   = Icons.event_seat_outlined;
    }

    return ScaleTransition(
      scale: _scale,
      child: Semantics(
        button: !widget.occupied,
        selected: widget.selected,
        label: '${widget.number}, ${widget.occupied ? l10n.bookingTaken : widget.selected ? l10n.bookingSelected : l10n.bookingFree}',
        child: GestureDetector(
          onTap: _onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 62,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: widget.selected ? 2 : 1.5),
              boxShadow: widget.selected ? [
                BoxShadow(color: _kRed.withValues(alpha: 0.25),
                    blurRadius: 8, offset: const Offset(0, 3)),
              ] : [],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 20, color: fg),
              const SizedBox(height: 3),
              Text('${widget.number}',
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: fg)),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Legend item ───────────────────────────────────────────────────────────
class _Legend extends StatelessWidget {
  const _Legend({
    required this.bg,
    required this.iconColor,
    required this.icon,
    required this.label,
    this.border,
  });
  final Color    bg, iconColor;
  final IconData icon;
  final String   label;
  final Color?   border;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 22, height: 22,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: border ?? bg.withValues(alpha: 0.80), width: 1.5)),
        child: Icon(icon, size: 13, color: iconColor)),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 11.5, color: Color(0xFF555555),
          fontWeight: FontWeight.w500)),
    ]);
  }
}

// ── Dot separator ─────────────────────────────────────────────────────────
class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 4, height: 4,
          decoration: BoxDecoration(
              color: Colors.grey.shade300, shape: BoxShape.circle));
}
