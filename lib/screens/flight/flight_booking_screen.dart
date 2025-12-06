import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../routes/app_routes.dart';

class FlightBookingScreen extends StatefulWidget {
  final String airline;
  final String from;
  final String to;
  final String time;
  final String price;

  const FlightBookingScreen({
    super.key,
    required this.airline,
    required this.from,
    required this.to,
    required this.time,
    required this.price,
  });

  @override
  State<FlightBookingScreen> createState() => _FlightBookingScreenState();
}

class _FlightBookingScreenState extends State<FlightBookingScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  bool isRefunded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Flight Booking',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Informasi Tiket
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flight_takeoff, color: Colors.blue),
                      const SizedBox(width: 10),
                      Text(
                        widget.airline,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${widget.from} → ${widget.to}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(widget.time, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 6),
                  Text(
                    widget.price,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 👤 Data Penumpang
            const Text(
              'Passenger Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildTextField(nameController, 'Full Name'),
            const SizedBox(height: 10),
            _buildTextField(idController, 'ID / Passport Number'),
            const SizedBox(height: 25),

            // 💳 Metode Pembayaran
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Icon(Icons.account_balance_wallet, color: Colors.blue),
                  SizedBox(width: 10),
                  Text('Virtual Account (BCA / Mandiri / BNI)'),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ✅ Tombol Konfirmasi Booking
            SizedBox(
              width: double.infinity,
              child: InkWell(
                onTap: _handleBooking,
                borderRadius: BorderRadius.circular(12),
                splashColor: Colors.white24,
                child: Ink(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: const Center(
                    child: Text(
                      'Confirm Booking',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 🔁 Refund Section
            const Text(
              'Need to cancel?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'You can request a refund for your ticket before departure time.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: InkWell(
                      onTap: isRefunded
                          ? null
                          : () {
                              setState(() {
                                isRefunded = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Refund has been successfully requested.'),
                                ),
                              );
                            },
                      borderRadius: BorderRadius.circular(10),
                      splashColor: Colors.red.shade200,
                      child: Ink(
                        decoration: BoxDecoration(
                          color: isRefunded ? Colors.grey : Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            isRefunded
                                ? 'Refund Requested'
                                : 'Request Refund',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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

  /// Fungsi validasi dan navigasi ke halaman sukses
  void _handleBooking() {
    if (nameController.text.isEmpty || idController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete passenger details.'),
        ),
      );
      return;
    }

    // Navigasi ke halaman sukses booking
    Navigator.pushNamed(context, AppRoutes.bookingSuccess);
  }

  /// Text field builder agar tidak repetitif
  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
