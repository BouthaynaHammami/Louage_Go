import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/widgets/app_logo.dart';

// ══════════════════════════════════════════════════════════════════════════════
// IntroScreen — Vidéo cinématique plein écran
// Asset : assets/videos/louage_reveal.mp4
// ══════════════════════════════════════════════════════════════════════════════

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  late final VideoPlayerController _video;

  // UI (logo + bouton) — apparaît à 75% de la vidéo
  late final AnimationController _uiCtrl;
  late final Animation<double>   _uiFade;
  late final Animation<double>   _uiSlide;

  // Fondu blanc de sortie
  late final AnimationController _exitCtrl;
  late final Animation<double>   _exitFade;

  bool _videoReady = false;
  bool _uiTriggered = false;
  bool _exitTriggered = false;

  @override
  void initState() {
    super.initState();

    // ── Masquer la barre de statut pour un rendu plein écran ──────────
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // ── Contrôleurs UI ─────────────────────────────────────────────────
    _uiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _uiFade  = CurvedAnimation(parent: _uiCtrl, curve: Curves.easeOut);
    _uiSlide = Tween<double>(begin: 28.0, end: 0.0).animate(
      CurvedAnimation(parent: _uiCtrl, curve: Curves.easeOutCubic),
    );

    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _exitFade = CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn);

    // ── Initialisation vidéo ───────────────────────────────────────────
    _video = VideoPlayerController.asset('assets/videos/louage_reveal.mp4')
      ..setLooping(false)
      ..setVolume(1.0)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _videoReady = true);
        _video.play();
        // Écouter la progression pour déclencher UI et sortie
        _video.addListener(_onVideoProgress);
      }).catchError((e) {
        // Si la vidéo ne charge pas, passer au splash directement
        if (mounted) context.goNamed('splash');
      });
  }

  void _onVideoProgress() {
    if (!mounted || !_video.value.isInitialized) return;

    final duration = _video.value.duration;
    final position = _video.value.position;
    if (duration.inMilliseconds <= 0) return;

    final progress = position.inMilliseconds / duration.inMilliseconds;

    // Déclencher le logo + bouton à 70% de la vidéo
    if (!_uiTriggered && progress >= 0.70) {
      _uiTriggered = true;
      _uiCtrl.forward();
    }

    // Déclencher le fondu de sortie à 92% de la vidéo
    if (!_exitTriggered && progress >= 0.92) {
      _exitTriggered = true;
      _exitCtrl.forward().then((_) {
        if (mounted) _navigate();
      });
    }

    // Sécurité : si la vidéo se termine naturellement
    if (!_video.value.isPlaying && _video.value.position >= duration) {
      if (!_exitTriggered) {
        _exitTriggered = true;
        _exitCtrl.forward().then((_) {
          if (mounted) _navigate();
        });
      }
    }
  }

  void _navigate() {
    context.goNamed('introSlides');
  }

  void _skip() {
    _video.removeListener(_onVideoProgress);
    _video.pause();
    _uiCtrl.stop();
    _exitCtrl.stop();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (mounted) context.goNamed('introSlides');
  }

  void _book() => _skip();

  @override
  void dispose() {
    _video.removeListener(_onVideoProgress);
    _video.dispose();
    _uiCtrl.dispose();
    _exitCtrl.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size  = MediaQuery.sizeOf(context);
    final safeB = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: Listenable.merge([_uiCtrl, _exitCtrl]),
        builder: (_, __) {
          return Stack(
            children: [

              // ── Vidéo plein écran ──────────────────────────────────
              if (_videoReady)
                Positioned.fill(
                  child: FittedBox(
                    // SizeCover = la vidéo remplit l'écran sans déformation
                    // en gardant ses proportions natives
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width:  _video.value.size.width,
                      height: _video.value.size.height,
                      child: VideoPlayer(_video),
                    ),
                  ),
                )
              else
                // Fond noir pendant le chargement
                const ColoredBox(
                  color: Colors.black,
                  child: SizedBox.expand(),
                ),
X
              // ── Logo + bouton ──────────────────────────────────────
              if (_uiFade.value > 0)
                Positioned(
                  bottom: safeB + size.height * 0.052,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _uiFade,
                    child: AnimatedBuilder(
                      animation: _uiSlide,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, _uiSlide.value),
                        child: child,
                      ),
                      child: _BottomUI(onBook: _book),
                    ),
                  ),
                ),

              // ── Fondu blanc de sortie ──────────────────────────────
              if (_exitFade.value > 0)
                Opacity(
                  opacity: _exitFade.value,
                  child: const ColoredBox(
                    color: Colors.white,
                    child: SizedBox.expand(),
                  ),
                ),

              // ── Bouton skip ────────────────────────────────────────
              if (_exitFade.value < 0.5)
                Positioned(
                  top:   size.height * 0.055,
                  right: 18,
                  child: _SkipBtn(onTap: _skip),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UI bas : logo + tagline + bouton réserver
// ─────────────────────────────────────────────────────────────────────────────
class _BottomUI extends StatelessWidget {
  const _BottomUI({required this.onBook});
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Séparateur doré
        Center(
          child: Container(
            width: 52,
            height: 1.5,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.transparent,
                  Color(0xFFD4A843),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Logo avec halo doré
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4A843).withValues(alpha: 0.35),
                blurRadius: 32,
                spreadRadius: 6,
              ),
              BoxShadow(
                color: const Color(0xFFDC2D2A).withValues(alpha: 0.22),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const AppLogoMark(size: 60),
        ),
        const SizedBox(height: 10),

        const AppWordmark(onDark: true),
        const SizedBox(height: 6),

        const Text(
          'Voyagez à travers la Tunisie  🇹🇳',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFD4A843),
            fontSize: 11,
            letterSpacing: 1.7,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 20),

        // Bouton réserver
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2D2A),
                foregroundColor: Colors.white,
                elevation: 14,
                shadowColor: const Color(0xFFDC2D2A).withValues(alpha: 0.55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_bus_rounded, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Réserver mon trajet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bouton skip
// ─────────────────────────────────────────────────────────────────────────────
class _SkipBtn extends StatelessWidget {
  const _SkipBtn({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.40),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFD4A843).withValues(alpha: 0.45),
            width: 0.8,
          ),
        ),
        child: const Text(
          'Passer  ›',
          style: TextStyle(
            color: Color(0xFFD4A843),
            fontSize: 12,
            letterSpacing: 0.6,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
