import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_logo.dart';

// ══════════════════════════════════════════════════════════════════════════════
// IntroSlidesScreen — 3 slides créatifs après la vidéo intro
// Présente l'application avec des animations et louage_1.png
// ══════════════════════════════════════════════════════════════════════════════

const _kDark    = Color(0xFF10111A);
const _kDark2   = Color(0xFF1A0B0C);
const _kRed     = Color(0xFFDC2D2A);
const _kRedSoft = Color(0xFFFF6B6B);
const _kGold    = Color(0xFFD4A843);

// ─────────────────────────────────────────────────────────────────────────────
// Modèle de slide
// ─────────────────────────────────────────────────────────────────────────────
class _Slide {
  const _Slide({
    required this.emoji,
    required this.title,
    required this.body,
    required this.accent,
    required this.painter,
  });
  final String emoji;
  final String title;
  final String body;
  final Color accent;
  final CustomPainter Function(double t) painter;
}

final _slides = <_Slide>[
  _Slide(
    emoji: '🇹🇳',
    title: 'Voyagez à travers\nla Tunisie',
    body: 'Des louages partagés reliant\ntoutes les villes du pays.',
    accent: _kRed,
    painter: (t) => _MapPainter(t),
  ),
  _Slide(
    emoji: '⚡',
    title: 'Réservez en\nquelques secondes',
    body: 'Choisissez votre place,\nconfirmez — c\'est réservé.',
    accent: _kGold,
    painter: (t) => _SpeedPainter(t),
  ),
  _Slide(
    emoji: '🛡️',
    title: 'Voyagez l\'esprit\ntranquille',
    body: 'Billet numérique, suivi temps\nréel, paiement sécurisé.',
    accent: _kRedSoft,
    painter: (t) => _ShieldPainter(t),
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
// Widget principal
// ══════════════════════════════════════════════════════════════════════════════

class IntroSlidesScreen extends StatefulWidget {
  const IntroSlidesScreen({super.key});

  @override
  State<IntroSlidesScreen> createState() => _IntroSlidesScreenState();
}

class _IntroSlidesScreenState extends State<IntroSlidesScreen>
    with TickerProviderStateMixin {

  static const _count = 3;
  final _pageCtrl = PageController();
  int _page = 0;

  // Boucle de fond (18 s)
  late final AnimationController _bgCtrl;

  // Entrée de chaque slide (720 ms, re-trigger à chaque page)
  late final AnimationController _inCtrl;
  late final Animation<double>   _vanOffset;   // -1.2 → 0 (unité : largeur écran)
  late final Animation<double>   _vanFade;
  late final Animation<double>   _textFade;
  late final Animation<Offset>   _textSlide;
  late final Animation<double>   _badgeScale;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _inCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );

    _vanOffset = Tween<double>(begin: -1.3, end: 0.0).animate(
      CurvedAnimation(parent: _inCtrl,
          curve: const Interval(0.00, 0.62, curve: Curves.easeOutCubic)));

    _vanFade = CurvedAnimation(parent: _inCtrl,
        curve: const Interval(0.00, 0.48, curve: Curves.easeOut));

    _textFade = CurvedAnimation(parent: _inCtrl,
        curve: const Interval(0.38, 0.88, curve: Curves.easeOut));

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _inCtrl,
        curve: const Interval(0.38, 0.92, curve: Curves.easeOutCubic)));

    _badgeScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _inCtrl,
          curve: const Interval(0.50, 1.00, curve: Curves.elasticOut)));

    _inCtrl.forward();
  }

  void _goNext() {
    if (_page == _count - 1) {
      _done();
      return;
    }
    _pageCtrl.animateToPage(
      _page + 1,
      duration: const Duration(milliseconds: 440),
      curve: Curves.easeInOutCubic,
    );
  }

  void _done() {
    if (!mounted) return;
    context.goNamed('splash');
  }

  void _onPageChanged(int p) {
    setState(() => _page = p);
    _inCtrl
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _bgCtrl.dispose();
    _inCtrl.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size  = MediaQuery.sizeOf(context);
    final safeT = MediaQuery.viewPaddingOf(context).top;
    final safeB = MediaQuery.viewPaddingOf(context).bottom;
    final slide = _slides[_page];

    return Scaffold(
      backgroundColor: _kDark,
      body: Stack(
        children: [

          // ── 1. Fond animé (CustomPainter par slide) ──────────────────
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _bgCtrl,
                builder: (_, _) => CustomPaint(
                  painter: slide.painter(_bgCtrl.value),
                ),
              ),
            ),
          ),

          // ── 2. Dégradé de lisibilité (bas) ───────────────────────────
          Positioned(
            left: 0, right: 0, bottom: 0,
            height: size.height * 0.52,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      _kDark.withValues(alpha: 0.97),
                      _kDark.withValues(alpha: 0.78),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.50, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── 3. PageView (pour le swipe) ──────────────────────────────
          PageView.builder(
            controller: _pageCtrl,
            itemCount: _count,
            onPageChanged: _onPageChanged,
            itemBuilder: (_, _) => const SizedBox.expand(),
          ),

          // ── 4. Zone illustration (van + route) ───────────────────────
          Positioned(
            left: 0, right: 0,
            top: safeT + size.height * 0.06,
            height: size.height * 0.46,
            child: AnimatedBuilder(
              animation: _inCtrl,
              builder: (_, _) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [

                    // Route (ligne + tirets)
                    Positioned(
                      left: 0, right: 0,
                      bottom: size.height * 0.035,
                      child: _Road(bgCtrl: _bgCtrl),
                    ),

                    // Van qui entre de la gauche
                    Positioned(
                      left: 0, right: 0,
                      bottom: size.height * 0.035 + 2,
                      child: FadeTransition(
                        opacity: _vanFade,
                        child: Transform.translate(
                          offset: Offset(size.width * _vanOffset.value, 0),
                          child: _VanWidget(
                            bgCtrl: _bgCtrl,
                            accent: slide.accent,
                          ),
                        ),
                      ),
                    ),

                    // Badge emoji (haut-droit, bounce)
                    Positioned(
                      right: 24,
                      top: 0,
                      child: ScaleTransition(
                        scale: _badgeScale,
                        child: _Badge(
                          emoji: slide.emoji,
                          accent: slide.accent,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // ── 5. Texte (titre + body) ──────────────────────────────────
          Positioned(
            left: 28, right: 28,
            bottom: safeB + 148,
            child: AnimatedBuilder(
              animation: _inCtrl,
              builder: (_, _) => FadeTransition(
                opacity: _textFade,
                child: SlideTransition(
                  position: _textSlide,
                  child: _SlideText(slide: slide),
                ),
              ),
            ),
          ),

          // ── 6. Barre bas (dots + bouton) ─────────────────────────────
          Positioned(
            left: 24, right: 24,
            bottom: safeB + 24,
            child: _BottomBar(
              page: _page,
              count: _count,
              isLast: _page == _count - 1,
              accent: slide.accent,
              bgCtrl: _bgCtrl,
              onNext: _goNext,
            ),
          ),

          // ── 7. Bouton "Passer" ────────────────────────────────────────
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _page < _count - 1 ? 1.0 : 0.0,
            child: Positioned(
              top: safeT + 10,
              right: 14,
              child: TextButton(
                onPressed: _done,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withValues(alpha: 0.45),
                  minimumSize: const Size(64, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'Passer',
                  style: TextStyle(fontSize: 13, letterSpacing: 0.3),
                ),
              ),
            ),
          ),

          // ── 8. Logo (haut-gauche) ────────────────────────────────────
          Positioned(
            top: safeT + 14,
            left: 18,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppLogoMark(size: 26, showBackground: false),
                const SizedBox(width: 6),
                const AppWordmark(onDark: true),
              ],
            ),
          ),

        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Van widget — louage_1.png avec bob + halo
// ─────────────────────────────────────────────────────────────────────────────
class _VanWidget extends StatelessWidget {
  const _VanWidget({required this.bgCtrl, required this.accent});
  final AnimationController bgCtrl;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final w   = MediaQuery.sizeOf(context).width;
    final vanW = w * 0.68;
    return AnimatedBuilder(
      animation: bgCtrl,
      builder: (_, child) {
        final bob  = math.sin(bgCtrl.value * 2 * math.pi) * 4.0;
        final halo = 0.50 + 0.50 * math.sin(bgCtrl.value * 2 * math.pi * 0.9);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: Offset(0, bob),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Halo sous le van
                  Positioned(
                    bottom: -4,
                    child: Container(
                      width: vanW * 0.60,
                      height: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.26 * halo),
                            blurRadius: 36,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Image
                  child!,
                ],
              ),
            ),
            // Ombre au sol
            Transform.translate(
              offset: Offset(0, bob * 0.25),
              child: Container(
                width: vanW * 0.52,
                height: 7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.black.withValues(alpha: 0.28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      child: Image.asset(
        'assets/images/louage_1.png',
        width: vanW,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Route animée
// ─────────────────────────────────────────────────────────────────────────────
class _Road extends StatelessWidget {
  const _Road({required this.bgCtrl});
  final AnimationController bgCtrl;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: bgCtrl,
        builder: (_, _) => CustomPaint(
          size: Size(MediaQuery.sizeOf(context).width, 14),
          painter: _RoadPainter(bgCtrl.value),
        ),
      ),
    );
  }
}

class _RoadPainter extends CustomPainter {
  const _RoadPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    // Ligne
    canvas.drawLine(
      Offset(0, 7), Offset(w, 7),
      Paint()
        ..color = _kRed.withValues(alpha: 0.20)
        ..strokeWidth = 1.5,
    );
    // Tirets défilants
    const dashW = 26.0;
    const gap   = 20.0;
    const cycle = dashW + gap;
    final off = (t * cycle * 2.8) % cycle;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var x = -cycle + off; x < w + dashW; x += cycle) {
      canvas.drawLine(Offset(x, 7), Offset(x + dashW, 7), paint);
    }
  }

  @override
  bool shouldRepaint(_RoadPainter o) => o.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge emoji
// ─────────────────────────────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  const _Badge({required this.emoji, required this.accent});
  final String emoji;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56, height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: 0.14),
        border: Border.all(color: accent.withValues(alpha: 0.38), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.28),
            blurRadius: 22,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 26)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Texte du slide
// ─────────────────────────────────────────────────────────────────────────────
class _SlideText extends StatelessWidget {
  const _SlideText({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Accent bar
        Container(
          width: 34, height: 3,
          decoration: BoxDecoration(
            color: slide.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          slide.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w700,
            height: 1.22,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          slide.body,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.68),
            fontSize: 15,
            height: 1.55,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Barre bas : dots + bouton
// ─────────────────────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.page,
    required this.count,
    required this.isLast,
    required this.accent,
    required this.bgCtrl,
    required this.onNext,
  });
  final int page;
  final int count;
  final bool isLast;
  final Color accent;
  final AnimationController bgCtrl;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Dots
        Row(
          children: List.generate(count, (i) {
            final active = i == page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(right: 8),
              width: active ? 26 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: active
                    ? accent
                    : Colors.white.withValues(alpha: 0.18),
              ),
            );
          }),
        ),
        const Spacer(),
        // Bouton
        GestureDetector(
          onTap: onNext,
          child: AnimatedBuilder(
            animation: bgCtrl,
            builder: (_, child) {
              final pulse = isLast
                  ? 1.0 + 0.03 * math.sin(bgCtrl.value * 2 * math.pi * 2)
                  : 1.0;
              return Transform.scale(scale: pulse, child: child);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              width: isLast ? 164 : 58,
              height: 58,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(29),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.42),
                    blurRadius: 22,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: isLast
                      ? const Text(
                          'Commencer',
                          key: ValueKey('start'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        )
                      : const Icon(
                          Icons.arrow_forward_rounded,
                          key: ValueKey('arrow'),
                          color: Colors.white,
                          size: 24,
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

// ══════════════════════════════════════════════════════════════════════════════
// PAINTERS
// ══════════════════════════════════════════════════════════════════════════════

// ── Slide 1 : Carte Tunisie ───────────────────────────────────────────────────
class _MapPainter extends CustomPainter {
  const _MapPainter(this.t);
  final double t;

  static const _cities = [
    Offset(0.52, 0.08), // Tunis
    Offset(0.46, 0.04), // Bizerte
    Offset(0.60, 0.28), // Sousse
    Offset(0.57, 0.50), // Sfax
    Offset(0.59, 0.70), // Gabes
    Offset(0.28, 0.66), // Tozeur
    Offset(0.64, 0.82), // Medenine
    Offset(0.48, 0.38), // Kairouan
  ];
  static const _routes = [
    (0, 2), (2, 3), (3, 4), (4, 5), (4, 6), (0, 7), (7, 3), (0, 1),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Fond dégradé
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kDark, _kDark2],
        ).createShader(Rect.fromLTWH(0, 0, w, h)));

    // Blob rouge haut-gauche
    final bx = w * (0.18 + 0.10 * math.sin(t * 2 * math.pi));
    final by = h * (0.16 + 0.08 * math.cos(t * 2 * math.pi * 0.7));
    canvas.drawCircle(Offset(bx, by), w * 0.65,
      Paint()
        ..shader = RadialGradient(
          colors: [_kRed.withValues(alpha: 0.22), Colors.transparent],
        ).createShader(Rect.fromCircle(center: Offset(bx, by), radius: w * 0.65)));

    // Carte réseau (côté droit)
    final mr = Rect.fromLTWH(w * 0.40, h * 0.03, w * 0.55, h * 0.82);
    Offset city(Offset n) =>
        Offset(mr.left + n.dx * mr.width, mr.top + n.dy * mr.height);

    for (final (ia, ib) in _routes) {
      final a = city(_cities[ia]);
      final b = city(_cities[ib]);
      canvas.drawLine(a, b,
        Paint()
          ..color = _kRed.withValues(alpha: 0.16)
          ..strokeWidth = 0.8);

      final ph   = ((ia + ib) % 8) / 8.0;
      final prog = (t * 0.7 + ph) % 1.0;
      final vp   = Offset.lerp(a, b, prog)!;
      final tr   = Offset.lerp(a, b, math.max(0.0, prog - 0.14))!;

      canvas.drawLine(tr, vp,
        Paint()
          ..color = _kRed.withValues(alpha: 0.26)
          ..strokeWidth = 1.3
          ..strokeCap = StrokeCap.round);
      canvas.drawCircle(vp, 2.8,
        Paint()..color = _kRed.withValues(alpha: 0.55));
    }

    for (var i = 0; i < _cities.length; i++) {
      final p     = city(_cities[i]);
      final ph    = (i / _cities.length + t * 1.4) % 1.0;
      final pulse = 0.62 + 0.38 * math.sin(ph * 2 * math.pi);
      canvas.drawCircle(p, 3.0,
        Paint()..color = _kRed.withValues(alpha: 0.62 * pulse));
      canvas.drawCircle(p, 5.5 * pulse,
        Paint()
          ..color = _kRed.withValues(alpha: 0.24 * pulse)
          ..strokeWidth = 0.7
          ..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(_MapPainter o) => o.t != t;
}

// ── Slide 2 : Lignes de vitesse or ───────────────────────────────────────────
class _SpeedPainter extends CustomPainter {
  const _SpeedPainter(this.t);
  final double t;

  static final _rng = math.Random(99);
  static final _lines = List.generate(16, (_) => (
    y:     _rng.nextDouble(),
    len:   0.10 + _rng.nextDouble() * 0.24,
    spd:   0.007 + _rng.nextDouble() * 0.017,
    thk:   0.6 + _rng.nextDouble() * 1.9,
    ph:    _rng.nextDouble(),
  ));

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kDark, _kDark2, _kDark],
          stops: [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h)));

    // Blob or
    final gx = w * (0.60 + 0.14 * math.cos(t * 2 * math.pi));
    final gy = h * (0.26 + 0.10 * math.sin(t * 2 * math.pi * 0.65));
    canvas.drawCircle(Offset(gx, gy), w * 0.52,
      Paint()
        ..shader = RadialGradient(
          colors: [_kGold.withValues(alpha: 0.18), Colors.transparent],
        ).createShader(Rect.fromCircle(center: Offset(gx, gy), radius: w * 0.52)));

    for (final l in _lines) {
      final x  = ((t * l.spd * 68 + l.ph) % 1.28) - 0.12;
      final sx = (x - l.len) * w;
      final ex = x * w;
      final y  = l.y * h;
      if (ex < 0 || sx > w) continue;
      canvas.drawLine(Offset(sx, y), Offset(ex, y),
        Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.transparent,
              _kGold.withValues(alpha: 0.38),
              _kGold.withValues(alpha: 0.16),
              Colors.transparent,
            ],
            stops: const [0.0, 0.22, 0.78, 1.0],
          ).createShader(Rect.fromLTWH(sx, y, ex - sx, 1))
          ..strokeWidth = l.thk
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(_SpeedPainter o) => o.t != t;
}

// ── Slide 3 : Grille + particules ────────────────────────────────────────────
class _ShieldPainter extends CustomPainter {
  const _ShieldPainter(this.t);
  final double t;

  static final _rng  = math.Random(77);
  static final _dots = List.generate(28, (_) => (
    x:  _rng.nextDouble(),
    y:  _rng.nextDouble(),
    sz: 1.5 + _rng.nextDouble() * 2.5,
    ph: _rng.nextDouble(),
    sp: 0.004 + _rng.nextDouble() * 0.009,
    a:  _rng.nextDouble() * 2 * math.pi,
  ));

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [_kDark, _kDark2],
        ).createShader(Rect.fromLTWH(0, 0, w, h)));

    // Blob rouge doux
    final bx = w * (0.72 - 0.12 * math.sin(t * 2 * math.pi));
    final by = h * (0.20 + 0.10 * math.cos(t * 2 * math.pi * 0.75));
    canvas.drawCircle(Offset(bx, by), w * 0.58,
      Paint()
        ..shader = RadialGradient(
          colors: [_kRedSoft.withValues(alpha: 0.20), Colors.transparent],
        ).createShader(Rect.fromCircle(center: Offset(bx, by), radius: w * 0.58)));

    // Grille subtile
    final gp = Paint()
      ..color = _kRedSoft.withValues(alpha: 0.04)
      ..strokeWidth = 0.5;
    const step = 42.0;
    for (var x = 0.0; x < w + step; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gp);
    }
    for (var y = 0.0; y < h + step; y += step) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gp);
    }

    // Particules
    for (final d in _dots) {
      final ft  = (t + d.ph) % 1.0;
      final px  = (d.x + math.cos(d.a) * d.sp * ft * 30) % 1.0;
      final py  = (d.y + math.sin(d.a) * d.sp * ft * 30) % 1.0;
      final pul = 0.38 + 0.62 * math.sin(ft * 2 * math.pi + d.ph * 5);
      canvas.drawCircle(
        Offset(px * w, py * h),
        d.sz * pul,
        Paint()
          ..color = _kRedSoft.withValues(alpha: 0.20 * pul)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_ShieldPainter o) => o.t != t;
}
