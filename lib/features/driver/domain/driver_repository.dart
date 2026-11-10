import 'entities/driver_dashboard_data.dart';
import '../../../models/driver_earning.dart';

abstract interface class DriverRepository {
  Stream<DriverDashboardData> watchDashboard(String driverId);

  Stream<List<DriverEarning>> watchEarnings(String driverId);

  Future<void> toggleQueue(String louageId);
}
