import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Palette ────────────────────────────────────────────────────────────────
const _kRed = Color(0xFFD71935);
const _kRedDeep = Color(0xFFAA0F28);

const double kPremiumNavBarHeight = 64.0 + 22.0 + 28.0;

/// Data model for one nav item.
class PremiumNavItem {
  const PremiumNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.isFab = false,
  });
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isFab;
}

// ═══════════════════════════════════════════════════════════════════════════
/// Bubble-pop bottom navigation bar.
///
/// The active item floats ABOVE the bar inside a glowing red circle.
/// The notch/cutout under it is carved into the bar via a [CustomClipper].
/// Switching tabs animates the bubble smoothly left/right.
// ═══════════════════════════════════════════════════════════════════════════
class PremiumNavBar extends StatefulWidget {
  const PremiumNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.isPassenger = true,
  });

  final List<PremiumNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isPassenger;

  @override
  State<PremiumNavBar> createState() => _PremiumNavBarState();
}

class _PremiumNavBarState extends State<PremiumNavBar>
    with TickerProviderStateMixin {
  // Bubble horizontal slide
  late final AnimationController _bubbleCtrl;
  late Animation<double> _bubbleX; // 0..1 fraction of bar width

  // Bubble pop (scale up on appear / per-tab change)
  late final AnimationController _popCtrl;
  late final Animation<double> _popScale;

  // Per-item press scale
  late final List<AnimationController> _pressCtrl;

  @override
  void initState() {
    super.initState();

    _bubbleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _bubbleX = AlwaysStoppedAnimation(
      _itemFraction(widget.currentIndex, widget.items.length),
    );

    _popCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _popScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _popCtrl, curve: Curves.easeOutBack));
    _popCtrl.value = 1.0; // already popped on first frame

    _pressCtrl = List.generate(
      widget.items.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
      ),
    );
  }

  @override
  void didUpdateWidget(PremiumNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      final from = _itemFraction(old.currentIndex, widget.items.length);
      final to = _itemFraction(widget.currentIndex, widget.items.length);

      _bubbleX = Tween<double>(begin: from, end: to).animate(
        CurvedAnimation(parent: _bubbleCtrl, curve: Curves.easeOutCubic),
      );

      _bubbleCtrl.forward(from: 0);

      // Pop the bubble
      _popCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bubbleCtrl.dispose();
    _popCtrl.dispose();
    for (final c in _pressCtrl) {
      c.dispose();
    }
    super.dispose();
  }

  double _itemFraction(int index, int count) => (index + 0.5) / count;

  void _tap(int i) {
    HapticFeedback.selectionClick();
    _pressCtrl[i].forward().then((_) => _pressCtrl[i].reverse());
    widget.onTap(i);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final botPad = MediaQuery.viewPaddingOf(context).bottom;
    final n = widget.items.length;

    // Bar dimensions
    const barH = 64.0;
    const bubbleR = 28.0; // radius of the floating circle
    const riseH = 22.0; // how far the circle pops above the bar top

    return SizedBox(
      height: kPremiumNavBarHeight + botPad,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Notched bar ───────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: barH + botPad,
            child: AnimatedBuilder(
              animation: _bubbleX,
              builder: (_, _) {
                return CustomPaint(
                  painter: _NotchedBarPainter(
                    fraction: _bubbleX.value,
                    notchRadius: bubbleR + 6, // a little wider than bubble
                    barColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                    shadowColor: Colors.black.withValues(
                      alpha: isDark ? 0.40 : 0.10,
                    ),
                    borderColor: isDark
                        ? Colors.white.withValues(alpha: 0.07)
                        : Colors.grey.shade200,
                  ),
                );
              },
            ),
          ),

          // ── Item labels + icons (inactive items only) ─────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: botPad,
            height: barH,
            child: Row(
              children: List.generate(n, (i) {
                final active = i == widget.currentIndex;
                return Expanded(
                  child: _InactiveItem(
                    item: widget.items[i],
                    active: active,
                    isDark: isDark,
                    pressCtrl: _pressCtrl[i],
                    onTap: () => _tap(i),
                  ),
                );
              }),
            ),
          ),

          // ── Floating bubble (active icon) ─────────────────────────────
          AnimatedBuilder(
            animation: Listenable.merge([_bubbleX, _popScale]),
            builder: (_, _) {
              final barWidth = MediaQuery.sizeOf(context).width;
              final cx = _bubbleX.value * barWidth;
              final cy =
                  barH +
                  botPad +
                  riseH -
                  bubbleR; // center Y from bottom of SizedBox

              return Positioned(
                left: cx - bubbleR,
                bottom: cy,
                width: bubbleR * 2,
                height: bubbleR * 2,
                child: Transform.scale(
                  scale: _popScale.value,
                  child: _BubbleIcon(
                    item: widget.items[widget.currentIndex],
                    radius: bubbleR,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class PremiumNavScaffold extends StatelessWidget {
  const PremiumNavScaffold({
    super.key,
    required this.child,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.isPassenger = true,
  });

  final Widget child;
  final List<PremiumNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isPassenger;

  @override
  Widget build(BuildContext context) => Scaffold(
    extendBody: false,
    body: child,
    bottomNavigationBar: PremiumNavBar(
      items: items,
      currentIndex: currentIndex,
      isPassenger: isPassenger,
      onTap: onTap,
    ),
  );
}

// ─── Inactive item ────────────────────────────────────────────────────────
class _InactiveItem extends StatelessWidget {
  const _InactiveItem({
    required this.item,
    required this.active,
    required this.isDark,
    required this.pressCtrl,
    required this.onTap,
  });
  final PremiumNavItem item;
  final bool active, isDark;
  final AnimationController pressCtrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Active item space is reserved for the bubble; show label only
    final iconColor = active
        ? _kRed
        : isDark
        ? Colors.white38
        : Colors.grey.shade400;
    final labelColor = active
        ? _kRed
        : isDark
        ? Colors.white30
        : Colors.grey.shade400;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: pressCtrl,
        builder: (_, child) =>
            Transform.scale(scale: 1.0 - 0.12 * pressCtrl.value, child: child),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Active item: leave space for bubble, show nothing above label
            if (!active) Icon(item.icon, size: 22, color: iconColor),
            if (!active) const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: labelColor,
              ),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Floating bubble icon ──────────────────────────────────────────────────
class _BubbleIcon extends StatelessWidget {
  const _BubbleIcon({required this.item, required this.radius});
  final PremiumNavItem item;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [_kRed, _kRedDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _kRed.withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: _kRed.withValues(alpha: 0.20),
            blurRadius: 32,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Icon(item.selectedIcon, color: Colors.white, size: 24),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CUSTOM PAINTER — draws the bar with a smooth notch/cutout above the bubble
// ═══════════════════════════════════════════════════════════════════════════
class _NotchedBarPainter extends CustomPainter {
  const _NotchedBarPainter({
    required this.fraction,
    required this.notchRadius,
    required this.barColor,
    required this.shadowColor,
    required this.borderColor,
  });

  final double fraction;
  final double notchRadius;
  final Color barColor, shadowColor, borderColor;

  static const _cornerR = 32.0; // bar pill corner radius
  static const _notchDepth = 14.0; // how deep the notch dips into the bar

  @override
  void paint(Canvas canvas, Size size) {
    final cx = fraction * size.width;
    final nr = notchRadius;
    final top = 0.0;
    final bottom = size.height;
    const cr = _cornerR;

    // ── Build path ────────────────────────────────────────────────────
    final path = Path();

    // Start top-left corner
    path.moveTo(cr, top);

    // Top edge going right → notch start
    final notchLeft = cx - nr - 8;
    final notchRight = cx + nr + 8;

    if (notchLeft > cr) {
      path.lineTo(notchLeft, top);
    }

    // Notch: smooth arc dipping down then back up
    // Uses a cubic bezier for the left shoulder, arc for bottom, cubic for right
    if (notchLeft > cr && notchRight < size.width - cr) {
      final notchCenterY = top + _notchDepth;
      path.cubicTo(
        notchLeft + nr * 0.4,
        top,
        cx - nr,
        notchCenterY,
        cx,
        notchCenterY,
      );
      path.cubicTo(
        cx + nr,
        notchCenterY,
        notchRight - nr * 0.4,
        top,
        notchRight,
        top,
      );
    }

    // Continue to top-right corner
    path.lineTo(size.width - cr, top);
    path.quadraticBezierTo(size.width, top, size.width, top + cr);

    // Right edge down
    path.lineTo(size.width, bottom);

    // Bottom edge
    path.lineTo(0, bottom);

    // Left edge up
    path.lineTo(0, top + cr);
    path.quadraticBezierTo(0, top, cr, top);
    path.close();

    // ── Shadow ────────────────────────────────────────────────────────
    canvas.drawShadow(path, shadowColor, 16, true);

    // ── Fill ─────────────────────────────────────────────────────────
    canvas.drawPath(path, Paint()..color = barColor);

    // ── Border ───────────────────────────────────────────────────────
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(_NotchedBarPainter old) =>
      old.fraction != fraction ||
      old.barColor != barColor ||
      old.borderColor != borderColor;
}
