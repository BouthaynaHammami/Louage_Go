import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import 'animated_background.dart';
import 'app_logo.dart';

// ══════════════════════════════════════════════════════════════════════════════
// AuthScaffold — Design premium  v2
//
// Mobile :
//   • Header plein-écran sombre avec louage animé sur route courbe
//   • Logo centré avec halo doré
//   • Card glassmorphism avec blur + bordure lumineuse
//   • Stagger animations à l'entrée (fade + slide)
//
// Wide (≥800px) :
//   • Panneau gauche (brand) / panneau droit (form)
// ══════════════════════════════════════════════════════════════════════════════

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
  // ── Stagger d'entrée ──────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final List<CurvedAnimation> _staggerAnims;

  // ── Louage animé sur la route ──────────────────────────────────────────
  late final AnimationController _routeCtrl;

  // ── Pulsation halo logo ────────────────────────────────────────────────
  late final AnimationController _haloCtrl;
  late final Animation<double> _haloPulse;

  bool? _motionDisabled;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _routeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );

    _haloCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _haloPulse = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _haloCtrl, curve: Curves.easeInOut),
    );

    _staggerAnims = List.generate(14, (i) {
      final start = math.min(0.02 + i * 0.050, 0.62);
      final end   = math.min(start + 0.38, 1.0);
      return CurvedAnimation(
        parent: _entranceCtrl,
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
      _entranceCtrl.value = 1;
      _routeCtrl..stop()..value = 0;
      _haloCtrl.stop();
      return;
    }

    if (wasDisabled == true) {
      _entranceCtrl.forward(from: 0);
    } else if (_entranceCtrl.status == AnimationStatus.dismissed) {
      _entranceCtrl.forward();
    }
    if (!_routeCtrl.isAnimating) _routeCtrl.repeat();
    if (!_haloCtrl.isAnimating)  _haloCtrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    for (final a in _staggerAnims) { a.dispose(); }
    _entranceCtrl.dispose();
    _routeCtrl.dispose();
    _haloCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 800;

    return _AuthStaggerScope(
      animations: _staggerAnims,
      disabled: _motionDisabled ?? false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Arrière-plan animé (mid intensity)
            const AnimatedBackground(intensity: BackgroundIntensity.mid),

            // Contenu
            SafeArea(
              top: isWide,
              child: isWide
                  ? _WideLayout(
                      routeCtrl: _routeCtrl,
                      haloPulse: _haloPulse,
                      title: widget.title,
                      subtitle: widget.subtitle,
                      child: widget.child,
                    )
                  : _MobileLayout(
                      routeCtrl:   _routeCtrl,
                      haloPulse:   _haloPulse,
                      title:       widget.title,
                      subtitle:    widget.subtitle,
                      motionOff:   _motionDisabled ?? false,
                      child:       widget.child,
                    ),
            ),

            // Bouton retour
            if (widget.showBackButton)
              PositionedDirectional(
                top: isWide
                    ? 8
                    : MediaQuery.viewPaddingOf(context).top + 8,
                start: 8,
                child: _BackBtn(
                  onBack: widget.onBack ?? Navigator.of(context).maybePop,
                  colorScheme: colorScheme,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Layout mobile
// ─────────────────────────────────────────────────────────────────────────────
class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.routeCtrl,
    required this.haloPulse,
    required this.title,
    required this.subtitle,
    required this.motionOff,
    required this.child,
  });

  final AnimationController routeCtrl;
  final Animation<double> haloPulse;
  final String? title;
  final String? subtitle;
  final bool motionOff;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Column(
      children: [
        // ── Header cinématique ──────────────────────────────────────────
        _CinematicHeader(
          routeCtrl:  routeCtrl,
          haloPulse:  haloPulse,
          motionOff:  motionOff,
          isDark:     isDark,
          colorScheme: colorScheme,
        ),

        // ── Card formulaire ─────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 36),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: AuthStaggerItem(
                  index: 2,
                  child: _PremiumCard(
                    isDark: isDark,
                    colorScheme: colorScheme,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          26, 28, 26, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (title != null) ...[
                            AuthStaggerItem(
                              index: 3,
                              child: Text(
                                title!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 6),
                              AuthStaggerItem(
                                index: 4,
                                child: Text(
                                  subtitle!,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                          ],
                          child,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Header cinématique
// ─────────────────────────────────────────────────────────────────────────────
class _CinematicHeader extends StatelessWidget {
  const _CinematicHeader({
    required this.routeCtrl,
    required this.haloPulse,
    required this.motionOff,
    required this.isDark,
    required this.colorScheme,
  });

  final AnimationController routeCtrl;
  final Animation<double> haloPulse;
  final bool motionOff;
  final bool isDark;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark
        ? const Color(0xFF1B232D)
        : const Color(0xFF222C38);

    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          // Fond dégradé
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    bgColor,
                    bgColor.withValues(alpha: 0.92),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(36),
                ),
              ),
            ),
          ),

          // Route animée (CustomPainter)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(36),
              ),
              child: _RouteAnimation(
                controller: routeCtrl,
                height: 200,
                reducedMotion: motionOff,
                colorScheme: colorScheme,
              ),
            ),
          ),

          // Particules de lumière (overlay)
          if (!motionOff)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: routeCtrl,
                builder: (_, __) => CustomPaint(
                  painter: _HeaderParticlesPainter(
                    progress: routeCtrl.value,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),

          // Ligne de séparation lumineuse en bas
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    colorScheme.primary.withValues(alpha: 0.60),
                    Colors.transparent,
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(36),
                ),
              ),
            ),
          ),

          // Logo centré avec halo pulsant
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AuthStaggerItem(
                  index: 0,
                  child: AnimatedBuilder(
                    animation: haloPulse,
                    builder: (_, child) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary
                                .withValues(alpha: 0.35 * haloPulse.value),
                            blurRadius: 28 * haloPulse.value,
                            spreadRadius: 4 * haloPulse.value,
                          ),
                          BoxShadow(
                            color: Colors.white
                                .withValues(alpha: 0.12 * haloPulse.value),
                            blurRadius: 14 * haloPulse.value,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                    child: const AppLogoMark(size: 78),
                  ),
                ),
                const SizedBox(height: 10),
                const AuthStaggerItem(
                  index: 1,
                  child: AppWordmark(onDark: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card premium (glassmorphism)
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumCard extends StatelessWidget {
  const _PremiumCard({
    required this.isDark,
    required this.colorScheme,
    required this.child,
  });

  final bool isDark;
  final ColorScheme colorScheme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1B232D).withValues(alpha: 0.88)
                : Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : colorScheme.primary.withValues(alpha: 0.10),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.08),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bouton retour
// ─────────────────────────────────────────────────────────────────────────────
class _BackBtn extends StatelessWidget {
  const _BackBtn({required this.onBack, required this.colorScheme});
  final VoidCallback onBack;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onBack,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.20),
              width: 0.8,
            ),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Route animée (louage sur courbe de Bézier)
