// ignore_for_file: avoid_redundant_argument_values
import 'dart:math' as math;

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public API
// ─────────────────────────────────────────────────────────────────────────────

/// Intensité de l'animation selon le contexte de l'écran.
///
/// - [full]   Toutes les 4 couches actives — splash, onboarding
/// - [mid]    Couches 1 + 3 + 4 — login, register, otp
/// - [subtle] Couches 1 + 4 uniquement — tous les écrans fonctionnels
enum BackgroundIntensity { full, mid, subtle }

/// Arrière-plan animé "LouageGo Living World".
///
/// Pose ce widget en premier dans un [Stack], puis le [Scaffold] avec
/// `backgroundColor: Colors.transparent` par-dessus.
///
/// ```dart
/// Stack(children: [
///   const AnimatedBackground(intensity: BackgroundIntensity.full),
///   Scaffold(backgroundColor: Colors.transparent, body: …),
/// ])
/// ```
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({
    super.key,
    this.intensity = BackgroundIntensity.subtle,
  });

  final BackgroundIntensity intensity;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Durée du cycle principal : 28 s pour du smooth sur A57
  static const _cycleDuration = Duration(seconds: 28);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _cycleDuration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _ctrl.stop();
    } else if (!_ctrl.isAnimating) {
      _ctrl.repeat();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final intensity = widget.intensity;

    return Positioned.fill(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) => CustomPaint(
            painter: _LivingWorldPainter(
              progress: _ctrl.value,
              isDark: isDark,
              intensity: intensity,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Palette
// ─────────────────────────────────────────────────────────────────────────────

class _Palette {
  static const red = Color(0xFFDC2D2A);
  static const redSoft = Color(0xFFFF6B68);
  static const orange = Color(0xFFF97316);

  // Fond clair
  static const bgLight = Color(0xFFF9FBFA);
  static const bgLight2 = Color(0xFFFBE5E4);

  // Fond sombre
  static const bgDark = Color(0xFF0D1117);
  static const bgDark2 = Color(0xFF1A0808);
}

// ─────────────────────────────────────────────────────────────────────────────
// Villes tunisiennes (coordonnées normalisées 0..1 sur la silhouette)
// ─────────────────────────────────────────────────────────────────────────────

const _cities = <({String name, double nx, double ny})>[
  (name: 'Tunis', nx: 0.52, ny: 0.08),
  (name: 'Bizerte', nx: 0.46, ny: 0.04),
  (name: 'Sousse', nx: 0.58, ny: 0.30),
  (name: 'Sfax', nx: 0.55, ny: 0.52),
  (name: 'Gabes', nx: 0.57, ny: 0.72),
  (name: 'Tozeur', nx: 0.28, ny: 0.68),
  (name: 'Medenine', nx: 0.64, ny: 0.84),
  (name: 'Kairouan', nx: 0.48, ny: 0.40),
  (name: 'Jendouba', nx: 0.30, ny: 0.10),
];

// Routes entre villes (paires d'indices dans _cities)
const _routes = <(int, int)>[
  (0, 2), // Tunis → Sousse
  (2, 3), // Sousse → Sfax
  (3, 4), // Sfax → Gabes
  (4, 5), // Gabes → Tozeur
  (4, 6), // Gabes → Medenine
  (0, 7), // Tunis → Kairouan
  (7, 3), // Kairouan → Sfax
  (0, 8), // Tunis → Jendouba
  (0, 1), // Tunis → Bizerte
];

// ─────────────────────────────────────────────────────────────────────────────
// Particule
// ─────────────────────────────────────────────────────────────────────────────

class _Particle {
  _Particle(math.Random rng)
      : x = rng.nextDouble(),
        y = rng.nextDouble(),
        size = 1.5 + rng.nextDouble() * 2.5,
        speed = 0.004 + rng.nextDouble() * 0.008,
        angle = rng.nextDouble() * 2 * math.pi,
        phase = rng.nextDouble();

  double x, y;
  final double size, speed, angle, phase;
}

// ─────────────────────────────────────────────────────────────────────────────
// Louage mobile (couche 3)
// ─────────────────────────────────────────────────────────────────────────────

class _SpeedLine {
  _SpeedLine(math.Random rng)
      : y = rng.nextDouble(),
        length = 0.08 + rng.nextDouble() * 0.18,
        speed = 0.012 + rng.nextDouble() * 0.020,
        thickness = 0.6 + rng.nextDouble() * 1.2,
        phase = rng.nextDouble(),
        hasVehicle = rng.nextDouble() < 0.25;

  double y;
  final double length, speed, thickness, phase;
  final bool hasVehicle;
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter principal
// ─────────────────────────────────────────────────────────────────────────────

class _LivingWorldPainter extends CustomPainter {
  _LivingWorldPainter({
    required this.progress,
    required this.isDark,
    required this.intensity,
  }) {
    final rng = math.Random(42); // seed fixe = stable entre repaints
    _particles = List.generate(40, (_) => _Particle(rng));
    _lines = List.generate(7, (_) => _SpeedLine(rng));
  }

  final double progress;
  final bool isDark;
  final BackgroundIntensity intensity;

  late final List<_Particle> _particles;
  late final List<_SpeedLine> _lines;

  // ── Couche 1 : Fond dégradé animé ─────────────────────────────────────────
  void _paintSky(Canvas canvas, Size size) {
    final shift = math.sin(progress * 2 * math.pi) * 0.12;
    final c1 = isDark ? _Palette.bgDark : _Palette.bgLight;
    final c2 = isDark
        ? Color.lerp(_Palette.bgDark2, const Color(0xFF120A0A), shift + 0.5)!
        : Color.lerp(_Palette.bgLight2, const Color(0xFFFFF0EE), shift + 0.5)!;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [c1, c2],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  // ── Couche 2 : Carte Tunisie + réseau de trajets ──────────────────────────
  void _paintMap(Canvas canvas, Size size) {
    // Zone de la carte : centrée dans la moitié droite, haute de 70% de l'écran
    final mapRect = Rect.fromLTWH(
      size.width * 0.38,
      size.height * 0.05,
      size.width * 0.56,
      size.height * 0.82,
    );

    final baseAlpha = isDark ? 0.22 : 0.07;

    // Convertit coordonnées normalisées → pixel dans mapRect
    Offset cityPos(double nx, double ny) => Offset(
          mapRect.left + nx * mapRect.width,
          mapRect.top + ny * mapRect.height,
        );

    // ── Routes animées
    for (final (ia, ib) in _routes) {
      final a = cityPos(_cities[ia].nx, _cities[ia].ny);
      final b = cityPos(_cities[ib].nx, _cities[ib].ny);

      // Ligne de fond
      final linePaint = Paint()
        ..color = _Palette.red.withValues(alpha: baseAlpha)
        ..strokeWidth = isDark ? 0.8 : 0.6
        ..style = PaintingStyle.stroke;
      canvas.drawLine(a, b, linePaint);

      // Point de louage qui se déplace sur la route
      // Chaque route a une phase différente basée sur son index
      final routePhase = ((ia + ib) % 9) / 9.0;
      final t = ((progress + routePhase) % 1.0);
      final vehiclePos = Offset.lerp(a, b, t)!;

      final vehiclePaint = Paint()
        ..color = _Palette.red.withValues(alpha: isDark ? 0.55 : 0.28)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(vehiclePos, isDark ? 3.0 : 2.2, vehiclePaint);

      // Traînée lumineuse derrière le véhicule
      if (isDark) {
        final trailEnd = Offset.lerp(a, b, math.max(0, t - 0.12))!;
        final trailPaint = Paint()
          ..shader = LinearGradient(
            colors: [
              _Palette.red.withValues(alpha: 0.0),
              _Palette.red.withValues(alpha: 0.30),
            ],
          ).createShader(Rect.fromPoints(trailEnd, vehiclePos))
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(trailEnd, vehiclePos, trailPaint);
      }
    }

    // ── Points de villes avec pulse
    for (var i = 0; i < _cities.length; i++) {
      final city = _cities[i];
      final pos = cityPos(city.nx, city.ny);
      final cityPhase = (i / _cities.length + progress * 2) % 1.0;
      final pulse = 0.7 + 0.3 * math.sin(cityPhase * 2 * math.pi);

      // Halo extérieur
      if (isDark) {
        final haloPaint = Paint()
          ..color = _Palette.red.withValues(alpha: 0.12 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(pos, 8 * pulse, haloPaint);
      }

      // Point principal
      final dotPaint = Paint()
        ..color = _Palette.red.withValues(
          alpha: isDark ? 0.65 * pulse : 0.30 * pulse,
        )
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, isDark ? 3.5 : 2.8, dotPaint);

      // Anneau
      final ringPaint = Paint()
        ..color = _Palette.red.withValues(
          alpha: isDark ? 0.35 * pulse : 0.15 * pulse,
        )
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(pos, (isDark ? 6.0 : 5.0) * pulse, ringPaint);
    }
  }

  // ── Couche 3 : Lignes de vitesse + véhicules ──────────────────────────────
  void _paintSpeedLines(Canvas canvas, Size size) {
    final baseAlpha = isDark ? 0.30 : 0.10;

    for (final line in _lines) {
      // Position x animée : de gauche à droite en boucle
      final x = ((progress * line.speed * 60 + line.phase) % 1.2) - 0.1;
      final startX = (x - line.length) * size.width;
      final endX = x * size.width;
      final y = line.y * size.height;

      if (endX < 0 || startX > size.width) continue;

      // Gradient de la ligne (s'efface aux extrémités)
      final linePaint = Paint()
        ..shader = LinearGradient(
          colors: [
            _Palette.red.withValues(alpha: 0.0),
            _Palette.red.withValues(alpha: baseAlpha),
            isDark
                ? _Palette.orange.withValues(alpha: baseAlpha * 0.7)
                : _Palette.red.withValues(alpha: baseAlpha * 0.4),
            _Palette.red.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.2, 0.8, 1.0],
        ).createShader(
          Rect.fromLTWH(startX, y, endX - startX, 1),
        )
        ..strokeWidth = line.thickness
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(startX, y), Offset(endX, y), linePaint);

      // Icône véhicule au bout de la ligne
      if (line.hasVehicle && endX > 0 && endX < size.width) {
        final iconPaint = Paint()
          ..color = _Palette.red.withValues(alpha: isDark ? 0.60 : 0.25)
          ..style = PaintingStyle.fill;

        // Corps du louage (rectangle arrondi)
        final vehicleRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(endX + 12, y),
            width: 20,
            height: 10,
          ),
          const Radius.circular(3),
        );
        canvas.drawRRect(vehicleRect, iconPaint);

        // Roues
        canvas.drawCircle(Offset(endX + 5, y + 6), 3, iconPaint);
        canvas.drawCircle(Offset(endX + 19, y + 6), 3, iconPaint);
      }
    }
  }

  // ── Couche 4 : Particules de poussière ────────────────────────────────────
  void _paintParticles(Canvas canvas, Size size) {
    final baseAlpha = isDark ? 0.22 : 0.10;

    for (final p in _particles) {
      // Position animée
      final t = (progress + p.phase) % 1.0;
      final px = (p.x + math.cos(p.angle) * p.speed * t * 30) % 1.0;
      final py = (p.y + math.sin(p.angle) * p.speed * t * 30) % 1.0;

      final pulse = 0.5 + 0.5 * math.sin(t * 2 * math.pi + p.phase * 6);
      final color = (px + py) % 1.0 < 0.5 ? _Palette.red : _Palette.orange;

      final paint = Paint()
        ..color = color.withValues(alpha: baseAlpha * pulse)
        ..style = PaintingStyle.fill;

      if (isDark && p.size > 3) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      }

      canvas.drawCircle(
        Offset(px * size.width, py * size.height),
        p.size * pulse,
        paint,
      );
    }
  }

  // ── Aurora blob (remplace la carte pour intensité mid) ────────────────────
  void _paintAuroraBlobs(Canvas canvas, Size size) {
    void blob(double cx, double cy, double r, double alpha, double blur) {
      canvas.drawCircle(
        Offset(cx * size.width, cy * size.height),
        r * size.width,
        Paint()
          ..color = _Palette.red.withValues(alpha: alpha)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
      );
    }

    final s = math.sin(2 * math.pi * progress);
    final c = math.cos(2 * math.pi * progress);

    blob(0.5 + 0.35 * c, 0.30 + 0.20 * s,
        0.50, isDark ? 0.14 : 0.06, isDark ? 80 : 100);
    blob(0.25 + 0.28 * c, 0.65 + 0.18 * s,
        0.38, isDark ? 0.10 : 0.05, isDark ? 70 : 90);
    blob(0.80 + 0.14 * c, 0.20 + 0.16 * s,
        0.28, isDark ? 0.08 : 0.04, isDark ? 60 : 80);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // ── Couche 1 : toujours présente
    _paintSky(canvas, size);

    switch (intensity) {
      case BackgroundIntensity.full:
        // Carte + réseau complet
        _paintMap(canvas, size);
        // Lignes de vitesse
        _paintSpeedLines(canvas, size);
        // Particules
        _paintParticles(canvas, size);

      case BackgroundIntensity.mid:
        // Blobs aurora à la place de la carte (moins chargé)
        _paintAuroraBlobs(canvas, size);
        // Lignes de vitesse légères
        _paintSpeedLines(canvas, size);
        // Particules
        _paintParticles(canvas, size);

      case BackgroundIntensity.subtle:
        // Blobs aurora très doux
        _paintAuroraBlobs(canvas, size);
        // Particules seulement
        _paintParticles(canvas, size);
    }
  }

  @override
  bool shouldRepaint(_LivingWorldPainter old) =>
      old.progress != progress ||
      old.isDark != isDark ||
      old.intensity != intensity;
}

// ─────────────────────────────────────────────────────────────────────────────
// Rétrocompatibilité — ancienne enum BackgroundVariant conservée
// (les références existantes compilent sans modification)
// ─────────────────────────────────────────────────────────────────────────────

/// @deprecated Utiliser [BackgroundIntensity] à la place.
enum BackgroundVariant {
  aurora,
  neonGrid;

  BackgroundIntensity get intensity => switch (this) {
        BackgroundVariant.neonGrid => BackgroundIntensity.full,
        BackgroundVariant.aurora => BackgroundIntensity.mid,
      };
}

/// @deprecated Wrapper de compatibilité — à migrer vers [AnimatedBackground].
class AnimatedBackgroundLegacy extends StatelessWidget {
  const AnimatedBackgroundLegacy({super.key, required this.variant});
  final BackgroundVariant variant;

  @override
  Widget build(BuildContext context) =>
      AnimatedBackground(intensity: variant.intensity);
}
