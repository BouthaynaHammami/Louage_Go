import 'dart:async';

import 'package:hive_ce/hive.dart';

import '../../../core/storage/hive_service.dart';
import '../../../models/app_user.dart';
import '../../../models/booking.dart';
import '../../../models/driver_profile.dart';
import '../../../models/louage.dart';
import '../../../models/station.dart';
import '../../../models/trip.dart';
import '../domain/driver_repository.dart';
import '../domain/entities/driver_dashboard_data.dart';
import '../domain/entities/driver_passenger.dart';

class HiveDriverRepository implements DriverRepository {
  HiveDriverRepository({
    Box<Map>? driversBox,
    Box<Map>? louagesBox,
    Box<Map>? stationsBox,
    Box<Map>? tripsBox,
    Box<Map>? bookingsBox,
    Box<Map>? usersBox,
    Box<Map>? sessionBox,
  }) : _driversBox = driversBox ?? HiveService.drivers,
       _louagesBox = louagesBox ?? HiveService.louages,
       _stationsBox = stationsBox ?? HiveService.stations,
       _tripsBox = tripsBox ?? HiveService.trips,
       _bookingsBox = bookingsBox ?? HiveService.bookings,
       _usersBox = usersBox ?? HiveService.users,
       _sessionBox = sessionBox ?? HiveService.session;

  final Box<Map> _driversBox;
  final Box<Map> _louagesBox;
  final Box<Map> _stationsBox;
  final Box<Map> _tripsBox;
  final Box<Map> _bookingsBox;
  final Box<Map> _usersBox;
  final Box<Map> _sessionBox;

  @override
  Stream<DriverDashboardData> watchDashboard(String driverId) =>
      Stream<DriverDashboardData>.multi((controller) {
        final subscriptions = <StreamSubscription<dynamic>>[];

        void reload() {
          try {
            controller.add(_loadDashboard(driverId));
          } catch (error, stackTrace) {
            controller.addError(error, stackTrace);
          }
        }

        subscriptions
          ..add(_driversBox.watch().listen((_) => reload()))
          ..add(_louagesBox.watch().listen((_) => reload()))
          ..add(_stationsBox.watch().listen((_) => reload()))
          ..add(_tripsBox.watch().listen((_) => reload()))
          ..add(_bookingsBox.watch().listen((_) => reload()))
          ..add(_usersBox.watch().listen((_) => reload()));

        controller.onCancel = () async {
          await Future.wait(
            subscriptions.map((subscription) => subscription.cancel()),
          );
        };
        reload();
      });

  @override
  Future<void> toggleQueue(String louageId) async {
    final louageMap = _louagesBox.get(louageId);
    if (louageMap == null) return;

    final louage = Louage.fromMap(louageMap);
    await _louagesBox.put(
      louageId,
      louage.copyWith(isQueued: !louage.isQueued).toMap(),
    );
  }

  DriverDashboardData _loadDashboard(String driverId) {
    final profileMap = _driversBox.get(driverId);
    final profile = profileMap == null
        ? DriverProfile(userId: driverId)
        : DriverProfile.fromMap(profileMap);
    final matchingLouages = _louagesBox.values
        .map(Louage.fromMap)
        .where(
          (louage) =>
              louage.driverId == driverId ||
              (profile.matricule.isNotEmpty &&
                  louage.matricule == profile.matricule),
        )
        .toList();
    var louage = matchingLouages.isEmpty ? null : matchingLouages.first;

    if (louage != null) {
      final storedLouage = _louagesBox.get(louage.id);
      if (storedLouage != null && !storedLouage.containsKey('isQueued')) {
        final legacyKey = 'driverQueue_$driverId';
        final legacyValue = _sessionBox.get(legacyKey);
        louage = louage.copyWith(isQueued: legacyValue?['joined'] == true);
        unawaited(_louagesBox.put(louage.id, louage.toMap()));
        if (legacyValue != null) unawaited(_sessionBox.delete(legacyKey));
      }
    }

    final stationMap = louage == null
        ? null
        : _stationsBox.get(louage.currentStationId);
    final station = stationMap == null ? null : Station.fromMap(stationMap);
    final trips =
        louage == null
              ? <Trip>[]
              : _tripsBox.values
                    .map(Trip.fromMap)
                    .where((trip) => trip.louageId == louage!.id)
                    .toList()
          ..sort((a, b) => a.departureTime.compareTo(b.departureTime));
    final tripIds = trips.map((trip) => trip.id).toSet();
    final bookings = _bookingsBox.values
        .map(Booking.fromMap)
        .where(
          (booking) =>
              tripIds.contains(booking.tripId) &&
              !const {'cancelled', 'rejected'}.contains(booking.status),
        )
        .toList();
    final passengers = <String, DriverPassenger>{};
    for (final entry in _usersBox.toMap().entries) {
      final user = AppUser.fromMap(entry.value);
      final userId = user.id.isEmpty ? entry.key.toString() : user.id;
      passengers[userId] = DriverPassenger(
        id: userId,
        name: user.name,
        phone: user.phone,
      );
    }

    return DriverDashboardData(
      profile: profile,
      louage: louage,
      station: station,
      trips: trips,
      bookings: bookings,
      passengers: passengers,
    );
  }
}