// ─────────────────────────────────────────────────────────────────────────────
class _RouteAnimation extends StatelessWidget {
  const _RouteAnimation({
    required this.controller,
    required this.height,
    required this.reducedMotion,
    required this.colorScheme,
  });

  final AnimationController controller;
  final double height;
  final bool reducedMotion;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => SizedBox(
        height: height,
        child: LayoutBuilder(
          builder: (_, constraints) {
            final size = Size(constraints.maxWidth, height);
            final path = _buildPath(size, rtl);
            final metric = path.computeMetrics().first;
            final progress = reducedMotion ? 0.35 : controller.value;
            final tangent = metric.getTangentForOffset(
                metric.length * progress)!;
            final destination = metric
                .getTangentForOffset(metric.length)!
                .position;

            final vehicleX = rtl
                ? size.width - tangent.position.dx - 16
                : tangent.position.dx - 16;
            final pinX = rtl
                ? size.width - destination.dx - 14
                : destination.dx - 14;
            final pulse = reducedMotion
                ? 1.0
                : 0.94 + 0.10 *
                      (math.sin(controller.value * math.pi * 5) + 1) / 2;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Chemin
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RoutePainter(
                      path: path,
                      primary: colorScheme.primary,
                      dash: colorScheme.onPrimary,
                    ),
                  ),
                ),
                // Louage
                PositionedDirectional(
                  start: vehicleX,
                  top: tangent.position.dy - 14,
                  child: Transform.rotate(
                    angle: tangent.angle,
                    child: Icon(
                      Icons.airport_shuttle_rounded,
                      size: 28,
                      color: colorScheme.primary,
                      shadows: [
                        Shadow(
                          color: colorScheme.primary.withValues(alpha: 0.50),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                ),
                // Pin destination
                PositionedDirectional(
                  start: pinX,
                  top: destination.dy - 16,
                  child: Transform.scale(
                    scale: pulse,
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 30,
                      color: colorScheme.primary,
                      shadows: [
                        Shadow(
                          color: colorScheme.primary.withValues(alpha: 0.55),
                          blurRadius: 14,
                        ),
                      ],
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

  Path _buildPath(Size size, bool rtl) {
    final sx = rtl ? size.width * 0.92 : size.width * 0.08;
    final ex = rtl ? size.width * 0.08 : size.width * 0.92;
    final dx = ex - sx;
    return Path()
      ..moveTo(sx, size.height * 0.80)
      ..cubicTo(
        sx + dx * 0.25, size.height * 0.05,
        sx + dx * 0.75, size.height * 0.95,
        ex, size.height * 0.20,
      );
  }
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter({
    required this.path,
    required this.primary,
    required this.dash,
  });
  final Path path;
  final Color primary;
  final Color dash;

  @override
  void paint(Canvas canvas, Size size) {
    // Halo lumineux autour de la route
    canvas.drawPath(
      path,
      Paint()
        ..color = primary.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // Route principale
    canvas.drawPath(
      path,
      Paint()
        ..color = primary.withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    // Tirets
    final dashPaint = Paint()
      ..color = dash.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (final metric in path.computeMetrics()) {
      for (var off = 0.0; off < metric.length; off += 22) {
        final end = math.min(off + 10, metric.length);
        canvas.drawPath(metric.extractPath(off, end), dashPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_RoutePainter o) =>
      o.path != path || o.primary != primary;
}

// ─────────────────────────────────────────────────────────────────────────────
// Particules de lumière dans le header
// ─────────────────────────────────────────────────────────────────────────────
class _HeaderParticlesPainter extends CustomPainter {
  const _HeaderParticlesPainter({
    required this.progress,
    required this.color,
  });
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < 18; i++) {
      final px = rng.nextDouble() * size.width;
      final py = rng.nextDouble() * size.height;
      final phase = rng.nextDouble();
      final radius = 1.0 + rng.nextDouble() * 2.0;
      final alpha = math.sin((progress + phase) * 2 * math.pi).abs() * 0.35;
      if (alpha < 0.04) continue;
      paint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(px, py), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_HeaderParticlesPainter o) => o.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Wide layout (tablette)
// ─────────────────────────────────────────────────────────────────────────────
class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.routeCtrl,
    required this.haloPulse,
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final AnimationController routeCtrl;
  final Animation<double> haloPulse;
  final String? title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final bgColor = isDark
        ? const Color(0xFF1B232D)
        : const Color(0xFF222C38);

    return Row(
      children: [
        // Panneau brand
        Expanded(
          flex: 45,
          child: ClipRRect(
            borderRadius: const BorderRadiusDirectional.only(
              bottomEnd: Radius.circular(32),
            ),
            child: ColoredBox(
              color: bgColor,
              child: _BrandPanel(
                routeCtrl: routeCtrl,
                haloPulse: haloPulse,
                colorScheme: colorScheme,
              ),
            ),
          ),
        ),
        // Panneau formulaire
        Expanded(
          flex: 55,
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(48, 72, 48, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    AuthStaggerItem(index: 2, child: child),
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

// ─────────────────────────────────────────────────────────────────────────────
// Brand panel (wide)
// ─────────────────────────────────────────────────────────────────────────────
class _BrandPanel extends StatelessWidget {
  const _BrandPanel({
    required this.routeCtrl,
    required this.haloPulse,
    required this.colorScheme,
  });
  final AnimationController routeCtrl;
  final Animation<double> haloPulse;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final features = [
      (Icons.confirmation_number_outlined, l10n.onboardingReserveTitle),
      (Icons.route_outlined, l10n.onboardingTrackTitle),
      (Icons.account_balance_wallet_outlined, l10n.onboardingPayTitle),
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(48),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AuthStaggerItem(
                index: 0,
                child: AnimatedBuilder(
                  animation: haloPulse,
                  builder: (_, child) => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary
                              .withValues(alpha: 0.40 * haloPulse.value),
                          blurRadius: 32 * haloPulse.value,
                          spreadRadius: 5 * haloPulse.value,
                        ),
                      ],
                    ),
                    child: child,
                  ),
                  child: const AppLogoMark(size: 144),
                ),
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
              for (var i = 0; i < features.length; i++) ...[
                AuthStaggerItem(
                  index: i + 2,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          features[i].$1,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          features[i].$2,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: colorScheme.onPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < features.length - 1) const SizedBox(height: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stagger scope
// ─────────────────────────────────────────────────────────────────────────────
class AuthStaggerItem extends StatelessWidget {
  const AuthStaggerItem({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scope = _AuthStaggerScope.maybeOf(context);
    if (scope == null || scope.disabled) return child;

    final anim = scope.animations[
        index.clamp(0, scope.animations.length - 1).toInt()];
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.040),
      end: Offset.zero,
    ).animate(anim);

    return FadeTransition(
      opacity: anim,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

class _AuthStaggerScope extends InheritedWidget {
  const _AuthStaggerScope({
    required this.animations,
    required this.disabled,
    required super.child,
  });

  final List<Animation<double>> animations;
  final bool disabled;

  static _AuthStaggerScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AuthStaggerScope>();

  @override
  bool updateShouldNotify(_AuthStaggerScope o) =>
      animations != o.animations || disabled != o.disabled;
}
