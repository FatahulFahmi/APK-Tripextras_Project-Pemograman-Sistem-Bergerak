import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  final String id; // ID Dokumen Firestore
  final String userId;
  final String flightId;
  final String passengerName;
  final String passengerId; // NIK / Paspor
  final String seatClass;
  final String paymentMethod;
  final String status; // 'paid', 'verified', dll
  final String totalPrice;
  final Timestamp bookingDate;

  TicketModel({
    required this.id,
    required this.userId,
    required this.flightId,
    required this.passengerName,
    required this.passengerId,
    required this.seatClass,
    required this.paymentMethod,
    required this.status,
    required this.totalPrice,
    required this.bookingDate,
  });

  // Getter agar kode 'ticket.ticketId' di E-Ticket tidak error
  String get ticketId => id;

  // 1. FACTORY: Mengubah data Firestore (Map) MENJADI Object TicketModel
  // Dipakai saat READ data
  factory TicketModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TicketModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      flightId: data['flightId'] ?? '',
      passengerName: data['passengerName'] ?? 'Penumpang',
      passengerId: data['passengerId'] ?? '-',
      seatClass: data['seatClass'] ?? 'Economy',
      paymentMethod: data['paymentMethod'] ?? 'Virtual Account',
      status: data['status'] ?? 'pending',
      totalPrice: data['totalPrice'] ?? '0',
      bookingDate: data['bookingDate'] is Timestamp
          ? data['bookingDate']
          : Timestamp.now(),
    );
  }

  // 2. METHOD BARU: Mengubah Object TicketModel MENJADI Map
  // ✅ Dipakai saat CREATE/UPDATE data ke Firestore (Ini yang bikin error tadi)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'flightId': flightId,
      'passengerName': passengerName,
      'passengerId': passengerId,
      'seatClass': seatClass,
      'paymentMethod': paymentMethod,
      'status': status,
      'totalPrice': totalPrice,
      'bookingDate': bookingDate,
      // Note: 'id' tidak ikut disimpan karena itu ID dokumen yang digenerate otomatis
    };
  }
}
