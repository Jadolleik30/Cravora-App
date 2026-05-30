import 'package:flutter/material.dart';
import '../session.dart';

class CustomFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red.shade900,
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        children: [
          Text(
            "Cravora Delivery",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: Session.isLoggedIn
              ? [
                  _footerLink(context, "Menu", "/delivery"),
                  _footerLink(context, "Search", "/search"),
                  _footerLink(context, "Profile", "/profile"),
                  _footerAction(context, "Logout", () {
                    Session.logout();
                    Navigator.pushReplacementNamed(context, '/home');
                  }),
                ]
              : [
                  _footerLink(context, "Home", "/home"),
                  _footerLink(context, "About", "/about"),
                  _footerLink(context, "Login", "/login"),
                  _footerLink(context, "Signup", "/signup"),
                ],
          ),
          SizedBox(height: 20),
          Text(
            "© 2026 Jad Olleik. All Rights Reserved.",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _footerLink(BuildContext context, String title, String route) {
    return InkWell(
      onTap: () => Navigator.pushReplacementNamed(context, route),
      child: Text(
        title,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
      ),
    );
  }

  Widget _footerAction(BuildContext context, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        title,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
      ),
    );
  }
}
