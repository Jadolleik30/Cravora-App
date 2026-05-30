import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../../widgets/admin_drawer.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map stats = {"users": 0, "restaurants": 0, "foods": 0, "orders": 0};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final response = await http.get(Uri.parse(Config.baseUrl + "admin_stats.php"));
      setState(() {
        stats = json.decode(response.body);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
      ),
      drawer: AdminDrawer(),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome, Admin!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                Text("Here is your platform overview.", style: TextStyle(color: Colors.grey)),
                SizedBox(height: 30),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    children: [
                      _buildStatCard("Users", stats['users'].toString(), Icons.people, Colors.blue),
                      _buildStatCard("Restaurants", stats['restaurants'].toString(), Icons.restaurant, Colors.orange),
                      _buildStatCard("Food Items", stats['foods'].toString(), Icons.fastfood, Colors.green),
                      _buildStatCard("Total Orders", stats['orders'].toString(), Icons.shopping_basket, Colors.purple),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 10),
            Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
