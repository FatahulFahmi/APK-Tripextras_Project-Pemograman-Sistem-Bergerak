import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'routes/app_routes.dart';
import 'constants/colors.dart';

// Tambahkan semua import admin screen di sini (paling atas)
import 'screens/admin/dashboard_screen.dart';
import 'screens/admin/manage_users_screen.dart';
import 'screens/admin/manage_flights_screen.dart';
import 'screens/admin/manage_destinations_screen.dart';
import 'screens/admin/admin_profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const TripextrasApp());
}

class TripextrasApp extends StatelessWidget {
  const TripextrasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tripextras',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF4F7FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        ...AppRoutes.routes,
        '/admin/dashboard': (context) => const AdminDashboardScreen(),
        '/admin/manage-users': (context) => const ManageUsersScreen(),
        '/admin/manage-flights': (context) => const ManageFlightsScreen(),
        '/admin/manage-destinations': (context) =>
            const ManageDestinationsScreen(),
        '/admin/profile': (context) => const AdminProfileScreen(),
      },
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text("Page Not Found")),
          body: const Center(child: Text("Halaman tidak ditemukan")),
        ),
      ),
    );
  }
}
