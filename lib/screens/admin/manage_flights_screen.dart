// 1. IMPORT BARU
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import paket intl
import '../../../constants/colors.dart';
// Sesuaikan path jika model Anda ada di folder lain
import '../../../models/trip_model.dart';

// 2. UBAH JADI STATEFULWIDGET
class ManageFlightsScreen extends StatefulWidget {
  const ManageFlightsScreen({super.key});

  @override
  State<ManageFlightsScreen> createState() => _ManageFlightsScreenState();
}

class _ManageFlightsScreenState extends State<ManageFlightsScreen> {
  // 3. KONEKSI KE FIREBASE
  final CollectionReference _flights =
      FirebaseFirestore.instance.collection('flights');

  // 4. CONTROLLER UNTUK FORM DIALOG
  final TextEditingController _airlineController = TextEditingController();
  final TextEditingController _flightCodeController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();

  // 5. HELPER UNTUK MENGAMBIL TANGGAL & WAKTU
  Future<DateTime?> _pickDateTime(BuildContext context, DateTime initialDate) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null) return null;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) return null;

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  // 6. FUNGSI UNTUK MENAMPILKAN DIALOG (UNTUK ADD / EDIT)
  Future<void> _showFlightDialog([DocumentSnapshot? documentSnapshot]) async {
    String action = 'add';
    DateTime? departureDateTime;
    DateTime? arrivalDateTime;

    if (documentSnapshot != null) {
      action = 'edit';
      final data = documentSnapshot.data() as Map<String, dynamic>;
      
      _airlineController.text = data['airline'] ?? '';
      _flightCodeController.text = data['flightCode'] ?? '';
      _originController.text = data['origin'] ?? '';
      _destinationController.text = data['destination'] ?? '';
      _priceController.text = (data['price'] ?? 0).toString();
      _seatsController.text = (data['availableSeats'] ?? 0).toString();
      // Konversi Timestamp dari Firestore ke DateTime
      if (data['departureTime'] != null) {
        departureDateTime = (data['departureTime'] as Timestamp).toDate();
      }
      if (data['arrivalTime'] != null) {
        arrivalDateTime = (data['arrivalTime'] as Timestamp).toDate();
      }
    } else {
      // Reset controller jika 'add'
      _airlineController.clear();
      _flightCodeController.clear();
      _originController.clear();
      _destinationController.clear();
      _priceController.clear();
      _seatsController.clear();
      departureDateTime = null;
      arrivalDateTime = null;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        // Gunakan StatefulBuilder agar dialog bisa update state-nya sendiri (untuk tanggal)
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action == 'add' ? 'Add New Flight' : 'Edit Flight',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextField(controller: _airlineController, decoration: const InputDecoration(labelText: 'Airline (e.g., Garuda Indonesia)')),
                    TextField(controller: _flightCodeController, decoration: const InputDecoration(labelText: 'Flight Code (e.g., GA-123)')),
                    TextField(controller: _originController, decoration: const InputDecoration(labelText: 'Origin (e.g., CGK)')),
                    TextField(controller: _destinationController, decoration: const InputDecoration(labelText: 'Destination (e.g., DPS)')),
                    TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
                    TextField(controller: _seatsController, decoration: const InputDecoration(labelText: 'Available Seats'), keyboardType: TextInputType.number),
                    const SizedBox(height: 10),
                    // Tombol Pilih Tanggal
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Departure Time'),
                      subtitle: Text(departureDateTime == null
                          ? 'Not set'
                          : DateFormat('dd MMM yyyy, HH:mm').format(departureDateTime!)),
                      onTap: () async {
                        final dt = await _pickDateTime(context, departureDateTime ?? DateTime.now());
                        if (dt != null) {
                          setDialogState(() { departureDateTime = dt; });
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Arrival Time'),
                      subtitle: Text(arrivalDateTime == null
                          ? 'Not set'
                          : DateFormat('dd MMM yyyy, HH:mm').format(arrivalDateTime!)),
                      onTap: () async {
                        final dt = await _pickDateTime(context, arrivalDateTime ?? DateTime.now());
                        if (dt != null) {
                          setDialogState(() { arrivalDateTime = dt; });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      child: Text(action == 'add' ? 'Create' : 'Update'),
                      onPressed: () async {
                        // Ambil dan validasi data
                        final String airline = _airlineController.text;
                        final String flightCode = _flightCodeController.text;
                        final String origin = _originController.text;
                        final String destination = _destinationController.text;
                        final double? price = double.tryParse(_priceController.text);
                        final int? seats = int.tryParse(_seatsController.text);

                        if (airline.isNotEmpty && flightCode.isNotEmpty && origin.isNotEmpty && destination.isNotEmpty && price != null && seats != null && departureDateTime != null && arrivalDateTime != null) {
                          
                          // Siapkan data untuk Firestore
                          final Map<String, dynamic> flightData = {
                            "airline": airline,
                            "flightCode": flightCode,
                            "origin": origin,
                            "destination": destination,
                            "price": price,
                            "availableSeats": seats,
                            "departureTime": Timestamp.fromDate(departureDateTime!),
                            "arrivalTime": Timestamp.fromDate(arrivalDateTime!),
                          };

                          if (action == 'add') {
                            await _flights.add(flightData);
                          } else if (action == 'edit') {
                            await _flights
                                .doc(documentSnapshot!.id)
                                .update(flightData);
                          }
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Semua field wajib diisi!')));
                        }
                      },
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 7. FUNGSI UNTUK MENGHAPUS
  Future<void> _deleteFlight(String flightId) async {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus penerbangan ini?'),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
              onPressed: () async {
                await _flights.doc(flightId).delete();
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Penerbangan berhasil dihapus')));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title:
            const Text("Manage Flights", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // 8. ARAHKAN FAB KE FUNGSI DIALOG
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showFlightDialog(),
      ),
      // 9. GUNAKAN STREAMBUILDER
      body: StreamBuilder(
        stream: _flights.orderBy('departureTime', descending: true).snapshots(), // Urutkan berdasarkan waktu
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (streamSnapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${streamSnapshot.error}'));
          }
          if (!streamSnapshot.hasData || streamSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada data penerbangan.'));
          }

          // Tampilkan ListView
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: streamSnapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final DocumentSnapshot document =
                  streamSnapshot.data!.docs[index];
              // Kita butuh model TripModel
              final TripModel trip = TripModel.fromJson(
                  document.data() as Map<String, dynamic>, document.id);
              
              // 10. TAMPILKAN KARTU KUSTOM
              return _FlightCard(
                trip: trip,
                onEdit: () => _showFlightDialog(document),
                onDelete: () => _deleteFlight(document.id),
              );
            },
          );
        },
      ),
    );
  }
}

// 11. WIDGET BARU UNTUK KARTU (LEBIH INFORMATIF)
class _FlightCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FlightCard({
    required this.trip,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Format tanggal
    final String departure = DateFormat('dd/MM/yy HH:mm').format(trip.departureTime.toDate());
    final String arrival = DateFormat('dd/MM/yy HH:mm').format(trip.arrivalTime.toDate());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${trip.airline} (${trip.flightCode})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  trip.origin,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.arrow_forward, color: AppColors.primary),
                Text(
                  trip.destination,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Berangkat: $departure'),
            Text('Tiba:       $arrival'),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rp${NumberFormat.decimalPattern('id').format(trip.price)}',
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
                Text('${trip.availableSeats} kursi tersisa'),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: onEdit,
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: onDelete,
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
