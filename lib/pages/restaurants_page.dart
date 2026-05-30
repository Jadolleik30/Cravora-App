import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../widgets/user_drawer.dart';
import '../widgets/notification_bell.dart';

class RestaurantsPage extends StatefulWidget {
  @override
  _RestaurantsPageState createState() => _RestaurantsPageState();
}

class _RestaurantsPageState extends State<RestaurantsPage> {
  List restaurants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  Future<void> _fetchRestaurants() async {
    try {
      final response =
          await http.get(Uri.parse(Config.baseUrl + "get_restaurants.php"));
      if (mounted) {
        setState(() {
          restaurants = json.decode(response.body);
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
        title: Text("All Restaurants",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.red.shade700,
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
          : RefreshIndicator(
              onRefresh: _fetchRestaurants,
              color: Colors.red,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                physics: BouncingScrollPhysics(),
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  final rest = restaurants[index];
                  return _buildRestaurantCard(rest);
                },
              ),
            ),
    );
  }

  Widget _buildRestaurantCard(dynamic rest) {
    String imageUrl = rest['image'] ??
        "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4";

    return Container(
      margin: EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: Offset(0, 10))
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/delivery',
            arguments: {'restaurant_id': rest['id']}),
        borderRadius: BorderRadius.circular(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                  child: Image.network(imageUrl,
                      height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 5)
                        ]),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text("${rest['rating']}",
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                if (rest['is_open'] == '1')
                  Positioned(
                    bottom: 15,
                    left: 15,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text("OPEN NOW",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),

            // Restaurant Info
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          rest['name'],
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.favorite_border, color: Colors.grey.shade400),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    rest['description'] ?? "Premium dining experience",
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 14, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      _buildInfoTag(
                        Icons.access_time_rounded,
                        rest['delivery_time'] ?? "20-30 min",
                      ),
                      SizedBox(width: 15),
                      _buildInfoTag(Icons.location_on_outlined,
                          rest['address'] ?? "City Center"),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      _buildInfoTag(Icons.phone_outlined,
                          rest['phone'] ?? "+961 01 234 567"),
                      SizedBox(width: 15),
                      _buildInfoTag(
                          Icons.delivery_dining_outlined, "Free Delivery"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.red),
        SizedBox(width: 6),
        Text(text,
            style: TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
