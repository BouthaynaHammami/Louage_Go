import 'package:flutter/material.dart';

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
  bool _focused = false;

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
    final darkButtonBackground = colorScheme.brightness == Brightness.dark
        ? colorScheme.surfaceContainer
        : colorScheme.secondary;
    final darkButtonForeground = colorScheme.brightness == Brightness.dark
        ? colorScheme.onSurface
        : colorScheme.onSecondary;
    final foreground = switch (widget.variant) {
      AppButtonVariant.primary => colorScheme.onPrimary,
      AppButtonVariant.secondary => colorScheme.onSurface,
      AppButtonVariant.accent => darkButtonForeground,
    };
    final background = switch (widget.variant) {
      AppButtonVariant.primary => colorScheme.primary,
      AppButtonVariant.secondary => colorScheme.surface,
      AppButtonVariant.accent => darkButtonBackground,
    };
    final callback = widget.isLoading ? null : widget.onPressed;
    final borderRadius = BorderRadius.circular(16);
    final shape = RoundedRectangleBorder(borderRadius: borderRadius);

    late final Widget button;
    if (widget.variant == AppButtonVariant.secondary) {
      button = OutlinedButton(
        onPressed: callback,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(0, widget.height),
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
          foregroundColor: foreground,
          side: BorderSide(color: colorScheme.secondary),
          shape: shape,
        ),
        child: _content(foreground),
      );
    } else {
      button = AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: ElevatedButton(
          onPressed: callback,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(0, widget.height),
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
            backgroundColor: background,
            foregroundColor: foreground,
            disabledBackgroundColor: colorScheme.onSurface.withValues(
              alpha: 0.12,
            ),
            disabledForegroundColor: colorScheme.onSurface.withValues(
              alpha: 0.38,
            ),
            elevation: 0,
            shape: shape,
          ),
          child: _content(
            callback == null
                ? colorScheme.onSurface.withValues(alpha: 0.38)
                : foreground,
          ),
        ),
      );
    }

    return Focus(
      onFocusChange: (focused) {
        if (_focused != focused) setState(() => _focused = focused);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: _focused
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.28),
                    blurRadius: 0,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Listener(
          onPointerDown: (_) => setState(() => _pressed = true),
          onPointerUp: (_) => setState(() => _pressed = false),
          onPointerCancel: (_) => setState(() => _pressed = false),
          child: button,
        ),
      ),
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
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
