import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/hive_driver_repository.dart';
import '../../domain/driver_repository.dart';
import '../../domain/entities/driver_dashboard_data.dart';

final driverRepositoryProvider = Provider<DriverRepository>(
  (ref) => HiveDriverRepository(),
);

final driverDashboardProvider =
    StreamProvider.family<DriverDashboardData, String>(
      (ref, driverId) =>
          ref.watch(driverRepositoryProvider).watchDashboard(driverId),
    );
