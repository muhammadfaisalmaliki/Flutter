import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  final CollectionReference tiketCollection =
      FirebaseFirestore.instance.collection('Tiket');

  final CollectionReference pembelianCollection =
      FirebaseFirestore.instance.collection('Pembelian');

  Stream<QuerySnapshot> getTiket() {
    return tiketCollection.snapshots();
  }


  Future<void> deleteTiket(String tiketId) {
    return tiketCollection.doc(tiketId).delete();
  }

  Future<void> addPembelian(Map<String, dynamic> tiketData) {
    return pembelianCollection.add(tiketData);
  }
  
}

