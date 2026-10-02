import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:louage_go/features/driver/data/hive_driver_repository.dart';
import 'package:louage_go/models/driver_profile.dart';
import 'package:louage_go/models/louage.dart';

void main() {
  late Directory tempDirectory;
  late Box<Map> driversBox;
  late Box<Map> louagesBox;
  late Box<Map> stationsBox;
  late Box<Map> tripsBox;
  late Box<Map> bookingsBox;
  late Box<Map> usersBox;
  late Box<Map> sessionBox;
  late HiveDriverRepository repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'louagego_driver_test',
    );
    Hive.init(tempDirectory.path);
    driversBox = await Hive.openBox<Map>('drivers');
    louagesBox = await Hive.openBox<Map>('louages');
    stationsBox = await Hive.openBox<Map>('stations');
    tripsBox = await Hive.openBox<Map>('trips');
    bookingsBox = await Hive.openBox<Map>('bookings');
    usersBox = await Hive.openBox<Map>('users');
    sessionBox = await Hive.openBox<Map>('session');
    repository = HiveDriverRepository(
      driversBox: driversBox,
      louagesBox: louagesBox,
      stationsBox: stationsBox,
      tripsBox: tripsBox,
      bookingsBox: bookingsBox,
      usersBox: usersBox,
      sessionBox: sessionBox,
    );
  });

  tearDown(() async {
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('queue state is stored on the louage', () async {
    await driversBox.put(
      'driver',
      const DriverProfile(userId: 'driver').toMap(),
    );
    await louagesBox.put(
      'vehicle',
      const Louage(id: 'vehicle', driverId: 'driver').toMap(),
    );

    await repository.toggleQueue('vehicle');

    expect(Louage.fromMap(louagesBox.get('vehicle')!).isQueued, isTrue);
    expect(sessionBox.get('driverQueue_driver'), isNull);

    await repository.toggleQueue('vehicle');

    expect(Louage.fromMap(louagesBox.get('vehicle')!).isQueued, isFalse);
  });

  test('dashboard migrates the legacy session queue state', () async {
    await driversBox.put(
      'driver',
      const DriverProfile(userId: 'driver').toMap(),
    );
    await louagesBox.put('vehicle', {
      'id': 'vehicle',
      'driverId': 'driver',
      'matricule': '',
      'capacity': 8,
      'currentStationId': '',
      'status': 'active',
    });
    await sessionBox.put('driverQueue_driver', {'joined': true});

    final dashboard = await repository.watchDashboard('driver').first;

    expect(dashboard.louage?.isQueued, isTrue);
    expect(sessionBox.get('driverQueue_driver'), isNull);
    expect(Louage.fromMap(louagesBox.get('vehicle')!).isQueued, isTrue);
  });
}
