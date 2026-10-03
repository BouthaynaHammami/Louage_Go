import '../../../../models/station.dart';

class GovernorateStations {
  const GovernorateStations({
    required this.governorate,
    required this.governorateAr,
    required this.stations,
  });

  final String governorate;
  final String governorateAr;
  final List<Station> stations;
}
