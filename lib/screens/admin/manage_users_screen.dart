import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ 1. IMPORT FIREBASE
import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../models/user_model.dart'; // ✅ 2. IMPORT USER MODEL

// ✅ 3. UBAH JADI STATEFULWIDGET
class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  // ✅ 4. BUAT KONEKSI KE KOLEKSI 'users'
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  // ✅ 5. FUNGSI UNTUK MENGHAPUS USER
  Future<void> _deleteUser(String userId, String userName) async {
    // Tampilkan dialog konfirmasi dulu
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus user "$userName"?'),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
              onPressed: () async {
                try {
                  // Hapus dokumen dari Firestore
                  await _users.doc(userId).delete();
                  Navigator.of(ctx).pop(); // Tutup dialog
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('User berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ));
                } catch (e) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Gagal menghapus user: $e'),
                    backgroundColor: Colors.red,
                  ));
                }
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
        title: const Text("Manage Users", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // ✅ 6. GUNAKAN STREAMBUILDER UNTUK DATA LIVE
      body: StreamBuilder(
        stream: _users.snapshots(), // Dengarkan perubahan di koleksi 'users'
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          // Tampilkan loading
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Tampilkan error
          if (streamSnapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan.'));
          }
          // Tampilkan jika tidak ada data
          if (!streamSnapshot.hasData || streamSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada user terdaftar.'));
          }

          // Jika ada data, tampilkan ListView
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: streamSnapshot.data!.docs.length, // ✅ 7. JUMLAH ITEM ASLI
            itemBuilder: (context, index) {
              final DocumentSnapshot document = streamSnapshot.data!.docs[index];
              // Ubah data mentah menjadi objek UserModel
              final UserModel user = UserModel.fromSnapshot(document);

              // Jangan tampilkan user dengan role 'admin' di daftar ini (opsional)
              if (user.role == 'admin') {
                return const SizedBox.shrink(); // Sembunyikan admin
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                  // ✅ 8. TAMPILKAN DATA ASLI
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    // ✅ 9. PANGGIL FUNGSI HAPUS
                    onPressed: () => _deleteUser(user.id, user.name),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
