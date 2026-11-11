// ignore_for_file: avoid_redundant_argument_values
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_config.dart';
import '../../../../core/theme/app_preferences.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../auth_providers.dart';
import '../../domain/auth_exception.dart';
import '../../domain/otp_challenge.dart';
import '../../domain/phone_number.dart';
import '../auth_error_message.dart';
import '../auth_home_route.dart';
import '../otp_arguments.dart';

// ------------------------------------------------------------------------------
// AuthGateScreen v5 � Keyboard-aware � DraggableBottomSheet � Compact Van
// ------------------------------------------------------------------------------

const _kRed       = Color(0xFFD71935);
const _kDark      = Color(0xFF10111A);
const _kDark2     = Color(0xFF1A1B26);
const _kSoftWhite = Color(0xFFFAF9FA);
const _kLightGray = Color(0xFFF1F1F3);

// -- Fraction de l'�cran pour la bottom sheet ------------------------------
const _kSheetMinSize  = 0.50;  // hauteur minimale
const _kSheetInitSize = 0.56;  // hauteur initiale (clavier ferm�)
const _kSheetMaxSize  = 0.94;  // hauteur maximale (clavier ouvert / drag up)

class AuthGateScreen extends ConsumerStatefulWidget {
  const AuthGateScreen({super.key, this.initialPage = 0});
  final int initialPage;

  @override
  ConsumerState<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends ConsumerState<AuthGateScreen>
    with TickerProviderStateMixin {

  late int _page;

  // -- Contr�leurs d'animation --------------------------------------------
  late final AnimationController _bgCtrl;
  late final AnimationController _vanCtrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _pageCtrl;
  late final AnimationController _staggerCtrl;

  // ── Animations ────────────────────────────────────────────────────────
  late final List<Animation<double>> _staggerAnims;

  // -- DraggableScrollableController -------------------------------------
  final _sheetCtrl = DraggableScrollableController();

  bool _motionOff   = false;
  double _kbHeight  = 0; // hauteur du clavier en pixels

  // -- Destinations flottantes -------------------------------------------
  static const _destinations = [
    _DestData('Tunis',    Icons.location_on_rounded,   Offset(0.06, 0.20)),
    _DestData('Sousse',   Icons.directions_bus_rounded, Offset(0.72, 0.12)),
    _DestData('Sfax',     Icons.location_pin,           Offset(0.08, 0.50)),
    _DestData('Nabeul',   Icons.map_rounded,            Offset(0.68, 0.44)),
    _DestData('Monastir', Icons.flag_rounded,           Offset(0.36, 0.04)),
  ];

  @override
  void initState() {
    super.initState();
    _page = widget.initialPage;

    _bgCtrl = AnimationController(vsync: this,
        duration: const Duration(seconds: 12))..repeat();

    _vanCtrl = AnimationController(vsync: this,
        duration: const Duration(seconds: 9))..repeat();

    _floatCtrl = AnimationController(vsync: this,
        duration: const Duration(seconds: 6))..repeat();

    _pageCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 380));
    if (_page == 1) _pageCtrl.value = 1.0;

    _staggerCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 700));
    _staggerAnims = List.generate(14, (i) {
      final b = math.min(0.02 + i * 0.050, 0.65);
      final e = math.min(b + 0.38, 1.0);
      return CurvedAnimation(parent: _staggerCtrl,
          curve: Interval(b, e, curve: Curves.easeOutCubic));
    });
    _staggerCtrl.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _motionOff = MediaQuery.of(context).disableAnimations;
    if (_motionOff) {
      for (final c in [_bgCtrl, _vanCtrl, _floatCtrl]) {
        c.stop();
      }
      _staggerCtrl.value = 1;
    }
    // NOTE : avec resizeToAvoidBottomInset: true, Flutter remonte le body
    // automatiquement quand le clavier s'ouvre. Pas besoin d'animer
    // manuellement la sheet ici. La DraggableScrollableSheet s'ancre
    // naturellement au bas de l'espace disponible.
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _vanCtrl.dispose();
    _floatCtrl.dispose();
    _pageCtrl.dispose();
    _staggerCtrl.dispose();
    _sheetCtrl.dispose();
    super.dispose();
  }

  void _switchPage(int newPage) {
    if (newPage == _page) return;
    setState(() => _page = newPage);
    newPage == 1 ? _pageCtrl.forward() : _pageCtrl.reverse();
    _staggerCtrl..stop()..value = 0;
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _staggerCtrl.forward();
    });
  }

  void _snack(String msg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 13)),
      behavior: SnackBarBehavior.floating,
      backgroundColor: isDark ? const Color(0xFF2A1A1A) : _kRed,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size   = MediaQuery.sizeOf(context);
    final safeT  = MediaQuery.viewPaddingOf(context).top;
    final safeB  = MediaQuery.viewPaddingOf(context).bottom;
    final kb     = MediaQuery.viewInsetsOf(context).bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // M�moriser la hauteur du clavier pour les formulaires
    if (kb != _kbHeight) _kbHeight = kb;

    // R�duire la zone hero quand le clavier est ouvert
    final heroVisible = kb < 80;

    // Hauteur disponible pour la sheet une fois le clavier ouvert
    // Flutter g�re le resize via resizeToAvoidBottomInset: true
    // La DraggableScrollableSheet s'adapte donc automatiquement
    final screenH = size.height;

    return Scaffold(
      // --- resizeToAvoidBottomInset: true ? Flutter remonte tout le contenu
      // au-dessus du clavier automatiquement. La sheet et le formulaire
      // restent accessibles sans que le clavier les cache.
      resizeToAvoidBottomInset: true,
      backgroundColor: _kDark,
      body: Stack(children: [

        // -- 1. Fond anim� (plein �cran physique, ignore le clavier) ----
        // MediaQuery.removePadding retire les viewInsets du contexte enfant
        // pour que le fond reste plein �cran m�me quand le clavier est ouvert
        Positioned.fill(
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              viewInsets: EdgeInsets.zero),
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _bgCtrl,
                builder: (_, _) => CustomPaint(
                  painter: _BgPainter(_bgCtrl.value)),
              ),
            ),
          ),
        ),

        // -- 2. Hero section (logo + van + cartes) ---------------------
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          top: 0,
          left: 0, right: 0,
          height: heroVisible
            ? screenH - screenH * _kSheetInitSize
            : safeT + 72,
          child: Stack(children: [

            // Cartes destinations
            if (!_motionOff && heroVisible)
              Positioned.fill(
                child: Stack(
                  children: _destinations.asMap().entries.map((e) =>
                    _FloatingCard(
                      data:      e.value,
                      floatCtrl: _floatCtrl,
                      index:     e.key,
                      total:     _destinations.length,
                    )).toList(),
                ),
              ),

                        // Route animee + Louage (louage_1.png)
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _vanCtrl,
                  builder: (_, _) => CustomPaint(
                    painter: _RoutePainter(
                      progress:  _vanCtrl.value,
                      motionOff: _motionOff,
                    ),
                  ),
                ),
              ),
            ),

            // Louage image fixe a gauche sur la route
            Positioned.fill(
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  final heroW = constraints.maxWidth;
                  final heroH = constraints.maxHeight;
                  final vanW = heroW * 0.30;
                  final vanH = vanW * 0.55;
                  final vx = heroW * 0.08;
                  final vy = heroH * 0.72 - vanH * 0.5;
                  return Stack(
                    children: [
                      Positioned(
                        left:   vx,
                        top:    vy,
                        width:  vanW,
                        height: vanH,
                        child: Image.asset(
                          'assets/images/louage_1.png',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Logo + tagline
            Positioned(
              top: safeT + 10,
              left: 0, right: 0,
              child: AnimatedOpacity(
                opacity: heroVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: _LogoHeader(),
              ),
            ),
          ]),
        ),

        // -- 3. DraggableScrollableSheet --------------------------------
        // Quand resizeToAvoidBottomInset: true, le Scaffold r�duit la
        // hauteur disponible du body. La DraggableScrollableSheet
        // s'ancre donc au bas de l'espace disponible (au-dessus du clavier).
        DraggableScrollableSheet(
          controller: _sheetCtrl,
          initialChildSize: _kSheetInitSize,
          minChildSize:     _kSheetMinSize,
          maxChildSize:     _kSheetMaxSize,
          snap: true,
          snapSizes: const [_kSheetInitSize, 0.78, _kSheetMaxSize],
          snapAnimationDuration: const Duration(milliseconds: 280),
          shouldCloseOnMinExtent: false,
          builder: (context, scrollController) => _SheetContent(
            scrollController: scrollController,
            page:         _page,
            staggerAnims: _staggerAnims,
            safeBot:      safeB,
            kbHeight:     kb,
            onSwitch:     _switchPage,
            snack:        _snack,
            isDark:       isDark,
            ref:          ref,
            ctx:          context,
          ),
        ),
      ]),
    );
  }
}

