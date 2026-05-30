import 'package:flutter/material.dart';
import '../session.dart';
import '../widgets/user_drawer.dart';
import '../widgets/notification_bell.dart';

class FoodDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> food = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      drawer: UserDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(food['image']!, fit: BoxFit.cover),
            ),
            iconTheme: IconThemeData(color: Colors.white),
            actions: [
              NotificationBell(),
              SizedBox(width: 10),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(food['name']!, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (food['discount'] != null && food['discount'] != "0.00")
                              Text("\$${food['price']}", style: TextStyle(fontSize: 18, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                            Text("\$${food['discount'] != null && food['discount'] != "0.00" ? food['discount'] : food['price']}", 
                                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: List.generate(5, (index) => Icon(Icons.star, color: Colors.orange, size: 20)),
                    ),
                    SizedBox(height: 20),
                    Text("Description", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text(
                      food['description'] ?? "No description available.",
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.5),
                    ),
                    SizedBox(height: 20),
                    if (food['calories'] != null)
                      _buildDetailRow(Icons.bolt, "Calories", "${food['calories']} kcal"),
                    if (food['ingredients'] != null)
                      _buildDetailRow(Icons.list, "Ingredients", food['ingredients'] ?? ""),
                    if (food['featured_review'] != null)
                      _buildDetailRow(Icons.rate_review, "Featured Review", food['featured_review'] ?? ""),
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        if (!Session.isLoggedIn) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please login to add to cart")));
                          Navigator.pushNamed(context, '/login');
                          return;
                        }

                        int foodRestId = int.tryParse(food['restaurant_id'].toString()) ?? 0;
                        String restaurantName = food['restaurant_name'] ?? "Lebanese Restaurant";

                        if (Session.activeRestaurantId != null && Session.activeRestaurantId != foodRestId) {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text("Different Restaurant"),
                              content: Text("You already have items from ${Session.activeRestaurantName}. Clear cart to add this item?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
                                TextButton(onPressed: () {
                                  Session.clearCart();
                                  Session.addToCart(food);
                                  Navigator.pop(ctx);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cart cleared and item added!"), backgroundColor: Colors.green));
                                }, child: Text("Clear & Add", style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                        } else {
                          Session.addToCart(food);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("${food['name']} added to cart"),
                            backgroundColor: Colors.red,
                          ));
                        }
                      },
                      child: Text("Add to Cart", style: TextStyle(fontSize: 18, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.red),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(value, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
