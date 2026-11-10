import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/hive_driver_repository.dart';
import '../../domain/driver_repository.dart';
import '../../domain/entities/driver_dashboard_data.dart';
import '../../../../models/driver_earning.dart';

final driverRepositoryProvider = Provider<DriverRepository>(
  (ref) => HiveDriverRepository(),
);

final driverDashboardProvider =
    StreamProvider.family<DriverDashboardData, String>(
      (ref, driverId) =>
          ref.watch(driverRepositoryProvider).watchDashboard(driverId),
    );

final driverEarningsProvider =
    StreamProvider.family<List<DriverEarning>, String>(
      (ref, driverId) =>
          ref.watch(driverRepositoryProvider).watchEarnings(driverId),
    );
