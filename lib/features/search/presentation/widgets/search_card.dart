import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─── Palette LouageGo ──────────────────────────────────────────────────────
const _kRed      = Color(0xFFD71935);
const _kRedDeep  = Color(0xFFAA0F28);
const _kRedLight = Color(0xFFFFF0F2);

// ═══════════════════════════════════════════════════════════════════════════
/// Carte de recherche principale — design premium animé
// ═══════════════════════════════════════════════════════════════════════════
class SearchCard extends StatefulWidget {
  final String departureLabel;
  final String destinationLabel;
  final String chooseCityLabel;
  final String dateLabel;
  final String dateValue;
  final String timeLabel;
  final String timeValue;
  final String swapTooltip;
  final String searchLabel;
  final String? departure;
  final String? destination;
  final Animation<double> swapAnimation;
  final bool departureError;
  final bool destinationError;
  final bool isLoading;
  final VoidCallback onDepartureTap;
  final VoidCallback onDestinationTap;
  final VoidCallback onSwap;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;
  final VoidCallback onSearch;

  const SearchCard({
    super.key,
    required this.departureLabel,
    required this.destinationLabel,
    required this.chooseCityLabel,
    required this.dateLabel,
    required this.dateValue,
    required this.timeLabel,
    required this.timeValue,
    required this.swapTooltip,
    required this.searchLabel,
    required this.departure,
    required this.destination,
    required this.swapAnimation,
    required this.departureError,
    required this.destinationError,
    required this.isLoading,
    required this.onDepartureTap,
    required this.onDestinationTap,
    required this.onSwap,
    required this.onDateTap,
    required this.onTimeTap,
    required this.onSearch,
  });

  @override
  State<SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard>
    with SingleTickerProviderStateMixin {
  // Animation d'entrée staggered
  late final AnimationController _entryCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 5 éléments : route, départ, destination, date+heure, bouton
    _fadeAnims = List.generate(5, (i) {
      final start = i * 0.12;
      final end   = (start + 0.55).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _entryCtrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });
    _slideAnims = List.generate(5, (i) {
      final start = i * 0.12;
      final end   = (start + 0.55).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.18),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _entryCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });

    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  Widget _animated(int i, Widget child) => FadeTransition(
        opacity: _fadeAnims[i],
        child: SlideTransition(position: _slideAnims[i], child: child),
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _kRed.withValues(alpha: 0.10),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── Route : départ ↕ destination ──────────────────────────────
          _animated(0, _RouteFields(
            departureLabel:   widget.departureLabel,
            destinationLabel: widget.destinationLabel,
            chooseCityLabel:  widget.chooseCityLabel,
            departure:        widget.departure,
            destination:      widget.destination,
            swapAnimation:    widget.swapAnimation,
            swapTooltip:      widget.swapTooltip,
            departureError:   widget.departureError,
            destinationError: widget.destinationError,
            onDepartureTap:   widget.onDepartureTap,
            onDestinationTap: widget.onDestinationTap,
            onSwap:           widget.onSwap,
            isDark:           isDark,
          )),

          const SizedBox(height: 14),

          // ── Date + Heure ───────────────────────────────────────────────
          _animated(3, Row(
            children: [
              Expanded(child: _PillDateField(
                icon:   Icons.calendar_today_rounded,
                label:  widget.dateLabel,
                value:  widget.dateValue,
                onTap:  widget.onDateTap,
                isDark: isDark,
              )),
              const SizedBox(width: 10),
              Expanded(child: _PillDateField(
                icon:   Icons.access_time_rounded,
                label:  widget.timeLabel,
                value:  widget.timeValue,
                onTap:  widget.onTimeTap,
                isDark: isDark,
              )),
            ],
          )),

          const SizedBox(height: 16),

          // ── Bouton Rechercher ─────────────────────────────────────────
          _animated(4, _SearchButton(
            label:     widget.searchLabel,
            isLoading: widget.isLoading,
            onPressed: widget.isLoading ? null : widget.onSearch,
          )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
/// Section départ / destination avec ligne pointillée animée
// ═══════════════════════════════════════════════════════════════════════════
class _RouteFields extends StatelessWidget {
  const _RouteFields({
    required this.departureLabel,
    required this.destinationLabel,
    required this.chooseCityLabel,
    required this.departure,
    required this.destination,
    required this.swapAnimation,
    required this.swapTooltip,
    required this.departureError,
    required this.destinationError,
    required this.onDepartureTap,
    required this.onDestinationTap,
    required this.onSwap,
    required this.isDark,
  });

  final String departureLabel;
  final String destinationLabel;
  final String chooseCityLabel;
  final String? departure;
  final String? destination;
  final Animation<double> swapAnimation;
  final String swapTooltip;
  final bool departureError;
  final bool destinationError;
  final VoidCallback onDepartureTap;
  final VoidCallback onDestinationTap;
  final VoidCallback onSwap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : _kRedLight;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _kRed.withValues(alpha: 0.10),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icônes de route (point rouge + ligne + pin)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            child: _RouteLine(),
          ),

          // Champs départ / destination
          Expanded(
            child: Column(
              children: [
                LocationField(
                  label:       departureLabel,
                  value:       departure,
                  placeholder: chooseCityLabel,
                  isError:     departureError,
                  onTap:       onDepartureTap,
                  isDark:      isDark,
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: _kRed.withValues(alpha: 0.08),
                  indent: 0,
                  endIndent: 16,
                ),
                LocationField(
                  label:       destinationLabel,
                  value:       destination,
                  placeholder: chooseCityLabel,
                  isError:     destinationError,
                  onTap:       onDestinationTap,
                  isDark:      isDark,
                ),
              ],
            ),
          ),

          // Bouton swap
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: RotationTransition(
              turns: swapAnimation,
              child: _SwapButton(
                tooltip:  swapTooltip,
                onPressed: onSwap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ligne de route animée ─────────────────────────────────────────────────
class _RouteLine extends StatefulWidget {
  @override
  State<_RouteLine> createState() => _RouteLineState();
}

class _RouteLineState extends State<_RouteLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 112,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) => CustomPaint(
          painter: _RouteLinePainter(_ctrl.value),
        ),
      ),
    );
  }
}