// ------------------------------------------------------------------------------
// Contenu de la DraggableScrollableSheet
// ------------------------------------------------------------------------------
class _SheetContent extends StatelessWidget {
  const _SheetContent({
    required this.scrollController,
    required this.page,
    required this.staggerAnims,
    required this.safeBot,
    required this.kbHeight,
    required this.onSwitch,
    required this.snack,
    required this.isDark,
    required this.ref,
    required this.ctx,
  });

  final ScrollController scrollController;
  final int page;
  final List<Animation<double>> staggerAnims;
  final double safeBot;
  final double kbHeight;
  final void Function(int) onSwitch;
  final void Function(String) snack;
  final bool isDark;
  final WidgetRef ref;
  final BuildContext ctx;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
              ? _kDark2.withValues(alpha: 0.97)
              : _kSoftWhite.withValues(alpha: 0.98),
            borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: _kRed.withValues(alpha: 0.15), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.30),
                blurRadius: 40, offset: const Offset(0, -4)),
              BoxShadow(
                color: _kRed.withValues(alpha: 0.06),
                blurRadius: 18),
            ],
          ),
          child: Column(children: [

            // -- Poign�e draggable -------------------------------------
            // Toute cette zone r�pond au drag
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 14),
              child: Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: _kRed.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(2)),
                )),
            ),

            // -- Toggle Connexion / Inscription -------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _PageToggle(
                page: page, onSwitch: onSwitch, isDark: isDark),
            ),
            const SizedBox(height: 16),

            // -- Formulaire scrollable avec awareness clavier -----------
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 360),
                switchInCurve:  Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, anim) {
                  final isLogin = child.key == const ValueKey('login');
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(isLogin ? -0.06 : 0.06, 0),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  );
                },
                child: page == 0
                  ? _LoginForm(
                      key:            const ValueKey('login'),
                      scrollCtrl:     scrollController,
                      staggerAnims:   staggerAnims,
                      isDark:         isDark,
                      safeBot:        safeBot,
                      kbHeight:       kbHeight,
                      snack:          snack,
                      ref:            ref,
                      ctx:            ctx)
                  : _SignUpForm(
                      key:            const ValueKey('signup'),
                      scrollCtrl:     scrollController,
                      staggerAnims:   staggerAnims,
                      isDark:         isDark,
                      safeBot:        safeBot,
                      kbHeight:       kbHeight,
                      snack:          snack,
                      ref:            ref,
                      ctx:            ctx),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------------------
