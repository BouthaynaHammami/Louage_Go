import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/hive_service.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../l10n/generated/app_localizations.dart';

// ══════════════════════════════════════════════════════════════════════════════
// SplashScreen — écran de transition après l'intro vidéo
// Fond sombre avec carte Tunisie + van animé + logo
// ══════════════════════════════════════════════════════════════════════════════

const _kDark  = Color(0xFF10111A);
const _kDark2 = Color(0xFF1A0B0B);
const _kRed   = Color(0xFFDC2D2A);
const _kGold  = Color(0xFFD4A843);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // Animation principale : 0→1 en 1.8 s
  late final AnimationController _mainCtrl;

  // Animation fond en boucle
  late final AnimationController _bgCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _taglineFade;
  late final Animation<double> _vanX;

  late final Timer _redirectTimer;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _logoFade = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _taglineFade = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.35, 0.80, curve: Curves.easeOut),
    );

    _vanX = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.10, 0.90, curve: Curves.easeInOutCubic),
    );

    _mainCtrl.forward();
    _redirectTimer = Timer(const Duration(milliseconds: 2200), _continue);
  }

  void _continue() {
    if (!mounted) return;
    final onboardingSeen =
        HiveService.session.get('onboardingSeen')?['value'] == true;
    context.goNamed(onboardingSeen ? 'login' : 'onboarding');
  }

  @override
  void dispose() {
    _redirectTimer.cancel();
    _mainCtrl.dispose();
    _bgCtrl.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size   = MediaQuery.sizeOf(context);
    final safeT  = MediaQuery.viewPaddingOf(context).top;
    final slogan = AppLocalizations.of(context)!.splashSlogan;

    return Scaffold(
      backgroundColor: _kDark,
      body: Stack(
        children: [
          // ── Fond animé sombre ────────────────────────────────────────
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _bgCtrl,
                builder: (_, _) => CustomPaint(
                  painter: _SplashBgPainter(_bgCtrl.value),
                ),
              ),
            ),
          ),

          // ── Carte Tunisie (silhouette réseau) ────────────────────────
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _bgCtrl,
                builder: (_, _) => CustomPaint(
                  painter: _TunisiaMapPainter(_bgCtrl.value),
                ),
              ),
            ),
          ),

          // ── Van animé sur la route ───────────────────────────────────
          Positioned(
            bottom: size.height * 0.28,
            left: 0,
            right: 0,
            height: 80,
            child: AnimatedBuilder(
              animation: _vanX,
              builder: (_, _) {
                final progress = _vanX.value;
                final vanW = size.width * 0.28;
                final x = -vanW + progress * (size.width + vanW);
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Route
                    Positioned(
                      left: 0, right: 0,
                      top: 52,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              _kRed.withValues(alpha: 0.35),
                              _kRed.withValues(alpha: 0.35),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.15, 0.85, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Tirets de la route
                    ...List.generate(6, (i) {
                      final pos = (i / 6 + _bgCtrl.value * 0.3) % 1.0;
                      return Positioned(
                        left: pos * size.width,
                        top: 52,
                        child: Container(
                          width: 24,
                          height: 2,
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      );
                    }),
                    // Van (icône)
                    Positioned(
                      left: x,
                      top: 0,
                      width: vanW,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_pin,
                            size: 20,
                            color: _kRed,
                          ),
                          Icon(
                            Icons.airport_shuttle_rounded,
                            size: 44,
                            color: _kRed,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // ── Logo + wordmark + tagline ────────────────────────────────
          Positioned(
            left: 0, right: 0,
            top: safeT + size.height * 0.38,
            child: AnimatedBuilder(
              animation: _mainCtrl,
              builder: (_, _) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo mark avec halo
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _kRed.withValues(alpha: 0.40),
                              blurRadius: 40,
                              spreadRadius: 8,
                            ),
                            BoxShadow(
                              color: _kGold.withValues(alpha: 0.20),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const AppLogoMark(size: 88),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Wordmark
                  FadeTransition(
                    opacity: _logoFade,
                    child: const AppWordmark(onDark: true),
                  ),
                  const SizedBox(height: 12),

                  // Séparateur doré
                  FadeTransition(
                    opacity: _taglineFade,
                    child: Container(
                      width: 48,
                      height: 1.5,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.transparent,
                            _kGold,
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tagline
                  FadeTransition(
                    opacity: _taglineFade,
                    child: Text(
                      slogan,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFD4A843),
                        fontSize: 12,
                        letterSpacing: 1.8,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Indicateur de chargement ─────────────────────────────────
          Positioned(
            bottom: 40,
            left: 0, right: 0,
            child: AnimatedBuilder(
              animation: _bgCtrl,
              builder: (_, _) {
                final t = _bgCtrl.value;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final phase = (t * 3 + i / 3) % 1.0;
                    final scale = 0.6 + 0.4 * math.sin(phase * math.pi);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _kRed.withValues(alpha: 0.4 + 0.6 * scale),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fond animé sombre — blobs rouges doux
// ─────────────────────────────────────────────────────────────────────────────
class _SplashBgPainter extends CustomPainter {
  const _SplashBgPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Fond de base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kDark, _kDark2],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Blob rouge haut
    final cx1 = w * (0.30 + 0.20 * math.sin(t * 2 * math.pi));
    final cy1 = h * (0.20 + 0.10 * math.cos(t * 2 * math.pi * 0.7));
    canvas.drawCircle(
      Offset(cx1, cy1),
      w * 0.70,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _kRed.withValues(alpha: 0.18),
            _kRed.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(
          Rect.fromCircle(center: Offset(cx1, cy1), radius: w * 0.70),
        ),
    );

    // Blob rouge bas
    final cx2 = w * (0.70 - 0.18 * math.sin(t * 2 * math.pi + 1.2));
    final cy2 = h * (0.80 + 0.08 * math.cos(t * 2 * math.pi * 0.5));
    canvas.drawCircle(
      Offset(cx2, cy2),
      w * 0.55,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _kRed.withValues(alpha: 0.12),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: Offset(cx2, cy2), radius: w * 0.55),
        ),
    );
  }

  @override
  bool shouldRepaint(_SplashBgPainter old) => old.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// Carte Tunisie — réseau de trajets animé
// ─────────────────────────────────────────────────────────────────────────────
const _kCities = <({String name, double nx, double ny})>[
  (name: 'Tunis',    nx: 0.52, ny: 0.08),
  (name: 'Sousse',   nx: 0.60, ny: 0.32),
  (name: 'Sfax',     nx: 0.57, ny: 0.54),
  (name: 'Gabes',    nx: 0.59, ny: 0.72),
  (name: 'Tozeur',   nx: 0.28, ny: 0.68),
  (name: 'Kairouan', nx: 0.50, ny: 0.40),
  (name: 'Bizerte',  nx: 0.46, ny: 0.04),
];

const _kRoutes = <(int, int)>[
  (0, 1), (1, 2), (2, 3), (3, 4), (0, 5), (5, 2), (0, 6),
];

class _TunisiaMapPainter extends CustomPainter {
  const _TunisiaMapPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final mapRect = Rect.fromLTWH(
      size.width * 0.42,
      size.height * 0.04,
      size.width * 0.52,
      size.height * 0.78,
    );

    Offset pos(double nx, double ny) => Offset(
          mapRect.left + nx * mapRect.width,
          mapRect.top  + ny * mapRect.height,
        );

    // Routes
    for (final (ia, ib) in _kRoutes) {
      final a = pos(_kCities[ia].nx, _kCities[ia].ny);
      final b = pos(_kCities[ib].nx, _kCities[ib].ny);

      canvas.drawLine(
        a, b,
        Paint()
          ..color = _kRed.withValues(alpha: 0.14)
          ..strokeWidth = 0.7
          ..style = PaintingStyle.stroke,
      );

      // Louage mobile sur la route
      final phase = ((ia + ib) % 7) / 7.0;
      final progress = (t + phase) % 1.0;
      final vPos = Offset.lerp(a, b, progress)!;

      canvas.drawCircle(
        vPos,
        2.5,
        Paint()..color = _kRed.withValues(alpha: 0.45),
      );

      // Traînée
      final trailStart = Offset.lerp(a, b, math.max(0.0, progress - 0.15))!;
      canvas.drawLine(
        trailStart, vPos,
        Paint()
          ..color = _kRed.withValues(alpha: 0.22)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    // Points villes avec pulse
    for (var i = 0; i < _kCities.length; i++) {
      final p    = pos(_kCities[i].nx, _kCities[i].ny);
      final ph   = (i / _kCities.length + t * 1.5) % 1.0;
      final pulse = 0.65 + 0.35 * math.sin(ph * 2 * math.pi);

      // Halo
      canvas.drawCircle(
        p, 8 * pulse,
        Paint()
          ..color = _kRed.withValues(alpha: 0.10 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );

      // Point
      canvas.drawCircle(
        p, 3.0,
        Paint()..color = _kRed.withValues(alpha: 0.55 * pulse),
      );

      // Anneau
      canvas.drawCircle(
        p, 5.5 * pulse,
        Paint()
          ..color = _kRed.withValues(alpha: 0.25 * pulse)
          ..strokeWidth = 0.7
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_TunisiaMapPainter old) => old.t != t;
}
