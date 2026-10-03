import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_providers.dart';
import '../../features/favorites/presentation/providers/favorites_provider.dart';
import '../../l10n/generated/app_localizations.dart';

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton.route({super.key, required this.routeId})
    : stationId = null,
      louageId = null,
      departureHm = null;

  const FavoriteButton.station({super.key, required this.stationId})
    : routeId = null,
      louageId = null,
      departureHm = null;

  const FavoriteButton.offer({
    super.key,
    required this.louageId,
    required this.departureHm,
    required this.routeId,
  }) : stationId = null;

  final String? routeId;
  final String? stationId;
  final String? louageId;
  final String? departureHm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final userAsync = ref.watch(currentUserProvider);
    final userId = userAsync.asData?.value?.id;
    if (userId == null) return const SizedBox.shrink();

    final isStation = stationId != null;
    final isOffer = louageId != null;
    final referenceId = stationId ?? routeId!;
    final favoritesAsync = ref.watch(favoritesProvider(userId));
    final favorites = favoritesAsync.asData?.value;
    final isFavorite = favorites == null
        ? false
        : isStation
        ? favorites.isStationFavorite(userId, referenceId)
        : isOffer
        ? favorites.isOfferFavorite(userId, louageId!, departureHm!)
        : favorites.isRouteFavorite(userId, referenceId);
    final label = isFavorite
        ? isStation
              ? l10n.favoriteRemoveStation
              : isOffer
              ? l10n.favoritesOfferRemove
              : l10n.favoriteRemoveRoute
        : isStation
        ? l10n.favoriteAddStation
        : isOffer
        ? l10n.favoritesOfferAdd
        : l10n.favoriteAddRoute;

    return Semantics(
      button: true,
      label: label,
      child: IconButton(
        tooltip: label,
        onPressed: favoritesAsync.hasError
            ? null
            : () async {
                try {
                  if (isStation) {
                    await ref
                        .read(favoritesRepositoryProvider)
                        .toggleStation(userId, referenceId);
                  } else if (isOffer) {
                    await ref
                        .read(favoritesRepositoryProvider)
                        .toggleOffer(
                          userId,
                          louageId!,
                          departureHm!,
                          routeId!,
                        );
                  } else {
                    await ref
                        .read(favoritesRepositoryProvider)
                        .toggleRoute(userId, referenceId);
                  }
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.favoriteUpdateError)),
                  );
                }
              },
        icon: AnimatedScale(
          scale: isFavorite ? 1.12 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              key: ValueKey(isFavorite),
              color: isFavorite ? Theme.of(context).colorScheme.error : null,
            ),
          ),
        ),
      ),
    );
  }
}
