import 'dart:math' as math;

import 'package:flutter/material.dart';

class OnboardingIllustration extends StatefulWidget {
  const OnboardingIllustration({
    super.key,
    required this.index,
    this.size = 236,
  });

  final int index;
  final double size;

  @override
  State<OnboardingIllustration> createState() => _OnboardingIllustrationState();
}

class _OnboardingIllustrationState extends State<OnboardingIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  bool _animationsDisabled = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disabled = MediaQuery.disableAnimationsOf(context);
    if (_animationsDisabled == disabled) return;
    _animationsDisabled = disabled;
    if (disabled) {
      _controller
        ..stop()
        ..value = 0.65;
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox.square(
      dimension: widget.size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              colorScheme.primary.withValues(alpha: 0.10),
              colorScheme.secondary.withValues(alpha: 0.07),
              colorScheme.surface.withValues(alpha: 0),
            ],
            stops: const [0, 0.62, 1],
          ),
        ),
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: _OnboardingScenePainter(
                index: widget.index,
                progress: _animationsDisabled ? 0.65 : _controller.value,
                surface: colorScheme.surface,
                primary: colorScheme.primary,
                secondary: colorScheme.secondary,
                outline: colorScheme.outline,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingScenePainter extends CustomPainter {
  const _OnboardingScenePainter({
    required this.index,
    required this.progress,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.outline,
  });

  final int index;
  final double progress;
  final Color surface;
  final Color primary;
  final Color secondary;
  final Color outline;

  @override
  void paint(Canvas canvas, Size size) {
    _paintDecorations(canvas, size);
    switch (index) {
      case 0:
        _paintTicket(canvas, size);
      case 1:
        _paintRoute(canvas, size);
      case 2:
        _paintWallet(canvas, size);
    }
  }

  void _paintDecorations(Canvas canvas, Size size) {
    final paint = Paint()..color = outline.withValues(alpha: 0.18);
    final drift = math.sin(progress * math.pi * 2) * 6;
    canvas.drawCircle(Offset(size.width * .18, size.height * .28 + drift), 4, paint);
    canvas.drawCircle(Offset(size.width * .82, size.height * .34 - drift), 3, paint);
    canvas.drawCircle(Offset(size.width * .74, size.height * .78 + drift), 5, paint);
    final halo = Paint()
      ..color = primary.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * .41,
      halo,
    );
  }

  void _paintTicket(Canvas canvas, Size size) {
    final unfold = Curves.easeOutBack.transform(
      ((progress * 1.3).clamp(0, 1)).toDouble(),
    );
    final width = size.width * .56 * unfold;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: width,
      height: size.height * .48,
    );
    final radius = Radius.circular(size.width * .055);
    final card = RRect.fromRectAndRadius(rect, radius);
    canvas.drawRRect(
      card.shift(const Offset(0, 7)),
      Paint()..color = secondary.withValues(alpha: 0.12),
    );
    canvas.drawRRect(card, Paint()..color = surface);
    canvas.drawRRect(
      card,
      Paint()
        ..color = outline.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    if (unfold < .18) return;

    final centerX = rect.center.dx;
    final qrRect = Rect.fromLTWH(
      rect.left + rect.width * .12,
      rect.top + rect.height * .19,
      rect.width * .34,
      rect.height * .56,
    );
    final qrProgress = ((progress - .12) / .64).clamp(0.0, 1.0);
    final qrPaint = Paint()..color = secondary;
    canvas.save();
    canvas.clipRect(
      Rect.fromLTRB(
        qrRect.left,
        qrRect.top,
        qrRect.right,
        qrRect.top + qrRect.height * qrProgress,
      ),
    );
    const cells = 7;
    final cell = qrRect.width / cells;
    for (var y = 0; y < cells; y++) {
      for (var x = 0; x < cells; x++) {
        if (_qrCell(x, y)) {
          canvas.drawRect(
            Rect.fromLTWH(
              qrRect.left + x * cell,
              qrRect.top + y * cell,
              cell * .78,
              cell * .78,
            ),
            qrPaint,
          );
        }
      }
    }
    canvas.restore();

    final routePaint = Paint()
      ..color = outline.withValues(alpha: 0.7)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final linesLeft = rect.left + rect.width * .56;
    final linesRight = rect.right - rect.width * .1;
    for (var i = 0; i < 3; i++) {
      final y = rect.top + rect.height * (.28 + i * .18);
      canvas.drawLine(
        Offset(linesLeft, y),
        Offset(linesLeft + (linesRight - linesLeft) * (i == 2 ? .55 : .92), y),
        routePaint,
      );
    }
    final accentPaint = Paint()..color = primary;
    canvas.drawCircle(
      Offset(centerX, rect.bottom + 22),
      3.5,
      accentPaint,
    );
  }

  bool _qrCell(int x, int y) {
    final finder =
        (x < 2 && y < 2) ||
        (x > 4 && y < 2) ||
        (x < 2 && y > 4);
    if (finder) {
      final inFinder = (x % 6 == 0 || x % 6 == 1) &&
          (y % 6 == 0 || y % 6 == 1);
      return inFinder && (x == 0 || x == 1 || x == 5 || y == 0 || y == 1 || y == 5);
    }
    return ((x * 3 + y * 5 + x * y) % 4) < 2;
  }

  void _paintRoute(Canvas canvas, Size size) {
    final route = Path()
      ..moveTo(size.width * .24, size.height * .74)
      ..cubicTo(
        size.width * .18,
        size.height * .48,
        size.width * .82,
        size.height * .57,
        size.width * .73,
        size.height * .26,
      );
    final metric = route.computeMetrics().first;
    final roadPaint = Paint()
      ..color = outline.withValues(alpha: 0.8)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var d = 0.0; d < metric.length; d += 12) {
      final p = metric.getTangentForOffset(d)!.position;
      canvas.drawCircle(p, 1.7, roadPaint);
    }
    final tangent = metric.getTangentForOffset(metric.length * progress)!;
    final car = Offset(tangent.position.dx, tangent.position.dy - 14);
    canvas.save();
    canvas.translate(car.dx, car.dy);
    canvas.rotate(tangent.angle);
    final carRect = Rect.fromCenter(
      center: Offset.zero,
      width: size.width * .20,
      height: size.height * .105,
    );
    final body = RRect.fromRectAndRadius(carRect, const Radius.circular(9));
    canvas.drawRRect(body.shift(const Offset(0, 3)), Paint()..color = secondary.withValues(alpha: .12));
    canvas.drawRRect(body, Paint()..color = primary);
    final windowPaint = Paint()..color = surface;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, -2),
          width: carRect.width * .42,
          height: carRect.height * .43,
        ),
        const Radius.circular(3),
      ),
      windowPaint,
    );
    final wheelPaint = Paint()..color = secondary;
    canvas.drawCircle(Offset(-carRect.width * .27, carRect.height * .42), 3, wheelPaint);
    canvas.drawCircle(Offset(carRect.width * .27, carRect.height * .42), 3, wheelPaint);
    canvas.restore();
    canvas.drawCircle(
      Offset(size.width * .73, size.height * .26),
      7,
      Paint()..color = primary.withValues(alpha: .22),
    );
    canvas.drawCircle(
      Offset(size.width * .73, size.height * .26),
      3.5,
      Paint()..color = primary,
    );
  }

  void _paintWallet(Canvas canvas, Size size) {
    final wallet = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * .49, size.height * .53),
        width: size.width * .58,
        height: size.height * .38,
      ),
      const Radius.circular(18),
    );
    canvas.drawRRect(
      wallet.shift(const Offset(0, 7)),
      Paint()..color = secondary.withValues(alpha: .12),
    );
    canvas.drawRRect(wallet, Paint()..color = secondary);
    final flap = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        wallet.right - wallet.width * .42,
        wallet.top + wallet.height * .29,
        wallet.width * .49,
        wallet.height * .42,
      ),
      const Radius.circular(9),
    );
    canvas.drawRRect(flap, Paint()..color = surface);
    canvas.drawRRect(
      flap,
      Paint()
        ..color = outline.withValues(alpha: .7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    canvas.drawCircle(
      Offset(flap.right - 13, flap.center.dy),
      3,
      Paint()..color = primary,
    );

    final check = Path()
      ..moveTo(size.width * .32, size.height * .50)
      ..lineTo(size.width * .44, size.height * .61)
      ..lineTo(size.width * .69, size.height * .35);
    final checkMetric = check.computeMetrics().first;
    final shown = checkMetric.extractPath(
      0,
      checkMetric.length * Curves.easeOutCubic.transform(progress),
    );
    canvas.drawPath(
      shown,
      Paint()
        ..color = primary
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    for (var i = 0; i < 3; i++) {
      final phase = (progress + i / 3) % 1;
      final y = size.height * (.13 + phase * .20);
      final x = size.width * (.30 + i * .19);
      final coinPaint = Paint()
        ..color = primary.withValues(alpha: (1 - phase * .7).clamp(0, 1));
      canvas.drawCircle(Offset(x, y), 5, coinPaint);
      canvas.drawCircle(
        Offset(x, y),
        2,
        Paint()..color = surface.withValues(alpha: .9),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OnboardingScenePainter oldDelegate) =>
      oldDelegate.index != index ||
      oldDelegate.progress != progress ||
      oldDelegate.surface != surface ||
      oldDelegate.primary != primary ||
      oldDelegate.secondary != secondary ||
      oldDelegate.outline != outline;
}
