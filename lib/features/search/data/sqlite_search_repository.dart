import 'dart:convert';

import '../../../core/database/app_database.dart';
import '../../../models/driver_profile.dart';
import '../../../models/louage.dart';
import '../../../models/route_line.dart';
import '../../../models/station.dart';
import '../../../models/trip.dart';
import '../domain/entities/governorate_stations.dart';
import '../domain/entities/louage_detail_data.dart';
import '../domain/entities/passenger_home_data.dart';
import '../domain/entities/search_route_shortcut.dart';
import '../domain/entities/trip_search_result.dart';
import '../domain/search_repository.dart';
import '../domain/trip_search_criteria.dart';

class SqliteSearchRepository implements SearchRepository {
  const SqliteSearchRepository(this._db);

  final AppDatabase _db;

  static const _watchedSearch = {
    'trips', 'routes', 'louages', 'stations', 'drivers',
  };
  static const _watchedHome = {'stations', 'routes', 'session'};
  static const _watchedStations = {'stations'};

  // ── watchPassengerHomeData ────────────────────────────────────────────────
  @override
  Stream<PassengerHomeData> watchPassengerHomeData(String? userId) =>
      _db.observer.watchQuery(
        tables: _watchedHome,
        query: () => _loadPassengerHomeData(),
      );

  Future<PassengerHomeData> _loadPassengerHomeData() async {
    final stationRows = await _db.query(
      'stations',
      where: 'city != ?',
      whereArgs: [''],
    );
    final routeRows = await _db.query(
      'routes',
      where: 'fromStationId != ? AND toStationId != ?',
      whereArgs: ['', ''],
    );
    return PassengerHomeData(
      stations: stationRows.map(Station.fromMap).toList(),
      routes: routeRows.map(RouteLine.fromMap).toList(),
      recentTrips: await _readRecentTrips(),
    );
  }

  Future<List<SearchRouteShortcut>> _readRecentTrips() async {
    final rows = await _db.query(
      'session',
      where: 'key = ?',
      whereArgs: ['lastTrips'],
      limit: 1,
    );
    if (rows.isEmpty) return const [];
    try {
      final raw = jsonDecode(rows.first['value'] as String? ?? '[]');
      if (raw is! List) return const [];
      return [
        for (final item in raw)
          if (item is Map && item['from'] is String && item['to'] is String)
            SearchRouteShortcut(
              from: item['from'] as String,
              to: item['to'] as String,
            ),
      ];
    } catch (_) {
      return const [];
    }
  }

  // ── watchStationsByGovernorate ────────────────────────────────────────────
  @override
  Stream<List<GovernorateStations>> watchStationsByGovernorate() =>
      _db.observer.watchQuery(
        tables: _watchedStations,
        query: _loadStationsByGovernorate,
      );

  Future<List<GovernorateStations>> _loadStationsByGovernorate() async {
    final rows = await _db.query('stations', where: 'id != ?', whereArgs: ['']);
    final grouped = <String, List<Station>>{};
    for (final row in rows) {
      final station = Station.fromMap(row);
      grouped.putIfAbsent(station.governorate, () => []).add(station);
    }
    final result =
        grouped.entries.map((e) {
          final stations = e.value..sort((a, b) => a.name.compareTo(b.name));
          return GovernorateStations(
            governorate: e.key,
            governorateAr: stations.first.governorateAr.isNotEmpty
                ? stations.first.governorateAr
                : e.key,
            stations: List.unmodifiable(stations),
          );
        }).toList()
          ..sort((a, b) => a.governorate.compareTo(b.governorate));
    return result;
  }

  // ── getStation ────────────────────────────────────────────────────────────
  @override
  Station? getStation(String id) => null; // synchronous — not used in hot path

  // ── searchStations ────────────────────────────────────────────────────────
  @override
  List<Station> searchStations(String query) => []; // async alternative below

  /// Async version used by the UI.
  Future<List<Station>> searchStationsAsync(String query) async {
    final rows = await _db.getAll('stations');
    final stations = rows.map(Station.fromMap).toList();
    if (query.trim().isEmpty) return stations;
    final norm = _normalize(query);
    return stations.where((s) {
      final text = _normalize(
        '${s.name} ${s.city} ${s.governorate} ${s.nameAr} ${s.cityAr} ${s.governorateAr}',
      );
      return text.contains(norm);
    }).toList();
  }

  // ── countRoutesFromStation ────────────────────────────────────────────────
  @override
  int countRoutesFromStation(String stationId) => 0; // async alternative below

