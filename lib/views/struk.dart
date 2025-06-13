import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// Tambahan untuk Web download
// Tambahkan di pubspec.yaml bagian dependencies:
// universal_html: ^2.2.4
import 'package:universal_html/html.dart' as html;

class StrukPage extends StatefulWidget {
  final String tiketId;
  final String name;
  final String jenisTiket;
  final int harga;
  final Timestamp tanggal;

  const StrukPage({
    super.key,
    required this.tiketId,
    required this.name,
    required this.jenisTiket,
    required this.tanggal,
    required this.harga,
  });

  @override
  State<StrukPage> createState() => _StrukPageState();
}

class _StrukPageState extends State<StrukPage> {
  String? _successMessage; // state untuk pesan sukses

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    // kode PDF tetap sama
    final pdf = pw.Document();

    final tanggalFormatted = DateTime.fromMillisecondsSinceEpoch(
      widget.tanggal.millisecondsSinceEpoch,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'Bukti Pembayaran',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Nama: ${widget.name}'),
                pw.Text('Jenis Tiket: ${widget.jenisTiket}'),
                pw.Text('Harga: Rp ${widget.harga}'),
                pw.Text(
                  'Tanggal: ${tanggalFormatted.day}/${tanggalFormatted.month}/${tanggalFormatted.year}',
                ),
                pw.Divider(),
                pw.Text(
                  'Total Pembayaran: Rp ${widget.harga}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Spacer(),
                pw.Center(
                  child: pw.Text('Terima kasih telah melakukan transaksi!'),
                )
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _exportPdfUniversal() async {
    final pdfBytes = await _generatePdf(PdfPageFormat.a4);

    if (kIsWeb) {
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.Url.revokeObjectUrl(url);
    } else {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    }
  }

  Future<void> _handleExportPdf() async {
    await _exportPdfUniversal();
    setState(() {
      _successMessage = "Bukti pembayaran berhasil diunduh!";
    });

    // Optional: hapus pesan setelah beberapa detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _successMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Bukti Pembayaran',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Tampilkan pesan sukses jika ada
            if (_successMessage != null)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF008746),
                      size: 12,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _successMessage!,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF008746),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            Card(
              child: ListTile(
                title: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(1000)),
                        color: Color.fromARGB(29, 51, 147, 216),
                        image: DecorationImage(
                          image: AssetImage('assets/images/image9.png'),
                          fit: BoxFit.none,
                          scale: 2.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        Text("Pembayaran Berhasil",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text("Transaksi kamu telah selesai.",
                            style: GoogleFonts.poppins(fontSize: 12)),
                        Text("Detail pembelian ada di bawah ini.",
                            style: GoogleFonts.poppins(fontSize: 12)),
                      ],
                    )
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.name,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(widget.jenisTiket,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text(
                            "Rp ${widget.harga}",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total Pembayaran",
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold)),
                          Text("Rp ${widget.harga}",
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 146,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xFF1D4ED8),
                            ),
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Center(
                                child: Text(
                                  "Kembali",
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 146,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xFF1D4ED8),
                            ),
                            child: InkWell(
                              onTap: _handleExportPdf,
                              child: Center(
                                child: Text(
                                  "Export Pdf",
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}