import 'package:flutter/material.dart';
import '../session.dart';
import '../widgets/public_drawer.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Our Story", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: PublicDrawer(),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80"),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                      child: Icon(Icons.restaurant, color: Colors.white, size: 50),
                    ),
                    SizedBox(height: 15),
                    Text("CRAVORA", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 5)),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("The Vision", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.red)),
                  SizedBox(height: 15),
                  Text(
                    "Cravora was born from a simple idea: that great food should be accessible with just a few taps. We bridge the gap between your favorite local kitchens and your doorstep, ensuring every meal is delivered fresh, fast, and with a smile.",
                    style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey.shade800),
                  ),
                  
                  SizedBox(height: 40),
                  
                  _buildFeatureTile(Icons.flash_on, "Lightning Fast", "Our specialized routing ensures your food arrives while it's still hot."),
                  _buildFeatureTile(Icons.verified_user_outlined, "Verified Partners", "We only work with the top-rated restaurants in the city."),
                  _buildFeatureTile(Icons.support_agent, "24/7 Support", "Our dedicated team is always here to help you with your orders."),
                  
                  SizedBox(height: 40),
                  
                  Container(
                    padding: EdgeInsets.all(25),
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(25)),
                    child: Column(
                      children: [
        
                        SizedBox(height: 20),
                        Text("Jad Olleik", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        Text("Lead Developer", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 50),
                  Center(
                    child: Text(
                      "© 2026 CRAVORA. All Rights Reserved.",
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: Colors.red, size: 24),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                SizedBox(height: 5),
                Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