// FOND ANIM�
// ------------------------------------------------------------------------------
class _BgPainter extends CustomPainter {
  const _BgPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = _kDark);

    // Blob rouge anim�
    final cx = w * (0.28 + 0.38 * math.sin(t * 2 * math.pi));
    final cy = h * (0.22 + 0.14 * math.cos(t * 2 * math.pi * 0.7));
    canvas.drawCircle(cx == 0 ? Offset.zero : Offset(cx, cy), w * 0.80,
      Paint()..shader = RadialGradient(colors: [
        _kRed.withValues(alpha: 0.26),
        _kRed.withValues(alpha: 0.07),
        Colors.transparent,
      ], stops: const [0.0, 0.45, 1.0])
        .createShader(Rect.fromCircle(
            center: Offset(cx, cy), radius: w * 0.80)));

    // Second blob
    final cx2 = w * (0.74 - 0.18 * math.sin(t * 2 * math.pi + 1.1));
    final cy2 = h * (0.55 + 0.11 * math.cos(t * 2 * math.pi * 0.5));
    canvas.drawCircle(Offset(cx2, cy2), w * 0.50,
      Paint()..shader = RadialGradient(colors: [
        _kRed.withValues(alpha: 0.14),
        Colors.transparent,
      ]).createShader(Rect.fromCircle(
          center: Offset(cx2, cy2), radius: w * 0.50)));

    // Lignes route courbes
    final rp = Paint()
      ..color = _kRed.withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final dp = Paint()
      ..color = Colors.white.withValues(alpha: 0.055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 3; i++) {
      final y0 = h * (0.28 + i * 0.22);
      final path = Path()
        ..moveTo(0, y0)
        ..cubicTo(
          w * 0.28, y0 - h * 0.07 + i * h * 0.03,
          w * 0.72, y0 + h * 0.05 - i * h * 0.02,
          w, y0 + h * 0.02);
      canvas.drawPath(path, rp);
      for (final m in path.computeMetrics()) {
        final off = (t * 55 + i * 22) % 38;
        for (var o = off; o < m.length; o += 38) {
          canvas.drawPath(m.extractPath(o, math.min(o + 15, m.length)), dp);
        }
      }
    }

    // Particules
    final rng = math.Random(7);
    final pp = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 26; i++) {
      final px = rng.nextDouble() * w;
      final by = rng.nextDouble() * h;
      final phase = rng.nextDouble();
      final r = 1.0 + rng.nextDouble() * 1.8;
      final py = by + math.sin((t + phase) * 2 * math.pi) * 10;
      final a = (math.sin((t + phase) * 2 * math.pi) + 1) / 2 * 0.20;
      pp.color = _kRed.withValues(alpha: a);
      canvas.drawCircle(Offset(px, py), r, pp);
    }
  }

  @override
  bool shouldRepaint(_BgPainter o) => o.t != t;
}

// ------------------------------------------------------------------------------
// CARTES DESTINATIONS FLOTTANTES
// ------------------------------------------------------------------------------
class _DestData {
  const _DestData(this.city, this.icon, this.pos);
  final String city;
  final IconData icon;
  final Offset pos; // fraction de la zone hero
}

class _FloatingCard extends StatelessWidget {
  const _FloatingCard({
    required this.data, required this.floatCtrl,
    required this.index, required this.total,
  });
  final _DestData data;
  final AnimationController floatCtrl;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final size  = MediaQuery.sizeOf(context);
    // La zone hero fait (1 - _kSheetInitSize) de l'�cran
    // Les cartes doivent rester dans les 85% du haut de cette zone
    final heroH = size.height * (1 - _kSheetInitSize);
    final phase = index / total;
    return AnimatedBuilder(
      animation: floatCtrl,
      builder: (_, _) {
        final t  = floatCtrl.value;
        final dy = math.sin((t + phase) * 2 * math.pi) * 6.0;
        final dx = math.cos((t + phase) * 2 * math.pi * 0.6) * 2.5;
        final sc = 0.975 + 0.025 * math.sin((t + phase) * 2 * math.pi);
        return Stack(
          children: [
            Positioned(
              left: (data.pos.dx * size.width + dx).clamp(4.0, size.width - 90),
              top:  (data.pos.dy * heroH * 0.82 + dy).clamp(4.0, heroH - 36),
              child: Transform.scale(scale: sc,
                child: _DestCardWidget(data: data)),
            ),
          ],
        );
      },
    );
  }
}

class _DestCardWidget extends StatelessWidget {
  const _DestCardWidget({required this.data});
  final _DestData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16), width: 0.7),
        boxShadow: [BoxShadow(
          color: _kRed.withValues(alpha: 0.16),
          blurRadius: 10, spreadRadius: 0)],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 20, height: 20,
          decoration: BoxDecoration(
            color: _kRed.withValues(alpha: 0.88),
            shape: BoxShape.circle),
          child: Icon(data.icon, size: 11, color: Colors.white)),
        const SizedBox(width: 5),
        Text(data.city,
          style: const TextStyle(
            color: Colors.white, fontSize: 11,
            fontWeight: FontWeight.w600, letterSpacing: 0.2)),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ROUTE PAINTER — route + tirets animés dans la zone hero
// ══════════════════════════════════════════════════════════════════════════════
class _RoutePainter extends CustomPainter {
  const _RoutePainter({required this.progress, required this.motionOff});
  final double progress;
  final bool   motionOff;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Route asphalte (occupe le bas du hero) ─────────────────────────
    final ry = h * 0.74; // ligne de route
    canvas.drawRect(
      Rect.fromLTWH(0, ry, w, h - ry),
      Paint()..color = const Color(0xFF1A1C2E),
    );

    // Bord supérieur de la route (ligne rouge subtile)
    canvas.drawLine(
      Offset(0, ry), Offset(w, ry),
      Paint()
        ..color = _kRed.withValues(alpha: 0.35)
        ..strokeWidth = 1.5,
    );

    // Tirets centraux animés
    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.40)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final roadCenterY = ry + (h - ry) * 0.40;
    final offset = motionOff ? 0.0 : (progress * 56) % 40;
    for (var x = -offset; x < w + 20; x += 40) {
      canvas.drawLine(
        Offset(x, roadCenterY),
        Offset(x + 20, roadCenterY),
        dashPaint,
      );
    }

    // Reflet lumineux sur la route (effet sol brillant)
    canvas.drawRect(
      Rect.fromLTWH(0, ry, w, h - ry),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.04),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, ry, w, h - ry)),
    );
  }

  @override
  bool shouldRepaint(_RoutePainter o) =>
      o.progress != progress || o.motionOff != motionOff;
}

// ══════════════════════════════════════════════════════════════════════════════
// LOGO HEADER
// ------------------------------------------------------------------------------
class _LogoHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const AppLogoMark(size: 52),
      const SizedBox(height: 5),
      const AppWordmark(onDark: true),
      const SizedBox(height: 3),
      Text('Réservez votre louage  🇹🇳',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.45),
          fontSize: 10.5, letterSpacing: 0.4)),
    ]);
  }
}

