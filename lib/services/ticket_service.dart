// lib/services/ticket_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ticket_model.dart'; // Sesuaikan path jika perlu

class TicketService {
  // Referensi ke koleksi 'tickets' di Firestore
  final CollectionReference _ticketsCollection =
      FirebaseFirestore.instance.collection('tickets');

  // 1. FUNGSI CREATE: Membuat tiket baru
  Future<void> createTicket(TicketModel ticket) async {
    try {
      // .add() akan otomatis membuat ID dokumen unik
      await _ticketsCollection.add(ticket.toMap());
    } catch (e) {
      // Melempar error kembali ke UI untuk ditampilkan
      throw Exception('Gagal membuat tiket: $e');
    }
  }

  // 2. FUNGSI READ: Mendapatkan stream (daftar live) semua tiket
  // Diurutkan berdasarkan yang terbaru
  Stream<List<TicketModel>> getTicketsStream() {
    return _ticketsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TicketModel.fromSnapshot(doc);
      }).toList();
    });
  }

  // 3. FUNGSI DELETE: Menghapus tiket berdasarkan ID
  Future<void> deleteTicket(String ticketId) async {
    try {
      await _ticketsCollection.doc(ticketId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus tiket: $e');
    }
  }

  // ---
  // Fungsi helper untuk formulir admin
  // ---

  // Mengambil semua user (untuk dropdown)
  Future<List<QueryDocumentSnapshot>> getAllUsers() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      return snapshot.docs;
    } catch (e) {
      throw Exception('Gagal mengambil data users: $e');
    }
  }

  // =======================================================
  // ✅ PERBAIKAN: Mengambil dari 'flights', bukan 'trips'
  // =======================================================
  Future<List<QueryDocumentSnapshot>> getAllFlights() async {
    try {
      // Ganti 'trips' menjadi 'flights' agar konsisten
      final snapshot =
          await FirebaseFirestore.instance.collection('flights').get();
      return snapshot.docs;
    } catch (e) {
      // Perbarui juga pesan errornya
      throw Exception('Gagal mengambil data flights: $e');
    }
  }
}
