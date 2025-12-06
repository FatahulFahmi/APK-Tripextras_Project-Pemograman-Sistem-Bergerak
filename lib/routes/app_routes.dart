// ===========================================================
// 📌 APP ROUTES — Routing Management Tripextras
// ===========================================================

import 'package:flutter/material.dart';

// ===========================================================
// 🔹 Import semua screen utama
// ===========================================================
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile_screen.dart'; // ✅ Profile
import '../screens/flight/trip_history_screen.dart'; // ✅ Trip History

// ===========================================================
// 🔹 Import fitur penerbangan
// ===========================================================
import '../screens/flight/flight_screen.dart';
import '../screens/flight/available_flights_screen.dart';
import '../screens/flight/flight_booking_screen.dart';
import '../screens/flight/booking_success_screen.dart';

// ===========================================================
// 🔹 Import fitur admin
// ===========================================================
import '../screens/admin/dashboard_screen.dart';
import '../screens/admin/manage_users_screen.dart';
import '../screens/admin/manage_flights_screen.dart';
import '../screens/admin/manage_destinations_screen.dart';
// ✅ TAMBAHAN BARU
import '../screens/admin/manage_tickets_screen.dart'; // Import halaman tiket

class AppRoutes {
  // ===========================================================
  // 🔸 Nama Route (hindari typo)
  // ===========================================================
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';

  static const String home = '/home';
  static const String profile = '/profile';
  static const String tripHistory = '/trip-history';

  static const String flight = '/flight';
  static const String availableFlights = '/available-flights';
  static const String flightBooking = '/flight-booking';
  static const String bookingSuccess = '/booking-success';

  // ===========================================================
  // 🔸 Rute khusus Admin
  // ===========================================================
  static const String adminDashboard = '/admin-dashboard';
  static const String manageUsers = '/manage-users';
  static const String manageFlights = '/manage-flights';
  static const String manageDestinations = '/manage-destinations';
  // ✅ TAMBAHAN BARU
  static const String manageTickets = '/manage-tickets'; // Definisikan nama rute

  // ===========================================================
  // 🧭 Static Routes — halaman tanpa arguments
  // ===========================================================
  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),

    home: (context) => const HomeScreen(),
    profile: (context) => const ProfileScreen(),
    tripHistory: (context) => const TripHistoryScreen(),

    flight: (context) => const FlightScreen(),
    availableFlights: (context) => const AvailableFlightsScreen(),
    bookingSuccess: (context) => const BookingSuccessScreen(),

    // ===========================================================
    // 🧩 Admin Screen
    // ===========================================================
    adminDashboard: (context) => const AdminDashboardScreen(),
    manageUsers: (context) => const ManageUsersScreen(),
    manageFlights: (context) => const ManageFlightsScreen(),
    manageDestinations: (context) => const ManageDestinationsScreen(),
    // ✅ TAMBAHAN BARU
    manageTickets: (context) => const ManageTicketsScreen(), // Daftarkan rutenya
  };

  // ===========================================================
  // 🚀 onGenerateRoute — untuk halaman yang butuh arguments
  // ===========================================================
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ✈️ Halaman booking menerima detail flight
      case flightBooking:
        final args = settings.arguments as Map<String, dynamic>?;

        if (args == null) {
          return _errorPage('⚠️ No booking details provided.');
        }

        return MaterialPageRoute(
          builder: (context) => FlightBookingScreen(
            airline: args['airline'] ?? 'Unknown Airline',
            from: args['from'] ?? 'Unknown Origin',
            to: args['to'] ?? 'Unknown Destination',
            time: args['departure'] != null && args['arrival'] != null
                ? '${args['departure']} → ${args['arrival']}'
                : args['time'] ?? '-',
            price: args['price'] ?? '-',
          ),
        );

      // ===========================================================
      // ❌ Rute tidak ditemukan
      // ===========================================================
      default:
        return _errorPage('🚫 404 - Page Not Found (${settings.name})');
    }
  }

  // ===========================================================
  // 🧱 Fungsi bantu — halaman error sederhana
  // ===========================================================
  static MaterialPageRoute _errorPage(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
