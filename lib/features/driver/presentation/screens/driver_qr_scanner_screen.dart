import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/trip.dart';
import '../../domain/entities/ticket_validation_result.dart';
import '../providers/louage_provider.dart';

// ═════════════════════════════════════════════════════════════════════════════
// DriverQrScannerScreen — Phase 4
// ═════════════════════════════════════════════════════════════════════════════

class DriverQrScannerScreen extends ConsumerStatefulWidget {
  const DriverQrScannerScreen({super.key, this.initialTripId});

  final String? initialTripId;

  @override
  ConsumerState<DriverQrScannerScreen> createState() =>
      _DriverQrScannerScreenState();
}

class _DriverQrScannerScreenState extends ConsumerState<DriverQrScannerScreen> {
  String? _selectedTripId;
  TicketValidationResult? _result;
  String? _error;
  bool _validating = false;
  bool _torchOn = false;

  // Debounce: prevents scanning the same code twice within 2 s
  String? _lastScannedCode;
  Timer? _debounceTimer;

  final MobileScannerController _scannerCtrl = MobileScannerController(
    torchEnabled: false,
    facing: CameraFacing.back,
    autoStart: true,
  );

  @override
  void initState() {
    super.initState();
    _selectedTripId = widget.initialTripId;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scannerCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _resetScan() {
    setState(() {
      _result = null;
      _error = null;
    });
  }

  Future<void> _toggleTorch() async {
    await _scannerCtrl.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  Future<void> _switchCamera() async {
    await _scannerCtrl.switchCamera();
  }

  void _onDetect(String driverId, BarcodeCapture capture) {
    if (_validating || _result != null || _selectedTripId == null) return;

    final rawValue = capture.barcodes
        .map((b) => b.rawValue)
        .whereType<String>()
        .firstOrNull;
    if (rawValue == null) return;

    // Debounce: ignore same code within 2 seconds
    if (rawValue == _lastScannedCode) return;
    _lastScannedCode = rawValue;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      _lastScannedCode = null;
    });

    _validate(driverId, rawValue);
  }

