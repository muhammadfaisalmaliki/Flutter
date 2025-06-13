import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ticketing_app/services/firebase.dart';
import 'package:ticketing_app/views/pembayaran.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key}); // Tidak perlu tiketId lagi

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FireStoreService fireStoreService = FireStoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Ticketing App",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fireStoreService.getTiket(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List ticketlist = snapshot.data!.docs;

            return Padding(
              padding: const EdgeInsets.all(10),
              child: ListView.builder(
                itemCount: ticketlist.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = ticketlist[index];
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;

                  String name = data['name'] ?? '';
                  String jenisTiket = data['jenis_tiket'] ?? '';
                  int harga = data['Harga'] ?? 0;
                  Timestamp tanggal = data['Tanggal'] ?? Timestamp.now();

                  return Card(
                    child: ListTile(
                      title: Text(
                        name,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(jenisTiket, style: GoogleFonts.poppins()),
                          Text(
                            'Harga: Rp ${harga.toString()}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PembayaranPage(
                                    name: name,
                                    jenisTiket: jenisTiket,
                                    harga: harga,
                                    tanggal: tanggal,
                                    tiketId: document.id,
                                  ),
                                ),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(Color(0xFF2563EB)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.shopping_cart, color: Colors.white),
                                Text(
                                  "Beli",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}