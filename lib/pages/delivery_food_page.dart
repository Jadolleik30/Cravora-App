import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../session.dart';
import '../widgets/user_drawer.dart';
import '../widgets/notification_bell.dart';

class DeliveryFoodPage extends StatefulWidget {
  @override
  _DeliveryFoodPageState createState() => _DeliveryFoodPageState();
}

class _DeliveryFoodPageState extends State<DeliveryFoodPage> {
  List foods = [];
  List filteredFoods = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  int? _filterRestaurantId;
  Map? _currentRestaurant;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args != null && args.containsKey('restaurant_id')) {
      _filterRestaurantId = int.tryParse(args['restaurant_id'].toString());
    }
    _fetchFoods();
    if (_filterRestaurantId != null) {
      _fetchRestaurantDetails();
    }
  }

  Future<void> _fetchRestaurantDetails() async {
    try {
      final response =
          await http.get(Uri.parse(Config.baseUrl + "get_restaurants.php"));
      List restaurants = json.decode(response.body);
      setState(() {
        _currentRestaurant = restaurants.firstWhere(
            (r) => r['id'].toString() == _filterRestaurantId.toString());
      });
    } catch (e) {}
  }

  Future<void> _fetchFoods() async {
    try {
      final response =
          await http.get(Uri.parse(Config.baseUrl + "get_food.php"));
      List allFoods = json.decode(response.body);

      setState(() {
        foods = allFoods;
        if (_filterRestaurantId != null) {
          filteredFoods = foods
              .where((f) =>
                  f['restaurant_id'].toString() ==
                  _filterRestaurantId.toString())
              .toList();
        } else {
          filteredFoods = foods;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterFoods(String query) {
    setState(() {
      filteredFoods = foods.where((food) {
        final matchesSearch =
            food['name'].toString().toLowerCase().contains(query.toLowerCase());
        final matchesRestaurant = _filterRestaurantId == null ||
            food['restaurant_id'].toString() == _filterRestaurantId.toString();
        return matchesSearch && matchesRestaurant;
      }).toList();
    });
  }

  void _quickOrder(Map food, String imageUrl) {
    int foodRestId = int.tryParse(food['restaurant_id'].toString()) ?? 0;

    if (Session.activeRestaurantId != null &&
        Session.activeRestaurantId != foodRestId) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Switch Restaurant?"),
          content: Text(
              "You have items from ${Session.activeRestaurantName}. Clear cart to start an order with ${food['restaurant_name']}?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  Session.clearCart();
                  Session.addToCart({...food, 'image': imageUrl});
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("New order started!"),
                    backgroundColor: Colors.green));
              },
              child: Text("Clear & Add"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        Session.addToCart({...food, 'image': imageUrl});
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Added ${food['name']} to cart"),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 1),
      ));
    }
  }

  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10)))),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Your Selection",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                TextButton.icon(
                  icon: Icon(Icons.delete_outline, color: Colors.red),
                  label: Text("Clear", style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    setState(() => Session.clearCart());
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Text("From ${Session.activeRestaurantName}",
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: Session.cartItems.length,
                itemBuilder: (ctx, i) {
                  final item = Session.cartItems[i];
                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(item['image'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildImageFallback(iconSize: 24)),
                      ),
                      title: Text(item['name'],
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          "${Session.itemQuantity(item)} x \$${Session.itemPrice(item).toStringAsFixed(2)}"),
                      trailing: IconButton(
                          icon: Icon(Icons.remove_circle_outline,
                              color: Colors.grey),
                          onPressed: () {}),
                    ),
                  );
                },
              ),
            ),
            Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Subtotal",
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
                Text("\$${Session.cartTotal.toStringAsFixed(2)}",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.red)),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/place_order', arguments: {
                  ...Session.cartItems.first,
                  'total_price': Session.cartTotal,
                });
              },
              child: Text("Checkout Now",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _viewDetails(Map food, String imageUrl) {
    Navigator.pushNamed(context, '/food_details', arguments: {
      'id': food['id'],
      'name': food['name'],
      'price': food['price'].toString(),
      'image': imageUrl,
      'description': food['description'],
      'discount': food['discount']?.toString(),
      'restaurant_id': food['restaurant_id'],
      'restaurant_name': food['restaurant_name'],
      'rating': food['rating']?.toString() ?? "4.8",
      'calories': food['calories']?.toString() ?? "320",
      'ingredients': food['ingredients'],
      'featured_review': food['featured_review'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Browse Menu",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 24)),
        backgroundColor: Colors.red.shade700,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          NotificationBell(),
          SizedBox(width: 10),
        ],
      ),
      drawer: UserDrawer(),
      floatingActionButton: Session.cartItems.isEmpty
          ? null
          : Container(
              margin: EdgeInsets.only(bottom: 20),
              child: FloatingActionButton.extended(
                onPressed: _showCartBottomSheet,
                backgroundColor: Colors.black,
                elevation: 10,
                icon: Icon(Icons.shopping_bag, color: Colors.white),
                label: Text(
                    "${Session.cartItemCount} items  |  \$${Session.cartTotal.toStringAsFixed(2)}",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.red))
          : Column(
              children: [
                if (_currentRestaurant != null)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      image: DecorationImage(
                        image: NetworkImage(_currentRestaurant!['image']),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.3), BlendMode.darken),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_currentRestaurant!['name'],
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900)),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            Text(
                                " ${_currentRestaurant!['rating']}  |  Verified Restaurant",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: () => setState(() {
                            _filterRestaurantId = null;
                            _currentRestaurant = null;
                            filteredFoods = foods;
                          }),
                          child: Text("Switch Restaurant",
                              style: TextStyle(
                                  color: Colors.white,
                                  decoration: TextDecoration.underline)),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterFoods,
                    decoration: InputDecoration(
                      hintText: "Search in this menu...",
                      prefixIcon: Icon(Icons.search, color: Colors.red),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.only(
                        left: 20, right: 20, top: 10, bottom: 100),
                    physics: BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: filteredFoods.length,
                    itemBuilder: (context, index) {
                      final food = filteredFoods[index];
                      String imageUrl = food['image'] != null &&
                              food['image'].toString().isNotEmpty
                          ? food['image']
                          : "https://images.unsplash.com/photo-1604382354936-07c5d9983bd3";

                      double price =
                          double.tryParse(food['price'].toString()) ?? 0;
                      double? disc =
                          double.tryParse(food['discount']?.toString() ?? "");
                      bool hasDiscount =
                          disc != null && disc > 0 && disc < price;

                      return _buildModernFoodCard(
                          food, imageUrl, hasDiscount, disc);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildModernFoodCard(
      dynamic food, String imageUrl, bool hasDiscount, double? disc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: Offset(0, 10))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: () => _viewDetails(food, imageUrl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Image.network(imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) => _buildImageFallback()),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: InkWell(
                        onTap: () => _quickOrder(food, imageUrl),
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.9),
                          radius: 18,
                          child: Icon(Icons.add, color: Colors.red, size: 22),
                        ),
                      ),
                    ),
                    if (hasDiscount)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10)),
                          child: Text("SALE",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(food['name'],
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        Text(" ${food['rating'] ?? '4.8'}",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasDiscount)
                              Text("\$${food['price']}",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                      decoration: TextDecoration.lineThrough)),
                            Text(
                              "\$${hasDiscount ? disc : food['price']}",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: 14, color: Colors.grey.shade300),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageFallback({double iconSize = 42}) {
    return Container(
      color: Colors.red.shade50,
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_menu_outlined,
        color: Colors.red.shade200,
        size: iconSize,
      ),
    );
  }
}