// ------------------------------------------------------------------------------
// TOGGLE CONNEXION / INSCRIPTION
// ------------------------------------------------------------------------------
class _PageToggle extends StatelessWidget {
  const _PageToggle({
    required this.page, required this.onSwitch, required this.isDark});
  final int page;
  final void Function(int) onSwitch;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : _kLightGray,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kRed.withValues(alpha: 0.18), width: 0.8)),
      child: Stack(children: [
        // Indicateur glissant
        AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          alignment: page == 0
            ? AlignmentDirectional.centerStart
            : AlignmentDirectional.centerEnd,
          child: Padding(padding: const EdgeInsets.all(4),
            child: FractionallySizedBox(widthFactor: 0.5,
              child: Container(height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_kRed, Color(0xFFFF2D4A)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [BoxShadow(
                    color: _kRed.withValues(alpha: 0.36),
                    blurRadius: 12, offset: const Offset(0, 3))]),
              )))),
        // Labels
        Row(children: [
          _Tab(label: 'Connexion',   selected: page == 0, onTap: () => onSwitch(0)),
          _Tab(label: 'Inscription', selected: page == 1, onTap: () => onSwitch(1)),
        ]),
      ]),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: SizedBox(height: double.infinity,
        child: Center(child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade500,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            fontSize: 13.5, letterSpacing: 0.1),
          child: Text(label))))));
  }
}

// ------------------------------------------------------------------------------
// FORMULAIRE LOGIN � keyboard-aware
// ------------------------------------------------------------------------------
class _LoginForm extends StatefulWidget {
  const _LoginForm({
    super.key,
    required this.scrollCtrl,
    required this.staggerAnims,
    required this.isDark,
    required this.safeBot,
    required this.kbHeight,
    required this.snack,
    required this.ref,
    required this.ctx,
  });
  final ScrollController scrollCtrl;
  final List<Animation<double>> staggerAnims;
  final bool   isDark;
  final double safeBot;
  final double kbHeight;
  final void Function(String) snack;
  final WidgetRef ref;
  final BuildContext ctx;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _pwdCtrl   = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading   = false;
  bool _phoneMode = false;
  late final AnimationController _modeCtrl;


  @override
  void initState() {
    super.initState();
    _modeCtrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 260));
  }

  @override
  void dispose() {
    _emailCtrl.dispose(); _pwdCtrl.dispose(); _phoneCtrl.dispose();
    _modeCtrl.dispose();
    super.dispose();
  }

  void _setMode(bool phone) {
    if (_phoneMode == phone) return;
    setState(() => _phoneMode = phone);
    phone ? _modeCtrl.reverse() : _modeCtrl.forward();
  }

  Future<void> _loginEmail() async {
    if (_emailCtrl.text.trim().isEmpty || _pwdCtrl.text.isEmpty) {
      widget.snack(AppLocalizations.of(widget.ctx)!.formRequiredFields);
      return;
    }
    setState(() => _loading = true);
    try {
      final user = await widget.ref
        .read(authControllerProvider.notifier)
        .login(email: _emailCtrl.text.trim(), password: _pwdCtrl.text);
      if (!mounted) return;
      await widget.ref.read(localeProvider.notifier).setLocale(
        user.language.isNotEmpty ? Locale(user.language) : const Locale('fr'));
      if (!mounted) return;
      widget.ctx.go(authHomeRouteForRole(user.role));
    } on AuthException catch (e) {
      if (!mounted) return;
      widget.snack(authErrorMessage(AppLocalizations.of(widget.ctx)!, e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginPhone() async {
    setState(() => _loading = true);
    try {
      final phone = PhoneNumber(_phoneCtrl.text.trim());
      final challenge = await widget.ref
        .read(authControllerProvider.notifier)
        .requestOtp(phone, OtpPurpose.login);
      if (!mounted) return;
      widget.ctx.pushNamed('otp', extra: OtpArguments(
        phone: phone, purpose: OtpPurpose.login, challenge: challenge));
    } on AuthException catch (e) {
      if (!mounted) return;
      widget.snack(authErrorMessage(AppLocalizations.of(widget.ctx)!, e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgot() async {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = TextEditingController(text: _emailCtrl.text.trim());
    final email = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true, barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, _, _) => _ForgotDialog(ctrl: ctrl, l10n: l10n),
      transitionBuilder: (_, anim, _, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.86, end: 1.0).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
          child: child)));
    ctrl.dispose();
    if (email == null || !mounted) return;
    try {
      final code = await widget.ref
        .read(authControllerProvider.notifier).resetPassword(email);
      if (!mounted) return;
      widget.snack(l10n.authResetCodeGenerated(code));
    } on AuthException catch (e) {
      if (!mounted) return;
      widget.snack(authErrorMessage(l10n, e.code));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Padding bas = safe area + espace suffisant + hauteur clavier si ouvert
    // Quand le clavier est ouvert, on ajoute 24px suppl�mentaires pour
    // que le bouton "Se connecter" reste au-dessus de la derni�re ligne du clavier
    final bottomPad = widget.safeBot + 24 + (widget.kbHeight > 0 ? 24.0 : 0.0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ListView(
          controller: widget.scrollCtrl,
          padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPad),
          physics: const ClampingScrollPhysics(),
          children: [

        _S(0, widget.staggerAnims, Text('Bienvenue sur LouageGo',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800, letterSpacing: -0.4,
            color: widget.isDark ? Colors.white : _kDark))),

        const SizedBox(height: 4),
        _S(1, widget.staggerAnims, Text('Connectez-vous pour continuer',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: widget.isDark
              ? Colors.white.withValues(alpha: 0.50)
              : Colors.grey.shade500,
            fontSize: 13))),

        const SizedBox(height: 18),
        _S(2, widget.staggerAnims, _ModeToggle(
          phoneMode: _phoneMode, isDark: widget.isDark, onSwitch: _setMode)),
        const SizedBox(height: 14),

        // Champs avec slide horizontal
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve:  Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0), end: Offset.zero).animate(anim),
              child: child)),
          child: _phoneMode
            ? Column(key: const ValueKey('ph'),
                crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _TunisiaChip(),
                const SizedBox(height: 10),
                _LouageField(
                  controller: _phoneCtrl,
                  label: l10n.loginPhoneLabel,
                  hint: '12 345 678',
                  icon: Icons.phone_iphone_rounded,
                  keyboardType: TextInputType.phone,
                  prefixWidget: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: _kRed.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(6)),
                    child: const Text('+216', style: TextStyle(
                      color: _kRed, fontWeight: FontWeight.w700, fontSize: 12))),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8)],
                  maxLength: 8,
                  validator: (v) {
                    final ok = (v ?? '').length == 8;
                    return ok ? null : '8 chiffres requis';
                  }),
                const SizedBox(height: 16),
                _Btn(label: l10n.loginSendCode, icon: Icons.send_rounded,
                  loading: _loading, onPressed: _loading ? null : _loginPhone),
              ])
            : Column(key: const ValueKey('em'),
                crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _LouageField(
                  controller: _emailCtrl,
                  label: l10n.loginEmailLabel,
                  hint: 'vous@exemple.com',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    final email = v ?? '';
                    final ok = email.contains('@') && email.contains('.');
                    return ok ? null : 'Email invalide';
                  }),
                const SizedBox(height: 12),
                _LouageField(
                  controller: _pwdCtrl,
                  label: l10n.loginPasswordLabel,
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    final ok = (v ?? '').length >= 6;
                    return ok ? null : '6 caractères minimum';
                  }),
                Align(alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: _loading ? null : _forgot,
                    style: TextButton.styleFrom(
                      foregroundColor: _kRed,
                      minimumSize: const Size(48, 40)),
                    child: Text(l10n.loginForgotPassword,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)))),
                _Btn(label: l10n.loginSubmit, icon: Icons.login_rounded,
                  loading: _loading, onPressed: _loading ? null : _loginEmail),
              ]),
        ),

        const SizedBox(height: 14),
        _S(8, widget.staggerAnims, _OrDiv()),
        const SizedBox(height: 10),

        _S(9, widget.staggerAnims,
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Pas de compte ?', style: TextStyle(
              color: widget.isDark
                ? Colors.white.withValues(alpha: 0.50)
                : Colors.grey.shade500,
              fontSize: 13)),
            const SizedBox(width: 6),
            _Link(label: l10n.loginCreateAccount,
              onTap: () => context.goNamed('register')),
          ])),
      ],
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------------------
// FORMULAIRE SIGN UP � keyboard-aware
// ------------------------------------------------------------------------------
class _SignUpForm extends StatefulWidget {
  const _SignUpForm({
    super.key,
    required this.scrollCtrl,
    required this.staggerAnims,
    required this.isDark,
    required this.safeBot,
    required this.kbHeight,
    required this.snack,
    required this.ref,
    required this.ctx,
  });
  final ScrollController scrollCtrl;
  final List<Animation<double>> staggerAnims;
  final bool   isDark;
  final double safeBot;
  final double kbHeight;
  final void Function(String) snack;
  final WidgetRef ref;
  final BuildContext ctx;

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  // -- Controllers --------------------------------------------------------
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl   = TextEditingController();
  final _confCtrl  = TextEditingController();

