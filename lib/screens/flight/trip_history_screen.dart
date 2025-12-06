import 'package:flutter/material.dart';

class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7EEFF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2C4EFF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Trip History", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔎 search box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Find your ticket...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
              ),
            ),

            const SizedBox(height: 20),
            _TripCard(
              airline: "Garuda Airlines",
              from: "CGK",
              to: "DPS",
              price: "IDR 6.800.000",
              date: "22 April 2025",
              time: "13:00 PM - 17:25 PM",
            ),
            const SizedBox(height: 20),
            _TripCard(
              airline: "Citilink",
              from: "DPS",
              to: "CGK",
              price: "IDR 6.250.000",
              date: "18 March 2025",
              time: "08:00 AM - 11:55 AM",
            ),
          ],
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final String airline, from, to, price, date, time;

  const _TripCard({
    required this.airline,
    required this.from,
    required this.to,
    required this.price,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(airline,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(from, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Icon(Icons.airplanemode_active),
              Text(to, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(date),
          Text(time),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total"),
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
