import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../widgets/user_drawer.dart';
import '../widgets/notification_bell.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List results = [];
  bool _isLoading = false;

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() => results = []);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(Config.baseUrl + "search_food.php?q=$query"));
      setState(() {
        results = json.decode(response.body);
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
        title: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.white),
          onChanged: _search,
          decoration: InputDecoration(
            hintText: "Search for food...",
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
        ),
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          NotificationBell(),
          SizedBox(width: 10),
        ],
      ),
      drawer: UserDrawer(),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              children: [
                if (results.isEmpty)
                  Container(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 80, color: Colors.grey.shade300),
                          Text("Search for your favorite food", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final food = results[index];
                      String imageUrl = food['image'] != null && food['image'].toString().isNotEmpty 
                          ? food['image'] 
                          : "https://images.unsplash.com/photo-1604382354936-07c5d9983bd3";

                      return ListTile(
                        leading: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
                        title: Text(food['name']),
                        subtitle: Text("\$${food['price']}"),
                        onTap: () {
                          Navigator.pushNamed(context, '/food_details', arguments: {
                            'name': food['name'],
                            'price': food['price'].toString(),
                            'image': imageUrl,
                            'description': food['description'],
                            'discount': food['discount']?.toString(),
                            'calories': food['calories']?.toString(),
                            'ingredients': food['ingredients'],
                            'featured_review': food['featured_review'],
                          });
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
    );
  }
}
