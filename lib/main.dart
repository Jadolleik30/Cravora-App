import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/about_page.dart';
import 'pages/delivery_food_page.dart';
import 'pages/profile_page.dart';
import 'pages/order_history_page.dart';
import 'pages/search_page.dart';
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cravora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/home': (context) => HomePage(),
        '/about': (context) => AboutPage(),
        '/restaurants': (context) => RestaurantsPage(),
        '/delivery': (context) => DeliveryFoodPage(),
        '/profile': (context) => ProfilePage(),
        '/order_history': (context) => OrderHistoryPage(),
        '/support': (context) => SupportPage(),
        '/admin_dashboard': (context) => AdminDashboard(),
        '/admin_users': (context) => ManageUsersPage(),
        '/admin_restaurants': (context) => ManageRestaurantsPage(),
        '/admin_food': (context) => ManageFoodPage(),
        '/admin_orders': (context) => ManageOrdersPage(),
        '/admin_support': (context) => ManageSupportPage(),
        '/admin_notifications': (context) => ManageNotificationsPage(),
        '/notifications': (context) => NotificationsPage(),
        '/place_order': (context) => PlaceOrderPage(),
        '/food_details': (context) => FoodDetailsPage(),
        '/confirm_payment': (context) => ConfirmPaymentPage(),
        '/rewards': (context) => RewardsPage(),
      },
    );
  }
}
