import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, accent }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.height = 56,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  Widget _content(Color foreground) {
    return Semantics(
      label: widget.isLoading ? widget.label : null,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: widget.isLoading
            ? SizedBox.square(
                key: const ValueKey('loading'),
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foreground,
                ),
              )
            : _ButtonContent(
                key: const ValueKey('label'),
                label: widget.label,
                icon: widget.icon,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = switch (widget.variant) {
      AppButtonVariant.primary => colorScheme.onPrimary,
      AppButtonVariant.secondary => colorScheme.onSurface,
      AppButtonVariant.accent => colorScheme.onSecondary,
    };
    final callback = widget.isLoading ? null : widget.onPressed;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );

    if (widget.variant == AppButtonVariant.secondary) {
      return OutlinedButton(
        onPressed: callback,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(0, widget.height),
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
          foregroundColor: foreground,
          side: BorderSide(color: colorScheme.outline),
          shape: shape,
        ),
        child: _content(foreground),
      );
    }

    if (widget.variant == AppButtonVariant.primary) {
      return AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: Material(
          color: colorScheme.surface.withValues(alpha: 0),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.secondary,
                  Color.lerp(colorScheme.secondary, colorScheme.primary, 0.25)!,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: callback,
              onHighlightChanged: (pressed) =>
                  setState(() => _pressed = pressed),
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: widget.height,
                child: Center(child: _content(AppColors.textOnAccent)),
              ),
            ),
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: callback,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(0, widget.height),
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
        backgroundColor: widget.variant == AppButtonVariant.accent
            ? colorScheme.secondary
            : colorScheme.primary,
        foregroundColor: foreground,
        shape: shape,
      ),
      child: _content(foreground),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final String label;
  final IconData? icon;

  const _ButtonContent({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    if (icon == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(label)],
    );
  }
}
