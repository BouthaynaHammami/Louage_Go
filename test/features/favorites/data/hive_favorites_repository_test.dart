import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:louage_go/features/favorites/data/hive_favorites_repository.dart';
import 'package:louage_go/models/favorite.dart';
import 'package:louage_go/models/louage.dart';
import 'package:louage_go/models/route_line.dart';
import 'package:louage_go/models/station.dart';
import 'package:louage_go/models/trip.dart';

void main() {
  late Directory tempDirectory;
  late Box<Map> favoritesBox;
  late Box<Map> routesBox;
  late Box<Map> stationsBox;
  late Box<Map> louagesBox;
  late Box<Map> tripsBox;
  late HiveFavoritesRepository repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('louage_favorites');
    Hive.init(tempDirectory.path);
    favoritesBox = await Hive.openBox<Map>('favorites');
    routesBox = await Hive.openBox<Map>('routes');
    stationsBox = await Hive.openBox<Map>('stations');
    louagesBox = await Hive.openBox<Map>('louages');
    tripsBox = await Hive.openBox<Map>('trips');
    repository = HiveFavoritesRepository(
      favoritesBox: favoritesBox,
      routesBox: routesBox,
      stationsBox: stationsBox,
      louagesBox: louagesBox,
      tripsBox: tripsBox,
    );
    await stationsBox.putAll({
      'from': const Station(id: 'from', city: 'Tunis').toMap(),
      'to': const Station(id: 'to', city: 'Sousse').toMap(),
    });
    await routesBox.put(
      'route-1',
      const RouteLine(
        id: 'route-1',
        fromStationId: 'from',
        toStationId: 'to',
      ).toMap(),
    );
  });

  tearDown(() async {
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('toggle stores one deterministic record and toggles it off', () async {
    await repository.toggleRoute('user-1', 'route-1');

    expect(favoritesBox.length, 1);
    expect(favoritesBox.keys.single, 'user-1_route_route-1');
    expect(repository.isFavorite('user-1', 'route-1'), isTrue);

    await repository.toggleRoute('user-1', 'route-1');
    expect(favoritesBox, isEmpty);
  });

  test('favorites are isolated by user and reference type', () async {
    await repository.toggleRoute('user-1', 'route-1');
    await repository.toggleStation('user-1', 'from');

    expect(repository.isFavorite('user-1', 'route-1'), isTrue);
    expect(repository.isFavorite('user-2', 'route-1'), isFalse);
    expect(repository.isFavorite('user-1', 'from', type: 'station'), isTrue);
    expect(repository.isFavorite('user-1', 'from'), isFalse);
  });

  test('legacy favorites without type are routes', () async {
    await favoritesBox.put('legacy-key', {
      'id': 'legacy-key',
      'userId': 'user-1',
      'routeId': 'route-1',
      'createdAt': DateTime(2026).toIso8601String(),
    });

    expect(Favorite.fromMap(favoritesBox.get('legacy-key')!).type, 'route');
    expect(repository.isFavorite('user-1', 'route-1'), isTrue);
    final favorites = repository.watchFavorites('user-1').first;
    expect((await favorites).routes.single.favorite.routeId, 'route-1');
  });

  test('legacy and deterministic duplicates remain one entry and toggle off together', () async {
    final legacy = Favorite(
      id: 'legacy-key',
      userId: 'user-1',
      routeId: 'route-1',
      createdAt: DateTime(2026).toIso8601String(),
    ).toMap()..remove('type');
    await favoritesBox.put('legacy-key', legacy);
    await favoritesBox.put(
      'user-1_route_route-1',
      Favorite(
        id: 'user-1_route_route-1',
        userId: 'user-1',
        routeId: 'route-1',
        type: 'route',
      ).toMap(),
    );

    final data = await repository.watchFavorites('user-1').first;
    expect(data.routes, hasLength(1));
    expect(favoritesBox.length, 2);

    await repository.toggleRoute('user-1', 'route-1');
    expect(favoritesBox, isEmpty);
  });

  test('offers use a deterministic key and separate departure times', () async {
    await louagesBox.put(
      'louage-1',
      const Louage(id: 'louage-1', matricule: '122 TUN 7014').toMap(),
    );

    await repository.toggleOffer('user-1', 'louage-1', '7:15', 'route-1');
    expect(favoritesBox.length, 1);
    await repository.toggleOffer('user-1', 'louage-1', '08:15', 'route-1');

    expect(favoritesBox.length, 2);
    expect(
      favoritesBox.keys,
      containsAll(['user-1_offer_louage-1_0715', 'user-1_offer_louage-1_0815']),
    );
    expect(repository.isOfferFavorite('user-1', 'louage-1', '07:15'), isTrue);
    expect(repository.isOfferFavorite('user-2', 'louage-1', '07:15'), isFalse);
    expect(
      Favorite.fromMap(favoritesBox.get('user-1_offer_louage-1_0715')!)
          .matricule,
      '122 TUN 7014',
    );
  });

  test(
    'offer nextTrip skips a departure that has already passed today',
    () async {
      final now = DateTime.now();
      final todayAtMidnight = DateTime(now.year, now.month, now.day);
      final todayPast = todayAtMidnight;
      final tomorrow = todayPast.add(const Duration(days: 1));
      const time = '00:00';
      await louagesBox.put(
        'louage-1',
        const Louage(id: 'louage-1', matricule: '122 TUN 7014').toMap(),
      );
      await tripsBox.put(
        'past-trip',
        Trip(
          id: 'past-trip',
          louageId: 'louage-1',
          routeId: 'route-1',
          departureTime: todayPast.toIso8601String(),
        ).toMap(),
      );
      await tripsBox.put(
        'tomorrow-trip',
        Trip(
          id: 'tomorrow-trip',
          louageId: 'louage-1',
          routeId: 'route-1',
          departureTime: tomorrow.toIso8601String(),
        ).toMap(),
      );
      await repository.toggleOffer('user-1', 'louage-1', time, 'route-1');

      final data = await repository.watchFavorites('user-1').first;
      expect(data.offers.single.nextTrip?.id, 'tomorrow-trip');
    },
  );

  test('offer favorites are isolated per user', () async {
    await louagesBox.put('louage-1', const Louage(id: 'louage-1').toMap());
    await repository.toggleOffer('user-1', 'louage-1', '07:15', 'route-1');

    expect(repository.isOfferFavorite('user-1', 'louage-1', '07:15'), isTrue);
    expect(repository.isOfferFavorite('user-2', 'louage-1', '07:15'), isFalse);
  });
}
