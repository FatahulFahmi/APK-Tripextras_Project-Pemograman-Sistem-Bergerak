import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../flight/flight_screen.dart'; // pastikan file ini ada

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // untuk BottomNavigationBar

  // Fungsi untuk navigasi berdasarkan index
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Home
        break;
      case 1:
        // Navigasi ke halaman Flight
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FlightScreen()),
        );
        break;
      case 2:
        // Nanti bisa diarahkan ke halaman "History" atau lainnya
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur History belum aktif')),
        );
        break;
      case 3:
        // Nanti diarahkan ke halaman Profile
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur Profile belum aktif')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: const Text(
          "Hi, Whenny!",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const CircleAvatar(
              backgroundImage: AssetImage('assets/images/profile.png'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search your destination',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🚌 Menu Icon Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Flight → Navigasi ke FlightScreen
                _MenuIcon(
                  icon: Icons.flight,
                  label: 'Flight',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FlightScreen()),
                    );
                  },
                ),
                // Train → contoh belum aktif
                _MenuIcon(
                  icon: Icons.train,
                  label: 'Train',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur Train belum aktif')),
                    );
                  },
                ),
                // Car → contoh belum aktif
                _MenuIcon(
                  icon: Icons.directions_car,
                  label: 'Car',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur Car belum aktif')),
                    );
                  },
                ),
                _MenuIcon(
                  icon: Icons.more_horiz,
                  label: 'More',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ✈️ Upcoming Trip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Upcoming Trip",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "All",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                )
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.flight_takeoff, color: Colors.blue, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "CGK  →  PGK",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Jakarta  →  Pangkal Pinang",
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "28 Oct 2025 | 15:30 - 17:25",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_vert),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🏝️ Popular Destination
            const Text(
              "Popular Destination",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            const _DestinationCard(
              imagePath: 'assets/images/bangka.jpg',
              title: 'Bangka Belitung',
              subtitle: 'Indonesia',
              rating: 5,
            ),
            const SizedBox(height: 15),
            const _DestinationCard(
              imagePath: 'assets/images/borobudur.jpg',
              title: 'Borobudur',
              subtitle: 'Central Java',
              rating: 4,
            ),
          ],
        ),
      ),

      // 🌍 Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.flight), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}

// 🧩 Custom widget untuk ikon menu (dengan fungsi klik)
class _MenuIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
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
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// 🏝️ Custom widget untuk kartu destinasi
class _DestinationCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final int rating;

  const _DestinationCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imagePath,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(
                    rating,
                    (index) =>
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
