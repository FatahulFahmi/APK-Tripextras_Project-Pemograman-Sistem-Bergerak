// ============================================================
// 🧩 UserModel — Representasi data pengguna
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ TAMBAHAN: Import Firestore

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 🔹 admin / user

  // ============================================================
  // 🏗️ Constructor
  // ============================================================
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  // ============================================================
  // 🧠 Factory: buat objek dari JSON (Peta Data)
  // ============================================================
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '', // aman dari null / int
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user', // default user
    );
  }

  // ============================================================
  // ✅ TAMBAHAN BARU: Factory dari Firestore Snapshot
  // ============================================================
  // Ini adalah fungsi yang HILANG dan dibutuhkan oleh 'manage_tickets_screen.dart'
  factory UserModel.fromSnapshot(DocumentSnapshot doc) {
    // Ambil data dari snapshot, jadikan Map
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Panggil 'fromJson' yang sudah Anda buat sebelumnya
    // Ini berfungsi karena 'id' Anda sudah tersimpan di dalam data
    return UserModel.fromJson(data);
  }

  // ============================================================
  // 📦 Konversi objek ke JSON (Map Data)
  // ============================================================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }

  // ============================================================
  // 🧩 Utility opsional — untuk debugging atau log
  // ============================================================
  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role)';
  }
}
