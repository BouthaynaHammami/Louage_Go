import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/hive_service.dart';
import '../../../../core/widgets/app_logo.dart';

// ══════════════════════════════════════════════════════════════════════════════
// OnboardingScreen — intro créative 3 slides
// Fond sombre · louage_1.png · animations fluides
// ══════════════════════════════════════════════════════════════════════════════

const _kDark    = Color(0xFF10111A);
const _kDark2   = Color(0xFF16090C);
const _kRed     = Color(0xFFDC2D2A);
const _kRedSoft = Color(0xFFFF6B6B);
const _kGold    = Color(0xFFD4A843);
const _kWhite70 = Color(0xB3FFFFFF);
const _kWhite40 = Color(0x66FFFFFF);

// ─────────────────────────────────────────────────────────────────────────────
// Données de chaque slide
// ─────────────────────────────────────────────────────────────────────────────
class _Slide {
  const _Slide({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.painter,
  });
  final String emoji;
  final String title;
  final String subtitle;
  final Color accent;
  /// Factory qui construit le CustomPainter animé de fond pour ce slide
  final CustomPainter Function(double t) painter;
}

final _slides = <_Slide>[
  _Slide(
    emoji: '🇹🇳',
    title: 'Voyagez à travers\nla Tunisie',
    subtitle: 'Des louages partagés reliant\ntoutes les villes du pays.',
    accent: _kRed,
    painter: (t) => _MapPainter(t),
  ),
  _Slide(
    emoji: '⚡',
    title: 'Réservez en\nquelques secondes',
    subtitle: 'Choisissez votre place,\nconfirmez, c\'est réservé.',
    accent: _kGold,
    painter: (t) => _SpeedPainter(t),
  ),
  _Slide(
    emoji: '✅',
    title: 'Voyagez l\'esprit\ntranquille',
    subtitle: 'Billet numérique, suivi en temps\nréel, paiement sécurisé.',
    accent: _kRedSoft,
    painter: (t) => _CheckPainter(t),
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
// Screen
// ══════════════════════════════════════════════════════════════════════════════

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {

  static const _count = 3;

  final _pageCtrl = PageController();
  int _page = 0;

  // Animation continue de fond (boucle)
  late final AnimationController _bgCtrl;
  // Animation d'entrée de slide (0→1 à chaque changement de page)
  late final AnimationController _slideCtrl;

  late final Animation<double> _vanSlide;   // van entre depuis la gauche
  late final Animation<double> _vanFade;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _emojiBounce;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );

    _vanSlide = Tween<double>(begin: -1.2, end: 0.0).animate(
      CurvedAnimation(parent: _slideCtrl,
          curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic)),
    );

    _vanFade = CurvedAnimation(parent: _slideCtrl,
        curve: const Interval(0.0, 0.50, curve: Curves.easeOut));

    _textFade = CurvedAnimation(parent: _slideCtrl,
        curve: const Interval(0.40, 0.90, curve: Curves.easeOut));

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl,
        curve: const Interval(0.40, 0.95, curve: Curves.easeOutCubic)));

    _emojiBounce = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideCtrl,
          curve: const Interval(0.50, 1.0, curve: Curves.elasticOut)),
    );

    _slideCtrl.forward();
  }

  Future<void> _finish() async {
    await HiveService.session.put('onboardingSeen', {'value': true});
    if (mounted) context.goNamed('login');
  }

  Future<void> _next() async {
    if (_page == _count - 1) {
      await _finish();
      return;
    }
    await _pageCtrl.animateToPage(
      _page + 1,
      duration: const Duration(milliseconds: 460),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPageChanged(int p) {
    setState(() => _page = p);
    _slideCtrl
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _bgCtrl.dispose();
    _slideCtrl.dispose();
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
          // ── Fond animé (CustomPainter spécifique au slide) ──────────
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _bgCtrl,
                builder: (_, __) => CustomPaint(
                  painter: slide.painter(_bgCtrl.value),
                ),
              ),
            ),
          ),

          // ── Dégradé bas → haut pour lisibilité du texte ─────────────
          Positioned(
            left: 0, right: 0, bottom: 0,
            height: size.height * 0.55,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    _kDark.withValues(alpha: 0.97),
                    _kDark.withValues(alpha: 0.80),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // ── PageView (swipe) ─────────────────────────────────────────
          PageView.builder(
            controller: _pageCtrl,
            itemCount: _count,
            onPageChanged: _onPageChanged,
            itemBuilder: (_, index) => const SizedBox.expand(),
          ),

          // ── Van + illustration ───────────────────────────────────────
          Positioned(
            left: 0, right: 0,
            top: safeT + size.height * 0.07,
            height: size.height * 0.44,
            child: AnimatedBuilder(
              animation: _slideCtrl,
              builder: (_, __) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Route (ligne horizontale + tirets)
                    Positioned(
                      left: 0, right: 0,
                      bottom: size.height * 0.04,
                      child: _RoadStripe(bgCtrl: _bgCtrl),
                    ),

                    // Van avec entrée depuis la gauche
                    Positioned(
                      left: 0, right: 0,
                      bottom: size.height * 0.04 + 4,
                      child: FadeTransition(
                        opacity: _vanFade,
                        child: AnimatedBuilder(
                          animation: _vanSlide,
                          builder: (_, child) => Transform.translate(
                            offset: Offset(size.width * _vanSlide.value, 0),
                            child: child,
                          ),
                          child: _VanHero(
                            page: _page,
                            bgCtrl: _bgCtrl,
                            accent: slide.accent,
                          ),
                        ),
                      ),
                    ),

                    // Emoji flottant (badge haut-droit)
                    Positioned(
                      right: 28,
                      top: 0,
                      child: ScaleTransition(
                        scale: _emojiBounce,
                        child: _EmojiBadge(
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

          // ── Texte du slide ───────────────────────────────────────────
          Positioned(
            left: 28, right: 28,
            bottom: safeB + 160,
            child: AnimatedBuilder(
              animation: _slideCtrl,
              builder: (_, __) => FadeTransition(
                opacity: _textFade,
                child: SlideTransition(
                  position: _textSlide,
                  child: _SlideText(slide: slide),
                ),
              ),
            ),
          ),

          // ── Dots + bouton ────────────────────────────────────────────
          Positioned(
            left: 24, right: 24,
            bottom: safeB + 28,
            child: _BottomBar(
              page: _page,
              count: _count,
              isLast: _page == _count - 1,
              onNext: _next,
              onSkip: _finish,
              accent: slide.accent,
              bgCtrl: _bgCtrl,
            ),
          ),

          // ── Bouton passer (haut droite) ──────────────────────────────
          if (_page < _count - 1)
            Positioned(
              top: safeT + 12,
              right: 16,
              child: TextButton(
                onPressed: _finish,
                style: TextButton.styleFrom(
                  foregroundColor: _kWhite40,
                  minimumSize: const Size(64, 44),
                ),
                child: const Text(
                  'Passer',
                  style: TextStyle(fontSize: 13, letterSpacing: 0.3),
                ),
              ),
            ),

          // ── Logo discret (haut gauche) ───────────────────────────────
          Positioned(
            top: safeT + 14,
            left: 20,
            child: Row(
              children: [
                AppLogoMark(size: 28, showBackground: false),
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
// Van hero : image louage_1.png avec ombre + léger bob
// ─────────────────────────────────────────────────────────────────────────────
class _VanHero extends StatelessWidget {
  const _VanHero({
    required this.page,
    required this.bgCtrl,
    required this.accent,
  });
  final int page;
  final AnimationController bgCtrl;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final vanW = w * 0.72;
    return AnimatedBuilder(
      animation: bgCtrl,
      builder: (_, child) {
        // bob vertical subtil
        final bob = math.sin(bgCtrl.value * 2 * math.pi) * 4.0;
        // halo pulsant
        final halo = 0.55 + 0.45 * math.sin(bgCtrl.value * 2 * math.pi * 0.8);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: Offset(0, bob),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Halo de couleur sous le van
                  Positioned(
                    bottom: -6,
                    child: Container(
                      width: vanW * 0.65,
                      height: 18,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.28 * halo),
                            blurRadius: 32,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Image du van
                  Image.asset(
                    'assets/images/louage_1.png',
                    width: vanW,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ],
              ),
            ),
            // Ombre au sol
            Transform.translate(
              offset: Offset(0, bob * 0.3),
              child: Container(
                width: vanW * 0.55,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.black.withValues(alpha: 0.30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Route (ligne + tirets animés)
// ─────────────────────────────────────────────────────────────────────────────
class _RoadStripe extends StatelessWidget {
  const _RoadStripe({required this.bgCtrl});
  final AnimationController bgCtrl;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: bgCtrl,
        builder: (_, __) => CustomPaint(
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
    // Ligne centrale
    canvas.drawLine(
      Offset(0, 7), Offset(w, 7),
      Paint()
        ..color = _kRed.withValues(alpha: 0.22)
        ..strokeWidth = 1.5,
    );
    // Tirets mobiles
    final dashW = 28.0;
    final gap   = 20.0;
    final cycle = dashW + gap;
    final offset = (t * cycle * 2.5) % cycle;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var x = -cycle + offset; x < w + dashW; x += cycle) {
      canvas.drawLine(Offset(x, 7), Offset(x + dashW, 7), paint);
    }
  }

  @override
  bool shouldRepaint(_RoadPainter o) => o.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// Emoji badge flottant
// ─────────────────────────────────────────────────────────────────────────────
class _EmojiBadge extends StatelessWidget {
  const _EmojiBadge({required this.emoji, required this.accent});
  final String emoji;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56, height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: 0.15),
        border: Border.all(color: accent.withValues(alpha: 0.40), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.30),
            blurRadius: 20,
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
        // Séparateur coloré
        Container(
          width: 36, height: 3,
          decoration: BoxDecoration(
            color: slide.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 14),
        // Titre
        Text(
          slide.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.22,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        // Sous-titre
        Text(
          slide.subtitle,
          style: TextStyle(
            color: _kWhite70,
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
    required this.onNext,
    required this.onSkip,
    required this.accent,
    required this.bgCtrl,
  });
  final int page;
  final int count;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final Color accent;
  final AnimationController bgCtrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Dots
        Row(
          children: List.generate(count, (i) {
            final active = i == page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(right: 8),
              width: active ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: active
                    ? accent
                    : Colors.white.withValues(alpha: 0.20),
              ),
            );
          }),
        ),
        const Spacer(),
        // Bouton suivant / commencer
        AnimatedBuilder(
          animation: bgCtrl,
          builder: (_, child) {
            final pulse = isLast
                ? 1.0 + 0.03 * math.sin(bgCtrl.value * 2 * math.pi * 2)
                : 1.0;
            return Transform.scale(scale: pulse, child: child);
          },
          child: GestureDetector(
            onTap: onNext,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isLast ? 160 : 56,
              height: 56,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.40),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
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
// PAINTERS — fond animé par slide
// ══════════════════════════════════════════════════════════════════════════════

// ── Slide 1 : Carte Tunisie + réseau de routes ────────────────────────────────
class _MapPainter extends CustomPainter {
  const _MapPainter(this.t);
  final double t;

  static const _cities = <Offset>[
    Offset(0.52, 0.08), // Tunis
    Offset(0.46, 0.04), // Bizerte
    Offset(0.60, 0.28), // Sousse
    Offset(0.57, 0.50), // Sfax
    Offset(0.59, 0.70), // Gabes
    Offset(0.28, 0.66), // Tozeur
    Offset(0.64, 0.82), // Medenine
    Offset(0.48, 0.38), // Kairouan
  ];

  static const _routes = <(int, int)>[
    (0, 2), (2, 3), (3, 4), (4, 5), (4, 6), (0, 7), (7, 3), (0, 1),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Fond
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kDark, _kDark2],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Blob rouge haut-gauche
    final bx = size.width * (0.20 + 0.10 * math.sin(t * 2 * math.pi));
    final by = size.height * (0.18 + 0.08 * math.cos(t * 2 * math.pi * 0.7));
    canvas.drawCircle(
      Offset(bx, by), size.width * 0.65,
      Paint()
        ..shader = RadialGradient(
          colors: [_kRed.withValues(alpha: 0.20), Colors.transparent],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(
            center: Offset(bx, by), radius: size.width * 0.65)),
    );

    // Carte réseau (droite de l'écran)
    final mRect = Rect.fromLTWH(
      size.width * 0.40, size.height * 0.03,
      size.width * 0.55, size.height * 0.80,
    );

    Offset city(Offset n) =>
        Offset(mRect.left + n.dx * mRect.width, mRect.top + n.dy * mRect.height);

    for (final (ia, ib) in _routes) {
      final a = city(_cities[ia]);
      final b = city(_cities[ib]);
      canvas.drawLine(a, b,
          Paint()
            ..color = _kRed.withValues(alpha: 0.16)
            ..strokeWidth = 0.8
            ..style = PaintingStyle.stroke);

      // Louage animé sur la route
      final ph = ((ia + ib) % 8) / 8.0;
      final prog = (t + ph) % 1.0;
      final vp = Offset.lerp(a, b, prog)!;
      canvas.drawCircle(vp, 2.8,
          Paint()..color = _kRed.withValues(alpha: 0.50));
      final trail = Offset.lerp(a, b, math.max(0.0, prog - 0.14))!;
      canvas.drawLine(trail, vp,
          Paint()
            ..color = _kRed.withValues(alpha: 0.25)
            ..strokeWidth = 1.4
            ..strokeCap = StrokeCap.round);
    }

    for (var i = 0; i < _cities.length; i++) {
      final p = city(_cities[i]);
      final ph = (i / _cities.length + t * 1.6) % 1.0;
      final pulse = 0.65 + 0.35 * math.sin(ph * 2 * math.pi);
      canvas.drawCircle(p, 3.2,
          Paint()..color = _kRed.withValues(alpha: 0.60 * pulse));
      canvas.drawCircle(p, 5.5 * pulse,
          Paint()
            ..color = _kRed.withValues(alpha: 0.25 * pulse)
            ..strokeWidth = 0.7
            ..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(_MapPainter o) => o.t != t;
}

// ── Slide 2 : Lignes de vitesse ───────────────────────────────────────────────
class _SpeedPainter extends CustomPainter {
  const _SpeedPainter(this.t);
  final double t;

  static final _rng = math.Random(99);
  static final _lines = List.generate(14, (_) => (
    y:      _rng.nextDouble(),
    length: 0.10 + _rng.nextDouble() * 0.22,
    speed:  0.008 + _rng.nextDouble() * 0.018,
    thick:  0.7 + _rng.nextDouble() * 1.8,
    phase:  _rng.nextDouble(),
  ));

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kDark, _kDark2, _kDark],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Blob or
    final gx = size.width * (0.60 + 0.15 * math.cos(t * 2 * math.pi));
    final gy = size.height * (0.28 + 0.10 * math.sin(t * 2 * math.pi * 0.6));
    canvas.drawCircle(
      Offset(gx, gy), size.width * 0.50,
      Paint()
        ..shader = RadialGradient(
          colors: [_kGold.withValues(alpha: 0.16), Colors.transparent],
        ).createShader(Rect.fromCircle(
            center: Offset(gx, gy), radius: size.width * 0.50)),
    );

    for (final line in _lines) {
      final x = ((t * line.speed * 70 + line.phase) % 1.25) - 0.10;
      final sx = (x - line.length) * size.width;
      final ex = x * size.width;
      final y  = line.y * size.height;
      if (ex < 0 || sx > size.width) continue;
      canvas.drawLine(
        Offset(sx, y), Offset(ex, y),
        Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.transparent,
              _kGold.withValues(alpha: 0.35),
              _kGold.withValues(alpha: 0.18),
              Colors.transparent,
            ],
            stops: const [0.0, 0.25, 0.75, 1.0],
          ).createShader(Rect.fromLTWH(sx, y, ex - sx, 1))
          ..strokeWidth = line.thick
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_SpeedPainter o) => o.t != t;
}

// ── Slide 3 : Grille + particules verts / rouges ─────────────────────────────
class _CheckPainter extends CustomPainter {
  const _CheckPainter(this.t);
  final double t;

  static final _rng = math.Random(77);
  static final _dots = List.generate(30, (_) => (
    x:     _rng.nextDouble(),
    y:     _rng.nextDouble(),
    size:  1.5 + _rng.nextDouble() * 2.5,
    phase: _rng.nextDouble(),
    speed: 0.005 + _rng.nextDouble() * 0.010,
    angle: _rng.nextDouble() * 2 * math.pi,
  ));

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [_kDark, _kDark2],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Blob rouge doux
    final bx = size.width * (0.75 - 0.12 * math.sin(t * 2 * math.pi));
    final by = size.height * (0.22 + 0.10 * math.cos(t * 2 * math.pi * 0.8));
    canvas.drawCircle(
      Offset(bx, by), size.width * 0.55,
      Paint()
        ..shader = RadialGradient(
          colors: [_kRedSoft.withValues(alpha: 0.18), Colors.transparent],
        ).createShader(Rect.fromCircle(
            center: Offset(bx, by), radius: size.width * 0.55)),
    );

    // Grille subtile
    final gp = Paint()
      ..color = _kRedSoft.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;
    const step = 44.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gp);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gp);
    }

    // Particules flottantes
    for (final d in _dots) {
      final ft = (t + d.phase) % 1.0;
      final px = (d.x + math.cos(d.angle) * d.speed * ft * 28) % 1.0;
      final py = (d.y + math.sin(d.angle) * d.speed * ft * 28) % 1.0;
      final pulse = 0.4 + 0.6 * math.sin(ft * 2 * math.pi + d.phase * 5);
      canvas.drawCircle(
        Offset(px * size.width, py * size.height),
        d.size * pulse,
        Paint()
          ..color = _kRedSoft.withValues(alpha: 0.18 * pulse)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_CheckPainter o) => o.t != t;
}
