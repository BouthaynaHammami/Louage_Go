import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final end =
        trailing ??
        (actionLabel != null && onAction != null
            ? TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
                  foregroundColor: Theme.of(context).colorScheme.inversePrimary,
                ),
                child: Text(actionLabel!),
              )
            : const SizedBox.shrink());

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
        const SizedBox(width: 8),
        end,
      ],
    );
  }
}
