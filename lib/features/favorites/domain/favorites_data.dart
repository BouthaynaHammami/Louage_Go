import '../../../models/favorite.dart';
import '../../../models/louage.dart';
import '../../../models/route_line.dart';
import '../../../models/station.dart';
import '../../../models/trip.dart';

class FavoriteRoute {
  const FavoriteRoute({
    required this.favorite,
    required this.from,
    required this.to,
    required this.fromAr,
    required this.toAr,
    required this.fromStationId,
    required this.toStationId,
  });

  final Favorite favorite;
  final String from;
  final String to;
  final String fromAr;
  final String toAr;
  final String fromStationId;
  final String toStationId;
}

class FavoriteStation {
  const FavoriteStation({required this.favorite, required this.station});

  final Favorite favorite;
  final Station station;
}

class FavoriteOffer {
  const FavoriteOffer({
    required this.favorite,
    required this.louage,
    required this.route,
    required this.fromStation,
    required this.toStation,
    required this.nextTrip,
  });

  final Favorite favorite;
  final Louage louage;
  final RouteLine route;
  final Station fromStation;
  final Station toStation;
  final Trip? nextTrip;
}

class FavoritesData {
  const FavoritesData({
    this.routes = const [],
    this.stations = const [],
    this.offers = const [],
  });

  final List<FavoriteRoute> routes;
  final List<FavoriteStation> stations;
  final List<FavoriteOffer> offers;

  bool isRouteFavorite(String userId, String routeId) => routes.any(
    (item) =>
        item.favorite.userId == userId && item.favorite.routeId == routeId,
  );

  bool isStationFavorite(String userId, String stationId) => stations.any(
    (item) =>
        item.favorite.userId == userId && item.favorite.stationId == stationId,
  );

  bool isOfferFavorite(String userId, String louageId, String departureHm) =>
      offers.any(
        (item) =>
            item.favorite.userId == userId &&
            item.favorite.louageId == louageId &&
            item.favorite.departureHm == departureHm,
      );
}
