// lib/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripextras_project/models/user_model.dart';
import 'package:tripextras_project/routes/app_routes.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _users = FirebaseFirestore.instance.collection('users');

  // ============================
  // REGISTER (tanpa Firebase Auth)
  // ============================
  Future<void> register(
    String name,
    String email,
    String password,
    BuildContext context,
  ) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _show(context, "Semua form wajib diisi!");
      return;
    }

    final emailLower = email.trim().toLowerCase();

    try {
      // Cek email unik
      final exists = await _users
          .where('email', isEqualTo: emailLower)
          .limit(1)
          .get();
      if (exists.docs.isNotEmpty) {
        _show(context, "Email sudah terdaftar.");
        return;
      }

      // Simpan user ke Firestore (password disimpan biasa sesuai permintaan mini-project)
      final docRef = await _users.add({
        'name': name.trim(),
        'email': emailLower,
        'password':
            password, // NOTE: mini-project; untuk produksi harus di-hash!
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Simpan sesi
      final user = UserModel(
        id: docRef.id,
        name: name.trim(),
        email: emailLower,
        role: 'user',
      );
      await _saveSession(user);

      // Arahkan ke Home (atau role-based jika dibutuhkan)
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        _show(context, "Registrasi berhasil! Selamat datang, ${user.name}.");
      }
    } catch (e) {
      _show(context, "Terjadi kesalahan saat register: $e");
    }
  }

  // ============================
  // LOGIN (tanpa Firebase Auth)
  // ============================
  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      _show(context, "Email & Password tidak boleh kosong!");
      return;
    }

    final emailLower = email.trim().toLowerCase();

    try {
      final qs = await _users
          .where('email', isEqualTo: emailLower)
          .limit(1)
          .get();
      if (qs.docs.isEmpty) {
        _show(context, "Email tidak ditemukan.");
        return;
      }

      final data = qs.docs.first.data();
      final storedPassword = (data['password'] ?? '') as String;

      if (storedPassword != password) {
        _show(context, "Password salah.");
        return;
      }

      final user = UserModel(
        id: qs.docs.first.id,
        name: (data['name'] ?? '') as String,
        email: (data['email'] ?? '') as String,
        role: (data['role'] ?? 'user') as String,
      );

      await _saveSession(user);

      if (context.mounted) {
        // Role-based redirect (opsional)
        if (user.role.toLowerCase() == 'admin') {
          Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
        _show(context, "Login berhasil — Selamat datang ${user.name}!");
      }
    } catch (e) {
      _show(context, "Login gagal: $e");
    }
  }

  // ============================
  // LOGOUT
  // ============================
  Future<void> logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        _show(context, "Anda telah logout.");
      }
    } catch (e) {
      _show(context, "Logout gagal: $e");
    }
  }

  // ============================
  // Session helper
  // ============================
  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userId", user.id);
    await prefs.setString("userName", user.name);
    await prefs.setString("userEmail", user.email);
    await prefs.setString("userRole", user.role);
  }

  Future<UserModel?> getStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString("userId");
      if (id == null) return null;
      return UserModel(
        id: id,
        name: prefs.getString("userName") ?? "",
        email: prefs.getString("userEmail") ?? "",
        role: prefs.getString("userRole") ?? "user",
      );
    } catch (_) {
      return null;
    }
  }

  void _show(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
