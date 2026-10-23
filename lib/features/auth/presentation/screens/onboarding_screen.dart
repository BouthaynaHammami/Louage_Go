import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/hive_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/interactive_logo.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../widgets/onboarding_illustration.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  static const _pageCount = 3;
  final PageController _pageController = PageController();
  late final AnimationController _skipController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  );
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  Timer? _skipDelay;
  int _page = 0;
  bool _animationsDisabled = true;

  Future<void> _finish() async {
    await HiveService.session.put('onboardingSeen', {'value': true});
    if (mounted) context.goNamed('login');
  }

  Future<void> _next() async {
    if (_page == _pageCount - 1) {
      await _finish();
      return;
    }
    await _navigateTo(_page + 1);
  }

  Future<void> _navigateTo(int page) async {
    if (_animationsDisabled) {
      _pageController.jumpToPage(page);
      return;
    }
    await _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 460),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPageChanged(int page) {
    setState(() => _page = page);
    if (_animationsDisabled) return;
    if (page == _pageCount - 1) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController
        ..stop()
        ..value = 0;
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (isRtl) {
        if (_page > 0) {
          unawaited(_navigateTo(_page - 1));
        }
      } else {
        unawaited(_next());
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (isRtl) {
        unawaited(_next());
      } else if (_page > 0) {
        unawaited(_navigateTo(_page - 1));
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disabled = MediaQuery.disableAnimationsOf(context);
    if (_animationsDisabled == disabled) return;
    _animationsDisabled = disabled;
    _skipDelay?.cancel();
    if (disabled) {
      _skipController
        ..stop()
        ..value = 1;
      _pulseController
        ..stop()
        ..value = 0;
      return;
    }
    _skipController.value = 0;
    _skipDelay = Timer(const Duration(milliseconds: 380), () {
      if (mounted && !_animationsDisabled) _skipController.forward();
    });
    if (_page == _pageCount - 1) _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _skipDelay?.cancel();
    _pageController.dispose();
    _skipController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final slides = [
      _OnboardingSlide(
        title: l10n.onboardingReserveTitle,
        description: l10n.onboardingReserveBody,
      ),
      _OnboardingSlide(
        title: l10n.onboardingTrackTitle,
        description: l10n.onboardingTrackBody,
      ),
      _OnboardingSlide(
        title: l10n.onboardingPayTitle,
        description: l10n.onboardingPayBody,
      ),
    ];
    final topInset = MediaQuery.viewPaddingOf(context).top;
    final headerHeight = math.min(214.0, 184 + topInset);

    return Focus(
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLow,
        body: Stack(
          children: [
            Positioned.fill(
              child: _OnboardingBackdrop(
                pageController: _pageController,
                page: _page,
                animationsDisabled: _animationsDisabled,
              ),
            ),
            SafeArea(
              top: false,
              child: Column(
                children: [
                  _OnboardingHeader(
                    height: headerHeight,
                    topInset: topInset,
                    skipLabel: l10n.onboardingSkip,
                    onSkip: _finish,
                    skipAnimation: _skipController,
                    animationsDisabled: _animationsDisabled,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onVerticalDragEnd: (details) {
                        if (_page == _pageCount - 1 &&
                            (details.primaryVelocity ?? 0) < -350) {
                          _finish();
                        }
                      },
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _pageCount,
                        onPageChanged: _onPageChanged,
                        itemBuilder: (context, index) => _OnboardingPage(
                          slide: slides[index],
                          index: index,
                          pageController: _pageController,
                          animationsDisabled: _animationsDisabled,
                        ),
                      ),
                    ),
                  ),
                  _PageProgress(
                    pageController: _pageController,
                    page: _page,
                    pageCount: _pageCount,
                    animationsDisabled: _animationsDisabled,
                    onSelect: _navigateTo,
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      24,
                      16,
                      24,
                      20,
                    ),
                    child: _OnboardingCta(
                      label: _page == _pageCount - 1
                          ? l10n.onboardingStart
                          : l10n.onboardingNext,
                      onPressed: _next,
                      isLastPage: _page == _pageCount - 1,
                      pulseAnimation: _pulseController,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({required this.title, required this.description});

  final String title;
  final String description;
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({
    required this.height,
    required this.topInset,
    required this.skipLabel,
    required this.onSkip,
    required this.skipAnimation,
    required this.animationsDisabled,
  });

  final double height;
  final double topInset;
  final String skipLabel;
  final VoidCallback onSkip;
  final Animation<double> skipAnimation;
  final bool animationsDisabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = colorScheme.brightness == Brightness.dark
        ? colorScheme.surfaceContainer
        : colorScheme.secondary;
    return ClipRRect(
      borderRadius: const BorderRadiusDirectional.vertical(
        bottom: Radius.circular(32),
      ),
      child: SizedBox(
        height: height,
        child: ColoredBox(
          color: background,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: topInset + 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const InteractiveLogo(size: 104),
                    const SizedBox(height: 2),
                    const AppWordmark(onDark: true),
                  ],
                ),
              ),
              PositionedDirectional(
                top: topInset + 4,
                end: 10,
                child: FadeTransition(
                  opacity: animationsDisabled
                      ? const AlwaysStoppedAnimation(1)
                      : skipAnimation,
                  child: TextButton(
                    onPressed: onSkip,
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.onPrimary,
                      minimumSize: const Size(64, 48),
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 14,
                      ),
                    ),
                    child: Text(skipLabel),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.slide,
    required this.index,
    required this.pageController,
    required this.animationsDisabled,
  });

  final _OnboardingSlide slide;
  final int index;
  final PageController pageController;
  final bool animationsDisabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final sceneSize = math.min(
          236.0,
          math.min(constraints.maxWidth * .72, constraints.maxHeight * .45),
        );
        return AnimatedBuilder(
          animation: pageController,
          builder: (context, _) {
            final currentPage = animationsDisabled
                ? index.toDouble()
                : pageController.hasClients
                ? pageController.page ?? index.toDouble()
                : index.toDouble();
            final difference = currentPage - index;
            final visibility = (1 - difference.abs()).clamp(0.0, 1.0);
            final pageScale = 1 - (difference.abs().clamp(0.0, 1.0) * .08);
            return Opacity(
              opacity: visibility,
              child: Transform.scale(
                scale: pageScale,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: Offset(-difference * 24, 0),
                      child: RepaintBoundary(
                        child: OnboardingIllustration(
                          index: index,
                          size: sceneSize,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Transform.translate(
                      offset: Offset(0, difference * 14),
                      child: Column(
                        children: [
                          Text(
                            slide.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 32,
                            ),
                            child: Text(
                              slide.description,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: .76,
                                    ),
                                    height:
                                        Localizations.localeOf(context)
                                                .languageCode ==
                                            'ar'
                                        ? 1.65
                                        : 1.4,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PageProgress extends StatelessWidget {
  const _PageProgress({
    required this.pageController,
    required this.page,
    required this.pageCount,
    required this.animationsDisabled,
    required this.onSelect,
  });

  final PageController pageController;
  final int page;
  final int pageCount;
  final bool animationsDisabled;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, _) {
        final currentPage = animationsDisabled
            ? page.toDouble()
            : pageController.hasClients
            ? (pageController.page ?? page.toDouble()).clamp(
                0.0,
                (pageCount - 1).toDouble(),
              )
            : page.toDouble();
        return Semantics(
          label: '${page + 1} / $pageCount',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var index = 0; index < pageCount; index++)
                Semantics(
                  button: true,
                  selected: index == page,
                  label: MaterialLocalizations.of(context)
                      .pageRowsInfoTitle(index + 1, pageCount, 1, false),
                  child: InkWell(
                    key: ValueKey('onboarding-page-$index'),
                    onTap: () => onSelect(index),
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Center(
                        child: SizedBox(
                          width: 28,
                          height: 7,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: colorScheme.outline.withValues(alpha: .35),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: FractionallySizedBox(
                                widthFactor: (1 - (currentPage - index).abs())
                                    .clamp(0.0, 1.0),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _OnboardingCta extends StatelessWidget {
  const _OnboardingCta({
    required this.label,
    required this.onPressed,
    required this.isLastPage,
    required this.pulseAnimation,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLastPage;
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    final animationsDisabled = MediaQuery.disableAnimationsOf(context);
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) => Transform.scale(
        scale: isLastPage && !animationsDisabled
            ? 1 + pulseAnimation.value * .025
            : 1,
        child: child,
      ),
      child: AnimatedSwitcher(
        duration: animationsDisabled
            ? Duration.zero
            : const Duration(milliseconds: 320),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, .16),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: Stack(
          key: ValueKey(label),
          alignment: AlignmentDirectional.center,
          children: [
            AppButton(
              label: label,
              onPressed: onPressed,
              variant: AppButtonVariant.primary,
              height: 56,
            ),
            PositionedDirectional(
              end: 20,
              child: IgnorePointer(
                child: AnimatedSlide(
                  duration: animationsDisabled
                      ? Duration.zero
                      : const Duration(milliseconds: 360),
                  curve: Curves.easeOutBack,
                  offset: isLastPage
                      ? Offset.zero
                      : Offset(
                          Directionality.of(context) == TextDirection.rtl
                              ? -.35
                              : .35,
                          0,
                        ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: colorScheme.onPrimary,
                    textDirection: Directionality.of(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingBackdrop extends StatelessWidget {
  const _OnboardingBackdrop({
    required this.pageController,
    required this.page,
    required this.animationsDisabled,
  });

  final PageController pageController;
  final int page;
  final bool animationsDisabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, _) {
        final currentPage = animationsDisabled
            ? page.toDouble()
            : pageController.hasClients
            ? pageController.page ?? page.toDouble()
            : page.toDouble();
        final alignment = Alignment((currentPage / 2 - .5).clamp(-.5, .5), .15);
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: alignment,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surfaceContainerLow,
                colorScheme.primary.withValues(alpha: .055),
                colorScheme.surfaceContainerLow,
              ],
              stops: const [0, .52, 1],
            ),
          ),
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _RoadBackdropPainter(
                progress: currentPage,
                color: colorScheme.outline.withValues(alpha: .20),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        );
      },
    );
  }
}

class _RoadBackdropPainter extends CustomPainter {
  const _RoadBackdropPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final shift = (progress * 42) % 84;
    final path = Path()
      ..moveTo(size.width * .82 + shift, size.height * .34)
      ..cubicTo(
        size.width * .64 + shift,
        size.height * .50,
        size.width * .92 + shift,
        size.height * .57,
        size.width * .71 + shift,
        size.height * .76,
      );
    canvas.drawPath(path, paint);
    final metric = path.computeMetrics().first;
    final dashPaint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    for (var distance = 0.0; distance < metric.length; distance += 14) {
      final position = metric.getTangentForOffset(distance)!.position;
      canvas.drawCircle(position, 1.5, dashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RoadBackdropPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
