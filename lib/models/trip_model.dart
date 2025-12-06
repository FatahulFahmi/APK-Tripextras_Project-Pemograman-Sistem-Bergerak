// lib/models/trip_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String id;
  final String airline;
  final String flightCode;
  final String origin;
  final String destination;
  final Timestamp departureTime;
  final Timestamp arrivalTime;
  final double price;
  final int availableSeats;

  TripModel({
    required this.id,
    required this.airline,
    required this.flightCode,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.availableSeats,
  });

  // Factory untuk membuat model dari Map (data dari Firestore)
  // FUNGSI ANDA INI SUDAH BENAR
  factory TripModel.fromJson(Map<String, dynamic> json, String documentId) {
    return TripModel(
      id: documentId, // Gunakan ID dokumen
      airline: json['airline'] ?? 'Unknown Airline',
      flightCode: json['flightCode'] ?? 'N/A',
      origin: json['origin'] ?? '???',
      destination: json['destination'] ?? '???',
      // Pastikan data adalah Timestamp, beri default jika null
      departureTime: json['departureTime'] as Timestamp? ?? Timestamp.now(),
      arrivalTime: json['arrivalTime'] as Timestamp? ?? Timestamp.now(),
      price: (json['price'] ?? 0.0).toDouble(),
      availableSeats: (json['availableSeats'] ?? 0).toInt(),
    );
  }

  // ============================================================
  // ✅ TAMBAHAN BARU: Factory dari Firestore Snapshot
  // ============================================================
  // Ini adalah fungsi yang HILANG dan dibutuhkan oleh 'manage_tickets_screen.dart'
  factory TripModel.fromSnapshot(DocumentSnapshot doc) {
    // Ambil data dari snapshot, jadikan Map
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Panggil 'fromJson' Anda yang sudah ada di atas,
    // dengan mengirimkan data dan ID dokumennya
    return TripModel.fromJson(data, doc.id);
  }

  // Method untuk mengubah model ke Map (untuk dikirim ke Firestore)
  // ANDA MUNGKIN BUTUH INI UNTUK 'manage_flights_screen.dart'
  Map<String, dynamic> toJson() {
    return {
      'airline': airline,
      'flightCode': flightCode,
      'origin': origin,
      'destination': destination,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'price': price,
      'availableSeats': availableSeats,
    };
  }
}