  Future<int> countRoutesFromStationAsync(String stationId) async {
    final rows = await _db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM routes WHERE fromStationId = ?',
      [stationId],
    );
    return (rows.first['cnt'] as int?) ?? 0;
  }

  // ── rememberSearch ────────────────────────────────────────────────────────
  @override
  Future<void> rememberSearch(String from, String to) async {
    final existing = await _readRecentTrips();
    final filtered = existing
        .where((s) => s.from != from || s.to != to)
        .take(4)
        .toList();
    filtered.insert(0, SearchRouteShortcut(from: from, to: to));
    await _db.insert('session', {
      'key': 'lastTrips',
      'value': jsonEncode([
        for (final s in filtered) {'from': s.from, 'to': s.to},
      ]),
    });
  }

  // ── watchTripResults ──────────────────────────────────────────────────────
  @override
  Stream<List<TripSearchResult>> watchTripResults(
    TripSearchCriteria criteria,
  ) => _db.observer.watchQuery(
    tables: _watchedSearch,
    query: () async => findTrips(criteria),
  );

  // ── findTrips ─────────────────────────────────────────────────────────────
  @override
  List<TripSearchResult> findTrips(TripSearchCriteria criteria) => [];

  Future<List<TripSearchResult>> findTripsAsync(
    TripSearchCriteria criteria,
  ) async {
    // Paramétré : pas de concaténation de valeurs dans le SQL.
    final tripRows = await _db.rawQuery(
      '''
      SELECT t.*, r.*, l.*, s1.*, s2.*,
             dp.ratingAverage AS drv_avg, dp.reviewCount AS drv_cnt
      FROM trips t
      JOIN routes r ON t.routeId = r.id
      JOIN louages l ON t.louageId = l.id
      JOIN stations s1 ON r.fromStationId = s1.id
      JOIN stations s2 ON r.toStationId = s2.id
      LEFT JOIN drivers dp ON l.chauffeurId = dp.userId
      WHERE t.status IN ('waiting','full')
        AND l.statut NOT IN ('enDeplacement','horsService')
      ''',
    );

    final results = <TripSearchResult>[];
    for (final row in tripRows) {
      final trip = _tripFromJoined(row);
      final route = _routeFromJoined(row);
      final louage = _louageFromJoined(row);
      final from = _stationFrom(row, 's1_');
      final to = _stationFrom(row, 's2_');
      final departure = DateTime.tryParse(trip.departureTime);
      if (departure == null) continue;

      if (criteria.fromStationId != null
          ? from.id != criteria.fromStationId
          : from.city != criteria.from) {
        continue;
      }
      if (criteria.toStationId != null
          ? to.id != criteria.toStationId
          : to.city != criteria.to) {
        continue;
      }

      results.add(TripSearchResult(
        trip: trip,
        route: route,
        louage: louage,
        fromStation: from,
        toStation: to,
        departure: departure,
        driverRatingAverage:
            (row['drv_avg'] as num?)?.toDouble() ?? 0,
        driverReviewCount: (row['drv_cnt'] as int?) ?? 0,
      ));
    }
    return results;
  }

  // ── getLouageDetail ───────────────────────────────────────────────────────
  @override
  Future<LouageDetailData?> getLouageDetail(String tripId) async {
    final rows = await _db.rawQuery(
      '''
      SELECT t.*, r.*, l.*,
             u.name AS driver_name,
             dp.ratingAverage AS drv_avg, dp.reviewCount AS drv_cnt,
             dp.validationStatus AS drv_status,
             s1.id AS fs_id, s1.name AS fs_name, s1.city AS fs_city,
             s1.governorate AS fs_gov, s1.nameAr AS fs_nameAr,
             s1.cityAr AS fs_cityAr, s1.governorateAr AS fs_govAr,
             s1.lat AS fs_lat, s1.lng AS fs_lng, s1.address AS fs_addr,
             s2.id AS ts_id, s2.name AS ts_name, s2.city AS ts_city,
             s2.governorate AS ts_gov, s2.nameAr AS ts_nameAr,
             s2.cityAr AS ts_cityAr, s2.governorateAr AS ts_govAr,
             s2.lat AS ts_lat, s2.lng AS ts_lng, s2.address AS ts_addr
      FROM trips t
      LEFT JOIN routes r ON t.routeId = r.id
      LEFT JOIN louages l ON t.louageId = l.id
      LEFT JOIN users u ON l.chauffeurId = u.id
      LEFT JOIN drivers dp ON l.chauffeurId = dp.userId
      LEFT JOIN stations s1 ON r.fromStationId = s1.id
      LEFT JOIN stations s2 ON r.toStationId = s2.id
      WHERE t.id = ?
      ''',
      [tripId],
    );
    if (rows.isEmpty) return null;
    final row = rows.first;

    final trip = Trip.fromMap(row);
    RouteLine? route;
    Louage? louage;
    Station? from;
    Station? to;
    if ((row['routeId'] as String? ?? '').isNotEmpty) {
      route = RouteLine.fromMap(row);
    }
    if ((row['louageId'] as String? ?? '').isNotEmpty) {
      louage = Louage.fromMap(row);
    }
    if ((row['fs_id'] as String? ?? '').isNotEmpty) {
      from = Station(
        id: row['fs_id'] as String? ?? '',
        name: row['fs_name'] as String? ?? '',
        city: row['fs_city'] as String? ?? '',
        governorate: row['fs_gov'] as String? ?? '',
        nameAr: row['fs_nameAr'] as String? ?? '',
        cityAr: row['fs_cityAr'] as String? ?? '',
        governorateAr: row['fs_govAr'] as String? ?? '',
        lat: (row['fs_lat'] as num?)?.toDouble() ?? 0,
        lng: (row['fs_lng'] as num?)?.toDouble() ?? 0,
        address: row['fs_addr'] as String? ?? '',
      );
    }
    if ((row['ts_id'] as String? ?? '').isNotEmpty) {
      to = Station(
        id: row['ts_id'] as String? ?? '',
        name: row['ts_name'] as String? ?? '',
        city: row['ts_city'] as String? ?? '',
        governorate: row['ts_gov'] as String? ?? '',
        nameAr: row['ts_nameAr'] as String? ?? '',
        cityAr: row['ts_cityAr'] as String? ?? '',
        governorateAr: row['ts_govAr'] as String? ?? '',
        lat: (row['ts_lat'] as num?)?.toDouble() ?? 0,
        lng: (row['ts_lng'] as num?)?.toDouble() ?? 0,
        address: row['ts_addr'] as String? ?? '',
      );
    }

    DriverProfile? driverProfile;
    if ((row['drv_avg'] != null)) {
      driverProfile = DriverProfile(
        userId: louage?.driverId ?? '',
        ratingAverage: (row['drv_avg'] as num?)?.toDouble() ?? 0,
        reviewCount: (row['drv_cnt'] as int?) ?? 0,
        validationStatus: row['drv_status'] as String? ?? 'pending',
      );
    }

    return LouageDetailData(
      trip: trip,
      route: route,
      louage: louage,
      fromStation: from,
      toStation: to,
      driverName: row['driver_name'] as String? ?? '',
      driverProfile: driverProfile,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static Trip _tripFromJoined(Map<String, Object?> row) => Trip.fromMap(row);

  static RouteLine _routeFromJoined(Map<String, Object?> row) =>
      RouteLine.fromMap(row);

  static Louage _louageFromJoined(Map<String, Object?> row) =>
      Louage.fromMap(row);

  static Station _stationFrom(Map<String, Object?> row, String prefix) {
    // With JOIN, columns are ambiguous — SQLite returns last one with same name.
    // We rely on the JOINED naming convention (s1.*, s2.*) which works for
    // simple column names when tables don't share names.
    // For the detail query, we use explicit aliases (fs_*, ts_*).
    return Station.fromMap(row);
  }

  static String _normalize(String value) {
    const latin = {
      'à': 'a', 'á': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a',
      'ç': 'c', 'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
      'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', 'ñ': 'n',
      'ò': 'o', 'ó': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o',
      'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
      'ý': 'y', 'ÿ': 'y', 'œ': 'oe', 'æ': 'ae',
    };
    final buf = StringBuffer();
    for (final rune in value.toLowerCase().runes) {
      final char = String.fromCharCode(rune);
      if (rune == 0x0640 ||
          (rune >= 0x0300 && rune <= 0x036F) ||
          (rune >= 0x064B && rune <= 0x065F) ||
          rune == 0x0670) {
        continue;
      }
      buf.write(latin[char] ?? switch (rune) {
        0x0622 || 0x0623 || 0x0625 || 0x0671 => 'ا',
        0x0649 => 'ي',
        0x0629 => 'ه',
        _ => char,
      });
    }
    return buf.toString();
  }
}
