// Comptes de démonstration :
// Admin : admin@louagego.tn / Admin123!
// Chauffeur : chauffeur@louagego.tn / Driver123!
// Passager : passager@louagego.tn / Passenger123!
import 'package:hive_ce/hive.dart';

import '../app_config.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import '../../models/app_user.dart';
import '../../models/booking.dart';
import '../../models/driver_profile.dart';
import '../../models/louage.dart';
import '../../models/route_line.dart';
import '../../models/station.dart';
import '../../models/trip.dart';
import 'hive_service.dart';

class SeedData {
  static const _seedVersion = 2;
  static const _seedVersionKey = 'seedVersion';

  static Future<void> runIfNeeded() => _run(
    stationsBox: HiveService.stations,
    usersBox: HiveService.users,
    driversBox: HiveService.drivers,
    routesBox: HiveService.routes,
    louagesBox: HiveService.louages,
    tripsBox: HiveService.trips,
    bookingsBox: HiveService.bookings,
    sessionBox: HiveService.session,
    now: DateTime.now(),
  );

  static Future<void> seedForTesting({
    required Box<Map> stationsBox,
    required Box<Map> usersBox,
    required Box<Map> driversBox,
    required Box<Map> routesBox,
    required Box<Map> louagesBox,
    required Box<Map> tripsBox,
    required Box<Map> sessionBox,
    required DateTime now,
    Box<Map>? bookingsBox,
  }) => _run(
    stationsBox: stationsBox,
    usersBox: usersBox,
    driversBox: driversBox,
    routesBox: routesBox,
    louagesBox: louagesBox,
    tripsBox: tripsBox,
    bookingsBox: bookingsBox,
    sessionBox: sessionBox,
    now: now,
  );

  static Future<void> _run({
    required Box<Map> stationsBox,
    required Box<Map> usersBox,
    required Box<Map> driversBox,
    required Box<Map> routesBox,
    required Box<Map> louagesBox,
    required Box<Map> tripsBox,
    required Box<Map>? bookingsBox,
    required Box<Map> sessionBox,
    required DateTime now,
  }) async {
    for (final station in _stations) {
      await stationsBox.put(station.id, station.toMap());
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
      if (!usersBox.containsKey(user.id)) {
        await usersBox.put(user.id, user.toMap());
      } else {
        final existing = AppUser.fromMap(usersBox.get(user.id)!);
        if (existing.email == user.email &&
            existing.acceptedTermsVersion.isEmpty) {
          await usersBox.put(
            user.id,
            existing
                .copyWith(
                  acceptedTermsVersion: AppConfig.legalVersion,
                  acceptedTermsAt: now.toIso8601String(),
                )
                .toMap(),
          );
        }
      }
    }

    final routes = <RouteLine>[];
    for (final (from, to, price, distance, duration) in _routeSpecs) {
      final canonicalFromId = 'station_$from';
      final canonicalToId = 'station_$to';
      final canonicalFrom = stationsBox.get(canonicalFromId);
      final canonicalTo = stationsBox.get(canonicalToId);
      if (canonicalFrom == null || canonicalTo == null) {
        throw StateError('Seed route $from-$to references a missing station.');
      }
      final fromCity = Station.fromMap(canonicalFrom).city;
      final toCity = Station.fromMap(canonicalTo).city;
      final fromStations =
          _stations.where((station) => station.city == fromCity).toList()
            ..sort((a, b) => a.id.compareTo(b.id));
      final toStations =
          _stations.where((station) => station.city == toCity).toList()
            ..sort((a, b) => a.id.compareTo(b.id));
      for (final fromStation in fromStations) {
        for (final toStation in toStations) {
          final isCanonical =
              fromStation.id == canonicalFromId &&
              toStation.id == canonicalToId;
          final route = RouteLine(
            id: isCanonical
                ? '${from}_$to'
                : 'alternate_${fromStation.id}_${toStation.id}',
            fromStationId: fromStation.id,
            toStationId: toStation.id,
            pricePerSeat: price,
            distanceKm: distance,
            durationMin: duration,
          );
          routes.add(route);
          await routesBox.put(route.id, route.toMap());
        }
      }
    }

    var vehicleNumber = 0;
    var driverMatricule = '';
    for (var routeIndex = 0; routeIndex < routes.length; routeIndex++) {
      final route = routes[routeIndex];
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
          currentStationId: route.fromStationId,
          status: 'active',
        );
        if (!louagesBox.containsKey(louage.id)) {
          await louagesBox.put(louage.id, louage.toMap());
        }

        for (var dayOffset = 0; dayOffset < 7; dayOffset++) {
          final serviceDay = DateTime(now.year, now.month, now.day + dayOffset);
          final departure = _departure(serviceDay, _departureTimes[timeIndex]);
          final id = '${_dateKey(serviceDay)}_${route.id}_${timeIndex + 1}';
          if (tripsBox.containsKey(id)) continue;
          // Démonstration : les réservations existantes ne sont jamais remplacées.
          final reservedSeats =
              _reservedSeatCounts[(routeIndex + timeIndex + dayOffset) %
                  _reservedSeatCounts.length];
          final trip = Trip(
            id: id,
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
          if (!tripsBox.containsKey(trip.id)) {
            if (!tripsBox.containsKey(trip.id)) {
              await tripsBox.put(trip.id, trip.toMap());
            }
          }
        }
      }
    }

