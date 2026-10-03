import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:louage_go/features/auth/auth_providers.dart';
import 'package:louage_go/features/favorites/domain/favorites_data.dart';
import 'package:louage_go/features/favorites/domain/favorites_repository.dart';
import 'package:louage_go/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:louage_go/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:louage_go/l10n/generated/app_localizations.dart';
import 'package:louage_go/models/app_user.dart';

void main() {
  testWidgets('favorites tabs render at 320 dp in French, English and Arabic', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final locale in const [Locale('fr'), Locale('en'), Locale('ar')]) {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => Stream.value(const AppUser(id: 'user-1')),
            ),
            favoritesRepositoryProvider.overrideWithValue(
              _FakeFavoritesRepository(),
            ),
            favoritesProvider.overrideWith(
              (ref, userId) => Stream.value(const FavoritesData()),
            ),
          ],
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const FavoritesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          (await AppLocalizations.delegate.load(locale)).favoritesTabOffers,
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
  });
}

class _FakeFavoritesRepository implements FavoritesRepository {
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
  ) async {}

  @override
  bool isFavorite(String userId, String referenceId, {String type = 'route'}) =>
      false;

  @override
  bool isOfferFavorite(String userId, String louageId, String departureHm) =>
      false;
}
