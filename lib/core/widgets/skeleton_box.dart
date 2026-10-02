import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

class SkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadiusGeometry borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surface;
    final highlight = Color.alphaBlend(
      scheme.secondary.withValues(alpha: 0.18),
      base,
    );
    final loadingLabel = AppLocalizations.of(context)!.commonLoading;

    return Semantics(
      label: loadingLabel,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Color.lerp(base, highlight, _controller.value),
              borderRadius: widget.borderRadius,
            ),
          ),
        ),
      ),
    );
  }
}
