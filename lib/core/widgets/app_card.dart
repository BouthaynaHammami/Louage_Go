import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? shadowColor;
  final double? elevation;
  final ShapeBorder? shape;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsetsDirectional.all(16),
    this.onTap,
    this.color,
    this.shadowColor,
    this.elevation,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(16);
    final cardShape =
        shape ??
        RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: colorScheme.outline),
        );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: (shadowColor ?? colorScheme.shadow).withValues(
              alpha: ((elevation ?? 1) / 10).clamp(0.08, 0.10),
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        color: color ?? colorScheme.surface,
        elevation: 0,
        shape: cardShape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
