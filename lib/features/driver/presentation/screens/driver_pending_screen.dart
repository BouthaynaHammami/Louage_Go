import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/driver_document.dart';
import '../../../../models/driver_profile.dart';
import '../widgets/driver_app_bar.dart';
import '../providers/document_provider.dart';
import '../providers/driver_home_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────────────────────────

class DriverPendingScreen extends ConsumerWidget {
  const DriverPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return ref
        .watch(currentUserProvider)
        .when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (err, _) => Scaffold(
            appBar: driverAppBar(context, l10n.driverDocumentsTitle),
            body: Center(child: Text(l10n.driverProfileUnavailable)),
          ),
          data: (user) {
            if (user == null) {
              return AppScaffold(
                appBar: driverAppBar(context, l10n.driverDocumentsTitle),
                body: Center(child: Text(l10n.sessionExpired)),
              );
            }

            return ref
                .watch(driverDashboardProvider(user.id))
                .when(
                  loading: () => const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => Scaffold(
                    appBar: driverAppBar(context, l10n.driverDocumentsTitle),
                    body: Center(child: Text(l10n.driverProfileUnavailable)),
                  ),
                  data: (dashboard) => _PendingBody(
                    driverId: user.id,
                    profile: dashboard.profile,
                  ),
                );
          },
        );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────────────────────────────

class _PendingBody extends ConsumerWidget {
  const _PendingBody({required this.driverId, required this.profile});

  final String driverId;
  final DriverProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final docs = ref.watch(driverDocumentsProvider(driverId));

    return AppScaffold(
      appBar: driverAppBar(context, l10n.driverDocumentsTitle),
      body: docs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('$err')),
        data: (documents) => _buildContent(context, ref, documents),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<DriverDocument> documents,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final allUploaded = ref.watch(allDocumentsUploadedProvider(documents));
    final status = profile.validationStatus;
    final hasRejected = documents.any(
      (d) => d.status == DocumentStatus.rejected.name,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 40),
          children: [
            // ── Status banner ───────────────────────────────────────────
            _StatusBanner(status: status),
            const SizedBox(height: 24),

            // ── Validation stepper ──────────────────────────────────────
            _ValidationStepper(status: status),
            const SizedBox(height: 28),

            // ── Document list ───────────────────────────────────────────
            Text(
              l10n.docSectionTitle,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            for (final type in DocumentType.values)
              _DocumentItem(
                driverId: driverId,
                type: type,
                document: documents
                    .where((d) => d.type == type.name)
                    .firstOrNull,
              ),

            const SizedBox(height: 20),

            // ── Submit button ───────────────────────────────────────────
            if (status != 'approved' && status != 'validated')
              AppButton(
                label: l10n.docSubmitAll,
                icon: Icons.send_rounded,
                onPressed: allUploaded && !hasRejected
                    ? () => _submitAll(context, ref)
                    : null,
              ),

            const SizedBox(height: 32),

            // ── Locked preview ──────────────────────────────────────────
            _LockedPreview(),
            const SizedBox(height: 32),

            // ── Help section ────────────────────────────────────────────
            _HelpSection(),
          ],
        ),
      ),
    );
  }

  Future<void> _submitAll(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.docSubmitConfirmTitle),
        content: Text(l10n.docSubmitConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.docUploadCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.docSubmitAll),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(documentRepositoryProvider).submitAll(driverId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.docSubmitSuccess)));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.docUploadError)));
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status banner
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    final (label, icon, color) = switch (status) {
      'approved' || 'validated' => (
        l10n.docValidationStatusApproved,
        Icons.verified_rounded,
        colors.tertiary,
      ),
      'rejected' || 'declined' => (
        l10n.docValidationStatusRejected,
        Icons.error_outline_rounded,
        colors.error,
      ),
      'documentsSubmitted' => (
        l10n.docValidationStatusSubmitted,
        Icons.hourglass_top_rounded,
        colors.secondary,
      ),
      _ => (
        l10n.docValidationStatusPending,
        Icons.pending_outlined,
        colors.secondary,
      ),
    };

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Validation stepper (progress indicator — 3 steps)
// ─────────────────────────────────────────────────────────────────────────────

