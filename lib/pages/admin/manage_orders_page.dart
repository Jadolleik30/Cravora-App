import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../../widgets/admin_drawer.dart';

class ManageOrdersPage extends StatefulWidget {
  @override
  _ManageOrdersPageState createState() => _ManageOrdersPageState();
}

class _ManageOrdersPageState extends State<ManageOrdersPage> {
  List orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final response = await http.get(Uri.parse(Config.baseUrl + "get_orders.php"));
      setState(() {
        orders = json.decode(response.body);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _viewOrderDetails(Map order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Order Details #${order['id']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Customer: ${order['user_name']}", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Price: \$${order['total_price']}"),
            Text("Payment: ${order['payment_method']}"),
            Text("Address: ${order['delivery_address']}"),
            Text("Status: ${order['status']}"),
            Text("Date: ${order['created_at']}"),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Close"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Orders"), backgroundColor: Colors.blueGrey.shade900, foregroundColor: Colors.white),
      drawer: AdminDrawer(),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text("Order #${order['id']} - ${order['user_name']}"),
                  subtitle: Text("Amount: \$${order['total_price']} | Method: ${order['payment_method']}"),
                  trailing: IconButton(
                    icon: Icon(Icons.visibility, color: Colors.green),
                    onPressed: () => _viewOrderDetails(order),
                  ),
                ),
              );
            },
          ),
    );
  }
}
