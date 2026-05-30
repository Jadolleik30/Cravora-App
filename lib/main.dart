import 'package:flutter/material.dart';
import 'session.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/about_page.dart';
import 'pages/delivery_food_page.dart';
import 'pages/profile_page.dart';
import 'pages/order_history_page.dart';
import 'pages/restaurants_page.dart';
import 'pages/support_page.dart';
import 'pages/admin/admin_dashboard.dart';
import 'pages/admin/manage_users_page.dart';
import 'pages/admin/manage_restaurants_page.dart';
import 'pages/admin/manage_food_page.dart';
import 'pages/admin/manage_orders_page.dart';
import 'pages/admin/manage_support_page.dart';
import 'pages/admin/manage_notifications_page.dart';
import 'pages/notifications_page.dart';
import 'pages/place_order_page.dart';
import 'pages/food_details_page.dart';
import 'pages/confirm_payment_page.dart';
import 'pages/rewards_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget _requireCompleteProfile(Widget page) {
    if (Session.isLoggedIn &&
        Session.userRole != 'admin' &&
        !Session.profileCompleted) {
      return ProfilePage();
    }

    return page;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cravora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          primary: Colors.red.shade700,
          secondary: Colors.redAccent,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Colors.red,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      initialRoute: '/home',
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/home': (context) => _requireCompleteProfile(HomePage()),
        '/about': (context) => AboutPage(),
        '/restaurants': (context) => _requireCompleteProfile(RestaurantsPage()),
        '/delivery': (context) => _requireCompleteProfile(DeliveryFoodPage()),
        '/delivery_food': (context) =>
            _requireCompleteProfile(DeliveryFoodPage()),
        '/profile': (context) => ProfilePage(),
        '/order_history': (context) =>
            _requireCompleteProfile(OrderHistoryPage()),
        '/support': (context) => _requireCompleteProfile(SupportPage()),
        '/admin_dashboard': (context) => AdminDashboard(),
        '/admin_users': (context) => ManageUsersPage(),
        '/admin_restaurants': (context) => ManageRestaurantsPage(),
        '/admin_food': (context) => ManageFoodPage(),
        '/admin_orders': (context) => ManageOrdersPage(),
        '/admin_support': (context) => ManageSupportPage(),
        '/admin_notifications': (context) => ManageNotificationsPage(),
        '/notifications': (context) =>
            _requireCompleteProfile(NotificationsPage()),
        '/place_order': (context) => _requireCompleteProfile(PlaceOrderPage()),
        '/food_details': (context) =>
            _requireCompleteProfile(FoodDetailsPage()),
        '/confirm_payment': (context) =>
            _requireCompleteProfile(ConfirmPaymentPage()),
        '/rewards': (context) => _requireCompleteProfile(RewardsPage()),
      },
    );
  }
}
