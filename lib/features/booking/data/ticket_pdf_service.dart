import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../models/booking.dart';

class TicketPdfService {
  static Future<File> create(Booking booking) async {
    final document = pw.Document();
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('LouageGo', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 8),
              pw.Text(
                'Billet de réservation',
                style: pw.TextStyle(fontSize: 18),
              ),
              pw.Divider(),
              _line('Référence', booking.id),
              _line(
                'Conducteur',
                booking.driverName.isEmpty
                    ? 'Non renseigné'
                    : booking.driverName,
              ),
              _line(
                'Matricule',
                booking.matricule.isEmpty ? 'Non renseigné' : booking.matricule,
              ),
              _line('Départ', booking.departureTime),
              _line('Places', booking.selectedSeats.join(', ')),
              _line('Total', '${booking.totalPrice.toStringAsFixed(2)} DT'),
              pw.SizedBox(height: 24),
              pw.Text('Référence locale : ${booking.qrCode}'),
              pw.SizedBox(height: 12),
              pw.Text(
                'Présentez ce billet et sa référence au conducteur. '
                'Le QR code contient un lien local utilisable par LouageGo.',
              ),
            ],
          ),
        ),
      ),
    );
    final bytes = await document.save();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/ticket_${booking.id}.pdf');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<void> share(Booking booking) async {
    final file = await create(booking);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Billet LouageGo ${booking.id}',
      ),
    );
  }

  static pw.Widget _line(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 5),
    child: pw.Row(
      children: [
        pw.SizedBox(width: 100, child: pw.Text('$label :')),
        pw.Expanded(child: pw.Text(value)),
      ],
    ),
  );
}
