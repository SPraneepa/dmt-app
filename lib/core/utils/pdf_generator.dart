import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/appointment_model.dart';

class PdfGenerator {
  static Future<void> generateAndPrintReceipt(
    AppointmentModel appointment,
  ) async {
    final pdf = pw.Document();

    final primaryMaroon = PdfColor.fromHex('#670000');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header Banner
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  color: primaryMaroon,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'DEPARTMENT OF MOTOR TRAFFIC',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'SRI LANKA - APPOINTMENT CONFIRMATION RECEIPT',
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 24),

                // Notice Box
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(6),
                    ),
                  ),
                  child: pw.Text(
                    'Please present this document along with your original NIC upon arrival at the district office. Arrive 10 minutes prior to your allocated time slot.',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey800,
                    ),
                  ),
                ),
                pw.SizedBox(height: 24),

                // Applicant Information Section
                pw.Text(
                  'APPLICANT INFORMATION',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryMaroon,
                  ),
                ),
                pw.Divider(color: primaryMaroon, thickness: 1),
                pw.SizedBox(height: 8),
                _buildPdfRow('NIC Number:', appointment.nic),
                _buildPdfRow('Full Name:', appointment.fullName),
                _buildPdfRow('Contact Number:', appointment.phoneNumber),
                pw.SizedBox(height: 20),

                // Booking Information Section
                pw.Text(
                  'APPOINTMENT DETAILS',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryMaroon,
                  ),
                ),
                pw.Divider(color: primaryMaroon, thickness: 1),
                pw.SizedBox(height: 8),
                _buildPdfRow('Service Type:', appointment.service),
                _buildPdfRow('District Office:', appointment.district),
                _buildPdfRow('Appointment Date:', appointment.date),
                _buildPdfRow('Allocated Time Slot:', appointment.timeSlot),
                _buildPdfRow('Reference Code:', 'DMT-SL-REF-2026'),
                pw.SizedBox(height: 40),

                // Footer
                pw.Spacer(),
                pw.Divider(color: PdfColors.grey400),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Generated via DMT Mobile App',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(
                      'Government of Sri Lanka',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    // Displays native Print/PDF Save dialog on mobile & desktop
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'DMT_Appointment_Receipt.pdf',
    );
  }

  // Row builder with proper wrapping and alignment
  static pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
