// Comptes de démonstration :
// Admin : admin@louagego.tn / Admin123!
// Chauffeur : chauffeur@louagego.tn / Driver123!
// Passager : passager@louagego.tn / Passenger123!
import '../../models/app_user.dart';
import '../../models/driver_profile.dart';
import '../../models/louage.dart';
import '../../models/route_line.dart';
import '../../models/station.dart';
import '../../models/trip.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import 'hive_service.dart';

class SeedData {
  static const _seedFlag = 'seeded';

  static Future<void> runIfNeeded() async {
    if (HiveService.session.get(_seedFlag)?['value'] == true) return;

    final now = DateTime.now();
    final stations = _stations;

    for (final station in stations) {
      await HiveService.stations.put(station.id, station.toMap());
    }

    final admin = _demoUser(
      id: 'demo_admin',
      name: 'Administrateur Demo',
      phone: '20000001',
      email: 'admin@louagego.tn',
      role: 'admin',
      password: 'Admin123!',
      city: 'Tunis',
      createdAt: now,
    );
    final driver = _demoUser(
      id: 'demo_driver',
      name: 'Chauffeur Demo',
      phone: '20000002',
      email: 'chauffeur@louagego.tn',
      role: 'driver',
      password: 'Driver123!',
      city: 'Tunis',
      createdAt: now,
    );
    final passenger = _demoUser(
      id: 'demo_passenger',
      name: 'Passager Demo',
      phone: '20000003',
      email: 'passager@louagego.tn',
      role: 'passenger',
      password: 'Passenger123!',
      city: 'Tunis',
      createdAt: now,
    );

    for (final user in [admin, driver, passenger]) {
      await HiveService.users.put(user.id, user.toMap());
    }

    final routes = <RouteLine>[];
    for (final (from, to, price, distance, duration) in _routeSpecs) {
      final routeId = '${from}_$to';
      final route = RouteLine(
        id: routeId,
        fromStationId: 'station_$from',
        toStationId: 'station_$to',
        pricePerSeat: price,
        distanceKm: distance,
        durationMin: duration,
      );
      routes.add(route);
      await HiveService.routes.put(route.id, route.toMap());
    }

    var vehicleNumber = 0;
    var driverMatricule = '';
    for (var routeIndex = 0; routeIndex < routes.length; routeIndex++) {
      final route = routes[routeIndex];
      final currentStationId = route.fromStationId;

      for (var timeIndex = 0; timeIndex < _departureTimes.length; timeIndex++) {
        vehicleNumber++;
        final louageId =
            '${route.id}_${(timeIndex + 1).toString().padLeft(2, '0')}';
        final matricule = _matricule(vehicleNumber);
        driverMatricule = driverMatricule.isEmpty ? matricule : driverMatricule;
        final louage = Louage(
          id: louageId,
          driverId: driver.id,
          matricule: matricule,
          capacity: 8,
          currentStationId: currentStationId,
          status: 'active',
        );
        await HiveService.louages.put(louage.id, louage.toMap());

        for (var dayOffset = 0; dayOffset < 2; dayOffset++) {
          final serviceDay = DateTime(now.year, now.month, now.day + dayOffset);
          final departure = _departure(serviceDay, _departureTimes[timeIndex]);
          final reservedSeats =
              _reservedSeatCounts[(routeIndex + timeIndex + dayOffset) %
                  _reservedSeatCounts.length];
          final trip = Trip(
            id: '${_dateKey(serviceDay)}_${route.id}_${timeIndex + 1}',
            louageId: louage.id,
            routeId: route.id,
            totalSeats: louage.capacity,
            reservedSeats: reservedSeats,
            status: reservedSeats == louage.capacity ? 'full' : 'waiting',
            departureTime: departure.toIso8601String(),
            arrivalTime: departure
                .add(Duration(minutes: route.durationMin))
                .toIso8601String(),
          );
          await HiveService.trips.put(trip.id, trip.toMap());
        }
      }
    }

    await HiveService.drivers.put(
      driver.id,
      DriverProfile(
        userId: driver.id,
        licenseNo: 'TN-PERMIT-2026-001',
        carteGrise: 'TN-CG-2026-001',
        assurance: 'TN-ASSURANCE-2026-001',
        matricule: driverMatricule,
        validationStatus: 'approved',
        ratingAverage: 4.8,
      ).toMap(),
    );

    await HiveService.session.put(_seedFlag, {'value': true});
  }