  Future<void> _validate(String driverId, String qrPayload) async {
    if (_validating || _selectedTripId == null) return;
    setState(() => _validating = true);
    try {
      final result = await ref
          .read(louageRepositoryProvider)
          .validateTicket(
            driverId: driverId,
            tripId: _selectedTripId!,
            qrPayload: qrPayload,
          );
      if (!mounted) return;

      // Haptic feedback based on result
      switch (result.status) {
        case TicketValidationStatus.valid:
          HapticFeedback.heavyImpact();
        case TicketValidationStatus.alreadyUsed:
          HapticFeedback.mediumImpact();
        case TicketValidationStatus.invalid:
          HapticFeedback.vibrate();
      }

      setState(() => _result = result);
    } catch (err) {
      if (!mounted) return;
      HapticFeedback.vibrate();
      setState(
        () => _error = AppLocalizations.of(context)!.driverOperationFailed,
      );
    } finally {
      if (mounted) setState(() => _validating = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ref
        .watch(currentUserProvider)
        .when(
          loading: () => Scaffold(
            appBar: AppBar(title: Text(l10n.driverScanTitle)),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => Scaffold(
            appBar: AppBar(title: Text(l10n.driverScanTitle)),
            body: EmptyState(
              icon: Icons.error_outline,
              title: l10n.driverOperationFailed,
            ),
          ),
          data: (user) {
            if (user == null || user.role != 'driver') {
              return Scaffold(
                appBar: AppBar(title: Text(l10n.driverScanTitle)),
                body: EmptyState(
                  icon: Icons.person_off_outlined,
                  title: l10n.sessionExpired,
                ),
              );
            }
            return ref
                .watch(driverTripsProvider(user.id))
                .when(
                  loading: () => Scaffold(
                    appBar: AppBar(title: Text(l10n.driverScanTitle)),
                    body: const Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => Scaffold(
                    appBar: AppBar(title: Text(l10n.driverScanTitle)),
                    body: EmptyState(
                      icon: Icons.error_outline,
                      title: l10n.driverOperationFailed,
                    ),
                  ),
                  data: (trips) => trips.isEmpty
                      ? Scaffold(
                          appBar: AppBar(title: Text(l10n.driverScanTitle)),
                          body: EmptyState(
                            icon: Icons.route_outlined,
                            title: l10n.driverTripsEmpty,
                          ),
                        )
                      : _buildScanner(context, user.id, trips),
                );
          },
        );
  }

  Widget _buildScanner(
    BuildContext context,
    String driverId,
    List<Trip> trips,
  ) {
    final l10n = AppLocalizations.of(context)!;

    // Auto-select first trip if none selected or selection stale
    if (!trips.any((t) => t.id == _selectedTripId)) {
      _selectedTripId = trips.first.id;
    }

    final selectedTrip = trips.firstWhere((t) => t.id == _selectedTripId);
    final tripBookings =
        ref.watch(driverTripBookingsProvider(_selectedTripId!)).asData?.value ??
        [];
    final validated = tripBookings
        .where((b) => b.booking.status == 'validated')
        .length;
    final total = selectedTrip.totalSeats;

    final result = _result;
    final colorScheme = Theme.of(context).colorScheme;
    final overlayColor = colorScheme.brightness == Brightness.dark
        ? colorScheme.surfaceContainer
        : colorScheme.secondary;
    final (resultColor, resultIcon, resultMsg) = _resultStyle(
      context,
      l10n,
      result,
      _error,
    );

    return Scaffold(
      backgroundColor: overlayColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: overlayColor.withValues(alpha: 0.7),
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        title: Text(l10n.driverScanTitle),
        actions: [
          // Torch toggle
          IconButton(
            icon: Icon(
              _torchOn ? Icons.flashlight_on : Icons.flashlight_off,
              color: colorScheme.onPrimary,
            ),
            tooltip: 'Torche',
            onPressed: _toggleTorch,
          ),
          // Switch camera
          IconButton(
            icon: Icon(
              Icons.flip_camera_ios_outlined,
              color: colorScheme.onPrimary,
            ),
            tooltip: 'Changer de caméra',
            onPressed: _switchCamera,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camera preview ──────────────────────────────────────────
          if (_result == null && _error == null && !_validating)
            MobileScanner(
              controller: _scannerCtrl,
              onDetect: (capture) => _onDetect(driverId, capture),
            )
          else
            // Result overlay
            ColoredBox(
              color: resultColor.withValues(alpha: 0.15),
              child: Center(
                child: Icon(resultIcon, size: 120, color: resultColor),
              ),
            ),

          // ── Viewfinder overlay ──────────────────────────────────────
          if (_result == null && _error == null && !_validating)
            _ViewfinderOverlay(),

          // ── Loading spinner ─────────────────────────────────────────
          if (_validating)
            Center(
              child: CircularProgressIndicator(color: colorScheme.onPrimary),
            ),

          // ── Bottom panel ────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: _BottomPanel(
                trips: trips,
                selectedTripId: _selectedTripId!,
                validated: validated,
                total: total,
                result: result,
                error: _error,
                resultMsg: resultMsg,
                resultColor: resultColor,
                resultIcon: resultIcon,
                l10n: l10n,
                onTripChanged: (id) => setState(() {
                  _selectedTripId = id;
                  _resetScan();
                }),
                onReset: _resetScan,
              ),
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData, String) _resultStyle(
    BuildContext context,
    AppLocalizations l10n,
    TicketValidationResult? result,
    String? error,
  ) {
    if (error != null) {
      return (Theme.of(context).colorScheme.error, Icons.error_outline, error);
    }
    return switch (result?.status) {
      TicketValidationStatus.valid => (
        Theme.of(context).colorScheme.tertiary,
        Icons.check_circle_outline_rounded,
        l10n.driverScanValid,
      ),
      TicketValidationStatus.alreadyUsed => (
        Theme.of(context).colorScheme.error,
        Icons.history_toggle_off_rounded,
        l10n.driverScanUsed,
      ),
      TicketValidationStatus.invalid => (
        AppColors.warning,
        Icons.cancel_outlined,
        l10n.driverScanInvalid,
      ),
      null => (
        Theme.of(context).colorScheme.inversePrimary,
        Icons.qr_code_scanner,
        l10n.driverScanInstructions,
      ),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Viewfinder overlay
// ─────────────────────────────────────────────────────────────────────────────

class _ViewfinderOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ViewfinderPainter(
        frameColor: Theme.of(context).colorScheme.onPrimary,
        cornerColor: Theme.of(context).colorScheme.primary,
        dimColor:
            (Theme.of(context).colorScheme.brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.surfaceContainer
                    : Theme.of(context).colorScheme.secondary)
                .withValues(alpha: 0.7),
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  const _ViewfinderPainter({
    required this.frameColor,
    required this.cornerColor,
    required this.dimColor,
  });

  final Color frameColor;
  final Color cornerColor;
  final Color dimColor;

  @override
  void paint(Canvas canvas, Size size) {
    const frameSize = 240.0;
    const cornerLen = 28.0;
    const cornerW = 4.0;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final l = cx - frameSize / 2;
    final t = cy - frameSize / 2;
    final r = cx + frameSize / 2;
    final b = cy + frameSize / 2;

    // Dim everything outside the frame
    final dimPaint = Paint()..color = dimColor;
    final holePath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(l, t, r, b),
          const Radius.circular(12),
        ),
      );
    canvas.drawPath(holePath..fillType = PathFillType.evenOdd, dimPaint);

    final framePaint = Paint()
      ..color = frameColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(l, t, r, b),
        const Radius.circular(12),
      ),
      framePaint,
    );

    // Corner brackets
    final paint = Paint()
      ..color = cornerColor
      ..strokeWidth = cornerW
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final (ox, oy, dx, dy) in [
      (l, t, 1.0, 1.0),
      (r, t, -1.0, 1.0),
      (l, b, 1.0, -1.0),
      (r, b, -1.0, -1.0),
    ]) {
      canvas.drawLine(Offset(ox, oy + dy * cornerLen), Offset(ox, oy), paint);
      canvas.drawLine(Offset(ox + dx * cornerLen, oy), Offset(ox, oy), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom panel
// ─────────────────────────────────────────────────────────────────────────────

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.trips,
    required this.selectedTripId,
    required this.validated,
    required this.total,
    required this.result,
    required this.error,
    required this.resultMsg,
    required this.resultColor,
    required this.resultIcon,
    required this.l10n,
    required this.onTripChanged,
    required this.onReset,
  });

  final List<Trip> trips;
  final String selectedTripId;
  final int validated;
  final int total;
  final TicketValidationResult? result;
  final String? error;
  final String resultMsg;
  final Color resultColor;
  final IconData resultIcon;
  final AppLocalizations l10n;
  final void Function(String) onTripChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Trip selector
          DropdownButtonFormField<String>(
            initialValue: selectedTripId,
            decoration: InputDecoration(
              labelText: l10n.driverScanSelectTrip,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsetsDirectional.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            items: [
              for (final trip in trips)
                DropdownMenuItem(
                  value: trip.id,
                  child: Text(
                    _tripLabel(trip),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (id) {
              if (id != null) onTripChanged(id);
            },
          ),
          const SizedBox(height: 12),

          // Boarding counter
          Container(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer
                  .withValues(alpha: 0.60),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_alt_rounded,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 10),
                Text(
                  '$validated / $total ${l10n.driverSeatWord}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),

          // Result feedback
          if (result != null || error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: resultColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: resultColor.withValues(alpha: 0.40)),
              ),
              child: Row(
                children: [
                  Icon(resultIcon, color: resultColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      resultMsg,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(color: resultColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.searchRetry),
            ),
          ],
        ],
      ),
    );
  }

  String _tripLabel(Trip trip) {
    if (trip.departureTime.isEmpty) return trip.id;
    final dep = DateTime.tryParse(trip.departureTime);
    if (dep == null) return trip.id;
    final h = dep.hour.toString().padLeft(2, '0');
    final m = dep.minute.toString().padLeft(2, '0');
    return '$h:$m — ${dep.day}/${dep.month}';
  }
}
