import 'favorites_data.dart';

abstract interface class FavoritesRepository {
  Stream<FavoritesData> watchFavorites(String userId);

  Future<void> toggleRoute(String userId, String routeId);

  Future<void> toggleStation(String userId, String stationId);

  Future<void> toggleOffer(
    String userId,
    String louageId,
    String departureHm,
    String routeId,
  );

  bool isFavorite(String userId, String referenceId, {String type = 'route'});

  bool isOfferFavorite(String userId, String louageId, String departureHm);
}
