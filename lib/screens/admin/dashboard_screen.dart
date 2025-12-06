// ✅ IMPORT BARU
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../routes/app_routes.dart';
import '../../services/auth_service.dart'; // Pastikan path ini benar
// ✅ TAMBAHAN BARU
import '../../services/activity_service.dart'; // Import service aktivitas

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // ✅ PERBAIKAN: Gunakan .instance sesuai pola Singleton
  final AuthService _authService = AuthService.instance;
  // ✅ TAMBAHAN BARU
  final ActivityService _activityService = ActivityService.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // STATE UNTUK MENAMPUNG DATA STATISTIK
  bool _isLoading = true;
  int _userCount = 0;
  int _flightCount = 0;
  int _destinationCount = 0;
  int _ticketCount = 0; // TAMBAHAN BARU

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  // FUNGSI BARU: Mengambil data count dari Firestore
  Future<void> _fetchStatistics() async {
    try {
      final userSnapshot = await _firestore.collection('users').count().get();
      final flightSnapshot =
          await _firestore.collection('flights').count().get();
      final destinationSnapshot =
          await _firestore.collection('destinations').count().get();
      final ticketSnapshot = await _firestore.collection('tickets').count().get();

      if (mounted) {
        setState(() {
          _userCount = userSnapshot.count ?? 0;
          _flightCount = flightSnapshot.count ?? 0;
          _destinationCount = destinationSnapshot.count ?? 0;
          _ticketCount = ticketSnapshot.count ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengambil data statistik: $e")),
        );
      }
    }
  }

  // ✅ HELPER BARU: Untuk mengubah string 'iconType' menjadi Ikon & Warna
  Map<String, dynamic> _getIconForType(String iconType) {
    switch (iconType) {
      case 'user':
        return {'icon': Icons.person_add, 'color': Colors.blue};
      case 'flight':
        return {'icon': Icons.flight_takeoff, 'color': Colors.orange};
      case 'destination':
        return {'icon': Icons.location_on, 'color': Colors.green};
      case 'ticket':
        return {'icon': Icons.confirmation_number, 'color': Colors.purple};
      case 'ticket_delete':
        return {'icon': Icons.delete_sweep, 'color': Colors.red};
      default:
        return {'icon': Icons.info_outline, 'color': Colors.grey};
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
          "Admin Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _authService.logout(context);
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
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
                  hintText: 'Search management tools...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Menu Manajemen Section
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _MenuIcon(
                  icon: Icons.flight_takeoff,
                  label: 'Flights',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.manageFlights),
                ),
                _MenuIcon(
                  icon: Icons.people,
                  label: 'Users',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.manageUsers),
                ),
                _MenuIcon(
                  icon: Icons.location_on,
                  label: 'Destinations',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.manageDestinations),
                ),
                // FITUR BARU: Tombol 'Tickets'
                _MenuIcon(
                  icon: Icons.confirmation_number,
                  label: 'Tickets',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.manageTickets);
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Statistik Section
            const Text(
              "System Overview",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Users',
                    value: _isLoading ? '...' : _userCount.toString(),
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    title: 'Active Flights',
                    value: _isLoading ? '...' : _flightCount.toString(),
                    icon: Icons.flight_takeoff,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Destinations',
                    value: _isLoading ? '...' : _destinationCount.toString(),
                    icon: Icons.location_on,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 10),
                // FITUR BARU: 'Total Tickets'
                Expanded(
                  child: _StatCard(
                    title: 'Total Tickets',
                    value: _isLoading ? '...' : _ticketCount.toString(),
                    icon: Icons.confirmation_number_outlined,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // =======================================================
            // 📰 RECENT ACTIVITIES (DINAMIS DARI FIREBASE)
            // =======================================================
            const Text(
              "Recent Activities",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // ✅ MENGGANTI LIST STATIS DENGAN STREAMBUILDER
            StreamBuilder<QuerySnapshot>(
              stream: _activityService.getActivitiesStream(), // Panggil fungsi
              builder: (context, snapshot) {
                // Tampilkan loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Tampilkan jika error
                if (snapshot.hasError) {
                  return const _ActivityItem(
                    icon: Icons.error_outline,
                    color: Colors.red,
                    text: 'Gagal memuat aktivitas.',
                  );
                }
                // Tampilkan jika tidak ada data
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const _ActivityItem(
                    icon: Icons.info_outline,
                    color: Colors.grey,
                    text: 'Belum ada aktivitas terbaru.',
                  );
                }

                // Jika ada data, buat daftarnya
                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final text = data['text'] ?? 'Aktivitas tidak diketahui';
                    final iconType = data['iconType'] ?? 'info';

                    // Panggil helper untuk dapat ikon
                    final iconData = _getIconForType(iconType);

                    return _ActivityItem(
                      icon: iconData['icon'],
                      color: iconData['color'],
                      text: text,
                    );
                  }).toList(),
                );
              },
            ),

            // ❌ KODE STATIS LAMA DIBAWAH INI SUDAH DIHAPUS
            // _ActivityItem(
            //   icon: Icons.person_add, ...
            // ),
            // _ActivityItem(
            //   icon: Icons.flight, ...
            // ),
            // _ActivityItem(
            //   icon: Icons.location_on, ...
            // ),
          ],
        ),
      ),
    );
  }
}

// 🧩 Reusable menu icon
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
        mainAxisAlignment: MainAxisAlignment.center,
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

// 📊 Statistik Card Widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w500)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🕒 Recent Activity Item
class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