class _RouteLinePainter extends CustomPainter {
  final double progress;
  _RouteLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // Point de départ (rond rouge)
    canvas.drawCircle(
      Offset(cx, 8),
      5,
      Paint()..color = _kRed,
    );
    canvas.drawCircle(
      Offset(cx, 8),
      3,
      Paint()..color = Colors.white,
    );

    // Ligne pointillée animée
    final paint = Paint()
      ..color = _kRed.withValues(alpha: 0.50)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final dashLen  = 5.0;
    final gapLen   = 5.0;
    final offset   = (progress * (dashLen + gapLen)) % (dashLen + gapLen);

    var y = 16.0 + offset;
    while (y < size.height - 14) {
      final end = math.min(y + dashLen, size.height - 14.0);
      canvas.drawLine(Offset(cx, y), Offset(cx, end), paint);
      y += dashLen + gapLen;
    }

    // Pin de destination
    final pinPaint = Paint()
      ..color = _kRed
      ..style = PaintingStyle.fill;
    final pinPath = Path()
      ..moveTo(cx, size.height)
      ..cubicTo(cx - 8, size.height - 12, cx - 8, size.height - 22, cx, size.height - 22)
      ..cubicTo(cx + 8, size.height - 22, cx + 8, size.height - 12, cx, size.height);
    canvas.drawPath(pinPath, pinPaint);
    canvas.drawCircle(
      Offset(cx, size.height - 18),
      3,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_RouteLinePainter old) => old.progress != progress;
}

// ─── Bouton swap premium ───────────────────────────────────────────────────
class _SwapButton extends StatefulWidget {
  const _SwapButton({required this.tooltip, required this.onPressed});
  final String tooltip;
  final VoidCallback onPressed;

  @override
  State<_SwapButton> createState() => _SwapButtonState();
}

