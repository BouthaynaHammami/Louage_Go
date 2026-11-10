import 'package:flutter_test/flutter_test.dart';
import 'package:louage_go/features/driver/domain/entities/driver_earning_summary.dart';
import 'package:louage_go/models/booking.dart';
import 'package:louage_go/models/driver_earning.dart';

void main() {
  test('income periods include midnight and start the week on Monday', () {
    final summary = DriverEarningSummary([
      _earning('midnight', 10, '2026-11-10T00:00:00.000'),
      _earning('monday', 20, '2026-11-09T23:59:59.000'),
      _earning('sunday', 30, '2026-11-08T23:59:59.000'),
      _earning('month-end', 40, '2026-10-31T23:59:59.000'),
    ]);
    final now = DateTime(2026, 11, 10, 12);

    expect(summary.total, 100);
    expect(summary.forDay(now), 10);
    expect(summary.forWeek(now), 30);
    expect(summary.forMonth(now), 60);
    expect(summary.countForMonth(now), 3);
    expect(summary.dailyTotals(now, 7), hasLength(7));
  });

  test('validated legacy bookings are included once using booking date', () {
    final summary = DriverEarningSummary.withLegacyBookings(
      [_earning('stored', 12, '2026-11-10T09:00:00.000')],
      [
        const Booking(
          id: 'stored',
          status: 'validated',
          totalPrice: 12,
          createdAt: '2026-11-10T08:00:00.000',
        ),
        const Booking(
          id: 'legacy',
          userId: 'passenger',
          status: 'validated',
          totalPrice: 25,
          createdAt: '2026-11-09T08:00:00.000',
        ),
        const Booking(
          id: 'cancelled',
          status: 'cancelled',
          totalPrice: 80,
          createdAt: '2026-11-10T08:00:00.000',
        ),
      ],
      driverId: 'driver-1',
      passengerNames: const {'passenger': 'Sami'},
    );

    expect(summary.total, 37);
    expect(summary.earnings, hasLength(2));
    expect(summary.earnings.last.passengerName, 'Sami');
  });
}

DriverEarning _earning(String bookingId, double amount, String earnedAt) =>
    DriverEarning(
      id: bookingId,
      bookingId: bookingId,
      amount: amount,
      earnedAt: earnedAt,
    );
