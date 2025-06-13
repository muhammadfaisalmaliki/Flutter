import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:ticketing_app/views/Struk.dart';
import 'package:ticketing_app/services/firebase.dart';

enum MetodePembayaran { tunai, kartuKredit, qris }

class PembayaranPage extends StatefulWidget {
  final String tiketId;
  final String name;
  final String jenisTiket;
  final int harga;
  final Timestamp tanggal;

  const PembayaranPage({
    super.key,
    required this.tiketId,
    required this.name,
    required this.jenisTiket,
    required this.tanggal,
    required this.harga,
  });

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  final fireStoreService = FireStoreService();

  Future<void> _handlePembayaran(MetodePembayaran metode) async {
    String metodeText;
    String imageAsset;
    String titleText;
    Widget? extraWidget;

    switch (metode) {
      case MetodePembayaran.tunai:
        metodeText = "Tunai";
        imageAsset = 'assets/images/image6.png';
        titleText = "Pembayaran Tunai";
        break;
      case MetodePembayaran.kartuKredit:
        metodeText = "Kartu Kredit";
        imageAsset = 'assets/images/image7.png';
        titleText = "Pembayaran Kartu Kredit";
        extraWidget = _buildCopyCard();
        break;
      case MetodePembayaran.qris:
        metodeText = "QRIS";
        imageAsset = 'assets/images/image8.png';
        titleText = "Pembayaran QRIS";
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  titleText,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D4ED8),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFFF3F4F6),
                image: DecorationImage(
                  image: AssetImage(imageAsset),
                  fit: BoxFit.none,
                  scale: 1.9,
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (extraWidget != null) extraWidget,
            const SizedBox(height: 10),
            Text(
              _getSubTitle(metode),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              width: 210,
              child: Text(
                _getDescription(metode),
                style: GoogleFonts.poppins(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await fireStoreService.addPembelian({
                  'tiketId': widget.tiketId,
                  'name': widget.name,
                  'jenis_tiket': widget.jenisTiket,
                  'Harga': widget.harga,
                  'Metode_Pembayaran': metodeText,
                  'created_at': FieldValue.serverTimestamp(),
                });
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StrukPage(
                        tiketId: widget.tiketId,
                        name: widget.name,
                        jenisTiket: widget.jenisTiket,
                        harga: widget.harga,
                        tanggal: widget.tanggal,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D4ED8),
              ),
              child: Text(
                'Konfirmasi Pembayaran',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSubTitle(MetodePembayaran metode) {
    switch (metode) {
      case MetodePembayaran.tunai:
        return 'Pembayaran Tunai';
      case MetodePembayaran.kartuKredit:
        return 'Transfer Pembayaran';
      case MetodePembayaran.qris:
        return 'Scan QR untuk Membayar';
    }
  }

  String _getDescription(MetodePembayaran metode) {
    switch (metode) {
      case MetodePembayaran.tunai:
        return 'Jika pembayaran telah diterima, klik button konfirmasi pembayaran untuk menyelesaikan transaksi';
      case MetodePembayaran.kartuKredit:
        return 'Pastikan nominal dan tujuan pembayaran sudah benar sebelum melanjutkan.';
      case MetodePembayaran.qris:
        return 'Gunakan aplikasi e-wallet atau mobile banking untuk scan QR di atas dan selesaikan pembayaran';
    }
  }

  Widget _buildCopyCard() {
    return Container(
      height: 40,
      width: 222,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1D4ED8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '8810 7766 1234 9876',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: '8810 7766 1234 9876'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Teks berhasil disalin!')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Pembayaran",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTagihanCard(),
            const SizedBox(height: 40),
            _buildMetodePembayaranSection(),
            const SizedBox(height: 20),
            _buildHelpSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTagihanCard() {
    return Card(
      color: Colors.white,
      elevation: 6,
      shadowColor: Colors.grey,
      child: ListTile(
        title: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: const Color(0xFFF3F4F6),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/image2.png'),
                    fit: BoxFit.none,
                    scale: 2,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Tagihan', style: GoogleFonts.poppins(fontSize: 12)),
                  Text(
                    'Rp ${widget.harga}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRowDetail('Nama pesanan', '${widget.name} - ${widget.jenisTiket}'),
              const SizedBox(height: 5),
              _buildRowDetail('Tanggal',
                  DateFormat('d MMMM yyyy', 'id_ID').format(widget.tanggal.toDate())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowDetail(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 12)),
        Text(value,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMetodePembayaranSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Metode Pembayaran',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _buildMetodeCard('Tunai', 'assets/images/image3.png', MetodePembayaran.tunai),
        _buildMetodeCard('Kartu Kredit', 'assets/images/image4.png', MetodePembayaran.kartuKredit),
        _buildMetodeCard('Qris/QR Pay', 'assets/images/image5.png', MetodePembayaran.qris),
      ],
    );
  }

  Widget _buildMetodeCard(String title, String imagePath, MetodePembayaran metode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        color: Colors.white,
        child: InkWell(
          onTap: () => _handlePembayaran(metode),
          child: ListTile(
            title: Row(
              children: [
                Image.asset(imagePath, height: 30, width: 30),
                const SizedBox(width: 10),
                Text(title, style: GoogleFonts.poppins(fontSize: 16)),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }

  Widget _buildHelpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Punya Pertanyaan ?',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Card(
          color: Colors.white,
          child: ListTile(
            title: Row(
              children: [
                Image.asset('assets/images/image10.png', height: 30, width: 30),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hubungi Admin untuk bantuan',
                        style: GoogleFonts.poppins(fontSize: 12)),
                    Text('pembayaran', style: GoogleFonts.poppins(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
