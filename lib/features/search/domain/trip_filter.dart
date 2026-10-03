import 'package:flutter/material.dart';

import 'entities/trip_search_result.dart';

enum TripSortMode { time, price, seats }

class TripFilterOptions {
  const TripFilterOptions({
    required this.selectedDate,
    this.maximumPrice,
    this.minimumSeats = 1,
    this.timeRange = const RangeValues(0, 1440),
    this.hideFull = false,
    this.sortMode = TripSortMode.time,
  });

  final DateTime selectedDate;
  final double? maximumPrice;
  final int minimumSeats;
  final RangeValues timeRange;
  final bool hideFull;
  final TripSortMode sortMode;
}

List<TripSearchResult> filterTripResults(
  Iterable<TripSearchResult> results,
  TripFilterOptions options,
) {
  final day = DateUtils.dateOnly(options.selectedDate);
  final visible = results.where((result) {
    final departure = result.departure;
    final sameDay =
        departure.year == day.year &&
        departure.month == day.month &&
        departure.day == day.day;
    final minute = departure.hour * 60 + departure.minute;
    return sameDay &&
        result.trip.status != 'cancelled' &&
        (options.maximumPrice == null ||
            result.price <= options.maximumPrice!) &&
        result.freeSeats >= options.minimumSeats &&
        (!options.hideFull || !result.isFull) &&
        minute >= options.timeRange.start &&
        minute <= options.timeRange.end;
  }).toList();

  switch (options.sortMode) {
    case TripSortMode.time:
      visible.sort((a, b) => a.departure.compareTo(b.departure));
    case TripSortMode.price:
      visible.sort((a, b) => a.price.compareTo(b.price));
    case TripSortMode.seats:
      visible.sort((a, b) => b.freeSeats.compareTo(a.freeSeats));
  }
  return visible;
}
