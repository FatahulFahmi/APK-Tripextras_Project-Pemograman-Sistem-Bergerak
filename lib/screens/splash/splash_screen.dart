import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../widgets/custom_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 👇 Tambahkan logo di sini
              Image.asset(
                'assets/images/logo.png',
                width: 120,
              ),
              const SizedBox(height: 20),
              //const Icon(Icons.flight_takeoff, size: 100, color: Colors.white),
              //const SizedBox(height: 30),
              const Text(
                "Let's get started!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    text: "Sign In",
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                  ),
                  const SizedBox(width: 20),
                  CustomButton(
                    text: "Sign Up",
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
