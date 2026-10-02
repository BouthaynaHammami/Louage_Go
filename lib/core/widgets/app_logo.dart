import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppLogoMark extends StatelessWidget {
  final double size;
  final bool showBackground;

  const AppLogoMark({super.key, this.size = 120, this.showBackground = true});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final image = Image.asset(
      'assets/images/louagego_mark.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.airport_shuttle_rounded,
        color: colorScheme.primary,
        size: size * 0.5,
      ),
    );
    final mark = showBackground
        ? Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.secondary, width: 1),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.16),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(padding: EdgeInsets.all(size * 0.18), child: image),
          )
        : SizedBox.square(dimension: size, child: image);

    return Hero(tag: 'app-logo', child: mark);
  }
}

class AppWordmark extends StatelessWidget {
  final bool prominent;

  const AppWordmark({super.key, this.prominent = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final style =
        (prominent
                ? Theme.of(context).textTheme.displayLarge
                : Theme.of(context).textTheme.headlineMedium)
            ?.copyWith(fontWeight: FontWeight.w700);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Louage',
            style: style?.copyWith(color: colorScheme.onSurface),
          ),
          TextSpan(
            text: 'Go',
            style: style?.copyWith(color: colorScheme.secondary),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class AppLogo extends StatelessWidget {
  final double size;
  final bool showBackground;

  const AppLogo({super.key, this.size = 120, this.showBackground = true});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: showBackground ? colorScheme.surface : null,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          'assets/images/louagego_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.airport_shuttle_rounded,
            size: size * 0.55,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
