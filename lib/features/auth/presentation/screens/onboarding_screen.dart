import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/hive_service.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../l10n/generated/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pageCount = 3;
  final PageController _pageController = PageController();
  int _page = 0;

  Future<void> _finish() async {
    await HiveService.session.put('onboardingSeen', {'value': true});
    if (mounted) context.goNamed('login');
  }

  Future<void> _next() async {
    if (_page == _pageCount - 1) {
      await _finish();
      return;
    }
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final slides = [
      _OnboardingSlide(
        icon: Icons.confirmation_number_outlined,
        title: l10n.onboardingReserveTitle,
        description: l10n.onboardingReserveBody,
      ),
      _OnboardingSlide(
        icon: Icons.route_outlined,
        title: l10n.onboardingTrackTitle,
        description: l10n.onboardingTrackBody,
      ),
      _OnboardingSlide(
        icon: Icons.account_balance_wallet_outlined,
        title: l10n.onboardingPayTitle,
        description: l10n.onboardingPayBody,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        actions: [
          TextButton(
            onPressed: _finish,
            style: TextButton.styleFrom(
              minimumSize: const Size(64, 48),
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
            ),
            child: Text(l10n.onboardingSkip),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pageCount,
                onPageChanged: (page) => setState(() => _page = page),
                itemBuilder: (context, index) => _OnboardingPage(
                  slide: slides[index],
                  showLogo: index == 0,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < _pageCount; index++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    width: index == _page ? 28 : 8,
                    height: 8,
                    margin: const EdgeInsetsDirectional.symmetric(
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      color: index == _page
                          ? colorScheme.primary
                          : colorScheme.outline,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 28),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(
                    _page == _pageCount - 1
                        ? l10n.onboardingStart
                        : l10n.onboardingNext,
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

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingSlide slide;
  final bool showLogo;

  const _OnboardingPage({required this.slide, required this.showLogo});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(32, 12, 32, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showLogo) ...[
            const AppLogo(size: 56),
            const SizedBox(height: 16),
          ],
          Container(
            width: 196,
            height: 196,
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(slide.icon, size: 86, color: colorScheme.secondary),
          ),
          const SizedBox(height: 36),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.5),
          ),
        ],
      ),
    );
  }
}