  String _role       = 'passenger';
  bool   _loading    = false;
  bool   _accepted   = false;
  bool   _consentErr = false;
  int    _strength   = 0;

  @override
  void initState() {
    super.initState();
    _pwdCtrl.addListener(_calcStrength);
  }

  void _calcStrength() {
    final p = _pwdCtrl.text;
    final s = p.isEmpty ? 0 :
      (p.length >= 12 && RegExp(r'[0-9]').hasMatch(p)
        && RegExp(r'[^A-Za-z0-9]').hasMatch(p)) ? 3 :
      p.length >= 8 ? 2 : 1;
    if (_strength != s) setState(() => _strength = s);
  }

  @override
  void dispose() {
    _pwdCtrl.removeListener(_calcStrength);
    for (final c in [_nameCtrl, _phoneCtrl, _emailCtrl, _pwdCtrl, _confCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_accepted) {
      setState(() => _consentErr = true);
      widget.snack(l10n.registerConsentRequired); return;
    }
    final n = _nameCtrl.text.trim();
    final ph = _phoneCtrl.text.trim();
    final e = _emailCtrl.text.trim();
    final pw = _pwdCtrl.text;
    if (n.isEmpty || ph.isEmpty || e.isEmpty || pw.isEmpty) {
      widget.snack(l10n.formRequiredFields); return;
    }
    if (pw != _confCtrl.text) {
      widget.snack(l10n.passwordMismatch); return;
    }
    setState(() => _loading = true);
    try {
      final user = await widget.ref
        .read(authControllerProvider.notifier)
        .register(name: n, phone: ph, email: e, password: pw, role: _role,
          acceptedTermsVersion: AppConfig.legalVersion,
          acceptedTermsAt: DateTime.now().toIso8601String());
      if (!mounted) return;
      widget.ctx.go(authHomeRouteForRole(user.role));
    } on AuthException catch (err) {
      if (!mounted) return;
      widget.snack(authErrorMessage(
        AppLocalizations.of(widget.ctx)!, err.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Padding bas suffisant pour que le bouton "S'inscrire" reste accessible
    // m�me avec le formulaire d'inscription long (10 champs)
    final bottomPad = widget.safeBot + 24 + (widget.kbHeight > 0 ? 24.0 : 0.0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ListView(
          controller: widget.scrollCtrl,
          padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPad),
          physics: const ClampingScrollPhysics(),
          children: [

        _S(0, widget.staggerAnims, Text(l10n.registerTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800, letterSpacing: -0.4,
            color: widget.isDark ? Colors.white : _kDark))),

        const SizedBox(height: 14),
        _S(1, widget.staggerAnims, _RoleSelector(
          role: _role, isDark: widget.isDark, l10n: l10n,
          onSelect: (r) => setState(() => _role = r))),

        const SizedBox(height: 14),
        _S(2, widget.staggerAnims, _LouageField(
          controller: _nameCtrl,
          label: l10n.registerNameLabel,
          hint: 'Mohamed Ben Ali',
          icon: Icons.badge_outlined,
          textInputAction: TextInputAction.next,
          validator: (v) => (v ?? '').trim().length >= 2
              ? null : 'Nom trop court')),

        const SizedBox(height: 10),
        _S(3, widget.staggerAnims, Column(children: [
          _TunisiaChip(),
          const SizedBox(height: 8),
          _LouageField(
            controller: _phoneCtrl,
            label: l10n.registerPhoneLabel,
            hint: '12 345 678',
            icon: Icons.phone_iphone_rounded,
            keyboardType: TextInputType.phone,
            prefixWidget: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: _kRed.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(6)),
              child: const Text('+216', style: TextStyle(
                color: _kRed, fontWeight: FontWeight.w700, fontSize: 12))),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8)],
            maxLength: 8,
            validator: (v) => (v ?? '').length == 8 ? null : '8 chiffres requis'),
        ])),

        const SizedBox(height: 10),
        _S(4, widget.staggerAnims, _LouageField(
          controller: _emailCtrl,
          label: l10n.registerEmailLabel,
          hint: 'vous@exemple.com',
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (v) => (v??'').contains('@') ? null : 'Email invalide')),

        const SizedBox(height: 10),
        _S(5, widget.staggerAnims, _LouageField(
          controller: _pwdCtrl,
          label: l10n.registerPasswordLabel,
          hint: '••••••••',
          icon: Icons.lock_outline,
          isPassword: true,
          textInputAction: TextInputAction.next,
          validator: (v) => (v??'').length >= 6 ? null : '6 caractères minimum')),

        const SizedBox(height: 5),
        _S(6, widget.staggerAnims, _StrBar(strength: _strength, l10n: l10n)),

        const SizedBox(height: 10),
        _S(7, widget.staggerAnims, _LouageField(
          controller: _confCtrl,
          label: l10n.registerConfirmPasswordLabel,
          hint: '••••••••',
          icon: Icons.lock_outline,
          isPassword: true,
          validator: (v) => v == _pwdCtrl.text ? null : 'Mots de passe différents')),

        const SizedBox(height: 14),
        _S(8, widget.staggerAnims, _Consent(
          accepted: _accepted, error: _consentErr, l10n: l10n,
          onChanged: (v) => setState(() {
            _accepted = v ?? false; _consentErr = false; }))),

        const SizedBox(height: 16),
        _S(9, widget.staggerAnims, _Btn(
          label: l10n.registerSubmit, icon: Icons.how_to_reg_rounded,
          loading: _loading, onPressed: _loading ? null : _register)),

        const SizedBox(height: 10),
        _S(10, widget.staggerAnims,
          Center(child: TextButton(
            onPressed: () => context.goNamed('login'),
            style: TextButton.styleFrom(foregroundColor: _kRed),
            child: Text(l10n.registerSignInLink,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))))),

        const SizedBox(height: 4),
      ],
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------------------
// WIDGETS PARTAG�S
// ------------------------------------------------------------------------------

Widget _S(int i, List<Animation<double>> a, Widget child) => _Stagger(
  index: i, anims: a, child: child);

class _Stagger extends StatelessWidget {
  const _Stagger({required this.index, required this.anims, required this.child});
  final int index;
  final List<Animation<double>> anims;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final anim = anims[index.clamp(0, anims.length - 1)];
    return FadeTransition(opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04), end: Offset.zero).animate(anim),
        child: child));
  }
}

