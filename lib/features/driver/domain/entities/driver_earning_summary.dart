import '../../../../models/booking.dart';
import '../../../../models/driver_earning.dart';

class DriverEarningSummary {
  final List<DriverEarning> earnings;

  const DriverEarningSummary(this.earnings);

  factory DriverEarningSummary.withLegacyBookings(
    List<DriverEarning> earnings,
    List<Booking> bookings, {
    required String driverId,
    Map<String, String> passengerNames = const {},
  }) {
    final bookingIds = earnings.map((earning) => earning.bookingId).toSet();
    final legacy = bookings
        .where(
          (booking) =>
              booking.status == 'validated' &&
              !bookingIds.contains(booking.id) &&
              DateTime.tryParse(booking.createdAt) != null,
        )
        .map(
          (booking) => DriverEarning(
            id: 'legacy_${booking.id}',
            driverId: driverId,
            bookingId: booking.id,
            tripId: booking.tripId,
            amount: booking.totalPrice,
            earnedAt: booking.createdAt,
            method: booking.paymentMethod,
            passengerName: passengerNames[booking.userId] ?? booking.userId,
            fromCity: booking.fromCity,
            toCity: booking.toCity,
          ),
        );
    return DriverEarningSummary([...earnings, ...legacy]);
  }

  double get total =>
      earnings.fold<double>(0, (sum, earning) => sum + earning.amount);

  double forDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return _between(start, end);
  }

  double forWeek(DateTime date) {
    final start = DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: date.weekday - DateTime.monday));
    return _between(start, start.add(const Duration(days: 7)));
  }

  double forMonth(DateTime date) {
    final start = DateTime(date.year, date.month);
    return _between(start, DateTime(date.year, date.month + 1));
  }

  int countForMonth(DateTime date) {
    final start = DateTime(date.year, date.month);
    final end = DateTime(date.year, date.month + 1);
    return earnings.where((earning) {
      final earnedAt = DateTime.tryParse(earning.earnedAt);
      return earnedAt != null &&
          !earnedAt.isBefore(start) &&
          earnedAt.isBefore(end);
    }).length;
  }

  List<double> dailyTotals(DateTime now, int days) {
    final today = DateTime(now.year, now.month, now.day);
    return [
      for (var offset = days - 1; offset >= 0; offset--)
        forDay(today.subtract(Duration(days: offset))),
    ];
  }

  double _between(DateTime start, DateTime end) =>
      earnings.fold<double>(0, (sum, earning) {
        final earnedAt = DateTime.tryParse(earning.earnedAt);
        if (earnedAt == null ||
            earnedAt.isBefore(start) ||
            !earnedAt.isBefore(end)) {
          return sum;
        }
        return sum + earning.amount;
      });
}
