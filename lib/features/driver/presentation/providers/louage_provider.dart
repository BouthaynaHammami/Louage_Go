import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/hive_louage_repository.dart';
import '../../domain/entities/driver_booking.dart';
import '../../domain/louage_repository.dart';
import '../../../../models/booking.dart';
import '../../../../models/louage.dart';
import '../../../../models/trip.dart';

final louageRepositoryProvider = Provider<LouageRepository>(
  (ref) => HiveLouageRepository(),
);

final driverLouageProvider = StreamProvider.family<Louage?, String>(
  (ref, driverId) =>
      ref.watch(louageRepositoryProvider).watchLouage(driverId),
);

final driverTripsProvider = StreamProvider.family<List<Trip>, String>(
  (ref, driverId) => ref.watch(louageRepositoryProvider).watchTrips(driverId),
);

final driverTripBookingsProvider =
    StreamProvider.family<List<DriverBooking>, String>(
      (ref, tripId) =>
          ref.watch(louageRepositoryProvider).watchBookings(tripId),
    );

final driverBookingsProvider = StreamProvider.family<List<Booking>, String>(
  (ref, driverId) =>
      ref.watch(louageRepositoryProvider).watchDriverBookings(driverId),
);

final driverLouageStatsProvider =
    FutureProvider.family<(double, int), String>(
      (ref, driverId) => ref
          .watch(louageRepositoryProvider)
          .ratingAndCompletedTrips(driverId),
    );
