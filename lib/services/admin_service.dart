import 'dart:async';
import '../models/user_model.dart'; // ✅ pastikan path ini benar

class AdminService {
  Future<List<UserModel>> getAllUsers() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      UserModel(id: '1', name: 'Whenny Zenica', email: 'whenny@example.com', role: 'admin'),
      UserModel(id: '2', name: 'Ari Pratama', email: 'ari@example.com', role: 'user'),
      UserModel(id: '3', name: 'Lina Putri', email: 'lina@example.com', role: 'user'),
    ];
  }

  Future<void> deleteUser(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('User dengan ID $id berhasil dihapus (dummy).');
  }

  Future<void> addDestination(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 700));
    print('Destinasi baru ditambahkan: ${data['name']}');
  }
}
