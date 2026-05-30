import 'package:flutter/material.dart';
import '../session.dart';

class UserDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Modern Header
          Container(
            padding: EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade700, Colors.orange.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(50)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white24,
                  backgroundImage: NetworkImage(
                    Session.userGender == "Female"
                        ? "https://cdn-icons-png.flaticon.com/512/6997/6997662.png"
                        : "https://www.w3schools.com/howto/img_avatar.png",
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Session.userName ?? "Guest User",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        Session.userEmail ?? "",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                        child: Text("${Session.userPoints} pts", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              physics: BouncingScrollPhysics(),
              children: [
                _buildDrawerItem(context, Icons.restaurant_menu_outlined, "Browse Menu", '/delivery'),
                _buildDrawerItem(context, Icons.storefront_outlined, "All Restaurants", '/restaurants'),
                _buildDrawerItem(context, Icons.stars_outlined, "Cravora Rewards", '/rewards', iconColor: Colors.amber),
                _buildDrawerItem(context, Icons.history_outlined, "Order History", '/order_history'),
                _buildDrawerItem(context, Icons.chat_bubble_outline, "Support Center", '/support'),
                _buildDrawerItem(context, Icons.person_outline, "My Profile", '/profile'),
                
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Divider(color: Colors.grey.shade100, thickness: 1),
                ),
                
                _buildDrawerItem(context, Icons.logout_outlined, "Sign Out", '/logout', isLogout: true),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text("CRAVORA v1.2.0", style: TextStyle(color: Colors.grey.shade300, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String route, {Color? iconColor, bool isLogout = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: ListTile(
        onTap: () {
          if (isLogout) {
            Session.logout();
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          } else {
            Navigator.pushReplacementNamed(context, route);
          }
        },
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(color: (isLogout ? Colors.red : Colors.grey).withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: isLogout ? Colors.red : (iconColor ?? Colors.black87), size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.red : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        trailing: Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade300),
      ),
    );
  }
}
