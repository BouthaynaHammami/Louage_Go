import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import 'app_button.dart';
import 'app_card.dart';
import 'app_text_field.dart';
import 'empty_state.dart';
import 'section_header.dart';
import 'seat_dots.dart';
import 'skeleton_box.dart';
import 'status_chip.dart';

class WidgetGallery extends StatefulWidget {
  const WidgetGallery({super.key});

  @override
  State<WidgetGallery> createState() => _WidgetGalleryState();
}

class _WidgetGalleryState extends State<WidgetGallery> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'passager@louagego.tn');
  final _passwordController = TextEditingController(text: 'Demo1234');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.widgetGalleryTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(
                    title: l10n.widgetGalleryFields,
                    actionLabel: l10n.widgetGalleryValidate,
                    onAction: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _showMessage(l10n.widgetGalleryFormValid);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          label: l10n.widgetGalleryEmail,
                          icon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              value == null || !value.contains('@')
                              ? l10n.authInvalidEmail
                              : null,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: l10n.widgetGalleryPassword,
                          icon: Icons.lock_outline,
                          isPassword: true,
                          controller: _passwordController,
                          validator: (value) =>
                              value == null || value.length < 6
                              ? l10n.widgetGalleryPasswordMin
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SectionHeader(title: l10n.widgetGalleryButtons),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      AppButton(
                        label: l10n.widgetGalleryPrimary,
                        icon: Icons.check,
                        onPressed: () =>
                            _showMessage(l10n.widgetGalleryPrimary),
                      ),
                      AppButton(
                        label: l10n.widgetGallerySecondary,
                        variant: AppButtonVariant.secondary,
                        onPressed: () =>
                            _showMessage(l10n.widgetGallerySecondary),
                      ),
                      AppButton(
                        label: l10n.widgetGalleryAccent,
                        variant: AppButtonVariant.accent,
                        onPressed: () => _showMessage(l10n.widgetGalleryAccent),
                      ),
                      AppButton(
                        label: l10n.widgetGalleryLoading,
                        onPressed: null,
                        isLoading: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SectionHeader(
                    title: l10n.widgetGalleryStatuses,
                    trailing: Icon(Icons.tune, color: colorScheme.secondary),
                  ),
                  const SizedBox(height: 12),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      StatusChip(status: 'waiting'),
                      StatusChip(status: 'full'),
                      StatusChip(status: 'departed'),
                      StatusChip(status: 'arrived'),
                      StatusChip(status: 'cancelled'),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SectionHeader(title: l10n.widgetGalleryCardsSeats),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Tunis → Sfax',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.widgetGalleryDeparturePrice,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        const SeatDots(freeSeats: 5),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SectionHeader(title: l10n.widgetGalleryLoadingSection),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SkeletonBox(width: 180, height: 18),
                        const SizedBox(height: 12),
                        const SkeletonBox(width: double.infinity, height: 14),
                        const SizedBox(height: 8),
                        SkeletonBox(
                          width: MediaQuery.sizeOf(context).width * 0.55,
                          height: 14,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SectionHeader(title: l10n.widgetGalleryEmpty),
                  const SizedBox(height: 12),
                  AppCard(
                    child: SizedBox(
                      width: double.infinity,
                      child: EmptyState(
                        icon: Icons.route_outlined,
                        title: l10n.widgetGalleryNoSavedTrip,
                        description: l10n.widgetGalleryAvailableTripsAppear,
                        actionLabel: l10n.widgetGallerySearch,
                        onAction: () => _showMessage(l10n.widgetGallerySearch),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
