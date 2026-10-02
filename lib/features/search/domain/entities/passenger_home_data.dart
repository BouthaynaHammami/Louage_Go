import '../../../../models/route_line.dart';
import '../../../../models/station.dart';
import 'search_route_shortcut.dart';

class PassengerHomeData {
  final List<Station> stations;
  final List<RouteLine> routes;
  final List<SearchRouteShortcut> recentTrips;
  final List<SearchRouteShortcut> favorites;

  const PassengerHomeData({
    this.stations = const [],
    this.routes = const [],
    this.recentTrips = const [],
    this.favorites = const [],
  });
}
