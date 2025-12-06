
// lib/services/api_service.dart

import '../models/user_model.dart';

class ApiService {
  // ============================================================
  // 🗂 SIMULASI DATABASE USER (fake DB)
  // ============================================================
  final List<UserModel> _registeredUsers = [
    UserModel(
      id: '1',
      name: 'Admin',
      email: 'admin@example.com',
      role: 'admin',
    ),
  ];

  // ✅ untuk menyimpan user yang sedang login
  UserModel? currentUser;

  // ============================================================
  // 🔐 LOGIN USER
  // ============================================================
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // simulasi delay

    try {
      final user = _registeredUsers.firstWhere(
        (u) => u.email == email,
      );

      // ✅ password disederhanakan untuk simulasi
      currentUser = user;
      return user;
    } catch (e) {
      throw "Email belum terdaftar!";
    }
  }

  // ============================================================
  // 👤 REGISTER USER
  // ============================================================
  Future<bool> register(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    // ❌ data kosong?
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return false;
    }

    // ❌ email duplikat?
    bool exists = _registeredUsers.any((u) => u.email == email);
    if (exists) return false;

    // ✅ buat user baru
    _registeredUsers.add(
      UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        role: 'user',
      ),
    );

    return true; // berhasil
  }

  // ============================================================
  // 👤 GET CURRENT USER (untuk Profile)
  // ============================================================
  UserModel? getCurrentUser() {
    return currentUser;
  }

  // ============================================================
  // 🚪 LOGOUT
  // ============================================================
  void logout() {
    currentUser = null;
  }

  // ============================================================
  // 🧾 SIMULASI HISTORY (mock data)
  // ============================================================
  List<Map<String, String>> getTripHistory() {
    return [
      {
        "id": "HST001",
        "airline": "Garuda Indonesia",
        "from": "Jakarta",
        "to": "Bali",
        "date": "2025-03-10"
      },
      {
        "id": "HST002",
        "airline": "AirAsia",
        "from": "Bali",
        "to": "Singapura",
        "date": "2025-04-02"
      }
    ];
  }
}
