import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../../widgets/admin_drawer.dart';

class ManageFoodPage extends StatefulWidget {
  @override
  _ManageFoodPageState createState() => _ManageFoodPageState();
}

class _ManageFoodPageState extends State<ManageFoodPage> {
  List foods = [];
  bool _isLoading = true;

  List restaurants = [];

  @override
  void initState() {
    super.initState();
    _fetchFoods();
    _fetchRestaurants();
  }

  Future<void> _fetchFoods() async {
    try {
      final response = await http.get(Uri.parse(Config.baseUrl + "get_food.php"));
      setState(() {
        foods = json.decode(response.body);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteFood(int id) async {
    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl + "admin_delete.php"),
        body: {"table": "food_items", "id": id.toString()},
      );
      _fetchFoods();
    } catch (e) {}
  }

  Future<void> _fetchRestaurants() async {
    try {
      final response = await http.get(Uri.parse(Config.baseUrl + "get_restaurants.php"));
      setState(() => restaurants = json.decode(response.body));
    } catch (e) {}
  }

  Future<void> _showFoodDialog([Map? food]) {
    final nameController = TextEditingController(text: food?['name']);
    final priceController = TextEditingController(text: food?['price']?.toString());
    final imageController = TextEditingController(text: food?['image']);
    final descController = TextEditingController(text: food?['description']);
    String? selectedRestId = food?['restaurant_id']?.toString();

    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(food == null ? "Add Food Item" : "Edit Food Item"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
              TextField(controller: priceController, decoration: InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
              TextField(controller: imageController, decoration: InputDecoration(labelText: "Image URL")),
              TextField(controller: descController, decoration: InputDecoration(labelText: "Description")),
              DropdownButtonFormField<String>(
                value: selectedRestId,
                items: restaurants.map((r) => DropdownMenuItem(value: r['id'].toString(), child: Text(r['name']))).toList(),
                onChanged: (v) => selectedRestId = v,
                decoration: InputDecoration(labelText: "Restaurant"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await http.post(
                Uri.parse(Config.baseUrl + "admin_save.php"),
                body: {
                  "table": "food_items",
                  "id": food?['id']?.toString() ?? "",
                  "name": nameController.text,
                  "price": priceController.text,
                  "image": imageController.text,
                  "description": descController.text,
                  "restaurant_id": selectedRestId ?? "",
                },
              );
              Navigator.pop(ctx);
              _fetchFoods();
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _viewFoodDetails(Map food) {
    String name = food['name']?.toString() ?? "N/A";
    String image = food['image']?.toString() ?? "";
    String price = food['price']?.toString() ?? "0.00";
    String restaurant = food['restaurant_name']?.toString() ?? "Unknown";
    String description = food['description']?.toString() ?? "No description provided.";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(name),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (image.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      image,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.grey.shade200,
                        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: Icon(Icons.fastfood, size: 50, color: Colors.grey),
                  ),
                SizedBox(height: 15),
                Text("Price:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text("\$$price", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                SizedBox(height: 10),
                Text("Restaurant:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text(restaurant, style: TextStyle(fontSize: 16)),
                SizedBox(height: 15),
                Text("Description:", style: TextStyle(fontWeight: FontWeight.bold)),
                Divider(),
                Text(description, style: TextStyle(height: 1.4)),
              ],
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Close"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Food"), backgroundColor: Colors.blueGrey.shade900, foregroundColor: Colors.white),
      drawer: AdminDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey.shade900,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _showFoodDialog(),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final food = foods[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      food['image'], 
                      width: 50, 
                      height: 50, 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.fastfood, size: 30, color: Colors.grey),
                    ),
                  ),
                  title: Text(food['name']),
                  subtitle: Text("${food['restaurant_name']} - \$${food['price']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.visibility, color: Colors.green), onPressed: () => _viewFoodDetails(food)),
                      IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => _showFoodDialog(food)),
                      IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteFood(int.parse(food['id'].toString()))),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}
