import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../../widgets/admin_drawer.dart';

class ManageRestaurantsPage extends StatefulWidget {
  @override
  _ManageRestaurantsPageState createState() => _ManageRestaurantsPageState();
}

class _ManageRestaurantsPageState extends State<ManageRestaurantsPage> {
  List restaurants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  Future<void> _fetchRestaurants() async {
    try {
      final response = await http.get(Uri.parse(Config.baseUrl + "get_restaurants.php"));
      setState(() {
        restaurants = json.decode(response.body);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteRestaurant(int id) async {
    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl + "admin_delete.php"),
        body: {"table": "restaurants", "id": id.toString()},
      );
      _fetchRestaurants();
    } catch (e) {}
  }

  Future<void> _showRestaurantDialog([Map? rest]) {
    final nameController = TextEditingController(text: rest?['name']);
    final imageController = TextEditingController(text: rest?['image']);
    final descController = TextEditingController(text: rest?['description']);
    final ratingController = TextEditingController(text: rest?['rating']?.toString() ?? "4.5");

    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(rest == null ? "Add Restaurant" : "Edit Restaurant"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
              TextField(controller: imageController, decoration: InputDecoration(labelText: "Image URL")),
              TextField(controller: descController, decoration: InputDecoration(labelText: "Description")),
              TextField(controller: ratingController, decoration: InputDecoration(labelText: "Rating"), keyboardType: TextInputType.number),
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
                  "table": "restaurants",
                  "id": rest?['id']?.toString() ?? "",
                  "name": nameController.text,
                  "image": imageController.text,
                  "description": descController.text,
                  "rating": ratingController.text,
                },
              );
              Navigator.pop(ctx);
              _fetchRestaurants();
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _viewRestaurantDetails(Map rest) {
    // Safely extract data
    String name = rest['name']?.toString() ?? "N/A";
    String image = rest['image']?.toString() ?? "";
    String rating = rest['rating']?.toString() ?? "0.0";
    String description = rest['description']?.toString() ?? "No description provided.";

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
                    child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                  ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 20),
                    SizedBox(width: 5),
                    Text(rating, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                SizedBox(height: 15),
                Text("About", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Divider(),
                Text(description, style: TextStyle(height: 1.4, color: Colors.grey.shade800)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Restaurants"), backgroundColor: Colors.blueGrey.shade900, foregroundColor: Colors.white),
      drawer: AdminDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey.shade900,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _showRestaurantDialog(),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final rest = restaurants[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      rest['image'], 
                      width: 50, 
                      height: 50, 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.restaurant, size: 30, color: Colors.grey),
                    ),
                  ),
                  title: Text(rest['name']),
                  subtitle: Text(rest['description'] ?? ""),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.visibility, color: Colors.green), onPressed: () => _viewRestaurantDetails(rest)),
                      IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => _showRestaurantDialog(rest)),
                      IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteRestaurant(int.parse(rest['id'].toString()))),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}