// Bouton principal
class _Btn extends StatefulWidget {
  const _Btn({
    required this.label, required this.icon,
    required this.loading, required this.onPressed});
  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback? onPressed;
  @override
  State<_Btn> createState() => _BtnState();
}
class _BtnState extends State<_Btn> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _sc;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 85));
    _sc = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sc,
      builder: (_, child) => Transform.scale(scale: _sc.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _c.forward(),
        onTapUp:   (_) => _c.reverse(),
        onTapCancel: () => _c.reverse(),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kRed, Color(0xFFFF2D4A)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(15),
            boxShadow: widget.onPressed == null ? [] : [
              BoxShadow(
                color: _kRed.withValues(alpha: 0.38),
                blurRadius: 14, offset: const Offset(0, 5))]),
          child: Material(color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(15),
              splashColor: Colors.white.withValues(alpha: 0.14),
              child: Center(child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: widget.loading
                  ? const SizedBox(key: ValueKey('l'),
                      width: 21, height: 21,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.3, color: Colors.white))
                  : Row(key: const ValueKey('c'),
                      mainAxisSize: MainAxisSize.min, children: [
                        Icon(widget.icon, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(widget.label,
                          style: const TextStyle(
                            color: Colors.white, fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2)),
                      ]))))),
        ),
      ),
    );
  }
}

// Toggle Phone / Email
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.phoneMode, required this.isDark, required this.onSwitch});
  final bool phoneMode;
  final bool isDark;
  final void Function(bool) onSwitch;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark
          ? Colors.white.withValues(alpha: 0.05) : _kLightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kRed.withValues(alpha: 0.14), width: 0.7)),
      child: Stack(children: [
        AnimatedAlign(
          duration: const Duration(milliseconds: 270),
          curve: Curves.easeOutBack,
          alignment: phoneMode
            ? AlignmentDirectional.centerStart
            : AlignmentDirectional.centerEnd,
          child: Padding(padding: const EdgeInsets.all(3),
            child: FractionallySizedBox(widthFactor: 0.5,
              child: Container(height: 38,
                decoration: BoxDecoration(
                  color: _kRed,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(
                    color: _kRed.withValues(alpha: 0.28),
                    blurRadius: 8, offset: const Offset(0, 2))]),
              )))),
        Row(children: [
          Expanded(child: InkWell(onTap: () => onSwitch(true),
            borderRadius: BorderRadius.circular(10),
            child: Center(child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: phoneMode ? Colors.white : Colors.grey.shade500,
                fontWeight: phoneMode ? FontWeight.w700 : FontWeight.w400,
                fontSize: 13),
              child: const Text('Téléphone'))))),
          Expanded(child: InkWell(onTap: () => onSwitch(false),
            borderRadius: BorderRadius.circular(10),
            child: Center(child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: !phoneMode ? Colors.white : Colors.grey.shade500,
                fontWeight: !phoneMode ? FontWeight.w700 : FontWeight.w400,
                fontSize: 13),
              child: const Text('Email'))))),
        ]),
      ]),
    );
  }
}

class _TunisiaChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(9, 5, 13, 5),
      decoration: BoxDecoration(
        color: _kRed.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _kRed.withValues(alpha: 0.20), width: 0.7)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('🇹🇳', style: TextStyle(fontSize: 15)),
        const SizedBox(width: 6),
        Text('Tunisie  +216', style: TextStyle(
          color: _kRed, fontWeight: FontWeight.w600, fontSize: 12.5)),
        const SizedBox(width: 4),
        const Icon(Icons.check_circle_rounded, size: 12, color: _kRed),
      ]));
  }
}

