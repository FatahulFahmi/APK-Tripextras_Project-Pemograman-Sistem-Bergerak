// 1. IMPORT FIREBASE & MODEL
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
// Sesuaikan path jika model Anda ada di folder lain
import '../../../models/destination_model.dart';

// 2. UBAH JADI STATEFULWIDGET
class ManageDestinationsScreen extends StatefulWidget {
  const ManageDestinationsScreen({super.key});

  @override
  State<ManageDestinationsScreen> createState() =>
      _ManageDestinationsScreenState();
}

class _ManageDestinationsScreenState extends State<ManageDestinationsScreen> {
  // 3. BUAT KONEKSI KE FIREBASE
  // ✅ PERBAIKAN: Baris '_firestore' dihapus karena tidak pernah digunakan.
  final CollectionReference _destinations =
      FirebaseFirestore.instance.collection('destinations');

  // 4. CONTROLLER UNTUK FORM DIALOG
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  // 5. FUNGSI UNTUK MENAMPILKAN DIALOG (UNTUK ADD / EDIT)
  Future<void> _showDestinationDialog(
      [DocumentSnapshot? documentSnapshot]) async {
    String action = 'add';
    if (documentSnapshot != null) {
      action = 'edit';
      // Isi controller dengan data yang ada jika ini adalah mode edit
      final data = documentSnapshot.data() as Map<String, dynamic>;
      _nameController.text = data['name'];
      _locationController.text = data['location'];
      _imageUrlController.text = data['imageUrl'];
    } else {
      // Reset jika 'add'
      _nameController.text = '';
      _locationController.text = '';
      _imageUrlController.text = '';
    }

    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
                20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action == 'add' ? 'Add New Destination' : 'Edit Destination',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: 'Name (e.g., Bangka Belitung)'),
                ),
                TextField(
                  controller: _locationController,
                  decoration:
                      const InputDecoration(labelText: 'Location (e.g., Indonesia)'),
                ),
                TextField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  child: Text(action == 'add' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String name = _nameController.text;
                    final String location = _locationController.text;
                    final String imageUrl = _imageUrlController.text;

                    if (name.isNotEmpty &&
                        location.isNotEmpty &&
                        imageUrl.isNotEmpty) {
                      if (action == 'add') {
                        // Tambah data baru ke Firestore
                        await _destinations.add({
                          "name": name,
                          "location": location,
                          "imageUrl": imageUrl,
                          "rating": 5.0 // Beri rating default
                        });
                      } else if (action == 'edit') {
                        // Update data yang ada
                        await _destinations
                            .doc(documentSnapshot!.id)
                            .update({
                          "name": name,
                          "location": location,
                          "imageUrl": imageUrl,
                        });
                      }

                      // Kosongkan controller & tutup dialog
                      _nameController.text = '';
                      _locationController.text = '';
                      _imageUrlController.text = '';
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Semua field wajib diisi!')));
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  // 6. FUNGSI UNTUK MENGHAPUS
  Future<void> _deleteDestination(String destinationId) async {
    // Tampilkan dialog konfirmasi
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus destinasi ini?'),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
              onPressed: () async {
                await _destinations.doc(destinationId).delete();
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Destinasi berhasil dihapus')));
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
        title: const Text("Manage Destinations",
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // 7. ARAHKAN FAB KE FUNGSI DIALOG
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showDestinationDialog(),
      ),
      // 8. GUNAKAN STREAMBUILDER UNTUK MENAMPILKAN DATA
      body: StreamBuilder(
        stream: _destinations.snapshots(), // Langganan ke koleksi 'destinations'
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          // Tampilkan loading indicator
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Tampilkan jika ada error
          if (streamSnapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan.'));
          }
          // Tampilkan jika tidak ada data
          if (!streamSnapshot.hasData || streamSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada destinasi.'));
          }

          // Jika ada data, tampilkan GridView
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8, // Sesuaikan rasio agar gambar terlihat
            ),
            itemCount: streamSnapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final DocumentSnapshot documentSnapshot =
                  streamSnapshot.data!.docs[index];
              final destination = DestinationModel.fromJson(
                  documentSnapshot.data() as Map<String, dynamic>);

              // 9. BUAT KARTU YANG MENAMPILKAN DATA ASLI
              return _DestinationCard(
                destination: destination,
                onEdit: () => _showDestinationDialog(documentSnapshot),
                onDelete: () => _deleteDestination(documentSnapshot.id),
              );
            },
          );
        },
      ),
    );
  }
}

// 10. WIDGET BARU UNTUK KARTU DESTINASI (LEBIH RAPI)
class _DestinationCard extends StatelessWidget {
  final DestinationModel destination;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DestinationCard({
    required this.destination,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tampilkan Gambar
            Expanded(
              child: Image.network(
                destination.imageUrl,
                fit: BoxFit.cover,
                // Error handler jika URL gambar salah
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                // Loading indicator saat gambar di-load
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
            // Tampilkan Teks
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                destination.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Tombol Edit & Delete
            Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
