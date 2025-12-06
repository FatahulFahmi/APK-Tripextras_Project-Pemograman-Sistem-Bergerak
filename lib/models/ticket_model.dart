// lib/models/ticket_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  final String? id; // ID Dokumen dari Firestore
  final String userId;
  final String userName; // Denormalisasi (duplikasi) data untuk kemudahan
  final String flightId;
  final String flightDestination; // Denormalisasi data
  final String seatNumber;
  final String status;
  final Timestamp createdAt;

  TicketModel({
    this.id,
    required this.userId,
    required this.userName,
    required this.flightId,
    required this.flightDestination,
    required this.seatNumber,
    required this.status,
    required this.createdAt,
  });

  // Method untuk mengubah object TicketModel menjadi Map
  // Ini digunakan saat MENULIS data ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'flightId': flightId,
      'flightDestination': flightDestination,
      'seatNumber': seatNumber,
      'status': status,
      'createdAt': createdAt,
    };
  }

  // Factory constructor untuk membuat TicketModel dari DocumentSnapshot
  // Ini digunakan saat MEMBACA data dari Firestore
  factory TicketModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return TicketModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      flightId: data['flightId'] ?? '',
      flightDestination: data['flightDestination'] ?? '',
      seatNumber: data['seatNumber'] ?? '',
      status: data['status'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}