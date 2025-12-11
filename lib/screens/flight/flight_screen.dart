import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Import Wajib Firestore
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import 'search_result_screen.dart';

class FlightScreen extends StatefulWidget {
  const FlightScreen({super.key});

  @override
  State<FlightScreen> createState() => _FlightScreenState();
}

class _FlightScreenState extends State<FlightScreen> {
  // Variabel untuk menyimpan pilihan Dropdown
  String? _selectedOrigin;
  String? _selectedDestination;

  // Variabel State Lainnya
  DateTime selectedDate = DateTime.now();
  int passengers = 1;
  String seatClass = 'Economy';

  // Fungsi Memilih Tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Fungsi Tukar Lokasi
  void _swapLocations() {
    setState(() {
      final temp = _selectedOrigin;
      _selectedOrigin = _selectedDestination;
      _selectedDestination = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Warna tema
    const Color primaryColor = Colors.blueAccent;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Cari Penerbangan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===========================
            // HEADER & FORM AREA
            // ===========================
            Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Background Biru Melengkung
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: const [
                        Text(
                          "Mau pergi ke mana?",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Card Form Mengambang
                Container(
                  margin: const EdgeInsets.only(top: 60, left: 20, right: 20),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  // 🔹 AMBIL DATA DARI FIREBASE (Field: name)
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('destinations')
                        .snapshots(),
                    builder: (context, snapshot) {
                      // State Loading
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // State Kosong/Error
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text("Data destinasi kosong."),
                        );
                      }

                      // ✅ PENGAMBILAN DATA (FIXED: Menggunakan 'name')
                      List<String> cityList = snapshot.data!.docs
                          .map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            // Mengambil field 'name' sesuai konfirmasi Anda
                            return data['name']?.toString() ?? 'Unknown';
                          })
                          .toSet()
                          .toList(); // Hapus duplikat

                      cityList.sort(); // Urutkan abjad A-Z

                      // UI FORM INPUT
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- INPUT DARI (Dropdown) ---
                          _buildDropdownInput(
                            label: "Dari",
                            hint: "Pilih Kota Asal",
                            icon: Icons.flight_takeoff,
                            items: cityList,
                            value: _selectedOrigin,
                            onChanged: (val) =>
                                setState(() => _selectedOrigin = val),
                          ),

                          // Tombol Swap (Tukar)
                          Center(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F7FF),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.swap_vert_rounded,
                                  color: primaryColor,
                                ),
                                onPressed: _swapLocations,
                              ),
                            ),
                          ),

                          // --- INPUT KE (Dropdown) ---
                          _buildDropdownInput(
                            label: "Ke",
                            hint: "Pilih Kota Tujuan",
                            icon: Icons.flight_land,
                            items: cityList,
                            value: _selectedDestination,
                            onChanged: (val) =>
                                setState(() => _selectedDestination = val),
                          ),

                          const SizedBox(height: 25),
                          const Divider(),
                          const SizedBox(height: 15),

                          // --- TANGGAL & PENUMPANG ---
                          Row(
                            children: [
                              Expanded(
                                child: _buildSelector(
                                  label: "Berangkat",
                                  value: DateFormat(
                                    'd MMM yyyy',
                                  ).format(selectedDate),
                                  icon: Icons.calendar_today_rounded,
                                  onTap: () => _selectDate(context),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: _buildSelector(
                                  label: "Penumpang",
                                  value: "$passengers Orang",
                                  icon: Icons.person_rounded,
                                  onTap: () {
                                    setState(() {
                                      passengers = passengers >= 5
                                          ? 1
                                          : passengers + 1;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // --- KELAS KURSI ---
                          Text(
                            "Kelas Kabin",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildClassOption("Economy", true),
                              const SizedBox(width: 10),
                              _buildClassOption("Business", false),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // --- TOMBOL CARI ---
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 5,
                              ),
                              onPressed: () {
                                // Validasi Input
                                if (_selectedOrigin == null ||
                                    _selectedDestination == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Harap pilih Kota Asal dan Tujuan!',
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                } else if (_selectedOrigin ==
                                    _selectedDestination) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Kota Asal dan Tujuan tidak boleh sama!',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                } else {
                                  // 🚀 Navigasi ke Hasil Pencarian
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SearchResultScreen(
                                        from: _selectedOrigin!,
                                        to: _selectedDestination!,
                                        date: selectedDate,
                                        passengers: passengers,
                                        seatClass: seatClass,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                'Cari Penerbangan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ======================
  // WIDGET HELPERS
  // ======================

  // Widget Dropdown
  Widget _buildDropdownInput({
    required String label,
    required String hint,
    required IconData icon,
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FD),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Row(
                children: [
                  Icon(icon, color: Colors.blueAccent, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    hint,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.blueAccent,
              ),
              items: items.map((String city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(
                    city,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // Widget Selector Tanggal/Penumpang
  Widget _buildSelector({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FD),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Opsi Kelas
  Widget _buildClassOption(String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            seatClass = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: seatClass == label
                ? Colors.blueAccent.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: seatClass == label
                  ? Colors.blueAccent
                  : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: seatClass == label ? Colors.blueAccent : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
