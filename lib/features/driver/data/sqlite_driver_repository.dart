import '../../../core/database/app_database.dart';
import '../../../models/booking.dart';
import '../../../models/driver_earning.dart';
import '../../../models/driver_profile.dart';
import '../../../models/louage.dart';
import '../../../models/station.dart';
import '../../../models/trip.dart';
import '../domain/driver_repository.dart';
import '../domain/entities/driver_dashboard_data.dart';
import '../domain/entities/driver_passenger.dart';

class SqliteDriverRepository implements DriverRepository {
  SqliteDriverRepository(this._db);

  final AppDatabase _db;

  static const _watchedDashboard = {
    'drivers', 'louages', 'stations', 'trips', 'bookings', 'users',
  };
  static const _watchedEarnings = {'earnings', 'louages', 'trips'};

  // ── watchDashboard ────────────────────────────────────────────────────────
  @override
  Stream<DriverDashboardData> watchDashboard(String driverId) =>
      _db.observer.watchQuery(
        tables: _watchedDashboard,
        query: () => _loadDashboard(driverId),
      );

  Future<DriverDashboardData> _loadDashboard(String driverId) async {
    // Driver profile.
    final profileRows = await _db.query(
      'drivers',
      where: 'userId = ?',
      whereArgs: [driverId],
      limit: 1,
    );
    final profile = profileRows.isEmpty
        ? DriverProfile(userId: driverId)
        : DriverProfile.fromMap(profileRows.first);

    // Louage (by driverId or matricule).
    final louageRows = await _db.query(
      'louages',
      where: 'chauffeurId = ?',
      whereArgs: [driverId],
      limit: 1,
    );
    final Louage? louage = louageRows.isEmpty
        ? null
        : Louage.fromMap(louageRows.first);

    // Current station.
    Station? station;
    if (louage != null && louage.currentStationId.isNotEmpty) {
      final stRows = await _db.query(
        'stations',
        where: 'id = ?',
        whereArgs: [louage.currentStationId],
        limit: 1,
      );
      if (stRows.isNotEmpty) station = Station.fromMap(stRows.first);
    }

    // Trips.
    final tripRows = louage == null
        ? <Map<String, Object?>>[]
        : await _db.query(
            'trips',
            where: 'louageId = ?',
            whereArgs: [louage.id],
            orderBy: 'departureTime ASC',
          );
    final trips = tripRows.map(Trip.fromMap).toList();

    // Bookings for these trips.
    final tripIds = trips.map((t) => t.id).toList();
    List<Booking> bookings = const [];
    if (tripIds.isNotEmpty) {
      final placeholders = List.filled(tripIds.length, '?').join(',');
      final bRows = await _db.rawQuery(
        '''SELECT * FROM bookings
           WHERE tripId IN ($placeholders)
             AND status NOT IN ('cancelled','rejected')''',
        tripIds,
      );
      bookings = bRows.map(Booking.fromMap).toList();
    }

    // Passengers map.
    final userRows = await _db.getAll('users');
    final passengers = <String, DriverPassenger>{
      for (final row in userRows)
        (row['id'] as String? ?? ''): DriverPassenger(
          id: row['id'] as String? ?? '',
          name: row['name'] as String? ?? '',
          phone: row['phone'] as String? ?? '',
        ),
    };

    return DriverDashboardData(
      profile: profile,
      louage: louage,
      station: station,
      trips: trips,
      bookings: bookings,
      passengers: passengers,
    );
  }

  // ── watchEarnings ─────────────────────────────────────────────────────────
  @override
  Stream<List<DriverEarning>> watchEarnings(String driverId) =>
      _db.observer.watchQuery(
        tables: _watchedEarnings,
        query: () => _loadEarnings(driverId),
      );

  Future<List<DriverEarning>> _loadEarnings(String driverId) async {
    final rows = await _db.rawQuery(
      '''SELECT e.* FROM earnings e
         JOIN trips t ON e.tripId = t.id
         JOIN louages l ON t.louageId = l.id
         WHERE e.driverId = ? AND l.chauffeurId = ?
         ORDER BY e.createdAt DESC''',
      [driverId, driverId],
    );
    return rows.map((row) => DriverEarning.fromMap(_fixEarningRow(row))).toList();
  }

  // ── toggleQueue ───────────────────────────────────────────────────────────
  @override
  Future<void> toggleQueue(String louageId) async {
    final rows = await _db.query(
      'louages',
      where: 'id = ?',
      whereArgs: [louageId],
      limit: 1,
    );
    if (rows.isEmpty) return;
    final louage = Louage.fromMap(rows.first);
    await _db.update(
      'louages',
      {'isQueued': louage.isQueued ? 0 : 1},
      where: 'id = ?',
      whereArgs: [louageId],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// earnings table uses `createdAt` but DriverEarning.fromMap reads `earnedAt`.
  static Map<String, Object?> _fixEarningRow(Map<String, Object?> row) {
    final m = Map<String, Object?>.from(row);
    if (!m.containsKey('earnedAt') && m.containsKey('createdAt')) {
      m['earnedAt'] = m['createdAt'];
    }
    return m;
  }
}

// Re-export DriverBooking for use by louage_provider that accesses it.
export '../domain/entities/driver_booking.dart';
