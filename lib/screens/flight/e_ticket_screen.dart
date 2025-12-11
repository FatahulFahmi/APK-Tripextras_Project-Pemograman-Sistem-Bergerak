import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/ticket_model.dart';
import '../../models/trip_model.dart';

// ✅ IMPORT BARU UNTUK PDF
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ETicketScreen extends StatelessWidget {
  final TicketModel ticket;
  final TripModel trip;

  const ETicketScreen({super.key, required this.ticket, required this.trip});

  // ==========================================
  // 🖨️ FUNGSI GENERATE PDF
  // ==========================================
  Future<void> _generateAndDownloadPdf(BuildContext context) async {
    final pdf = pw.Document();

    // Format Data
    final dateStr = DateFormat(
      'd MMM yyyy',
    ).format(trip.departureTime.toDate());
    final timeDep = DateFormat('HH:mm').format(trip.departureTime.toDate());
    final timeArr = DateFormat('HH:mm').format(trip.arrivalTime.toDate());

    // Desain PDF (Mirip Coding Flutter tapi pakai 'pw.')
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "TRIPEXTRAS E-TICKET",
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue,
                      ),
                    ),
                    pw.Text(
                      "Booking Ref: ${ticket.id.substring(0, 6).toUpperCase()}",
                      style: const pw.TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Detail Penerbangan
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      trip.airline,
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      "Economy Class",
                      style: const pw.TextStyle(color: PdfColors.grey),
                    ),
                    pw.Divider(),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              trip.origin,
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(timeDep),
                          ],
                        ),
                        pw.Icon(
                          const pw.IconData(0xe5df),
                          color: PdfColors.blue,
                          size: 30,
                        ), // Icon Arrow
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              trip.destination,
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(timeArr),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Detail Penumpang
              pw.Table.fromTextArray(
                context: context,
                border: null,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
                data: <List<String>>[
                  ['Passenger Name', 'Date', 'Seat'],
                  [ticket.passengerName, dateStr, '14B'], // Data Dummy Seat
                ],
              ),

              pw.Spacer(),

              // QR Code di PDF
              pw.Center(
                child: pw.BarcodeWidget(
                  data: ticket.ticketId,
                  barcode: pw.Barcode.qrCode(),
                  width: 100,
                  height: 100,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text("Show this QR code at the airport gate"),
              ),
            ],
          );
        },
      ),
    );

    // 🚀 Munculkan Menu Print/Save as PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'E-Ticket-${ticket.passengerName}.pdf', // Nama file saat disimpan
    );
  }

  // ==========================================
  // UI LAYAR (TETAP SAMA SEPERTI SEBELUMNYA)
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        title: const Text("E-Tiket", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "Tunjukkan QR Code ini kepada petugas bandara",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // 🎫 KARTU E-TIKET (TAMPILAN UI)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header Biru
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip.airline,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Economy Class",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.flight, color: Colors.white, size: 30),
                      ],
                    ),
                  ),

                  // Body
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCodeColumn(
                              trip.origin,
                              DateFormat(
                                'HH:mm',
                              ).format(trip.departureTime.toDate()),
                            ),
                            const Icon(
                              Icons.flight_takeoff,
                              color: Colors.grey,
                            ),
                            _buildCodeColumn(
                              trip.destination,
                              DateFormat(
                                'HH:mm',
                              ).format(trip.arrivalTime.toDate()),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildDetail("PENUMPANG", ticket.passengerName),
                            _buildDetail(
                              "TANGGAL",
                              DateFormat(
                                'd MMM yyyy',
                              ).format(trip.departureTime.toDate()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // QR Code
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(Icons.qr_code_2, size: 100, color: Colors.black87),
                        const SizedBox(height: 10),
                        Text(
                          ticket.ticketId,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ✅ TOMBOL DOWNLOAD PDF (SUDAH AKTIF)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    _generateAndDownloadPdf(context), // Panggil fungsi PDF
                icon: const Icon(Icons.download),
                label: const Text("Unduh E-Tiket (PDF)"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: const BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets UI (Tetap Sama)
  Widget _buildCodeColumn(String city, String time) {
    String code = city.length > 3
        ? city.substring(0, 3).toUpperCase()
        : city.toUpperCase();
    return Column(
      children: [
        Text(
          code,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(time, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
