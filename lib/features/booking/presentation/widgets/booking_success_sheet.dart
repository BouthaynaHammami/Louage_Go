import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../models/booking.dart';
import 'send_ticket_email_button.dart';

// ─── Palette ────────────────────────────────────────────────────────────────
const _kRed = Color(0xFFD71935);
const _kRedLight = Color(0xFFFFF0F2);
const _kGreen = Color(0xFF1B9C5A);
const _kGreenBg = Color(0xFFEDF9F2);

// ═══════════════════════════════════════════════════════════════════════════
/// Shows the full booking success experience:
///   1. Toast overlay at the top (auto-dismisses in 3s)
///   2. Premium bottom sheet ticket
// ═══════════════════════════════════════════════════════════════════════════
Future<void> showBookingSuccess(
  BuildContext context, {
  required Booking booking,
  VoidCallback? onViewTrips,
}) async {
  HapticFeedback.heavyImpact();

  // 1 — Toast
  _showToast(context, booking: booking);

  // 2 — Wait 600ms then show sheet
  await Future<void>.delayed(const Duration(milliseconds: 600));
  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    useSafeArea: true,
    builder: (_) => _SuccessSheet(booking: booking, onViewTrips: onViewTrips),
  );
}

// ── Toast ────────────────────────────────────────────────────────────────────
void _showToast(BuildContext context, {required Booking booking}) {
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) =>
        _BookingToast(booking: booking, onClose: () => entry.remove()),
  );
  Overlay.of(context).insert(entry);
}

class _BookingToast extends StatefulWidget {
  const _BookingToast({required this.booking, required this.onClose});
  final Booking booking;
  final VoidCallback onClose;

  @override
  State<_BookingToast> createState() => _BookingToastState();
}

