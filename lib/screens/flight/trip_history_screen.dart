import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/auth_service.dart';
import '../../models/trip_model.dart';
import '../../models/ticket_model.dart';
import 'e_ticket_screen.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          "Riwayat Pesanan",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: FutureBuilder(
        future: AuthService.instance.getStoredUser(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || userSnapshot.data == null) {
            print("DEBUG: User tidak ditemukan di AuthService"); // 🛠️ DEBUG
            return _buildEmptyState("Silakan login untuk melihat riwayat.");
          }

          final userId = userSnapshot.data!.id;
          print("DEBUG: User ID yang sedang login: $userId"); // 🛠️ DEBUG

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tickets')
                .where('userId', isEqualTo: userId)
                .orderBy('bookingDate', descending: true)
                .snapshots(),
            builder: (context, ticketSnapshot) {
              if (ticketSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!ticketSnapshot.hasData ||
                  ticketSnapshot.data!.docs.isEmpty) {
                print(
                  "DEBUG: Query berhasil tapi data TIKET kosong untuk User ID ini.",
                ); // 🛠️ DEBUG
                return _buildEmptyState("Belum ada tiket yang dipesan.");
              }

              print(
                "DEBUG: Ditemukan ${ticketSnapshot.data!.docs.length} tiket.",
              ); // 🛠️ DEBUG

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: ticketSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final ticketDoc = ticketSnapshot.data!.docs[index];
                  final ticket = TicketModel.fromSnapshot(ticketDoc);

                  print(
                    "DEBUG: Tiket ID: ${ticket.id}, Flight ID: ${ticket.flightId}",
                  ); // 🛠️ DEBUG

                  // Ambil Detail Penerbangan
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('flights')
                        .doc(ticket.flightId)
                        .get(),
                    builder: (context, flightSnapshot) {
                      if (!flightSnapshot.hasData)
                        return const SizedBox(
                          height: 100,
                          child: Center(child: CircularProgressIndicator()),
                        );

                      // Cek apakah data flight ada
                      if (!flightSnapshot.data!.exists) {
                        print(
                          "DEBUG: ERROR! Flight ID ${ticket.flightId} tidak ditemukan di koleksi 'flights'. Kartu disembunyikan.",
                        ); // 🛠️ DEBUG
                        // Jika ingin tetap tampil meski data flight hilang (agar tidak kosong melompong),
                        // kita bisa return kartu error, tapi untuk sekarang kita shrink dulu.
                        return const SizedBox.shrink();
                      }

                      final flightData =
                          flightSnapshot.data!.data() as Map<String, dynamic>;
                      final trip = TripModel.fromJson(
                        flightData,
                        ticket.flightId,
                      );

                      return _buildHistoryCard(context, ticket, trip);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    TicketModel ticket,
    TripModel trip,
  ) {
    // Format Data
    final dateStr = DateFormat(
      'd MMM yyyy',
    ).format(trip.departureTime.toDate());
    final timeStr = DateFormat('HH:mm').format(trip.departureTime.toDate());

    // Hitung Durasi Manual
    final durationDiff = trip.arrivalTime.toDate().difference(
      trip.departureTime.toDate(),
    );
    final String durationString =
        "${durationDiff.inHours}h ${durationDiff.inMinutes.remainder(60)}m";

    // Kode Kota
    final String originCode = trip.origin.length >= 3
        ? trip.origin.substring(0, 3).toUpperCase()
        : trip.origin;
    final String destinationCode = trip.destination.length >= 3
        ? trip.destination.substring(0, 3).toUpperCase()
        : trip.destination;

    final bool isVerified = ticket.status == 'verified';
    final statusColor = isVerified ? Colors.green : Colors.orange;
    final statusText = isVerified ? "E-Ticket Ready" : "Menunggu Verifikasi";

    return GestureDetector(
      onTap: () {
        if (isVerified) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ETicketScreen(ticket: ticket, trip: trip),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Tiket sedang diverifikasi oleh Admin. Harap tunggu.",
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.flight,
                          color: Colors.blueAccent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.airline,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            ticket.seatClass,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: statusColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 0.5),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        originCode,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(
                        Icons.flight_takeoff,
                        color: Colors.grey,
                        size: 20,
                      ),
                      Text(
                        durationString,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        destinationCode,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm').format(trip.arrivalTime.toDate()),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FD),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.grey, size: 18),
                      const SizedBox(width: 5),
                      Text(
                        ticket.passengerName,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'IDR ',
                      decimalDigits: 0,
                    ).format(trip.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.airplane_ticket_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
