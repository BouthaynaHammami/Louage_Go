import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import 'app_logo.dart';

class AuthScaffold extends StatefulWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;

  const AuthScaffold({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  State<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends State<AuthScaffold>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _routeController;
  late final List<CurvedAnimation> _staggerAnimations;
  bool? _motionDisabled;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _routeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _staggerAnimations = List.generate(12, (index) {
      final start = math.min(0.02 + index * 0.055, 0.64);
      final end = math.min(start + 0.34, 1.0);
      return CurvedAnimation(
        parent: _entranceController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disabled = MediaQuery.of(context).disableAnimations;
    final wasDisabled = _motionDisabled;
    _motionDisabled = disabled;

    if (disabled) {
      _entranceController.value = 1;
      _routeController
        ..stop()
        ..value = 0;
      return;
    }

    if (wasDisabled == true) {
      _entranceController.forward(from: 0);
    } else if (_entranceController.status == AnimationStatus.dismissed) {
      _entranceController.forward();
    }
    if (!_routeController.isAnimating) _routeController.repeat();
  }

  @override
  void dispose() {
    for (final animation in _staggerAnimations) {
      animation.dispose();
    }
    _routeController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 800;
    final linkColor = colorScheme.brightness == Brightness.dark
        ? colorScheme.surfaceContainer
        : colorScheme.secondary;

    return _AuthStaggerScope(
      animations: _staggerAnimations,
      disabled: _motionDisabled ?? false,
      child: Theme(
        data: Theme.of(context).copyWith(
          scaffoldBackgroundColor: colorScheme.surfaceContainerLow,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: linkColor),
          ),
        ),
        child: Scaffold(
          body: SafeArea(
            top: isWide,
            child: Stack(
              children: [
                if (isWide)
                  _buildWideLayout(context)
                else
                  _buildMobileLayout(context),
                if (widget.showBackButton)
                  PositionedDirectional(
                    top: isWide ? 8 : MediaQuery.viewPaddingOf(context).top + 8,
                    start: 8,
                    child: IconButton(
                      onPressed:
                          widget.onBack ?? Navigator.of(context).maybePop,
                      tooltip: MaterialLocalizations.of(context)
                          .backButtonTooltip,
                      constraints: const BoxConstraints.tightFor(
                        width: 48,
                        height: 48,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.onPrimary.withValues(
                          alpha: 0.12,
                        ),
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final headerBackground = colorScheme.brightness == Brightness.dark
        ? colorScheme.surfaceContainer
        : colorScheme.secondary;
    return Column(
      children: [
        SizedBox(
          height: 208,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: headerBackground,
                    borderRadius: const BorderRadiusDirectional.vertical(
                      bottom: Radius.circular(32),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadiusDirectional.vertical(
                      bottom: Radius.circular(32),
                    ),
                    child: _AuthRouteAnimation(
                      controller: _routeController,
                      height: 190,
                      reducedMotion: _motionDisabled ?? false,
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AuthStaggerItem(
                      index: 0,
                      child: AppLogoMark(size: 76),
                    ),
                    const SizedBox(height: 8),
                    AuthStaggerItem(
                      index: 1,
                      child: AppWordmark(
                        onDark: true,
                        key: const ValueKey('auth-wordmark'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: AuthStaggerItem(
                  index: 2,
                  child: _GlassCard(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (widget.title case final title?) ...[
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            if (widget.subtitle case final subtitle?) ...[
                              const SizedBox(height: 8),
                              Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                            const SizedBox(height: 20),
                          ],
                          widget.child,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(flex: 45, child: _BrandPanel(controller: _routeController)),
        Expanded(
          flex: 55,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.fromSTEB(48, 72, 48, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.title case final title?)
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    if (widget.subtitle case final subtitle?) ...[
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                    const SizedBox(height: 28),
                    AuthStaggerItem(index: 2, child: widget.child),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AuthStaggerItem extends StatelessWidget {
  final int index;
  final Widget child;

  const AuthStaggerItem({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    final scope = _AuthStaggerScope.maybeOf(context);
    if (scope == null || scope.disabled) return child;

    final animation =
        scope.animations[index.clamp(0, scope.animations.length - 1).toInt()];
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.035),
      end: Offset.zero,
    ).animate(animation);

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

class _AuthStaggerScope extends InheritedWidget {
  final List<Animation<double>> animations;
  final bool disabled;

  const _AuthStaggerScope({
    required this.animations,
    required this.disabled,
    required super.child,
  });

  static _AuthStaggerScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AuthStaggerScope>();

  @override
  bool updateShouldNotify(_AuthStaggerScope oldWidget) =>
      animations != oldWidget.animations || disabled != oldWidget.disabled;
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _AuthRouteAnimation extends StatelessWidget {
  final AnimationController controller;
  final double height;
  final bool reducedMotion;

  const _AuthRouteAnimation({
    required this.controller,
    required this.height,
    required this.reducedMotion,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rtl = Directionality.of(context) == TextDirection.rtl;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => SizedBox(
        height: height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, height);
            final path = _routePath(size, rtl);
            final metric = path.computeMetrics().first;
            final progress = reducedMotion ? 0.35 : controller.value;
            final tangent = metric.getTangentForOffset(
              metric.length * progress,
            )!;
            final destination = metric
                .getTangentForOffset(metric.length)!
                .position;
            final vehicleStart = rtl
                ? size.width - tangent.position.dx - 14
                : tangent.position.dx - 14;
            final pinStart = rtl
                ? size.width - destination.dx - 13
                : destination.dx - 13;
            final pulse = reducedMotion
                ? 1.0
                : 0.96 +
                      0.08 * (math.sin(controller.value * math.pi * 4) + 1) / 2;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _AuthRoutePainter(
                        path: path,
                        accent: colorScheme.primary,
                        dash: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: vehicleStart,
                  top: tangent.position.dy - 14,
                  child: Transform.rotate(
                    angle: tangent.angle,
                    child: Icon(
                      Icons.airport_shuttle_rounded,
                      size: 26,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: pinStart,
                  top: destination.dy - 14,
                  child: Transform.scale(
                    scale: pulse,
                    child: Icon(
                      Icons.location_on,
                      size: 28,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Path _routePath(Size size, bool rtl) {
  final startX = rtl ? size.width * 0.92 : size.width * 0.08;
  final endX = rtl ? size.width * 0.08 : size.width * 0.92;
  final dx = endX - startX;

  return Path()
    ..moveTo(startX, size.height * 0.78)
    ..cubicTo(
      startX + dx * 0.28,
      size.height * 0.06,
      startX + dx * 0.72,
      size.height * 0.96,
      endX,
      size.height * 0.22,
    );
}

class _AuthRoutePainter extends CustomPainter {
  final Path path;
  final Color accent;
  final Color dash;

  const _AuthRoutePainter({
    required this.path,
    required this.accent,
    required this.dash,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = accent.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, routePaint);

    final dashPaint = Paint()
      ..color = dash.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (final metric in path.computeMetrics()) {
      for (var offset = 0.0; offset < metric.length; offset += 20) {
        final end = math.min(offset + 8, metric.length);
        canvas.drawPath(metric.extractPath(offset, end), dashPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_AuthRoutePainter oldDelegate) =>
      path != oldDelegate.path ||
      accent != oldDelegate.accent ||
      dash != oldDelegate.dash;
}

class _BrandPanel extends StatelessWidget {
  final AnimationController controller;

  const _BrandPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final features = [
      (Icons.confirmation_number_outlined, l10n.onboardingReserveTitle),
      (Icons.route_outlined, l10n.onboardingTrackTitle),
      (Icons.account_balance_wallet_outlined, l10n.onboardingPayTitle),
    ];

    final background = colorScheme.brightness == Brightness.dark
        ? colorScheme.surfaceContainer
        : colorScheme.secondary;

    return ClipRRect(
      borderRadius: const BorderRadiusDirectional.only(
        bottomEnd: Radius.circular(32),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(color: background),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AuthStaggerItem(
                    index: 0,
                    child: AppLogoMark(size: 144),
                  ),
                  const SizedBox(height: 20),
                  const AuthStaggerItem(
                    index: 1,
                    child: AppWordmark(prominent: true, onDark: true),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.splashSlogan,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: colorScheme.onPrimary),
                  ),
                  const SizedBox(height: 40),
                  for (var index = 0; index < features.length; index++) ...[
                    AuthStaggerItem(
                      index: index + 2,
                      child: _BrandFeature(
                        icon: features[index].$1,
                        label: features[index].$2,
                        color: colorScheme,
                      ),
                    ),
                    if (index != features.length - 1)
                      const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandFeature extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme color;

  const _BrandFeature({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: Directionality.of(context),
      children: [
        Icon(icon, size: 24, color: color.primary),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: color.onPrimary),
          ),
        ),
      ],
    );
  }
}
