// lib/models/destination_model.dart

// ✅ 1. IMPORT TAMBAHAN
import 'package:cloud_firestore/cloud_firestore.dart';

class DestinationModel {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final double rating;

  DestinationModel({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.rating,
  });

  // Factory untuk membuat model dari Map (data dari Firestore)
  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    return DestinationModel(
      // ID BUKAN DARI JSON, TAPI DARI DOKUMEN ID
      // Kode di atas tidak menggunakan ID model ini, tapi ini praktik yang baik
      id: json['id'] ?? '',
      name: json['name'] ?? 'No Name',
      location: json['location'] ?? 'No Location',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }

  // ✅ 2. TAMBAHKAN FACTORY BARU "fromSnapshot"
  // Ini adalah cara yang benar untuk membaca data dari Firestore
  factory DestinationModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DestinationModel(
      id: doc.id, // <-- Mengambil ID dokumen yang benar
      name: data['name'] ?? 'No Name',
      location: data['location'] ?? 'No Location',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
    );
  }

  // Method untuk mengubah model ke Map (untuk dikirim ke Firestore)
  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // Sebaiknya ID tidak disimpan di dalam data
      'name': name,
      'location': location,
      'imageUrl': imageUrl,
      'rating': rating,
    };
  }
}
