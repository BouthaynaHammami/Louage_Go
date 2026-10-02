import 'entities/driver_dashboard_data.dart';

abstract interface class DriverRepository {
  Stream<DriverDashboardData> watchDashboard(String driverId);

  Future<void> toggleQueue(String louageId);
}