  static AppUser _demoUser({
    required String id,
    required String name,
    required String phone,
    required String email,
    required String role,
    required String password,
    required String city,
    required DateTime createdAt,
  }) {
    final salt = AuthRepositoryImpl.generateSalt();
    return AppUser(
      id: id,
      name: name,
      phone: phone,
      email: email,
      role: role,
      city: city,
      language: 'fr',
      status: 'active',
      passwordHash: AuthRepositoryImpl.hashPassword(password, salt),
      salt: salt,
      createdAt: createdAt.toIso8601String(),
    );
  }

  static String _matricule(int number) {
    final prefix = (100 + number).toString();
    final suffix = (4000 + number * 137 % 6000).toString().padLeft(4, '0');
    return '$prefix TUN $suffix';
  }

  static DateTime _departure(DateTime day, String time) {
    final parts = time.split(':');
    return DateTime(
      day.year,
      day.month,
      day.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  static String _dateKey(DateTime date) =>
      '${date.year}${date.month.toString().padLeft(2, '0')}'
      '${date.day.toString().padLeft(2, '0')}';

  static const _departureTimes = ['06:30', '07:15', '08:00', '09:45', '11:00'];

  static const _reservedSeatCounts = [0, 3, 8, 5, 7];

  static const _routeSpecs = <(String, String, double, double, int)>[
    ('tunis', 'sfax', 18, 270, 210),
    ('sfax', 'tunis', 18, 270, 210),
    ('tunis', 'sousse', 10, 143, 110),
    ('sousse', 'tunis', 10, 143, 110),
    ('tunis', 'nabeul', 7, 65, 70),
    ('nabeul', 'tunis', 7, 65, 70),
    ('tunis', 'bizerte', 6, 65, 75),
    ('bizerte', 'tunis', 6, 65, 75),
  ];

  static const _stations = <Station>[
    Station(
      id: 'station_tunis',
      name: 'Gare de Moncef Bey',
      city: 'Tunis',
      governorate: 'Tunis',
      lat: 36.7911,
      lng: 10.1833,
      address: 'Gare de Moncef Bey, Tunis',
    ),
    Station(
      id: 'station_ariana',
      name: 'Station Ariana',
      city: 'Ariana',
      governorate: 'Ariana',
      lat: 36.8665,
      lng: 10.1647,
      address: 'Centre-ville, Ariana',
    ),
    Station(
      id: 'station_ben_arous',
      name: 'Station Ben Arous',
      city: 'Ben Arous',
      governorate: 'Ben Arous',
      lat: 36.7531,
      lng: 10.2189,
      address: 'Centre-ville, Ben Arous',
    ),
    Station(
      id: 'station_manouba',
      name: 'Station Manouba',
      city: 'Manouba',
      governorate: 'Manouba',
      lat: 36.8080,
      lng: 10.0972,
      address: 'Centre-ville, Manouba',
    ),
    Station(
      id: 'station_nabeul',
      name: 'Gare routiere de Nabeul',
      city: 'Nabeul',
      governorate: 'Nabeul',
      lat: 36.4513,
      lng: 10.7357,
      address: 'Gare routiere, Nabeul',
    ),
    Station(
      id: 'station_zaghouan',
      name: 'Station Zaghouan',
      city: 'Zaghouan',
      governorate: 'Zaghouan',
      lat: 36.4029,
      lng: 10.1429,
      address: 'Centre-ville, Zaghouan',
    ),
    Station(
      id: 'station_bizerte',
      name: 'Gare routiere de Bizerte',
      city: 'Bizerte',
      governorate: 'Bizerte',
      lat: 37.2744,
      lng: 9.8739,
      address: 'Gare routiere, Bizerte',
    ),
    Station(
      id: 'station_beja',
      name: 'Station Beja',
      city: 'Beja',
      governorate: 'Beja',
      lat: 36.7256,
      lng: 9.1817,
      address: 'Centre-ville, Beja',
    ),
    Station(
      id: 'station_jendouba',
      name: 'Station Jendouba',
      city: 'Jendouba',
      governorate: 'Jendouba',
      lat: 36.5011,
      lng: 8.7802,
      address: 'Centre-ville, Jendouba',
    ),
    Station(
      id: 'station_kef',
      name: 'Station Le Kef',
      city: 'Le Kef',
      governorate: 'Le Kef',
      lat: 36.1742,
      lng: 8.7049,
      address: 'Centre-ville, Le Kef',
    ),
    Station(
      id: 'station_siliana',
      name: 'Station Siliana',
      city: 'Siliana',
      governorate: 'Siliana',
      lat: 36.0849,
      lng: 9.3708,
      address: 'Centre-ville, Siliana',
    ),
    Station(
      id: 'station_sousse',
      name: 'Gare routiere de Sousse',
      city: 'Sousse',
      governorate: 'Sousse',
      lat: 35.8256,
      lng: 10.6369,
      address: 'Gare routiere, Sousse',
    ),
    Station(
      id: 'station_monastir',
      name: 'Station Monastir',
      city: 'Monastir',
      governorate: 'Monastir',
      lat: 35.7643,
      lng: 10.8113,
      address: 'Centre-ville, Monastir',
    ),
    Station(
      id: 'station_mahdia',
      name: 'Station Mahdia',
      city: 'Mahdia',
      governorate: 'Mahdia',
      lat: 35.5047,
      lng: 11.0622,
      address: 'Centre-ville, Mahdia',
    ),
    Station(
      id: 'station_sfax',
      name: 'Gare routiere de Sfax',
      city: 'Sfax',
      governorate: 'Sfax',
      lat: 34.7406,
      lng: 10.7603,
      address: 'Gare routiere, Sfax',
    ),
    Station(
      id: 'station_kairouan',
      name: 'Station Kairouan',
      city: 'Kairouan',
      governorate: 'Kairouan',
      lat: 35.6781,
      lng: 10.0963,
      address: 'Centre-ville, Kairouan',
    ),
    Station(
      id: 'station_kasserine',
      name: 'Station Kasserine',
      city: 'Kasserine',
      governorate: 'Kasserine',
      lat: 35.1676,
      lng: 8.8365,
      address: 'Centre-ville, Kasserine',
    ),
    Station(
      id: 'station_sidi_bouzid',
      name: 'Station Sidi Bouzid',
      city: 'Sidi Bouzid',
      governorate: 'Sidi Bouzid',
      lat: 35.0382,
      lng: 9.4849,
      address: 'Centre-ville, Sidi Bouzid',
    ),
    Station(
      id: 'station_gafsa',
      name: 'Station Gafsa',
      city: 'Gafsa',
      governorate: 'Gafsa',
      lat: 34.4250,
      lng: 8.7842,
      address: 'Centre-ville, Gafsa',
    ),
    Station(
      id: 'station_tozeur',
      name: 'Station Tozeur',
      city: 'Tozeur',
      governorate: 'Tozeur',
      lat: 33.9197,
      lng: 8.1335,
      address: 'Centre-ville, Tozeur',
    ),
    Station(
      id: 'station_kebili',
      name: 'Station Kebili',
      city: 'Kebili',
      governorate: 'Kebili',
      lat: 33.7044,
      lng: 8.9690,
      address: 'Centre-ville, Kebili',
    ),
    Station(
      id: 'station_gabes',
      name: 'Station Gabes',
      city: 'Gabes',
      governorate: 'Gabes',
      lat: 33.8815,
      lng: 10.0982,
      address: 'Centre-ville, Gabes',
    ),
    Station(
      id: 'station_medenine',
      name: 'Station Medenine',
      city: 'Medenine',
      governorate: 'Medenine',
      lat: 33.3549,
      lng: 10.5055,
      address: 'Centre-ville, Medenine',
    ),
    Station(
      id: 'station_tataouine',
      name: 'Station Tataouine',
      city: 'Tataouine',
      governorate: 'Tataouine',
      lat: 32.9297,
      lng: 10.4518,
      address: 'Centre-ville, Tataouine',
    ),
  ];
}
