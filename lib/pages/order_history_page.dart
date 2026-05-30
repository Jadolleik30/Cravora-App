import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../session.dart';
import '../widgets/user_drawer.dart';
import '../widgets/notification_bell.dart';

class OrderHistoryPage extends StatefulWidget {
  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse(Config.baseUrl + "get_orders.php?user_id=${Session.userId}"),
      );
      if (mounted) {
        setState(() {
          orders = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Past Orders", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          NotificationBell(),
          SizedBox(width: 10),
        ],
      ),
      drawer: UserDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.red))
          : orders.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchOrders,
                  color: Colors.red,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    physics: BouncingScrollPhysics(),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _buildOrderCard(order);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle),
            child: Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade300),
          ),
          SizedBox(height: 20),
          Text("No orders yet", style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w900)),
          Text("Hungry? Let's fix that!", style: TextStyle(color: Colors.grey, fontSize: 16)),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/delivery'),
            child: Text("Explore Restaurants"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Order #${order['id']}", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    Text(order['created_at'].toString().split(' ')[0], style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                _buildStatusBadge(order['status']),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Divider(color: Colors.grey.shade100, thickness: 1),
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.shopping_bag_outlined, color: Colors.red, size: 20),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Amount", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                      Text("\$${order['total_price']}", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/delivery');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Start a new order!"), backgroundColor: Colors.black, behavior: SnackBarBehavior.floating)
                    );
                  },
                  child: Text("Reorder", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: Colors.grey, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order['delivery_address'] ?? "No address provided",
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    switch (status.toLowerCase()) {
      case 'pending': color = Colors.orange; icon = Icons.timer_outlined; break;
      case 'confirmed': color = Colors.blue; icon = Icons.check_circle_outline; break;
      case 'delivered': color = Colors.green; icon = Icons.done_all; break;
      case 'cancelled': color = Colors.red; icon = Icons.cancel_outlined; break;
      default: color = Colors.grey; icon = Icons.help_outline;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}