    if (!driversBox.containsKey(driver.id)) {
      await driversBox.put(
        driver.id,
        DriverProfile(
          userId: driver.id,
          licenseNo: 'TN-PERMIT-2026-001',
          carteGrise: 'TN-CG-2026-001',
          assurance: 'TN-ASSURANCE-2026-001',
          matricule: driverMatricule,
          validationStatus: 'approved',
          ratingAverage: 0,
          reviewCount: 0,
        ).toMap(),
      );
    }
    if (bookingsBox != null) {
      for (var index = 1; index <= 2; index++) {
        final tripId = 'demo_review_trip_$index';
        final departure = now.subtract(Duration(days: index, hours: 4));
        final trip = Trip(
          id: tripId,
          louageId: 'tunis_sfax_01',
          routeId: 'tunis_sfax',
          totalSeats: 8,
          reservedSeats: 2,
          status: 'arrived',
          departureTime: departure.toIso8601String(),
          arrivalTime: departure
              .add(const Duration(hours: 3))
              .toIso8601String(),
        );
        if (!tripsBox.containsKey(trip.id)) {
          await tripsBox.put(trip.id, trip.toMap());
        }
        final booking = Booking(
          id: 'demo_review_booking_$index',
          userId: passenger.id,
          tripId: trip.id,
          seats: 1,
          totalPrice: 18,
          status: 'confirmed',
          createdAt: departure
              .subtract(const Duration(days: 1))
              .toIso8601String(),
        );
        if (!bookingsBox.containsKey(booking.id)) {
          await bookingsBox.put(booking.id, booking.toMap());
        }
      }
    }
    await sessionBox.put(_seedVersionKey, {'value': _seedVersion});
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
      phoneVerified: true,
      acceptedTermsVersion: AppConfig.legalVersion,
      acceptedTermsAt: createdAt.toIso8601String(),
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

  // Valeurs démo : prix, distances et durées à valider sur le terrain.
  static const _routeSpecs = <(String, String, double, double, int)>[
    ('tunis', 'sfax', 18, 270, 210),
    ('sfax', 'tunis', 18, 270, 210),
    ('tunis', 'sousse', 10, 143, 110),
    ('sousse', 'tunis', 10, 143, 110),
    ('tunis', 'monastir', 12, 165, 130),
    ('monastir', 'tunis', 12, 165, 130),
    ('tunis', 'mahdia', 14, 200, 155),
    ('mahdia', 'tunis', 14, 200, 155),
    ('tunis', 'kairouan', 12, 160, 130),
    ('kairouan', 'tunis', 12, 160, 130),
    ('tunis', 'gabes', 23, 400, 300),
    ('gabes', 'tunis', 23, 400, 300),
    ('tunis', 'gafsa', 22, 360, 285),
    ('gafsa', 'tunis', 22, 360, 285),
    ('tunis', 'medenine', 27, 480, 360),
    ('medenine', 'tunis', 27, 480, 360),
    ('tunis', 'tozeur', 27, 450, 350),
    ('tozeur', 'tunis', 27, 450, 350),
    ('tunis', 'beja', 10, 110, 105),
    ('beja', 'tunis', 10, 110, 105),
    ('tunis', 'jendouba', 13, 155, 145),
    ('jendouba', 'tunis', 13, 155, 145),
    ('tunis', 'kef', 15, 175, 165),
    ('kef', 'tunis', 15, 175, 165),
    ('tunis', 'kasserine', 20, 290, 250),
    ('kasserine', 'tunis', 20, 290, 250),
    ('tunis', 'sidi_bouzid', 18, 260, 225),
    ('sidi_bouzid', 'tunis', 18, 260, 225),
    ('tunis', 'nabeul', 7, 65, 70),
    ('nabeul', 'tunis', 7, 65, 70),
    ('tunis', 'bizerte', 6, 65, 75),
    ('bizerte', 'tunis', 6, 65, 75),
    ('tunis', 'zaghouan', 5, 55, 60),
    ('zaghouan', 'tunis', 5, 55, 60),
  ];

