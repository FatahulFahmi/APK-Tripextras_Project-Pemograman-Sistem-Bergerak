import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManageTicketsScreen extends StatefulWidget {
  const ManageTicketsScreen({super.key});

  @override
  State<ManageTicketsScreen> createState() => _ManageTicketsScreenState();
}

class _ManageTicketsScreenState extends State<ManageTicketsScreen> {
  // Fungsi untuk Memverifikasi Tiket
  Future<void> _verifyTicket(String ticketId) async {
    try {
      await FirebaseFirestore.instance
          .collection('tickets')
          .doc(ticketId)
          .update({'status': 'verified'}); // Mengubah status menjadi verified

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tiket berhasil diverifikasi!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal verifikasi: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Colors.blueAccent;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        title: const Text(
          "Kelola Tiket Pesanan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // 1. Ambil Data Tiket dari Koleksi 'tickets'
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .orderBy('bookingDate', descending: true) // Tiket terbaru di atas
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final ticketDoc = snapshot.data!.docs[index];
              final ticketData = ticketDoc.data() as Map<String, dynamic>;
              final String flightId = ticketData['flightId'] ?? '';

              // 2. Ambil Detail Penerbangan berdasarkan flightId (Relasi Data)
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('flights')
                    .doc(flightId)
                    .get(),
                builder: (context, flightSnapshot) {
                  if (!flightSnapshot.hasData) {
                    return const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  // Handle jika data flight terhapus tapi tiket masih ada
                  final flightData = flightSnapshot.data!.exists
                      ? flightSnapshot.data!.data() as Map<String, dynamic>
                      : null;

                  return _buildTicketAdminCard(
                    ticketDoc.id,
                    ticketData,
                    flightData,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // --- WIDGET KARTU TIKET ADMIN ---
  Widget _buildTicketAdminCard(
    String ticketId,
    Map<String, dynamic> ticket,
    Map<String, dynamic>? flight,
  ) {
    final bool isVerified = ticket['status'] == 'verified';
    final String airline = flight?['airline'] ?? 'Unknown Airline';
    final String route = flight != null
        ? "${flight['origin']} ➔ ${flight['destination']}"
        : "Rute Tidak Dikenal";

    // Format Tanggal Booking
    final Timestamp? ts = ticket['bookingDate'];
    final String bookingDate = ts != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(ts.toDate())
        : '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Nama Penumpang & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket['passengerName'] ?? 'No Name',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "ID: ${ticket['passengerId']}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                // Badge Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isVerified
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isVerified ? Colors.green : Colors.orange,
                    ),
                  ),
                  child: Text(
                    isVerified ? "VERIFIED" : "PENDING",
                    style: TextStyle(
                      color: isVerified ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 25),

            // Body: Detail Penerbangan
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.flight, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        airline,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        route,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Booking: $bookingDate",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Footer: Tombol Aksi
            isVerified
                ? SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: null, // Disabled karena sudah verifikasi
                      icon: const Icon(Icons.check, color: Colors.green),
                      label: const Text(
                        "Tiket Telah Diverifikasi",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showVerifyDialog(ticketId, ticket['passengerName']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(
                        Icons.verified_user,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        "Verifikasi Tiket",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // Dialog Konfirmasi Verifikasi
  void _showVerifyDialog(String ticketId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Verifikasi Pembayaran"),
        content: Text(
          "Apakah Anda yakin ingin memverifikasi tiket atas nama $name?\n\nPastikan pembayaran sudah diterima.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _verifyTicket(ticketId); // Panggil fungsi update status
            },
            child: const Text("Ya, Verifikasi"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            "Belum ada pesanan tiket masuk.",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
