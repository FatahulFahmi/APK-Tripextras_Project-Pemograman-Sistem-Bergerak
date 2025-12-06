// lib/services/activity_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityService {
  // Gunakan pola Singleton, sama seperti AuthService Anda
  ActivityService._();
  static final ActivityService instance = ActivityService._();

  // 1. Buat referensi ke koleksi BARU: 'activities'
  final CollectionReference _activities =
      FirebaseFirestore.instance.collection('activities');

  /// Mencatat satu log aktivitas baru ke Firestore.
  ///
  /// [text] adalah pesan yang akan ditampilkan (misal: "User baru terdaftar")
  /// [iconType] adalah string untuk membantu dashboard memilih ikon
  /// (misal: 'user', 'flight', 'ticket', 'destination')
  Future<void> createActivity(String text, {String iconType = 'info'}) async {
    try {
      await _activities.add({
        'text': text,
        'iconType': iconType,
        'timestamp': FieldValue.serverTimestamp(), // Sangat penting untuk mengurutkan
      });
    } catch (e) {
      // Gagal mencatat log BUKAN masalah besar,
      // jadi kita tidak melempar error, hanya print ke konsol.
      print('Gagal mencatat aktivitas: $e');
    }
  }

  // ✅ FUNGSI BARU (READ)
  /// Mendapatkan stream dari 5 aktivitas terbaru
  Stream<QuerySnapshot> getActivitiesStream() {
    return _activities
        .orderBy('timestamp', descending: true)
        .limit(5) // Ambil 5 terbaru
        .snapshots();
  }
}

