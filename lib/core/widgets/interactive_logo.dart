import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_logo.dart';

class InteractiveLogo extends StatefulWidget {
  const InteractiveLogo({super.key, this.size = 112});

  final double size;

  @override
  State<InteractiveLogo> createState() => _InteractiveLogoState();
}

class _InteractiveLogoState extends State<InteractiveLogo>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _floatController;
  late final AnimationController _interactionController;
  late final AnimationController _sparkController;
  late final AnimationController _startController;
  bool _animationsDisabled = true;
  bool _hovered = false;
  Offset _dragPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _interactionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    );
    _sparkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    _startController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disabled = MediaQuery.disableAnimationsOf(context);
    if (_animationsDisabled == disabled) return;
    _animationsDisabled = disabled;
    if (disabled) {
      for (final controller in _controllers) {
        controller
          ..stop()
          ..value = 1;
      }
      _floatController.value = 0;
      _dragPosition = Offset.zero;
    } else {
      _entryController.forward(from: 0);
      _floatController.repeat();
    }
  }

  Iterable<AnimationController> get _controllers => [
    _entryController,
    _floatController,
    _interactionController,
    _sparkController,
    _startController,
  ];

  Future<void> _tap() async {
    if (_animationsDisabled) return;
    await HapticFeedback.lightImpact();
    _interactionController.forward(from: 0);
    _sparkController.forward(from: 0);
  }

  Future<void> _startLouage() async {
    if (_animationsDisabled) return;
    await HapticFeedback.lightImpact();
    _startController.forward(from: 0);
  }

  void _setHover(bool value) {
    if (_hovered != value) setState(() => _hovered = value);
  }

  void _updateDrag(DragUpdateDetails details) {
    if (_animationsDisabled) return;
    setState(() {
      _dragPosition = Offset(
        (_dragPosition.dx + details.delta.dx / widget.size).clamp(-1, 1),
        (_dragPosition.dy + details.delta.dy / widget.size).clamp(-1, 1),
      );
    });
  }

  void _endDrag(DragEndDetails details) {
    if (!_animationsDisabled) setState(() => _dragPosition = Offset.zero);
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final introScale = _animationsDisabled
        ? 1.0
        : CurvedAnimation(
            parent: _entryController,
            curve: Curves.elasticOut,
          ).value;
    final floatY = _animationsDisabled
        ? 0.0
        : math.sin(_floatController.value * math.pi * 2) * 4;
    final interaction = _animationsDisabled
        ? 0.0
        : _interactionController.value;
    final start = _animationsDisabled ? 0.0 : _startController.value;
    final scale = _animationsDisabled
        ? 1.0
        : 1 +
              (math.sin(interaction * math.pi * 4) *
                  0.08 *
                  (1 - interaction)) +
              (_hovered ? 0.06 : 0);
    final rotation = _animationsDisabled
        ? 0.0
        : (math.sin(interaction * math.pi * 2) * 0.07) +
              (_dragPosition.dx * 0.06);
    final shake = _animationsDisabled
        ? 0.0
        : math.sin(start * math.pi * 16) * (1 - start) * 5;
    final slide = _animationsDisabled
        ? 0.0
        : (start < 0.35
              ? 0.0
              : 24 * math.sin(((start - 0.35) / 0.65) * math.pi));
    return Semantics(
      button: true,
      label: 'LouageGo',
      onTap: _tap,
      onLongPress: _startLouage,
      child: MouseRegion(
        onEnter: (_) => _setHover(true),
        onExit: (_) => _setHover(false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _tap,
          onLongPress: _startLouage,
          onPanUpdate: _updateDrag,
          onPanEnd: _endDrag,
          child: SizedBox(
            width: widget.size + 28,
            height: widget.size + 28,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _entryController,
                    _floatController,
                    _interactionController,
                    _startController,
                  ]),
                  builder: (context, child) => Opacity(
                    opacity: _animationsDisabled
                        ? 1
                        : _entryController.value.clamp(0, 1),
                    child: TweenAnimationBuilder<Offset>(
                      tween: Tween<Offset>(end: _dragPosition),
                      duration: _animationsDisabled
                          ? Duration.zero
                          : const Duration(milliseconds: 240),
                      curve: Curves.elasticOut,
                      builder: (context, dragPosition, child) {
                        final tilt = Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateX(dragPosition.dy * -0.10)
                          ..rotateY(dragPosition.dx * 0.10);
                        final transform = Matrix4.identity()
                          ..translateByDouble(shake + slide, floatY, 0, 1)
                          ..rotateZ(rotation)
                          ..multiply(tilt)
                          ..scaleByDouble(
                            scale * introScale,
                            scale * introScale,
                            1,
                            1,
                          );
                        return Transform(
                          alignment: Alignment.center,
                          transform: transform,
                          child: child,
                        );
                      },
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(widget.size * .3),
                          boxShadow: _hovered && !_animationsDisabled
                              ? [
                                  BoxShadow(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.28,
                                    ),
                                    blurRadius: 24,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: AppLogoMark(size: widget.size),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _sparkController,
                        builder: (context, _) => CustomPaint(
                          painter: _SparkPainter(
                            progress: _animationsDisabled
                                ? 0
                                : _sparkController.value,
                            color: colorScheme.primary,
                            secondaryColor: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
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

class _SparkPainter extends CustomPainter {
  const _SparkPainter({
    required this.progress,
    required this.color,
    required this.secondaryColor,
  });

  final double progress;
  final Color color;
  final Color secondaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 8; i++) {
      final angle = (math.pi * 2 * i / 8) - math.pi / 2;
      final distance = 34 + progress * 28;
      final radius = (1 - progress) * (i.isEven ? 3.5 : 2.5);
      paint.color = (i.isEven ? color : secondaryColor).withValues(
        alpha: 1 - progress,
      );
      canvas.drawCircle(
        center +
            Offset(math.cos(angle) * distance, math.sin(angle) * distance),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.secondaryColor != secondaryColor;
}
