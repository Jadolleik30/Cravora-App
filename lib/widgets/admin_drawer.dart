import 'package:flutter/material.dart';
import '../session.dart';

class AdminDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.blueGrey.shade900),
            accountName: Text(Session.userName ?? "Admin"),
            accountEmail: Text(Session.userEmail ?? ""),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.blueGrey),
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text("Dashboard"),
            onTap: () => Navigator.pushReplacementNamed(context, '/admin_dashboard'),
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text("Manage Users"),
            onTap: () => Navigator.pushReplacementNamed(context, '/admin_users'),
          ),
          ListTile(
            leading: Icon(Icons.restaurant),
            title: Text("Manage Restaurants"),
            onTap: () => Navigator.pushReplacementNamed(context, '/admin_restaurants'),
          ),
          ListTile(
            leading: Icon(Icons.fastfood),
            title: Text("Manage Food"),
            onTap: () => Navigator.pushReplacementNamed(context, '/admin_food'),
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text("Manage Orders"),
            onTap: () => Navigator.pushReplacementNamed(context, '/admin_orders'),
          ),
          ListTile(
            leading: Icon(Icons.message),
            title: Text("Support Messages"),
            onTap: () => Navigator.pushReplacementNamed(context, '/admin_support'),
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Manage Notifications"),
            onTap: () => Navigator.pushReplacementNamed(context, '/admin_notifications'),
          ),
          Spacer(),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              Session.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
