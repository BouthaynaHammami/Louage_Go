import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as dart_ui;

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/booking.dart';

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

class TicketPdfService {
  /// Create a PDF ticket file for [booking] and return its [File].
  static Future<File> create(Booking booking) async {
    final pdfBytes = await _buildPdf(booking);
    final directory = await getApplicationDocumentsDirectory();
    final shortId = booking.id.length > 12
        ? booking.id.substring(booking.id.length - 12)
        : booking.id;
    final file = File('${directory.path}/ticket_$shortId.pdf');
    await file.writeAsBytes(pdfBytes, flush: true);
    return file;
  }

  /// Create and share the PDF ticket via the system share sheet.
  static Future<void> share(Booking booking) async {
    final file = await create(booking);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text:
            'Billet LouageGo • ${booking.matricule.isNotEmpty ? booking.matricule : booking.id}',
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PDF builder
// ---------------------------------------------------------------------------

Future<Uint8List> _buildPdf(Booking booking) async {
  // Parse departure
  final departure = DateTime.tryParse(booking.departureTime);
  final departureDate = departure == null
      ? booking.departureTime
      : '${departure.day.toString().padLeft(2, '0')}/'
          '${departure.month.toString().padLeft(2, '0')}/'
          '${departure.year}';
  final departureTime = departure == null
      ? ''
      : '${departure.hour.toString().padLeft(2, '0')}:'
          '${departure.minute.toString().padLeft(2, '0')}';

  // Generate QR image bytes
  final qrImageBytes = await _generateQrImageBytes(booking.qrCode);

  // Short booking reference
  final shortRef = booking.id.length > 20
      ? '...${booking.id.substring(booking.id.length - 20)}'
      : booking.id;

  final doc = pw.Document(
    title: 'Billet LouageGo',
    author: 'LouageGo',
    creator: 'LouageGo App',
  );

  // Colours
  const primaryColor = PdfColor.fromInt(0xFFCC1F1F);
  const lightRed = PdfColor.fromInt(0xFFFFF0F0);
  const darkGray = PdfColor.fromInt(0xFF424242);
  const medGray = PdfColor.fromInt(0xFF757575);
  const lightGray = PdfColor.fromInt(0xFFF5F5F5);
  const borderGray = PdfColor.fromInt(0xFFE0E0E0);

  final pw.TextStyle labelStyle =
      pw.TextStyle(fontSize: 9, color: medGray);
  final pw.TextStyle valueStyle = pw.TextStyle(
    fontSize: 11,
    fontWeight: pw.FontWeight.bold,
    color: darkGray,
  );
  final pw.TextStyle monoStyle =
      pw.TextStyle(fontSize: 8, color: darkGray);

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(0),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // ── Header band ─────────────────────────────────────────────
            pw.Container(
              color: primaryColor,
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 40, vertical: 20),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'LouageGo',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Billet de réservation',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.all(
                          pw.Radius.circular(6)),
                    ),
                    child: pw.Text(
                      'CONFIRMÉ',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Main content ────────────────────────────────────────────
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(40),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Left: ticket fields
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Informations du trajet',
                            style: pw.TextStyle(
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                              color: darkGray,
                            ),
                          ),
                          pw.SizedBox(height: 16),

