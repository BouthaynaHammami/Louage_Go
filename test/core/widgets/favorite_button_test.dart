import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:louage_go/core/widgets/app_card.dart';
import 'package:louage_go/features/auth/auth_providers.dart';
import 'package:louage_go/features/favorites/domain/favorites_data.dart';
import 'package:louage_go/features/favorites/domain/favorites_repository.dart';
import 'package:louage_go/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:louage_go/core/widgets/favorite_button.dart';
import 'package:louage_go/l10n/generated/app_localizations.dart';
import 'package:louage_go/models/app_user.dart';

void main() {
  testWidgets(
    'offer favorite button exposes localized semantics and toggles offer',
    (tester) async {
      final repository = _FakeFavoritesRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => Stream.value(const AppUser(id: 'user-1')),
            ),
            favoritesRepositoryProvider.overrideWithValue(repository),
            favoritesProvider.overrideWith(
              (ref, userId) => Stream.value(const FavoritesData()),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('fr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: Center(
                child: AppCard(
                  child: FavoriteButton.offer(
                    louageId: 'louage-1',
                    departureHm: '07:15',
                    routeId: 'route-1',
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Ajouter cette offre aux favoris'), findsOneWidget);
      await tester.tap(find.byTooltip('Ajouter cette offre aux favoris'));
      await tester.pumpAndSettle();

      expect(repository.toggledOffer, (
        'user-1',
        'louage-1',
        '07:15',
        'route-1',
      ));
    },
  );
}

class _FakeFavoritesRepository implements FavoritesRepository {
  (String, String, String, String)? toggledOffer;

  @override
  Stream<FavoritesData> watchFavorites(String userId) =>
      Stream.value(const FavoritesData());

  @override
  Future<void> toggleRoute(String userId, String routeId) async {}

  @override
  Future<void> toggleStation(String userId, String stationId) async {}

  @override
  Future<void> toggleOffer(
    String userId,
    String louageId,
    String departureHm,
    String routeId,
  ) async {
    toggledOffer = (userId, louageId, departureHm, routeId);
  }

  @override
  bool isFavorite(String userId, String referenceId, {String type = 'route'}) =>
      false;

  @override
  bool isOfferFavorite(String userId, String louageId, String departureHm) =>
      false;
}
