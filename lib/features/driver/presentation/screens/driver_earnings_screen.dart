import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/premium_nav_bar.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/driver_earning.dart';
import '../../domain/entities/driver_earning_summary.dart';
import '../providers/driver_home_provider.dart';
import '../providers/louage_provider.dart';

class DriverEarningsScreen extends ConsumerStatefulWidget {
  const DriverEarningsScreen({super.key});

  @override
  ConsumerState<DriverEarningsScreen> createState() =>
      _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends ConsumerState<DriverEarningsScreen> {
  int _chartDays = 7;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ref
        .watch(currentUserProvider)
        .when(
          loading: () => Scaffold(
            appBar: AppBar(title: Text(l10n.driverEarningsTitle)),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Scaffold(
            appBar: AppBar(title: Text(l10n.driverEarningsTitle)),
            body: EmptyState(
              icon: Icons.error_outline,
              title: l10n.driverOperationFailed,
            ),
          ),
          data: (user) {
            if (user == null || user.role != 'driver') {
              return Scaffold(
                appBar: AppBar(title: Text(l10n.driverEarningsTitle)),
                body: EmptyState(
                  icon: Icons.person_off_outlined,
                  title: l10n.sessionExpired,
                ),
              );
            }
            final earningsState = ref.watch(driverEarningsProvider(user.id));
            final bookingsState = ref.watch(driverBookingsProvider(user.id));
            final earnings = earningsState.asData?.value;
            final bookings = bookingsState.asData?.value ?? const [];
            final passengers =
                ref
                    .watch(driverDashboardProvider(user.id))
                    .asData
                    ?.value
                    .passengers ??
                const {};
            final passengerNames = {
              for (final item in bookings)
                if (item.userId.isNotEmpty && passengers[item.userId] != null)
                  item.userId: passengers[item.userId]!.name,
            };
            final summary = DriverEarningSummary.withLegacyBookings(
              earnings ?? const [],
              bookings,
              driverId: user.id,
              passengerNames: passengerNames,
            );
            final recent = [...summary.earnings]
              ..sort((a, b) => b.earnedAt.compareTo(a.earnedAt));

            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.driverEarningsTitle),
                actions: [
                  IconButton(
                    tooltip: l10n.driverEarningsExport,
                    onPressed: recent.isEmpty
                        ? null
                        : () => _export(context, l10n, recent),
                    icon: const Icon(Icons.file_download_outlined),
                  ),
                ],
              ),
              body: earningsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => EmptyState(
                  icon: Icons.error_outline,
                  title: l10n.driverOperationFailed,
                ),
                data: (_) => _content(context, l10n, summary, recent),
              ),
            );
          },
        );
  }

  Widget _content(
    BuildContext context,
    AppLocalizations l10n,
    DriverEarningSummary summary,
    List<DriverEarning> recent,
  ) {
    final now = DateTime.now();
    final dailyTotals = summary.dailyTotals(now, _chartDays);
    final maximum = dailyTotals.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(
            16,
            16,
            16,
            kPremiumNavBarHeight +
                MediaQuery.viewPaddingOf(context).bottom +
                20,
          ),
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final gap = 10.0;
                final width = (constraints.maxWidth - gap) / 2;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    _metric(
                      context,
                      width,
                      l10n.driverEarningsTotal,
                      summary.total,
                      l10n.driverCurrencyDt,
                    ),
                    _metric(
                      context,
                      width,
                      l10n.driverRevenueToday,
                      summary.forDay(now),
                      l10n.driverCurrencyDt,
                    ),
                    _metric(
                      context,
                      width,
                      l10n.driverRevenueWeek,
                      summary.forWeek(now),
                      l10n.driverCurrencyDt,
                    ),
                    _metric(
                      context,
                      width,
                      l10n.driverRevenueMonth,
                      summary.forMonth(now),
                      l10n.driverCurrencyDt,
                    ),
                    _countMetric(
                      context,
                      width,
                      l10n.driverEarningsScannedCount,
                      recent.length,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.driverEarningsChart,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<int>(
                    segments: [
                      ButtonSegment(
                        value: 7,
                        label: Text(l10n.driverEarningsLast7Days),
                      ),
                      ButtonSegment(
                        value: 30,
                        label: Text(l10n.driverEarningsLast30Days),
                      ),
                    ],
                    selected: {_chartDays},
                    onSelectionChanged: (selection) =>
                        setState(() => _chartDays = selection.first),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 210,
                    child: BarChart(
                      BarChartData(
                        minY: 0,
                        maxY: maximum == 0 ? 1 : maximum * 1.2,
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: Theme.of(context).colorScheme.outlineVariant
                                .withValues(alpha: 0.6),
                          ),
                        ),
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
                              reservedSize: 32,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= _chartDays) {
                                  return const SizedBox.shrink();
                                }
                                if (_chartDays == 30 && index % 5 != 0) {
                                  return const SizedBox.shrink();
                                }
                                final day =
                                    DateTime(
                                      now.year,
                                      now.month,
                                      now.day,
                                    ).subtract(
                                      Duration(days: _chartDays - index - 1),
                                    );
                                return SideTitleWidget(
                                  meta: meta,
                                  child: Text(
                                    DateFormat(
                                      _chartDays == 7 ? 'E' : 'd/M',
                                      locale,
                                    ).format(day),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          for (
                            var index = 0;
                            index < dailyTotals.length;
                            index++
                          )
                            BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: dailyTotals[index],
                                  color: Theme.of(context).colorScheme.primary,
                                  width: _chartDays == 7 ? 20 : 7,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.driverEarningsRecent,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (recent.isEmpty)
              AppCard(
                child: Text(
                  l10n.driverEarningsEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              for (final earning in recent.take(30))
                _earningCard(context, l10n, earning, locale),
          ],
        ),
      ),
    );
  }

  Widget _metric(
    BuildContext context,
    double width,
    String label,
    double amount,
    String currency,
  ) => SizedBox(
    width: width,
    child: AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Text(
            '${amount.toStringAsFixed(2)} $currency',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    ),
  );

  Widget _countMetric(
    BuildContext context,
    double width,
    String label,
    int count,
  ) => SizedBox(
    width: width,
    child: AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Text('$count', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    ),
  );

  Widget _earningCard(
    BuildContext context,
    AppLocalizations l10n,
    DriverEarning earning,
    String locale,
  ) {
    final passenger = earning.passengerName.isEmpty
        ? l10n.driverEarningsUnknown
        : earning.passengerName;
    final from = earning.fromCity.isEmpty
        ? l10n.driverEarningsUnknown
        : earning.fromCity;
    final to = earning.toCity.isEmpty
        ? l10n.driverEarningsUnknown
        : earning.toCity;
    final date = DateTime.tryParse(earning.earnedAt);
    final dateText = date == null
        ? l10n.driverEarningsUnknown
        : DateFormat.yMMMd(locale).add_Hm().format(date);
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8),
      child: AppCard(
        child: Row(
          children: [
            Icon(
              Icons.confirmation_num_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    passenger,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(l10n.driverEarningsRoute(from, to)),
                  Text(
                    dateText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${earning.amount.toStringAsFixed(2)} ${l10n.driverCurrencyDt}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _export(
    BuildContext context,
    AppLocalizations l10n,
    List<DriverEarning> earnings,
  ) async {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final rows = <List<dynamic>>[
      [
        l10n.driverEarningsCsvPassenger,
        l10n.driverEarningsCsvRoute,
        l10n.driverEarningsCsvAmount,
        l10n.driverEarningsCsvDate,
        l10n.driverEarningsCsvMethod,
      ],
      for (final earning in earnings)
        [
          earning.passengerName,
          l10n.driverEarningsRoute(earning.fromCity, earning.toCity),
          earning.amount.toStringAsFixed(2),
          DateTime.tryParse(earning.earnedAt) == null
              ? earning.earnedAt
              : DateFormat.yMMMd(locale)
                    .add_Hm()
                    .format(DateTime.parse(earning.earnedAt)),
          earning.method,
        ],
    ];
    try {
      final bytes = Uint8List.fromList(utf8.encode(Csv.excel().encode(rows)));
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              mimeType: 'text/csv',
              name: 'driver_earnings.csv',
            ),
          ],
          text: l10n.driverEarningsTitle,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.driverEarningsExportFailed)));
    }
  }
}
