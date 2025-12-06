import 'package:flutter/material.dart';
import '../../../constants/colors.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Admin Profile", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/admin_avatar.png'),
            ),
            SizedBox(height: 16),
            Text("Admin Tripextras", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text("admin@tripextras.com", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
