import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../features/driver/presentation/providers/louage_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/booking.dart';
import '../../domain/entities/driver_earning_summary.dart';
import '../providers/driver_home_provider.dart';

class DriverDashboardStats extends ConsumerWidget {
  const DriverDashboardStats({
    required this.driverId,
    required this.bookings,
    super.key,
  });

  final String driverId;
  final List<Booking> bookings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final dark = colors.brightness == Brightness.dark;
    final cardBackground = dark
        ? colors.surfaceContainerHigh
        : colors.secondary;
    final cardForeground = colors.onPrimary;
    final stats = ref.watch(driverLouageStatsProvider(driverId));
    final rating = stats.asData?.value.$1 ?? 0.0;
    final completedTrips = stats.asData?.value.$2 ?? 0;
    final now = DateTime.now();
    var passengersTotal = 0;
    for (final booking in bookings) {
      if (!const {'confirmed', 'validated'}.contains(booking.status)) continue;
      passengersTotal += booking.seats;
    }
    final earnings = ref.watch(driverEarningsProvider(driverId)).asData?.value;
    final summary = DriverEarningSummary.withLegacyBookings(
      earnings ?? const [],
      bookings,
      driverId: driverId,
    );
    final revenueDay = summary.forDay(now);
    final revenueWeek = summary.forWeek(now);

    final kpis = [
      _KpiData(
        Icons.star_rounded,
        rating == 0 ? '—' : rating.toStringAsFixed(1),
        l10n.driverRatingAverage,
      ),
      _KpiData(
        Icons.check_circle_outline,
        '$completedTrips',
        l10n.driverCompletedTrips,
      ),
      _KpiData(
        Icons.people_outline,
        '$passengersTotal',
        l10n.driverPassengersReserved,
      ),
      _KpiData(
        Icons.today_rounded,
        '${revenueDay.toStringAsFixed(0)} DT',
        l10n.driverRevenueToday,
      ),
      _KpiData(
        Icons.calendar_view_week_rounded,
        '${revenueWeek.toStringAsFixed(0)} DT',
        l10n.driverRevenueWeek,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.driverDashboardStatsTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final gap = 10.0;
            final width = (constraints.maxWidth - gap) / 2;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final kpi in kpis)
                  SizedBox(
                    width: width,
                    child: _KpiCard(
                      data: kpi,
                      background: cardBackground,
                      foreground: cardForeground,
                      accent: colors.primary,
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.driverDashboardRevenueTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 150,
                child: BarChart(
                  BarChartData(
                    minY: 0,
                    maxY: _chartMax(revenueDay, revenueWeek),
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: colors.outlineVariant.withValues(alpha: 0.7),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) => SideTitleWidget(
                            meta: meta,
                            child: Text(
                              value.toInt() == 0
                                  ? l10n.driverRevenueToday
                                  : l10n.driverRevenueWeek,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          ),
                        ),
                      ),
                    ),
                    barGroups: [
                      _revenueBar(0, revenueDay, colors.primary),
                      _revenueBar(1, revenueWeek, colors.outlineVariant),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static double _chartMax(double first, double second) {
    final maximum = first > second ? first : second;
    return maximum == 0 ? 1 : maximum * 1.2;
  }

  static BarChartGroupData _revenueBar(int index, double value, Color color) =>
      BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: color,
            width: 30,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
}

class _KpiData {
  const _KpiData(this.icon, this.value, this.label);

  final IconData icon;
  final String value;
  final String label;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.data,
    required this.background,
    required this.foreground,
    required this.accent,
  });

  final _KpiData data;
  final Color background;
  final Color foreground;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 84),
    padding: const EdgeInsetsDirectional.all(12),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(16),
      border: BorderDirectional(start: BorderSide(color: accent, width: 3)),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Icon(data.icon, size: 22, color: accent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
              ),
              Text(
                data.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: foreground.withValues(alpha: 0.76)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
