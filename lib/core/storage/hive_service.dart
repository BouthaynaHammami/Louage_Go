import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class BoxNames {
  static const users = 'users';
  static const drivers = 'drivers';
  static const stations = 'stations';
  static const routes = 'routes';
  static const louages = 'louages';
  static const trips = 'trips';
  static const bookings = 'bookings';
  static const payments = 'payments';
  static const reviews = 'reviews';
  static const reports = 'reports';
  static const notifications = 'notifications';
  static const favorites = 'favorites';
  static const session = 'session';

  static const values = [
    users,
    drivers,
    stations,
    routes,
    louages,
    trips,
    bookings,
    payments,
    reviews,
    reports,
    notifications,
    favorites,
    session,
  ];
}

class HiveService {
  static final Map<String, Box<Map>> _boxes = {};
  static String? initializationError;

  static Box<Map> get users => _box(BoxNames.users);
  static Box<Map> get drivers => _box(BoxNames.drivers);
  static Box<Map> get stations => _box(BoxNames.stations);
  static Box<Map> get routes => _box(BoxNames.routes);
  static Box<Map> get louages => _box(BoxNames.louages);
  static Box<Map> get trips => _box(BoxNames.trips);
  static Box<Map> get bookings => _box(BoxNames.bookings);
  static Box<Map> get payments => _box(BoxNames.payments);
  static Box<Map> get reviews => _box(BoxNames.reviews);
  static Box<Map> get reports => _box(BoxNames.reports);
  static Box<Map> get notifications => _box(BoxNames.notifications);
  static Box<Map> get favorites => _box(BoxNames.favorites);
  static Box<Map> get session => _box(BoxNames.session);

  static bool get isReady => initializationError == null;

  static Future<void> init() async {
    initializationError = null;
    try {
      await Hive.initFlutter();
    } catch (error) {
      initializationError = 'hive-init: $error';
      debugPrint(initializationError);
      return;
    }

    final failures = <String>[];
    for (final name in BoxNames.values) {
      try {
        _boxes[name] = await Hive.openBox<Map>(name);
      } catch (error) {
        failures.add('$name : $error');
      }
    }

    if (failures.isNotEmpty) {
      initializationError = 'hive-open-box: ${failures.join('; ')}';
      debugPrint(initializationError);
    }
  }

  static Future<void> clearAll() async {
    for (final box in _boxes.values) {
      await box.clear();
    }
  }

  static Box<Map> _box(String name) {
    final box = _boxes[name];
    if (box == null || !box.isOpen) {
      throw StateError('La box Hive "$name" n’est pas disponible.');
    }
    return box;
  }
}