class _BookingToastState extends State<_BookingToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 3200), _dismiss);
  }

  void _dismiss() {
    if (mounted) {
      _ctrl.reverse().then((_) {
        if (mounted) widget.onClose();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.viewPaddingOf(context).top;
    return Positioned(
      top: topPad + 12,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: GestureDetector(
            onTap: _dismiss,
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _kGreen.withValues(alpha: 0.30),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _kGreen.withValues(alpha: 0.18),
                          blurRadius: 24,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: _kGreenBg,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _kGreen.withValues(alpha: 0.25),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: _kGreen,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Réservation confirmée !',
                                      style: TextStyle(
                                        color: Color(0xFF1A1A1A),
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${widget.booking.fromCity.isEmpty ? "Départ" : widget.booking.fromCity}'
                                      ' → '
                                      '${widget.booking.toCity.isEmpty ? "Arrivée" : widget.booking.toCity}',
                                      style: const TextStyle(
                                        color: _kGreen,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Votre place a été réservée avec succès.',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.close_rounded,
                                color: Colors.black26,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                        // Progress bar
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 1.0, end: 0.0),
                          duration: const Duration(milliseconds: 3200),
                          builder: (_, v, _) => LinearProgressIndicator(
                            value: v,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: const AlwaysStoppedAnimation(_kGreen),
                            minHeight: 3,
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
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUCCESS BOTTOM SHEET — Digital Boarding Pass
// ═══════════════════════════════════════════════════════════════════════════
class _SuccessSheet extends StatefulWidget {
  const _SuccessSheet({required this.booking, this.onViewTrips});
  final Booking booking;
  final VoidCallback? onViewTrips;

  @override
  State<_SuccessSheet> createState() => _SuccessSheetState();
}

class _SuccessSheetState extends State<_SuccessSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sparkCtrl;
  late final List<_Spark> _sparks;
  bool _sparksDone = false;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
    _sparkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _sparks = List.generate(12, (i) => _Spark(i));
    _sparkCtrl.forward().then((_) {
      if (mounted) setState(() => _sparksDone = true);
    });
  }

  @override
  void dispose() {
    _sparkCtrl.dispose();
    super.dispose();
  }

  // Format date from ISO string
  String _formatDate(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    const months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Jun',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  // Extract HH:mm from ISO or plain "HH:mm" string
  String _extractTime(String raw) {
    if (raw.isEmpty) return '--:--';
    // Try ISO parse first
    final d = DateTime.tryParse(raw);
    if (d != null) {
      final h = d.hour.toString().padLeft(2, '0');
      final m = d.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    // Already HH:mm or HH:mm:ss
    if (raw.contains(':')) return raw.substring(0, 5);
    return raw;
  }

  // Reference LG-XXXXX from booking id
  String _ref(String id) {
    final clean = id.replaceAll(RegExp(r'[^0-9]'), '');
    final num = clean.length > 5
        ? clean.substring(0, 5)
        : clean.padLeft(5, '0');
    return 'LG-$num';
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final ref = _ref(b.id);
    final dateStr = _formatDate(b.createdAt);
    final from = b.fromCity.isEmpty ? 'Départ' : b.fromCity;
    final to = b.toCity.isEmpty ? 'Arrivée' : b.toCity;
    // Extract HH:mm from ISO or plain string
    final time = _extractTime(b.departureTime);
    final seats = b.selectedSeats.isEmpty ? '—' : b.selectedSeats.join(', ');
    final price = b.totalPrice.toStringAsFixed(2);
    final qrData = b.qrCode.isNotEmpty ? b.qrCode : b.id;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.60,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Stack(
        clipBehavior: Clip.none,
        children: [
          // Sheet background
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF7F8FA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                // Drag handle
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                Expanded(
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    children: [
                      // ── Success header ─────────────────────────────────
                      const SizedBox(height: 12),
                      _SuccessHeader(
                        sparkCtrl: _sparkCtrl,
                        sparks: _sparks,
                        done: _sparksDone,
                      ),

                      const SizedBox(height: 20),

                      // ── Boarding pass card ─────────────────────────────
                      _BoardingPass(
                        from: from,
                        to: to,
                        date: dateStr,
                        time: time,
                        seats: seats,
                        ref: ref,
                        price: price,
                        qrData: qrData,
                        driver: b.driverName,
                        plate: b.matricule,
                      ),

                      const SizedBox(height: 24),

                      // ── Actions ────────────────────────────────────────
                      SendTicketEmailButton(booking: b),
                      const SizedBox(height: 10),
                      _ActionButton(
                        icon: Icons.luggage_rounded,
                        label: 'Voir mon voyage',
                        primary: true,
                        onTap: () {
                          Navigator.pop(context);
                          widget.onViewTrips?.call();
                        },
                      ),
                      const SizedBox(height: 10),
                      _ActionButton(
                        icon: Icons.close_rounded,
                        label: 'Fermer',
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Success header with sparks ────────────────────────────────────────────
class _SuccessHeader extends StatelessWidget {
  const _SuccessHeader({
    required this.sparkCtrl,
    required this.sparks,
    required this.done,
  });
  final AnimationController sparkCtrl;
  final List<_Spark> sparks;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (!done)
              AnimatedBuilder(
                animation: sparkCtrl,
                builder: (_, _) => CustomPaint(
                  size: const Size(120, 120),
                  painter: _SparkPainter(sparks: sparks, t: sparkCtrl.value),
                ),
              ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_kGreen, Color(0xFF0FA858)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _kGreen.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Réservation confirmée !',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Votre ticket digital est prêt',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13.5),
        ),
      ],
    );
  }
}

// ── Boarding pass ─────────────────────────────────────────────────────────
class _BoardingPass extends StatelessWidget {
  const _BoardingPass({
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    required this.seats,
    required this.ref,
    required this.price,
    required this.qrData,
    required this.driver,
    required this.plate,
  });
  final String from, to, date, time, seats, ref, price, qrData, driver, plate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: _kRed.withValues(alpha: 0.06),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Red header stripe ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_kRed, Color(0xFFAA0F28)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🇹🇳  LouageGo',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _CityCode(city: from),
                            Expanded(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white60,
                                    size: 18,
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    height: 1,
                                    color: Colors.white.withValues(alpha: 0.25),
                                  ),
                                ],
                              ),
                            ),
                            _CityCode(city: to),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.confirmation_number_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ref,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Ticket perforation ──────────────────────────────────────
            _Perforation(),

            // ── Details ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Detail(
                          icon: Icons.calendar_today_rounded,
                          label: 'Date',
                          value: date,
                        ),
                        const SizedBox(height: 12),
                        _Detail(
                          icon: Icons.access_time_rounded,
                          label: 'Départ',
                          value: time,
                        ),
                        const SizedBox(height: 12),
                        _Detail(
                          icon: Icons.event_seat_rounded,
                          label: 'Siège(s)',
                          value: seats,
                        ),
                        if (driver.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _Detail(
                            icon: Icons.person_rounded,
                            label: 'Chauffeur',
                            value: driver,
                          ),
                        ],
                        if (plate.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _Detail(
                            icon: Icons.directions_car_rounded,
                            label: 'Matricule',
                            value: plate,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // QR Code
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: qrData,
                          size: 90,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Scanner à bord',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Price footer ────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _kRedLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_rounded, color: _kRed, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Total payé',
                    style: TextStyle(
                      color: _kRed,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$price DT',
                    style: const TextStyle(
                      color: _kRed,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── City code widget ──────────────────────────────────────────────────────
class _CityCode extends StatelessWidget {
  const _CityCode({required this.city});
  final String city;

  @override
  Widget build(BuildContext context) {
    // Use max 3 chars for the airport-style code
    final code = city.length >= 3
        ? city.substring(0, 3).toUpperCase()
        : city.toUpperCase();
    return SizedBox(
      width: 70,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            code,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          Text(
            city,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detail row ────────────────────────────────────────────────────────────
class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _kRedLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _kRed, size: 15),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Perforation divider ───────────────────────────────────────────────────
class _Perforation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(10),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: List.generate(
                22,
                (i) => Expanded(
                  child: Container(
                    height: 1.5,
                    color: i.isEven ? Colors.grey.shade200 : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────
class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
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
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) => _ctrl.reverse(),
        onTapCancel: () => _ctrl.reverse(),
        onTap: widget.onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: widget.primary
                ? const LinearGradient(
                    colors: [_kRed, Color(0xFFAA0F28)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.primary ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: widget.primary
                ? null
                : Border.all(color: Colors.grey.shade200, width: 1.5),
            boxShadow: widget.primary
                ? [
                    BoxShadow(
                      color: _kRed.withValues(alpha: 0.30),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: widget.primary ? Colors.white : Colors.grey.shade500,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.primary ? Colors.white : Colors.grey.shade700,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
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
// SPARK ANIMATION — confetti burst on success
// ═══════════════════════════════════════════════════════════════════════════
class _Spark {
  _Spark(int seed) {
    final r = (seed * 137 + 31) % 360;
    angle = r * 3.14159 / 180;
    distance = 40.0 + (seed * 17) % 30;
    size = 4.0 + (seed * 7) % 6;
    color = _sparkColors[seed % _sparkColors.length];
  }

  late final double angle, distance, size;
  late final Color color;

  static const _sparkColors = [
    _kRed,
    Color(0xFFFFB300),
    _kGreen,
    Color(0xFFFF6B35),
    Color(0xFF4A90E2),
    Color(0xFFAB5FFF),
  ];
}

class _SparkPainter extends CustomPainter {
  const _SparkPainter({required this.sparks, required this.t});
  final List<_Spark> sparks;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    for (final s in sparks) {
      final dist = s.distance * t;
      final alpha = (1 - t).clamp(0.0, 1.0);
      final x = cx + dist * _cos(s.angle);
      final y = cy + dist * _sin(s.angle);
      canvas.drawCircle(
        Offset(x, y),
        s.size * (1 - t * 0.5),
        Paint()..color = s.color.withValues(alpha: alpha),
      );
    }
  }

  double _cos(double a) => a < 3.14159 / 2
      ? (1 - a * a / 2)
      : -(a - 3.14159) * (a - 3.14159) / 2 + 1;

  double _sin(double a) {
    final b = a - 3.14159 / 2;
    return b < 0 ? -b * b / 2 + 1 : 1 - b * b / 2;
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.t != t;
}