class _ValidationStepper extends StatelessWidget {
  const _ValidationStepper({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    // 0 = account created, 1 = docs sent, 2 = validated
    final currentStep = switch (status) {
      'approved' || 'validated' => 2,
      'documentsSubmitted' => 1,
      _ => 0,
    };

    final steps = [
      l10n.docStepAccountCreated,
      l10n.docStepDocumentsSent,
      l10n.docStepValidated,
    ];

    return AppCard(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            _StepDot(index: i, label: steps[i], currentStep: currentStep),
            if (i < steps.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  color: i < currentStep
                      ? colors.primary
                      : colors.outlineVariant,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.index,
    required this.label,
    required this.currentStep,
  });

  final int index;
  final String label;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDone = index < currentStep;
    final isCurrent = index == currentStep;
    final dotColor = isDone
        ? colors.primary
        : isCurrent
        ? colors.primary
        : colors.outlineVariant;
    final textColor = isCurrent || isDone
        ? colors.primary
        : colors.onSurfaceVariant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? colors.primary : colors.surface,
            border: Border.all(color: dotColor, width: 2),
          ),
          child: Center(
            child: isDone
                ? Icon(Icons.check, size: 16, color: colors.onPrimary)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isCurrent
                          ? colors.primary
                          : colors.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 72,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Document list item
// ─────────────────────────────────────────────────────────────────────────────

class _DocumentItem extends ConsumerWidget {
  const _DocumentItem({
    required this.driverId,
    required this.type,
    required this.document,
  });

  final String driverId;
  final DocumentType type;
  final DriverDocument? document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final doc = document;
    final docStatus = doc?.documentStatus ?? DocumentStatus.toSend;
    final isRejected = docStatus == DocumentStatus.rejected;

    final (statusLabel, statusColor) = switch (docStatus) {
      DocumentStatus.toSend => (l10n.docStatusToSend, colors.onSurfaceVariant),
      DocumentStatus.sent => (l10n.docStatusSent, colors.secondary),
      DocumentStatus.rejected => (l10n.docStatusRejected, colors.error),
      DocumentStatus.validated => (l10n.docStatusValidated, colors.tertiary),
    };

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                // Status dot
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 10),
                // Doc type label
                Expanded(
                  child: Text(
                    _typeLabel(l10n, type),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Upload / resend button
                if (docStatus != DocumentStatus.validated)
                  IconButton(
                    icon: Icon(
                      isRejected
                          ? Icons.refresh_rounded
                          : Icons.upload_file_outlined,
                      color: isRejected ? colors.error : colors.primary,
                    ),
                    tooltip: isRejected ? l10n.docResend : l10n.docUploadTitle,
                    onPressed: () => _pickAndUpload(context, ref),
                  ),
              ],
            ),
            // Rejection reason
            if (isRejected && doc!.rejectionReason.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: colors.onErrorContainer,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${l10n.docRejectionReason} : ${doc.rejectionReason}',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colors.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Image thumbnail preview
            if (doc != null &&
                doc.imagePath.isNotEmpty &&
                File(doc.imagePath).existsSync()) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(doc.imagePath),
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, _) => const SizedBox.shrink(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    // Show picker choice dialog
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.docUploadTitle,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(l10n.docUploadFromCamera),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.docUploadFromGallery),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null || !context.mounted) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null || !context.mounted) return;

    // Preview dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) =>
          _PreviewDialog(imagePath: picked.path, title: _typeLabel(l10n, type)),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(documentRepositoryProvider)
          .saveDocument(
            driverId: driverId,
            type: type,
            sourceImagePath: picked.path,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.docUploadSuccess)));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.docUploadError)));
    }
  }

  String _typeLabel(AppLocalizations l10n, DocumentType t) => switch (t) {
    DocumentType.nationalId => l10n.docTypeNationalId,
    DocumentType.driverLicense => l10n.docTypeDriverLicense,
    DocumentType.vehicleCard => l10n.docTypeVehicleCard,
    DocumentType.insurance => l10n.docTypeInsurance,
    DocumentType.transportLicense => l10n.docTypeTransportLicense,
    DocumentType.driverPhoto => l10n.docTypeDriverPhoto,
    DocumentType.vehiclePhoto => l10n.docTypeVehiclePhoto,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Preview dialog (image confirmation before upload)
// ─────────────────────────────────────────────────────────────────────────────

class _PreviewDialog extends StatelessWidget {
  const _PreviewDialog({required this.imagePath, required this.title});

  final String imagePath;
  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.docUploadPreviewTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(imagePath),
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, _) =>
                  const Icon(Icons.broken_image, size: 80),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.docUploadCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.docUploadConfirm),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Locked preview of the driver workspace
// ─────────────────────────────────────────────────────────────────────────────

class _LockedPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    final features = [
      (Icons.qr_code_scanner_rounded, l10n.driverScanTitle),
      (Icons.people_outline, l10n.driverPassengersReserved),
      (Icons.route_outlined, l10n.driverTripsTitle),
      (Icons.payments_outlined, l10n.driverEarningsTitle),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.docLockedPreviewTitle,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.docLockedPreviewBody,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.2,
          children: [
            for (final (icon, label) in features)
              _LockedTile(icon: icon, label: label),
          ],
        ),
      ],
    );
  }
}

class _LockedTile extends StatelessWidget {
  const _LockedTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Opacity(
      opacity: 0.38,
      child: AppCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                Icon(icon, color: colors.onSurfaceVariant, size: 26),
                Icon(Icons.lock, size: 12, color: colors.onSurfaceVariant),
              ],
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Help section
// ─────────────────────────────────────────────────────────────────────────────

class _HelpSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: colors.secondary),
              const SizedBox(width: 8),
              Text(
                l10n.docHelpTitle,
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.quiz_outlined, color: colors.secondary),
            title: Text(l10n.docHelpFaq),
            trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
            onTap: () => context.pushNamed('supportFaq'),
          ),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.support_agent_outlined,
              color: colors.secondary,
            ),
            title: Text(l10n.docHelpContact),
            trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
            onTap: () => context.pushNamed('supportContact'),
          ),
        ],
      ),
    );
  }
}
