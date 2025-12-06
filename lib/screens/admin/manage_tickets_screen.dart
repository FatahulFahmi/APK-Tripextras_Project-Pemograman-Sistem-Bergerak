// lib/screens/admin/manage_tickets_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import model dan service Anda
// SESUAIKAN PATH/NAMA FILE INI
import '../../models/ticket_model.dart';
import '../../services/ticket_service.dart';
// Asumsi model Anda sudah ada
import '../../models/user_model.dart';
import '../../models/trip_model.dart';
// ✅ TAMBAHAN BARU: Import Activity Service untuk mencatat log
import '../../services/activity_service.dart';

class ManageTicketsScreen extends StatefulWidget {
  const ManageTicketsScreen({Key? key}) : super(key: key);

  @override
  _ManageTicketsScreenState createState() => _ManageTicketsScreenState();
}

class _ManageTicketsScreenState extends State<ManageTicketsScreen> {
  final TicketService _ticketService = TicketService();
  // ✅ TAMBAHAN BARU: Buat instance dari Activity Service
  final ActivityService _activityService = ActivityService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Tickets'),
      ),
      // Tombol (+) untuk membuat tiket baru
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showCreateTicketDialog(context);
        },
      ),
      // Body: Menampilkan daftar tiket yang sudah ada
      body: StreamBuilder<List<TicketModel>>(
        stream: _ticketService.getTicketsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Belum ada tiket.'));
          }

          List<TicketModel> tickets = snapshot.data!;

          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              TicketModel ticket = tickets[index];
              return ListTile(
                title: Text('${ticket.userName} - ${ticket.flightDestination}'),
                subtitle: Text('Seat: ${ticket.seatNumber} | ${ticket.status}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    // TODO: Tambahkan dialog konfirmasi sebelum hapus
                    if (ticket.id != null) {
                      await _ticketService.deleteTicket(ticket.id!);

                      // ✅ TAMBAHAN BARU: Catat log saat hapus
                      _activityService.createActivity(
                        'Tiket untuk ${ticket.userName} (${ticket.flightDestination}) dihapus',
                        iconType: 'ticket_delete',
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ---
  // DIALOG UNTUK MEMBUAT TIKET BARU
  // ---
  void _showCreateTicketDialog(BuildContext context) {
    // Controller untuk text field
    final TextEditingController _seatController = TextEditingController();

    // Variabel untuk menyimpan nilai dropdown
    UserModel? _selectedUser;
    TripModel? _selectedTrip;
    String _selectedStatus = 'confirmed'; // Nilai default

    // Data untuk dropdown
    List<UserModel> _userList = [];
    List<TripModel> _tripList = [];

    // Loading state untuk dropdown
    bool _isLoadingUsers = true;
    bool _isLoadingTrips = true;

    // Ambil data users & trips untuk dropdown
    // Kita pakai StatefulBuilder agar dialog bisa update state-nya sendiri

    // Fungsi untuk mengambil data
    void _fetchDropdownData(StateSetter setState) async {
      // Ambil Users
      try {
        // ✅ PERBAIKAN: Memanggil fungsi dari service
        var userDocs = await _ticketService.getAllUsers();
        // ✅ PERBAIKAN: Hapus .docs karena userDocs sudah List
        _userList =
            userDocs.map((doc) => UserModel.fromSnapshot(doc)).toList();
      } catch (e) {
        print(e);
      }
      setState(() => _isLoadingUsers = false);

      // ✅ PERBAIKAN: Mengambil dari 'flights' melalui service
      try {
        // Panggil fungsi service yang sudah benar
        var flightDocs = await _ticketService.getAllFlights();
        // ✅ PERBAIKAN: Hapus .docs karena flightDocs sudah List
        _tripList =
            flightDocs.map((doc) => TripModel.fromSnapshot(doc)).toList();
      } catch (e) {
        print(e);
      }
      setState(() => _isLoadingTrips = false);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create New Ticket'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              // Panggil fetch data sekali saja saat dialog pertama kali build
              if (_isLoadingUsers && _isLoadingTrips) {
                _fetchDropdownData(setState);
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    
                    // --- Dropdown Users ---
                    _isLoadingUsers
                        ? CircularProgressIndicator()
                        : DropdownButtonFormField<UserModel>(
                            hint: Text('Select User'),
                            // ✅ PERBAIKAN UI: Agar dropdown mengisi ruang
                            isExpanded: true, 
                            value: _selectedUser,
                            onChanged: (UserModel? newValue) {
                              setState(() => _selectedUser = newValue);
                            },
                            items: _userList.map((UserModel user) {
                              return DropdownMenuItem<UserModel>(
                                value: user,
                                // ✅ PERBAIKAN UI: Memotong teks jika panjang
                                child: Text(
                                  user.name, 
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                          ),
                    
                    SizedBox(height: 16),

                    // --- Dropdown Trips/Flights ---
                    _isLoadingTrips
                        ? CircularProgressIndicator()
                        : DropdownButtonFormField<TripModel>(
                            hint: Text('Select Flight'),
                            // ✅ PERBAIKAN UI: Agar dropdown mengisi ruang
                            isExpanded: true,
                            value: _selectedTrip,
                            onChanged: (TripModel? newValue) {
                              setState(() => _selectedTrip = newValue);
                            },
                            items: _tripList.map((TripModel trip) {
                              return DropdownMenuItem<TripModel>(
                                value: trip,
                                // ✅ PERBAIKAN UI: Memotong teks jika panjang
                                child: Text(
                                  '${trip.origin} - ${trip.destination}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                          ),
                    
                    SizedBox(height: 16),

                    // --- Input Seat Number ---
                    TextFormField(
                      controller: _seatController,
                      decoration: InputDecoration(
                        labelText: 'Seat Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    
                    SizedBox(height: 16),

                    // --- Dropdown Status ---
                    DropdownButtonFormField<String>(
                      // ✅ PERBAIKAN UI: Agar dropdown mengisi ruang
                      isExpanded: true,
                      value: _selectedStatus,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() => _selectedStatus = newValue);
                        }
                      },
                      items: <String>['confirmed', 'pending', 'cancelled']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.toUpperCase()),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () async {
                // --- Validasi Sederhana ---
                if (_selectedUser == null ||
                    _selectedTrip == null ||
                    _seatController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Please fill all fields!'),
                      backgroundColor: Colors.red));
                  return; // Stop jika data tidak lengkap
                }

                // --- Buat Objek TicketModel ---
                final newTicket = TicketModel(
                  userId: _selectedUser!.id, // ASUMSI 'id'
                  userName: _selectedUser!.name, // ASUMSI 'name'
                  flightId: _selectedTrip!.id, // ASUMSI 'id'
                  flightDestination:
                      _selectedTrip!.destination, // ASUMSI 'destination'
                  seatNumber: _seatController.text,
                  status: _selectedStatus,
                  createdAt: Timestamp.now(),
                );

                // --- Kirim ke Service ---
                try {
                  await _ticketService.createTicket(newTicket);

                  // ✅ TAMBAHAN BARU: Catat log aktivitas!
                  await _activityService.createActivity(
                    'Tiket baru untuk ${_selectedUser!.name} (${_selectedTrip!.origin} - ${_selectedTrip!.destination})',
                    iconType: 'ticket', // Tipe ikon 'ticket'
                  );

                  Navigator.of(context).pop(); // Tutup dialog
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Ticket created successfully!'),
                      backgroundColor: Colors.green));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Error: $e'), backgroundColor: Colors.red));
                }
              },
            ),
          ],
        );
      },
    );
  }
}

