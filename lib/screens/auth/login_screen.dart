import 'package:flutter/material.dart';
import 'package:tripextras_project/services/auth_service.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/custom_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Center(
                child: Text(
                  'Sign In',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),
              CustomTextField(controller: emailController, hintText: 'Email'),
              const SizedBox(height: 16),
              CustomTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Log In',
                onPressed: () async {
                  await AuthService.instance.login(
                    emailController.text.trim(),
                    passwordController.text.trim(),
                    context,
                  );
                },
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/signup'), // ✅ diperbaiki
                  child: const Text("Don't have an account? Sign up"),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
