import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import 'search_result_screen.dart'; // 👉 tambahkan ini untuk navigasi

class FlightScreen extends StatefulWidget {
  const FlightScreen({super.key});

  @override
  State<FlightScreen> createState() => _FlightScreenState();
}

class _FlightScreenState extends State<FlightScreen> {
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  DateTime selectedDate = DateTime(2025, 10, 28);
  String passengers = '2 Adult';
  String seatClass = 'Business';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Book Your Flight',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Destination',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 🧳 Card Utama Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Asal Bandara
                  TextField(
                    controller: fromController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.flight_takeoff, color: Colors.black54),
                      labelText: 'From',
                      hintText: 'Enter departure city or airport',
                      border: InputBorder.none,
                    ),
                  ),
                  const Divider(),
                  // Tujuan Bandara
                  TextField(
                    controller: toController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.flight_land, color: Colors.black54),
                      labelText: 'To',
                      hintText: 'Enter destination city or airport',
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tanggal
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F5FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.black54),
                          const SizedBox(width: 10),
                          Text(
                            '${selectedDate.day} ${_monthName(selectedDate.month)} ${selectedDate.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Penumpang & Kelas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _OptionBox(
                        icon: Icons.person,
                        label: passengers,
                        onTap: () {
                          setState(() {
                            passengers = passengers == '2 Adult'
                                ? '1 Adult'
                                : '2 Adult';
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      _OptionBox(
                        icon: Icons.chair,
                        label: seatClass,
                        onTap: () {
                          setState(() {
                            seatClass = seatClass == 'Business'
                                ? 'Economy'
                                : 'Business';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tombol Search
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (fromController.text.isEmpty ||
                            toController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Please fill both From and To fields'),
                            ),
                          );
                        } else {
                          // 🚀 Navigasi ke halaman hasil pencarian
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchResultScreen(
                                from: fromController.text,
                                to: toController.text,
                                date: selectedDate,
                                passengers: passengers,
                                seatClass: seatClass,
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Search Ticket',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Center(
              child: Text(
                "Make your memories more memorable with us",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
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
    return months[month];
  }
}

// 🔹 Widget kecil untuk kotak opsi (Passengers / Class)
class _OptionBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionBox({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F5FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.black54),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
