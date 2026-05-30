import 'package:flutter/material.dart';

class PublicDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: EdgeInsets.only(top: 80, bottom: 40),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade800, Colors.red.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(64)),
            ),
            child: Column(
              children: [
                Icon(Icons.fastfood, color: Colors.white, size: 60),
                SizedBox(height: 15),
                Text(
                  "CRAVORA",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2),
                ),
                Text("Taste the Speed",
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                _buildItem(context, Icons.home_outlined, "Home", '/home'),
                _buildItem(context, Icons.info_outline, "About Us", '/about'),
                _buildItem(context, Icons.login_outlined, "Login", '/login'),
                _buildItem(context, Icons.person_add_outlined, "Create Account",
                    '/signup'),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Text("Join the Foodie Community",
                style: TextStyle(
                    color: Colors.red.shade200,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
      BuildContext context, IconData icon, String title, String route) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () => Navigator.pushReplacementNamed(context, route),
        leading: Icon(icon, color: Colors.red.shade700),
        title: Text(title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        trailing: Icon(Icons.arrow_forward_ios,
            size: 14, color: Colors.grey.shade300),
      ),
    );
  }
}