  // Coordonnées approximatives : à valider sur le terrain.
  static final _stations = <Station>[
    for (final station in _stationsFrench)
      station.copyWith(
        nameAr: _arabic[station.city]!.name,
        cityAr: _arabic[station.city]!.city,
        governorateAr: _arabic[station.governorate]!.city,
      ),
    const Station(
      id: 'station_tunis_bab_saadoun',
      name: 'Station Bab Saadoun',
      city: 'Tunis',
      governorate: 'Tunis',
      nameAr: 'محطة باب سعدون',
      cityAr: 'تونس',
      governorateAr: 'تونس',
      lat: 36.8065,
      lng: 10.1512,
      address: 'Bab Saadoun, Tunis',
    ),
    const Station(
      id: 'station_tunis_bardo',
      name: 'Station Le Bardo',
      city: 'Tunis',
      governorate: 'Tunis',
      nameAr: 'محطة باردو',
      cityAr: 'تونس',
      governorateAr: 'تونس',
      lat: 36.8098,
      lng: 10.1403,
      address: 'Le Bardo, Tunis',
    ),
    const Station(
      id: 'station_sfax_centre',
      name: 'Station Sfax Centre',
      city: 'Sfax',
      governorate: 'Sfax',
      nameAr: 'محطة صفاقس وسط المدينة',
      cityAr: 'صفاقس',
      governorateAr: 'صفاقس',
      lat: 34.7396,
      lng: 10.7603,
      address: 'Centre-ville, Sfax',
    ),
    const Station(
      id: 'station_sfax_sakiet',
      name: 'Station Sakiet Ezzit',
      city: 'Sfax',
      governorate: 'Sfax',
      nameAr: 'محطة ساقية الزيت',
      cityAr: 'صفاقس',
      governorateAr: 'صفاقس',
      lat: 34.7952,
      lng: 10.7661,
      address: 'Sakiet Ezzit, Sfax',
    ),
    const Station(
      id: 'station_sousse_khezama',
      name: 'Station Khezama',
      city: 'Sousse',
      governorate: 'Sousse',
      nameAr: 'محطة خزامة',
      cityAr: 'سوسة',
      governorateAr: 'سوسة',
      lat: 35.8518,
      lng: 10.6123,
      address: 'Khezama, Sousse',
    ),
    const Station(
      id: 'station_sousse_hammam_sousse',
      name: 'Station Hammam Sousse',
      city: 'Sousse',
      governorate: 'Sousse',
      nameAr: 'محطة حمام سوسة',
      cityAr: 'سوسة',
      governorateAr: 'سوسة',
      lat: 35.8627,
      lng: 10.6034,
      address: 'Hammam Sousse',
    ),
  ];

  static const _arabic = <String, ({String city, String name})>{
    'Tunis': (city: 'تونس', name: 'محطة مونصف باي'),
    'Ariana': (city: 'أريانة', name: 'محطة أريانة'),
    'Ben Arous': (city: 'بن عروس', name: 'محطة بن عروس'),
    'Manouba': (city: 'منوبة', name: 'محطة منوبة'),
    'Nabeul': (city: 'نابل', name: 'محطة نابل'),
    'Zaghouan': (city: 'زغوان', name: 'محطة زغوان'),
    'Bizerte': (city: 'بنزرت', name: 'محطة بنزرت'),
    'Beja': (city: 'باجة', name: 'محطة باجة'),
    'Jendouba': (city: 'جندوبة', name: 'محطة جندوبة'),
    'Le Kef': (city: 'الكاف', name: 'محطة الكاف'),
    'Siliana': (city: 'سليانة', name: 'محطة سليانة'),
    'Sousse': (city: 'سوسة', name: 'محطة سوسة'),
    'Monastir': (city: 'المنستير', name: 'محطة المنستير'),
    'Mahdia': (city: 'المهدية', name: 'محطة المهدية'),
    'Sfax': (city: 'صفاقس', name: 'محطة صفاقس'),
    'Kairouan': (city: 'القيروان', name: 'محطة القيروان'),
    'Kasserine': (city: 'القصرين', name: 'محطة القصرين'),
    'Sidi Bouzid': (city: 'سيدي بوزيد', name: 'محطة سيدي بوزيد'),
    'Gafsa': (city: 'قفصة', name: 'محطة قفصة'),
    'Tozeur': (city: 'توزر', name: 'محطة توزر'),
    'Kebili': (city: 'قبلي', name: 'محطة قبلي'),
    'Gabes': (city: 'قابس', name: 'محطة قابس'),
    'Medenine': (city: 'مدنين', name: 'محطة مدنين'),
    'Tataouine': (city: 'تطاوين', name: 'محطة تطاوين'),
  };

  static const _stationsFrench = <Station>[
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
