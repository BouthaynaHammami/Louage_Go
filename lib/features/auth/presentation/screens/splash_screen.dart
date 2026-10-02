import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/hive_service.dart';
import '../../../../l10n/generated/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rideController;
  late final Animation<double> _rideProgress;
  late final Timer _redirectTimer;

  @override
  void initState() {
    super.initState();
    _rideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _rideProgress = CurvedAnimation(
      parent: _rideController,
      curve: Curves.easeInOutCubic,
    );
    _rideController.forward();
    _redirectTimer = Timer(const Duration(seconds: 2), _continue);
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
    _rideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onPrimary;
    final slogan = AppLocalizations.of(context)!.splashSlogan;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            children: [
              const Spacer(flex: 2),
              SizedBox(
                width: constraints.maxWidth,
                height: 150,
                child: AnimatedBuilder(
                  animation: _rideProgress,
                  builder: (context, child) => Stack(
                    clipBehavior: Clip.none,
                    children: [
                      PositionedDirectional(
                        start: 24,
                        end: 24,
                        top: 100,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withValues(
                              alpha: 0.45,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        start:
                            -72 +
                            _rideProgress.value * (constraints.maxWidth + 48),
                        top: 35,
                        child: child!,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_pin,
                        size: 30,
                        color: colorScheme.secondary,
                      ),
                      Icon(
                        Icons.airport_shuttle_rounded,
                        size: 64,
                        color: textColor,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOut,
                builder: (context, opacity, child) => Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(0, 10 * (1 - opacity)),
                    child: child,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'LouageGo',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontFamily: 'Poppins',
                            color: textColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      slogan,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: textColor.withValues(alpha: 0.78)),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