class _OrDiv extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Divider(
        color: Colors.grey.shade300, thickness: 0.7)),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text('ou', style: TextStyle(
          color: Colors.grey.shade500, fontSize: 12))),
      Expanded(child: Divider(
        color: Colors.grey.shade300, thickness: 0.7)),
    ]);
  }
}

class _Link extends StatelessWidget {
  const _Link({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: _kRed.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(7)),
        child: Text(label, style: const TextStyle(
          color: _kRed, fontWeight: FontWeight.w700, fontSize: 13))));
  }
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({
    required this.role, required this.isDark,
    required this.l10n, required this.onSelect});
  final String role;
  final bool isDark;
  final AppLocalizations l10n;
  final void Function(String) onSelect;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _RoleCard(
        label: l10n.registerPassengerRole,
        icon: Icons.person_rounded, selected: role == 'passenger',
        isDark: isDark, onTap: () => onSelect('passenger'))),
      const SizedBox(width: 10),
      Expanded(child: _RoleCard(
        label: l10n.registerDriverRole,
        icon: Icons.airport_shuttle_rounded, selected: role == 'driver',
        isDark: isDark, onTap: () => onSelect('driver'))),
    ]);
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.label, required this.icon,
    required this.selected, required this.isDark, required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 74,
      decoration: BoxDecoration(
        color: selected
          ? _kRed.withValues(alpha: 0.09)
          : (isDark ? Colors.white.withValues(alpha: 0.04) : _kLightGray),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? _kRed : Colors.grey.shade300,
          width: selected ? 1.6 : 0.9)),
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14),
        child: Stack(children: [
          Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: selected
                  ? _kRed.withValues(alpha: 0.11) : Colors.transparent,
                borderRadius: BorderRadius.circular(9)),
              child: Icon(icon,
                color: selected ? _kRed : Colors.grey.shade500, size: 20)),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(
              color: selected ? _kRed
                : (isDark ? Colors.white70 : Colors.grey.shade600),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              fontSize: 12)),
          ])),
          if (selected)
            Positioned(top: 5, right: 5,
              child: Container(
                width: 15, height: 15,
                decoration: const BoxDecoration(
                  color: _kRed, shape: BoxShape.circle),
                child: const Icon(Icons.check, size: 9, color: Colors.white))),
        ])));
  }
}

class _StrBar extends StatelessWidget {
  const _StrBar({required this.strength, required this.l10n});
  final int strength;
  final AppLocalizations l10n;
  @override
  Widget build(BuildContext context) {
    final col = switch (strength) {
      1 => const Color(0xFFE53935),
      2 => const Color(0xFFF57C00),
      3 => const Color(0xFF2E7D32),
      _ => Colors.grey.shade300,
    };
    final lbl = switch (strength) {
      1 => l10n.registerPasswordStrengthWeak,
      2 => l10n.registerPasswordStrengthMedium,
      3 => l10n.registerPasswordStrengthStrong,
      _ => '',
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        for (var i = 0; i < 3; i++) ...[
          Expanded(child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            decoration: BoxDecoration(
              color: i < strength ? col : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(3)))),
          if (i < 2) const SizedBox(width: 4),
        ],
      ]),
      if (strength > 0) ...[
        const SizedBox(height: 3),
        Text('${l10n.registerPasswordStrengthLabel}: $lbl',
          style: TextStyle(color: col, fontSize: 11)),
      ],
    ]);
  }
}

class _Consent extends StatefulWidget {
  const _Consent({
    required this.accepted, required this.error,
    required this.l10n, required this.onChanged});
  final bool accepted, error;
  final AppLocalizations l10n;
  final ValueChanged<bool?> onChanged;

  @override
  State<_Consent> createState() => _ConsentState();
}

class _ConsentState extends State<_Consent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeCtrl;
  late final Animation<double>   _shake;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 380));
    _shake = CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn);
  }

  @override
  void didUpdateWidget(_Consent old) {
    super.didUpdateWidget(old);
    if (widget.error && !old.error) {
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _shakeCtrl,
      builder: (_, child) {
        final dx = _shakeCtrl.isAnimating
            ? math.sin(_shake.value * 3 * math.pi) * 5.0
            : 0.0;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: widget.error
              ? const Color(0xFFE53935).withValues(alpha: 0.06)
              : widget.accepted
                  ? const Color(0xFF2E7D32).withValues(alpha: 0.06)
                  : isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : _kLightGray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.error
                ? const Color(0xFFE53935)
                : widget.accepted
                    ? const Color(0xFF2E7D32)
                    : isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : Colors.grey.shade300,
            width: widget.error || widget.accepted ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Checkbox animée
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 26, height: 26,
                  decoration: BoxDecoration(
                    color: widget.accepted
                        ? const Color(0xFF2E7D32)
                        : widget.error
                            ? const Color(0xFFE53935).withValues(alpha: 0.08)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: widget.accepted
                          ? const Color(0xFF2E7D32)
                          : widget.error
                              ? const Color(0xFFE53935)
                              : Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => widget.onChanged(!widget.accepted),
                    borderRadius: BorderRadius.circular(7),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: widget.accepted
                            ? const Icon(Icons.check_rounded,
                                key: ValueKey('check'),
                                size: 16, color: Colors.white)
                            : const SizedBox(key: ValueKey('empty')),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(widget.l10n.registerAcceptTerms,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.75)
                              : Colors.grey.shade700)),
                      TextButton(
                        onPressed: () => context.pushNamed('legalTerms'),
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          foregroundColor: _kRed,
                          padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 3, vertical: 2),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                        child: Text(widget.l10n.registerTermsLink)),
                      Text(widget.l10n.registerAnd,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.75)
                              : Colors.grey.shade700)),
                      TextButton(
                        onPressed: () => context.pushNamed('legalPrivacy'),
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          foregroundColor: _kRed,
                          padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 3, vertical: 2),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                        child: Text(widget.l10n.registerPrivacyLink)),
                    ],
                  ),
                ),
              ],
            ),
            // Message d'erreur ou confirmation
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: widget.error
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8, left: 2),
                      child: Row(children: [
                        const Icon(Icons.warning_amber_rounded,
                            size: 13, color: Color(0xFFE53935)),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(widget.l10n.registerConsentRequired,
                            style: const TextStyle(
                              color: Color(0xFFE53935),
                              fontSize: 12, fontWeight: FontWeight.w500))),
                      ]))
                  : widget.accepted
                      ? Padding(
                          padding: const EdgeInsets.only(top: 6, left: 2),
                          child: Row(children: [
                            const Icon(Icons.check_circle_rounded,
                                size: 13, color: Color(0xFF2E7D32)),
                            const SizedBox(width: 5),
                            const Flexible(
                              child: Text('Conditions acceptées',
                                style: TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontSize: 12, fontWeight: FontWeight.w500))),
                          ]))
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForgotDialog extends StatelessWidget {
  const _ForgotDialog({required this.ctrl, required this.l10n});
  final TextEditingController ctrl;
  final AppLocalizations l10n;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(child: Material(color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 26),
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: isDark ? _kDark2 : Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 32, offset: const Offset(0, 10))],
          border: Border.all(
            color: _kRed.withValues(alpha: 0.18), width: 1)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 48, height: 48,
            decoration: BoxDecoration(
              color: _kRed.withValues(alpha: 0.09),
              shape: BoxShape.circle),
            child: const Icon(Icons.lock_reset_rounded,
              color: _kRed, size: 24)),
          const SizedBox(height: 12),
          Text(l10n.authResetPasswordTitle, textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          _LouageField(
            controller: ctrl,
            label: l10n.authResetEmailLabel,
            hint: 'vous@exemple.com',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => (v??'').contains('@') ? null : 'Email invalide'),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 44),
                side: const BorderSide(color: _kRed),
                foregroundColor: _kRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
              child: Text(l10n.authCancel))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(ctrl.text.trim()),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 44),
                backgroundColor: _kRed, foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
              child: Text(l10n.authContinue))),
          ]),
        ]),
      )));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MASCOTTE VAN — personnage dessiné en CustomPaint
