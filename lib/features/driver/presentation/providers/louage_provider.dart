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
  (ref, driverId) => ref.watch(louageRepositoryProvider).watchLouage(driverId),
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

final driverLouageStatsProvider = FutureProvider.family<(double, int), String>(
  (ref, driverId) =>
      ref.watch(louageRepositoryProvider).ratingAndCompletedTrips(driverId),
);

final createDriverTripControllerProvider =
    AsyncNotifierProvider<CreateDriverTripController, Trip?>(
      CreateDriverTripController.new,
    );

class CreateDriverTripController extends AsyncNotifier<Trip?> {
  @override
  Future<Trip?> build() async => null;

  Future<Trip> createTrip({
    required String driverId,
    required String fromStationId,
    required String toStationId,
    required DateTime departureTime,
    required double pricePerSeat,
  }) async {
    state = const AsyncLoading();
    try {
      final trip = await ref
          .read(louageRepositoryProvider)
          .createTrip(
            driverId: driverId,
            fromStationId: fromStationId,
            toStationId: toStationId,
            departureTime: departureTime,
            pricePerSeat: pricePerSeat,
          );
      state = AsyncData(trip);
      ref.invalidate(driverTripsProvider(driverId));
      ref.invalidate(driverLouageProvider(driverId));
      return trip;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
