import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

class ReviewStars extends StatelessWidget {
  const ReviewStars({
    required this.rating,
    this.size = 20,
    this.interactive = false,
    this.onSelected,
    super.key,
  });

  final int rating;
  final double size;
  final bool interactive;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var value = 1; value <= 5; value++)
            Semantics(
              button: interactive,
              selected: interactive && value == rating,
              label: l10n.reviewsStarSemantics(value),
              child: SizedBox.square(
                dimension: interactive ? 48 : size + 6,
                child: IconButton(
                  tooltip: interactive ? l10n.reviewsStarSemantics(value) : null,
                  padding: EdgeInsets.zero,
                  onPressed: interactive ? () => onSelected?.call(value) : null,
                  icon: Icon(
                    value <= rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: size,
                    color: value <= rating ? colors.secondary : colors.outline,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
