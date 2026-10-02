import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, accent }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = switch (variant) {
      AppButtonVariant.primary => colorScheme.onPrimary,
      AppButtonVariant.secondary => colorScheme.onSurface,
      AppButtonVariant.accent => colorScheme.onSecondary,
    };
    final child = isLoading
        ? Semantics(
            label: label,
            child: SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: foreground,
              ),
            ),
          )
        : _ButtonContent(label: label, icon: icon);
    final callback = isLoading ? null : onPressed;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );

    if (variant == AppButtonVariant.secondary) {
      return OutlinedButton(
        onPressed: callback,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
          foregroundColor: foreground,
          side: BorderSide(color: colorScheme.outline),
          shape: shape,
        ),
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: callback,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(0, 52),
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
        backgroundColor: variant == AppButtonVariant.accent
            ? colorScheme.secondary
            : colorScheme.primary,
        foregroundColor: foreground,
        shape: shape,
      ),
      child: child,
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final String label;
  final IconData? icon;

  const _ButtonContent({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    if (icon == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(label)],
    );
  }
}
