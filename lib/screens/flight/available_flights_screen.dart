import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart'; // ✅ pastikan path benar

class AvailableFlightsScreen extends StatelessWidget {
  const AvailableFlightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 Daftar penerbangan (dummy data)
    final flights = [
      {
        'airline': 'Garuda Indonesia',
        'from': 'Jakarta (CGK)',
        'to': 'Pangkal Pinang (PGK)',
        'departure': '08:30',
        'arrival': '10:15',
        'price': 'Rp 1.250.000'
      },
      {
        'airline': 'Lion Air',
        'from': 'Jakarta (CGK)',
        'to': 'Pangkal Pinang (PGK)',
        'departure': '10:45',
        'arrival': '12:20',
        'price': 'Rp 850.000'
      },
      {
        'airline': 'Citilink',
        'from': 'Jakarta (CGK)',
        'to': 'Pangkal Pinang (PGK)',
        'departure': '13:00',
        'arrival': '14:45',
        'price': 'Rp 950.000'
      },
      {
        'airline': 'Batik Air',
        'from': 'Jakarta (CGK)',
        'to': 'Pangkal Pinang (PGK)',
        'departure': '16:30',
        'arrival': '18:05',
        'price': 'Rp 1.100.000'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A184D),
        title: const Text(
          'Available Flights',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFF4F7FF),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Info penerbangan utama
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jakarta → Pangkal Pinang',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '23 October 2025 • 2 Adult • Business',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Flight Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 🔹 Daftar penerbangan dengan efek klik
            Expanded(
              child: ListView.builder(
                itemCount: flights.length,
                itemBuilder: (context, index) {
                  final flight = flights[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      splashColor: Colors.blue.withOpacity(0.3),
                      onTap: () {
                        // ✅ Navigasi ke halaman FlightBooking
                        Navigator.pushNamed(
                          context,
                          AppRoutes.flightBooking,
                          arguments: {
                            'airline': flight['airline'],
                            'from': flight['from'],
                            'to': flight['to'],
                            'time':
                                '${flight['departure']} - ${flight['arrival']}',
                            'price': flight['price'],
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.flight_takeoff,
                                    color: Colors.blue, size: 28),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      flight['airline']!,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${flight['departure']} → ${flight['arrival']}',
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              flight['price']!,
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