class _SwapButtonState extends State<_SwapButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) => _pressCtrl.reverse(),
        onTapCancel: () => _pressCtrl.reverse(),
        onTap: widget.onPressed,
        child: Tooltip(
          message: widget.tooltip,
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kRed, _kRedDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _kRed.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.swap_vert_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
/// Champ localisation (départ / destination)
// ═══════════════════════════════════════════════════════════════════════════
class LocationField extends StatefulWidget {
  final String label;
  final String? value;
  final String placeholder;
  final bool isError;
  final bool isDark;
  final VoidCallback onTap;

  const LocationField({
    super.key,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.isError,
    required this.onTap,
    this.isDark = false,
  });

  @override
  State<LocationField> createState() => _LocationFieldState();
}

class _LocationFieldState extends State<LocationField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tapCtrl;
  late final Animation<double> _tapScale;

  @override
  void initState() {
    super.initState();
    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _tapScale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _tapCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _tapCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasValue  = widget.value != null && widget.value!.isNotEmpty;
    final textColor = widget.isError
        ? _kRed
        : hasValue
            ? (widget.isDark ? Colors.white : const Color(0xFF1A1A1A))
            : (widget.isDark ? Colors.white38 : Colors.black38);
    final labelColor = widget.isError
        ? _kRed
        : (widget.isDark
            ? Colors.white54
            : const Color(0xFF888888));

    return Semantics(
      button: true,
      label: '${widget.label}, ${widget.value ?? widget.placeholder}',
      child: ScaleTransition(
        scale: _tapScale,
        child: GestureDetector(
          onTapDown: (_) => _tapCtrl.forward(),
          onTapUp: (_) => _tapCtrl.reverse(),
          onTapCancel: () => _tapCtrl.reverse(),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 13),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: labelColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.value ?? widget.placeholder,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: hasValue
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: textColor,
                                letterSpacing: hasValue ? -0.2 : 0,
                              ),
                            ),
                          ),
                          if (hasValue)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: _kRed.withValues(alpha: 0.70),
                              ),
                            ),
                        ],
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
  }
}

// ═══════════════════════════════════════════════════════════════════════════
/// Champ Date / Heure — style pill avec icône
// ═══════════════════════════════════════════════════════════════════════════
class _PillDateField extends StatefulWidget {
  const _PillDateField({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    required this.isDark,
  });
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isDark;

  @override
  State<_PillDateField> createState() => _PillDateFieldState();
}

class _PillDateFieldState extends State<_PillDateField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark
        ? Colors.white.withValues(alpha: 0.07)
        : _kRedLight;

    return Semantics(
      button: true,
      label: '${widget.label}, ${widget.value}',
      child: ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTapDown: (_) => _pressCtrl.forward(),
          onTapUp: (_) => _pressCtrl.reverse(),
          onTapCancel: () => _pressCtrl.reverse(),
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _kRed.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: _kRed.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, size: 16, color: _kRed),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: widget.isDark
                              ? Colors.white54
                              : const Color(0xFF888888),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                      Text(
                        widget.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: widget.isDark
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
  }
}

// ═══════════════════════════════════════════════════════════════════════════
/// Bouton Rechercher avec shimmer animé
// ═══════════════════════════════════════════════════════════════════════════
class _SearchButton extends StatefulWidget {
  const _SearchButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  State<_SearchButton> createState() => _SearchButtonState();
}

class _SearchButtonState extends State<_SearchButton>
    with TickerProviderStateMixin {
  late final AnimationController _shimmerCtrl;
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: enabled ? (_) => _pressCtrl.forward() : null,
        onTapUp: enabled ? (_) => _pressCtrl.reverse() : null,
        onTapCancel: enabled ? () => _pressCtrl.reverse() : null,
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _shimmerCtrl,
          builder: (_, child) {
            return Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: enabled
                      ? [_kRed, _kRedDeep, _kRed]
                      : [Colors.grey.shade400, Colors.grey.shade300],
                  stops: enabled
                      ? [0.0, 0.5, 1.0]
                      : [0.0, 0.5, 1.0],
                ),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: _kRed.withValues(alpha: 0.38),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Stack(
                  children: [
                    // Shimmer sweep
                    if (enabled)
                      Positioned.fill(
                        child: FractionalTranslation(
                          translation: Offset(
                            -2 + _shimmerCtrl.value * 4,
                            0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: 0.14),
                                  Colors.white.withValues(alpha: 0),
                                ],
                                stops: const [0.3, 0.5, 0.7],
                              ),
                            ),
                          ),
                        ),
                      ),
                    child!,
                  ],
                ),
              ),
            );
          },
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: widget.isLoading
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      key: const ValueKey('label'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Painter ligne pointillée (gardé pour compatibilité) ───────────────────
class _DottedRoutePainter extends CustomPainter {
  final Color color;
  const _DottedRoutePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    for (var y = 2.0; y < size.height; y += 7) {
      canvas.drawLine(
        Offset(cx, y),
        Offset(cx, (y + 3).clamp(0, size.height)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DottedRoutePainter old) =>
      old.color != color;
}