                          // Matricule highlighted
                          pw.Container(
                            padding: const pw.EdgeInsets.all(12),
                            decoration: pw.BoxDecoration(
                              color: lightRed,
                              border: pw.Border.all(
                                  color: primaryColor, width: 1.5),
                              borderRadius: const pw.BorderRadius.all(
                                  pw.Radius.circular(8)),
                            ),
                            child: pw.Column(
                              crossAxisAlignment:
                                  pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Matricule du louage',
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    color: primaryColor,
                                  ),
                                ),
                                pw.SizedBox(height: 2),
                                pw.Text(
                                  booking.matricule.isNotEmpty
                                      ? booking.matricule
                                      : 'Non renseigné',
                                  style: pw.TextStyle(
                                    fontSize: 18,
                                    fontWeight: pw.FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(height: 14),

                          // De → Vers
                          _pdfField(
                              label: 'De',
                              value: booking.fromCity.isNotEmpty
                                  ? booking.fromCity
                                  : 'Départ',
                              labelStyle: labelStyle,
                              valueStyle: valueStyle),
                          _pdfField(
                              label: 'Vers',
                              value: booking.toCity.isNotEmpty
                                  ? booking.toCity
                                  : 'Destination',
                              labelStyle: labelStyle,
                              valueStyle: valueStyle),
                          _pdfHr(color: borderGray),

                          // Date & time
                          _pdfField(
                              label: 'Date de départ',
                              value: departureDate,
                              labelStyle: labelStyle,
                              valueStyle: valueStyle),
                          if (departureTime.isNotEmpty)
                            _pdfField(
                              label: 'Heure de départ',
                              value: departureTime,
                              labelStyle: labelStyle,
                              valueStyle: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          _pdfHr(color: borderGray),

                          // Seats
                          _pdfField(
                            label: 'Places réservées',
                            value: booking.selectedSeats.isEmpty
                                ? '—'
                                : booking.selectedSeats
                                    .map((s) => 'N°$s')
                                    .join(', '),
                            labelStyle: labelStyle,
                            valueStyle: valueStyle,
                          ),
                          _pdfField(
                            label: 'Nombre de places',
                            value: '${booking.seats}',
                            labelStyle: labelStyle,
                            valueStyle: valueStyle,
                          ),
                          _pdfHr(color: borderGray),

                          // Driver
                          _pdfField(
                            label: 'Conducteur',
                            value: booking.driverName.isEmpty
                                ? 'Non renseigné'
                                : booking.driverName,
                            labelStyle: labelStyle,
                            valueStyle: valueStyle,
                          ),
                          _pdfHr(color: borderGray),

                          // Total
                          _pdfField(
                            label: 'Montant total',
                            value:
                                '${booking.totalPrice.toStringAsFixed(2)} DT',
                            labelStyle: labelStyle,
                            valueStyle: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          _pdfField(
                            label: 'Mode de paiement',
                            value: _paymentLabel(booking.paymentMethod),
                            labelStyle: labelStyle,
                            valueStyle: valueStyle,
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(width: 30),

                    // Right: QR + reference
                    pw.SizedBox(
                      width: 160,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'Code de vérification',
                            style: pw.TextStyle(
                                fontSize: 9, color: medGray),
                          ),
                          pw.SizedBox(height: 8),
                          if (qrImageBytes != null)
                            pw.Container(
                              padding: const pw.EdgeInsets.all(8),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.white,
                                border: pw.Border.all(
                                    color: borderGray, width: 1),
                                borderRadius: const pw.BorderRadius.all(
                                    pw.Radius.circular(8)),
                              ),
                              child: pw.Image(
                                pw.MemoryImage(qrImageBytes),
                                width: 144,
                                height: 144,
                              ),
                            )
                          else
                            pw.Container(
                              width: 144,
                              height: 144,
                              color: lightGray,
                              child: pw.Center(
                                child: pw.Text(
                                  'QR Code',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    color: medGray,
                                  ),
                                ),
                              ),
                            ),
                          pw.SizedBox(height: 10),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: const pw.BoxDecoration(
                              color: lightGray,
                              borderRadius: pw.BorderRadius.all(
                                  pw.Radius.circular(6)),
                            ),
                            child: pw.Column(
                              children: [
                                pw.Text(
                                  'Référence',
                                  style: pw.TextStyle(
                                      fontSize: 8, color: medGray),
                                ),
                                pw.SizedBox(height: 3),
                                pw.Text(
                                  shortRef,
                                  style: monoStyle,
                                  textAlign: pw.TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Footer ──────────────────────────────────────────────────
            pw.Container(
              color: lightGray,
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 40, vertical: 14),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'LouageGo — Billet généré automatiquement',
                    style: pw.TextStyle(fontSize: 8, color: medGray),
                  ),
                  pw.Text(
                    'Présentez ce billet au conducteur',
                    style: pw.TextStyle(fontSize: 8, color: medGray),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  return doc.save();
}

// ---------------------------------------------------------------------------
// PDF widget helpers
// ---------------------------------------------------------------------------

pw.Widget _pdfField({
  required String label,
  required String value,
  required pw.TextStyle labelStyle,
  required pw.TextStyle valueStyle,
}) =>
    pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: labelStyle),
          pw.SizedBox(height: 2),
          pw.Text(value, style: valueStyle),
        ],
      ),
    );

pw.Widget _pdfHr({required PdfColor color}) => pw.Padding(
  padding: const pw.EdgeInsets.symmetric(vertical: 6),
  child: pw.Divider(color: color, height: 1),
);

String _paymentLabel(String method) => switch (method) {
  'cash' => "Paiement à l'embarquement",
  'card' => 'Carte bancaire',
  'mobile' => 'Portefeuille mobile',
  _ => method,
};

// ---------------------------------------------------------------------------
// QR image generation
// ---------------------------------------------------------------------------

/// Renders the QR code to a PNG [Uint8List] using qr_flutter's [QrPainter].
Future<Uint8List?> _generateQrImageBytes(String data) async {
  try {
    final painter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: true,
    );
    const sizeValue = 300.0;
    final recorder = dart_ui.PictureRecorder();
    final canvas = dart_ui.Canvas(
      recorder,
      dart_ui.Rect.fromLTWH(0, 0, sizeValue, sizeValue),
    );
    painter.paint(canvas, const dart_ui.Size(sizeValue, sizeValue));
    final picture = recorder.endRecording();
    final image =
        await picture.toImage(sizeValue.toInt(), sizeValue.toInt());
    final byteData =
        await image.toByteData(format: dart_ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  } catch (_) {
    return null;
  }
}
