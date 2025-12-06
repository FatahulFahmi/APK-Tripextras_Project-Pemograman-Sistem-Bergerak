import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import 'flight_booking_screen.dart'; // ⬅️ Pastikan file ini ada di folder yang sama (flight/)

class SearchResultScreen extends StatelessWidget {
  final String from;
  final String to;
  final DateTime date;
  final String passengers;
  final String seatClass;

  const SearchResultScreen({
    super.key,
    required this.from,
    required this.to,
    required this.date,
    required this.passengers,
    required this.seatClass,
  });

  @override
  Widget build(BuildContext context) {
    // 🔹 Data dummy penerbangan
    final List<Map<String, String>> flights = [
      {
        'airline': 'Garuda Indonesia',
        'departure': '08:30',
        'arrival': '10:15',
        'price': '1.250.000'
      },
      {
        'airline': 'Lion Air',
        'departure': '10:45',
        'arrival': '12:20',
        'price': '850.000'
      },
      {
        'airline': 'Citilink',
        'departure': '13:00',
        'arrival': '14:45',
        'price': '950.000'
      },
      {
        'airline': 'Batik Air',
        'departure': '16:30',
        'arrival': '18:05',
        'price': '1.100.000'
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Available Flights',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Info Pencarian
            Container(
              width: double.infinity,
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
                  Text(
                    '$from  →  $to',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_formatDate(date)} • $passengers • $seatClass',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Flight Options",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 🔹 Daftar Pilihan Penerbangan
            Expanded(
              child: ListView.builder(
                itemCount: flights.length,
                itemBuilder: (context, index) {
                  final flight = flights[index];
                  return _FlightCard(
                    airline: flight['airline']!,
                    departure: flight['departure']!,
                    arrival: flight['arrival']!,
                    price: flight['price']!,
                    from: from,
                    to: to,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔸 Format tanggal
  String _formatDate(DateTime date) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }
}

// ✈️ Widget Kartu Penerbangan
class _FlightCard extends StatelessWidget {
  final String airline;
  final String departure;
  final String arrival;
  final String price;
  final String from;
  final String to;

  const _FlightCard({
    required this.airline,
    required this.departure,
    required this.arrival,
    required this.price,
    required this.from,
    required this.to,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman booking
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlightBookingScreen(
              airline: airline,
              from: from,
              to: to,
              time: '$departure → $arrival',
              price: 'Rp $price',
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.flight_takeoff, color: Colors.blue, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      airline,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$departure → $arrival',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rp $price',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
