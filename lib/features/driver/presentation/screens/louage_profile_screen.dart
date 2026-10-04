import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/hive_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../features/profile/presentation/widgets/profile_widgets.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/louage.dart';
import '../../../../models/station.dart';
import '../providers/louage_provider.dart';

class LouageProfileScreen extends ConsumerStatefulWidget {
  const LouageProfileScreen({super.key});

  @override
  ConsumerState<LouageProfileScreen> createState() =>
      _LouageProfileScreenState();
}

class _LouageProfileScreenState extends ConsumerState<LouageProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _matriculeController = TextEditingController();
  final _modeleController = TextEditingController();
  final _totalSeatsController = TextEditingController();
  final _availableSeatsController = TextEditingController();
  String? _stationId;
  String? _loadedLouageId;
  bool _saving = false;

  @override
  void dispose() {
    _matriculeController.dispose();
    _modeleController.dispose();
    _totalSeatsController.dispose();
    _availableSeatsController.dispose();
    super.dispose();
  }

  void _loadForm(Louage? louage) {
    if (_loadedLouageId == (louage?.id ?? 'new')) return;
    _loadedLouageId = louage?.id ?? 'new';
    _matriculeController.text = louage?.matricule ?? '';
    _modeleController.text = louage?.modele ?? '';
    _totalSeatsController.text = (louage?.placesTotal ?? 8).toString();
    _availableSeatsController.text = (louage?.placesDisponibles ?? 8)
        .toString();
    _stationId = louage?.stationActuelle;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    return user.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: Text(l10n.driverLouageProfileTitle)),
        body: EmptyState(
          icon: Icons.error_outline,
          title: l10n.driverProfileUnavailable,
        ),
      ),
      data: (driver) {
        if (driver == null || driver.role != 'driver') {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.driverLouageProfileTitle)),
            body: EmptyState(
              icon: Icons.person_off_outlined,
              title: l10n.sessionExpired,
            ),
          );
        }
        return ref
            .watch(driverLouageProvider(driver.id))
            .when(
              loading: () => Scaffold(
                appBar: AppBar(title: Text(l10n.driverLouageProfileTitle)),
                body: const Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => Scaffold(
                appBar: AppBar(title: Text(l10n.driverLouageProfileTitle)),
                body: EmptyState(
                  icon: Icons.error_outline,
                  title: l10n.driverProfileUnavailable,
                ),
              ),
              data: (louage) {
                _loadForm(louage);
                return _buildProfile(context, driver.id, louage);
              },
            );
      },
    );
  }

  Widget _buildProfile(BuildContext context, String driverId, Louage? louage) {
    final l10n = AppLocalizations.of(context)!;
    final stations = HiveService.isReady
        ? HiveService.stations.values.map(Station.fromMap).toList()
        : <Station>[];
    final stats = ref.watch(driverLouageStatsProvider(driverId));
    final scheme = Theme.of(context).colorScheme;
    final stationValue = stations.any((station) => station.id == _stationId)
        ? _stationId
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.driverLouageProfileTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 28),
              children: [
                Text(
                  l10n.driverLouageProfileSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _matriculeController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: l10n.driverMatricule,
                            prefixIcon: const Icon(
                              Icons.confirmation_number_outlined,
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? l10n.driverOperationFailed
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _modeleController,
                          decoration: InputDecoration(
                            labelText: l10n.driverVehicleModel,
                            prefixIcon: const Icon(
                              Icons.directions_car_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _totalSeatsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.driverTotalSeats,
                            prefixIcon: const Icon(Icons.event_seat_outlined),
                          ),
                          validator: (value) {
                            final total = int.tryParse(value ?? '');
                            final available = int.tryParse(
                              _availableSeatsController.text,
                            );
                            if (total == null ||
                                total < 1 ||
                                available == null ||
                                available < 0 ||
                                available > total) {
                              return l10n.driverOperationFailed;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _availableSeatsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.driverAvailableSeats,
                            prefixIcon: const Icon(
                              Icons.airline_seat_recline_normal,
                            ),
                          ),
                          validator: (value) {
                            final available = int.tryParse(value ?? '');
                            final total = int.tryParse(
                              _totalSeatsController.text,
                            );
                            if (available == null ||
                                total == null ||
                                available < 0 ||
                                available > total) {
                              return l10n.driverOperationFailed;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        if (stations.isNotEmpty)
                          DropdownButtonFormField<String>(
                            initialValue: stationValue,
                            decoration: InputDecoration(
                              labelText: l10n.driverCurrentStation,
                              prefixIcon: const Icon(Icons.place_outlined),
                            ),
                            items: [
                              for (final station in stations)
                                DropdownMenuItem(
                                  value: station.id,
                                  child: Text(
                                    station.localizedName(
                                      Localizations.localeOf(context),
                                    ),
                                  ),
                                ),
                            ],
                            onChanged: (value) =>
                                setState(() => _stationId = value),
                            validator: (value) => value == null
                                ? l10n.driverOperationFailed
                                : null,
                          )
                        else
                          TextFormField(
                            initialValue: _stationId,
                            decoration: InputDecoration(
                              labelText: l10n.driverCurrentStation,
                            ),
                            onChanged: (value) => _stationId = value,
                          ),
                        const SizedBox(height: 20),
                        AppButton(
                          label: l10n.driverSaveLouage,
                          icon: Icons.save_outlined,
                          isLoading: _saving,
                          onPressed: () => _save(driverId, louage),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.driverChangeStatus,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.circle, color: scheme.primary),
                        title: Text(_statusLabel(l10n, louage?.statut)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: louage == null
                            ? null
                            : () => _changeStatus(louage),
                      ),
                      stats.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (error, stackTrace) => Text(
                          l10n.driverOperationFailed,
                          style: TextStyle(color: scheme.error),
                        ),
                        data: (summary) => Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _StatChip(
                              label: l10n.driverRatingAverage,
                              value: summary.$1.toStringAsFixed(1),
                              icon: Icons.star_outline,
                            ),
                            _StatChip(
                              label: l10n.driverCompletedTrips,
                              value: summary.$2.toString(),
                              icon: Icons.route_outlined,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => context.goNamed('driverQueue'),
                            icon: const Icon(Icons.route_outlined),
                            label: Text(l10n.driverTripsTitle),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => context.goNamed('driverRating'),
                            icon: const Icon(Icons.star_outline),
                            label: Text(l10n.driverRatingTitle),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => context.pushNamed('driverAccount'),
                            icon: const Icon(Icons.manage_accounts_outlined),
                            label: Text(l10n.profileTitle),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const SignOutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save(String driverId, Louage? existing) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    final total = int.parse(_totalSeatsController.text);
    final available = int.parse(_availableSeatsController.text);
    final louage = (existing ?? Louage(chauffeurId: driverId)).copyWith(
      chauffeurId: driverId,
      matricule: _matriculeController.text.trim(),
      modele: _modeleController.text.trim(),
      placesTotal: total,
      placesDisponibles: available,
      stationActuelle: _stationId?.trim() ?? '',
    );
    setState(() => _saving = true);
    try {
      await ref.read(louageRepositoryProvider).saveLouage(louage);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.driverLouageSaved)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.driverOperationFailed)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changeStatus(Louage louage) async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showDialog<LouageStatus>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.driverConfirmStatus),
        children: [
          RadioGroup<LouageStatus>(
            groupValue: louage.statut,
            onChanged: (value) => Navigator.pop(context, value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final status in LouageStatus.values)
                  RadioListTile<LouageStatus>(
                    value: status,
                    title: Text(_statusLabel(l10n, status)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (selected == null || selected == louage.statut || !mounted) return;
    try {
      await ref
          .read(louageRepositoryProvider)
          .updateStatus(louage.id, selected);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.driverOperationFailed)));
    }
  }

  String _statusLabel(AppLocalizations l10n, LouageStatus? status) =>
      switch (status ?? LouageStatus.disponible) {
        LouageStatus.disponible => l10n.driverStatusAvailable,
        LouageStatus.enAttente => l10n.driverStatusWaiting,
        LouageStatus.enDeplacement => l10n.driverStatusInTransit,
        LouageStatus.horsService => l10n.driverStatusOutOfService,
      };
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) =>
      Chip(avatar: Icon(icon, size: 18), label: Text('$label : $value'));
}