// États : 'idle' | 'valid' | 'error' | 'password'

// ══════════════════════════════════════════════════════════════════════════════
// _LouageField — champ épuré professionnel
// ══════════════════════════════════════════════════════════════════════════════
class _LouageField extends StatefulWidget {
  const _LouageField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLength,
    this.prefixWidget,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final Widget? prefixWidget;
  final String? Function(String?)? validator;

  @override
  State<_LouageField> createState() => _LouageFieldState();
}

class _LouageFieldState extends State<_LouageField>
    with TickerProviderStateMixin {
  final _focus = FocusNode();
  bool _obscure = true;
  bool _focused = false;
  String? _error;
  bool _touched = false;

  late final AnimationController _glowCtrl;
  late final AnimationController _shakeCtrl;
  late final Animation<double>   _shake;

  bool get _hasError => _error != null && _touched;
  bool get _isValid  => _error == null
      && widget.controller.text.isNotEmpty
      && _touched
      && widget.validator != null;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 240));
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _shake = CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn);
    _focus.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  void _onFocusChange() {
    setState(() => _focused = _focus.hasFocus);
    if (_focus.hasFocus) {
      _glowCtrl.forward();
    } else {
      _glowCtrl.reverse();
      if (_touched) _validate();
    }

  }

  void _onTextChange() {
    if (!_touched) setState(() => _touched = true);
    _validate();
  }

  void _validate() {
    if (widget.validator == null) return;
    final err = widget.validator!(widget.controller.text);
    final prev = _error;
    setState(() => _error = err);
    if (err != null && prev == null) _shakeCtrl.forward(from: 0);
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    _focus.dispose();
    _glowCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final iconColor = _hasError ? const Color(0xFFE53935)
        : _isValid  ? const Color(0xFF2E7D32)
        : _focused  ? _kRed
        : isDark    ? Colors.white38
                    : Colors.black38;

    // Un seul fond — blanc (dark: gris foncé), contour rouge si erreur
    final fillColor = _hasError
        ? const Color(0xFFE53935).withValues(alpha: isDark ? 0.12 : 0.05)
        : isDark
            ? const Color(0xFF2A2B36)
            : Colors.white;

    // Bordure seulement si erreur
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
    );

    return AnimatedBuilder(
      animation: _shakeCtrl,
      builder: (_, child) => Transform.translate(
        offset: Offset(
          _shakeCtrl.isAnimating
              ? math.sin(_shake.value * 3 * math.pi) * 5.0
              : 0.0,
          0),
        child: child),
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        obscureText: widget.isPassword && _obscure,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        inputFormatters: widget.inputFormatters,
        maxLength: widget.maxLength,
        onTap: () { if (!_touched) setState(() => _touched = true); },
        style: TextStyle(
          fontSize: 15,
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          letterSpacing: widget.isPassword && _obscure ? 2.5 : 0.0,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: fillColor,
          hintText: widget.hint ?? widget.label,
          hintStyle: TextStyle(
            fontSize: 14.5,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          // Prefix +216
          prefix: widget.prefixWidget != null
              ? Row(mainAxisSize: MainAxisSize.min, children: [
                  widget.prefixWidget!,
                  const SizedBox(width: 6),
                ])
              : null,
          prefixIcon: Icon(widget.icon, size: 20, color: iconColor),
          suffixIcon: widget.isPassword
              ? GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: iconColor,
                  ),
                )
              : _isValid
                  ? Icon(Icons.check_circle_rounded,
                      size: 20, color: const Color(0xFF2E7D32))
                  : _hasError
                      ? Icon(Icons.cancel_rounded,
                          size: 20, color: const Color(0xFFE53935))
                      : null,
          counterText: '',
          contentPadding:
              const EdgeInsetsDirectional.fromSTEB(0, 16, 16, 16),
          border: border,
          enabledBorder: border,
          focusedBorder: border,
          errorBorder: errorBorder,
          focusedErrorBorder: errorBorder,
          // Message erreur inline sous le champ
          errorText: _hasError ? _error : null,
          errorMaxLines: 2,
          errorStyle: const TextStyle(
            color: Color(0xFFE53935),
            fontSize: 11.5,
          ),
        ),
      ),
    );
  }
}
