import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7EEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C4EFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/profile.png'),
            ),
            const SizedBox(height: 10),
            const Text("Whenny",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text("cicakpanggangkusuka@gmail.com",
                style: TextStyle(color: Colors.blue)),
            const Text("+62 821-9002-002",
                style: TextStyle(color: Colors.grey)),
            const Divider(height: 30),

            _ProfileMenu(icon: Icons.credit_card, text: "Cards"),
            _ProfileMenu(icon: Icons.notifications, text: "Notification"),
            _ProfileMenu(icon: Icons.settings, text: "Setting"),
            _ProfileMenu(icon: Icons.help_outline, text: "Help Center"),
            _ProfileMenu(icon: Icons.logout, text: "Log Out"),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ProfileMenu({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(text,
          style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}
