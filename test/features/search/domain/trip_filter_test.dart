import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:louage_go/features/search/domain/entities/trip_search_result.dart';
import 'package:louage_go/features/search/domain/trip_filter.dart';
import 'package:louage_go/models/louage.dart';
import 'package:louage_go/models/route_line.dart';
import 'package:louage_go/models/station.dart';
import 'package:louage_go/models/trip.dart';

void main() {
  final day = DateTime(2026, 4, 10);

  TripSearchResult result({
    required String id,
    required int hour,
    required double price,
    int freeSeats = 4,
    String status = 'waiting',
  }) => TripSearchResult(
    trip: Trip(
      id: id,
      totalSeats: 8,
      reservedSeats: 8 - freeSeats,
      status: status,
    ),
    route: RouteLine(id: 'route-$id', pricePerSeat: price),
    louage: const Louage(),
    fromStation: const Station(),
    toStation: const Station(),
    departure: DateTime(day.year, day.month, day.day, hour),
  );

  test('combines date, price, seats, full-trip and time filters', () {
    final valid = result(id: 'valid', hour: 10, price: 20, freeSeats: 3);
    final results = [
      valid,
      result(id: 'too-expensive', hour: 10, price: 30),
      result(id: 'too-few-seats', hour: 10, price: 20, freeSeats: 1),
      result(id: 'full', hour: 10, price: 20, freeSeats: 0, status: 'full'),
      result(id: 'too-early', hour: 7, price: 20),
      result(id: 'cancelled', hour: 10, price: 20, status: 'cancelled'),
      TripSearchResult(
        trip: const Trip(totalSeats: 8),
        route: const RouteLine(pricePerSeat: 20),
        louage: const Louage(),
        fromStation: const Station(),
        toStation: const Station(),
        departure: day.add(const Duration(days: 1, hours: 10)),
      ),
    ];

    final filtered = filterTripResults(
      results,
      TripFilterOptions(
        selectedDate: day,
        maximumPrice: 25,
        minimumSeats: 2,
        timeRange: const RangeValues(9 * 60, 12 * 60),
        hideFull: true,
      ),
    );

    expect(filtered.map((item) => item.trip.id), ['valid']);
  });
}
