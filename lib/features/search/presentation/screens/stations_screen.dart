import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/favorite_button.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/station.dart';
import '../providers/trip_search_results_provider.dart';

class StationsScreen extends StatelessWidget {
  const StationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stationsTitle),
        actions: [
          IconButton(
            tooltip: l10n.stationsMapTitle,
            onPressed: () => context.pushNamed('passengerStationsMap'),
            icon: const Icon(Icons.map_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 16),
        child: StationSearchPanel(
          onStationSelected: (station) => _showStation(context, station),
        ),
      ),
    );
  }

  Future<void> _showStation(BuildContext context, Station station) async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              station.localizedName(locale),
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FavoriteButton.station(stationId: station.id),
            ),
            const SizedBox(height: 8),
            Text(station.address),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                context.goNamed(
                  'passengerHome',
                  queryParameters: {'fromStationId': station.id},
                );
              },
              icon: const Icon(Icons.search_rounded),
              label: Text(l10n.stationsSearchFrom),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Station?> showStationPicker(
  BuildContext context, {
  required String title,
}) => showModalBottomSheet<Station>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (context) {
    final media = MediaQuery.of(context);
    return SizedBox(
      height: (media.size.height - media.viewInsets.bottom - 48).clamp(
        260.0,
        media.size.height * 0.86,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),
            Expanded(
              child: StationSearchPanel(
                onStationSelected: (station) =>
                    Navigator.of(context).pop(station),
              ),
            ),
          ],
        ),
      ),
    );
  },
);

class StationSearchPanel extends ConsumerStatefulWidget {
  const StationSearchPanel({required this.onStationSelected, super.key});

  final ValueChanged<Station> onStationSelected;

  @override
  ConsumerState<StationSearchPanel> createState() => _StationSearchPanelState();
}

class _StationSearchPanelState extends ConsumerState<StationSearchPanel> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final groupsAsync = ref.watch(stationsByGovernorateProvider);
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: l10n.stationsSearchLabel,
            prefixIcon: const Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: groupsAsync.when(
            loading: () => ListView(
              children: const [
                SkeletonBox(height: 64),
                SizedBox(height: 10),
                SkeletonBox(height: 64),
                SizedBox(height: 10),
                SkeletonBox(height: 64),
              ],
            ),
            error: (error, stackTrace) => EmptyState(
              icon: Icons.error_outline,
              title: l10n.stationsLoadError,
            ),
            data: (groups) {
              final repository = ref.read(searchRepositoryProvider);
              final filtered = _query.trim().isEmpty
                  ? groups
                  : _groupStations(repository.searchStations(_query));
              if (filtered.isEmpty) {
                return EmptyState(
                  icon: Icons.location_off_outlined,
                  title: l10n.stationsNoResults,
                );
              }
              return ListView.builder(
                itemCount: filtered.fold<int>(
                  0,
                  (count, group) => count + group.stations.length + 1,
                ),
                itemBuilder: (context, index) {
                  var offset = index;
                  for (final group in filtered) {
                    if (offset == 0) {
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(
                          top: 10,
                          bottom: 4,
                        ),
                        child: Text(
                          locale.languageCode == 'ar' &&
                                  group.governorateAr.isNotEmpty
                              ? group.governorateAr
                              : group.governorate,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      );
                    }
                    offset--;
                    if (offset < group.stations.length) {
                      final station = group.stations[offset];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.location_on_outlined),
                        title: Text(station.localizedName(locale)),
                        subtitle: Text(station.localizedCity(locale)),
                        onTap: () => widget.onStationSelected(station),
                      );
                    }
                    offset -= group.stations.length;
                  }
                  return const SizedBox.shrink();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  List<GovernorateStations> _groupStations(List<Station> stations) {
    final grouped = <String, List<Station>>{};
    for (final station in stations) {
      grouped.putIfAbsent(station.governorate, () => []).add(station);
    }
    final result = grouped.entries.map((entry) {
      final stations = entry.value..sort((a, b) => a.name.compareTo(b.name));
      return GovernorateStations(
        governorate: entry.key,
        governorateAr: stations.first.governorateAr,
        stations: List.unmodifiable(stations),
      );
    }).toList()..sort((a, b) => a.governorate.compareTo(b.governorate));
    return result;
  }
}
