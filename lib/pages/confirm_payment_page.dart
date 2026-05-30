import 'package:flutter/material.dart';
import '../session.dart';
import '../widgets/notification_bell.dart';

class ConfirmPaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order Confirmed"),
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          NotificationBell(),
          SizedBox(width: 10),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
              SizedBox(height: 20),
              Text("Payment Successful!", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(
                "Your order has been confirmed and is being prepared. You will receive it shortly.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  String targetRoute = Session.isLoggedIn ? '/delivery' : '/home';
                  Navigator.pushNamedAndRemoveUntil(context, targetRoute, (route) => false);
                },
                child: Text("Back to ${Session.isLoggedIn ? 'Menu' : 'Home'}", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
