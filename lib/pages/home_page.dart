import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../session.dart';
import '../widgets/public_drawer.dart';
import '../widgets/user_drawer.dart';
import '../widgets/notification_bell.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List categories = [];
  List foodItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Session.isLoggedIn &&
          Session.userRole != 'admin' &&
          !Session.profileCompleted) {
        Navigator.pushReplacementNamed(context, '/profile');
      }
    });

    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final catRes =
          await http.get(Uri.parse(Config.baseUrl + "get_categories.php"));
      final foodRes =
          await http.get(Uri.parse(Config.baseUrl + "get_food.php"));

      if (!mounted) return;

      setState(() {
        categories = json.decode(catRes.body);
        foodItems = json.decode(foodRes.body);
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _openProtectedPage(String route) {
    if (!Session.isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    if (Session.userRole != 'admin' && !Session.profileCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Complete your profile to continue using Cravora."),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pushNamed(context, '/profile');
      return;
    }

    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final bool loggedIn = Session.isLoggedIn;
    final bool canUseUserNavigation =
        loggedIn && (Session.profileCompleted || Session.userRole == 'admin');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "CRAVORA",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          if (canUseUserNavigation) ...[
            NotificationBell(),
            const SizedBox(width: 5),
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.red.shade50,
                  child: const Icon(Icons.person_outline, color: Colors.red),
                ),
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: const Text("Sign In"),
              ),
            ),
        ],
      ),
      drawer: loggedIn
          ? (canUseUserNavigation ? UserDrawer() : null)
          : PublicDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : RefreshIndicator(
              onRefresh: _fetchData,
              color: Colors.red,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search & Hero Section
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "What are you\ncraving today?",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            decoration: InputDecoration(
                              hintText: "Search restaurants, dishes...",
                              prefixIcon:
                                  const Icon(Icons.search, color: Colors.grey),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Horizontal Categories
                    if (categories.isNotEmpty)
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          itemCount: categories.length,
                          itemBuilder: (ctx, i) {
                            final cat = categories[i];
                            return _buildModernCategory(
                                cat['name'] ?? "Category");
                          },
                        ),
                      ),

                    // Hero Banner
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            colors: [Colors.red.shade700, Colors.red.shade400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        constraints: const BoxConstraints(minHeight: 180),
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Positioned(
                              right: -20,
                              bottom: -20,
                              child: Icon(
                                Icons.restaurant_menu,
                                size: 200,
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(25.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.55,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        "NEW OFFER",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        "Get 50% Off\non your first order",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    ElevatedButton(
                                      onPressed: () =>
                                          _openProtectedPage('/delivery_food'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        "Order Now",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Popular Section Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Popular Dishes",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w800),
                          ),
                          TextButton(
                            onPressed: () =>
                                _openProtectedPage('/delivery_food'),
                            child: const Text(
                              "See All",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Modern Food Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: foodItems.length > 4 ? 4 : foodItems.length,
                      itemBuilder: (ctx, i) =>
                          _buildModernFoodCard(foodItems[i]),
                    ),

                    const SizedBox(height: 30),

                    // Features Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      color: Colors.grey.shade50,
                      child: Column(
                        children: [
                          const Text(
                            "Why Cravora?",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildModernFeature(Icons.flash_on, "Fast"),
                              _buildModernFeature(Icons.eco, "Fresh"),
                              _buildModernFeature(Icons.security, "Safe"),
                              _buildModernFeature(Icons.loyalty, "Rewards"),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildModernCategory(String name) {
    return Container(
      width: 90,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.fastfood_outlined,
                color: Colors.red, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernFoodCard(dynamic food) {
    String imageUrl =
        food['image'] != null && food['image'].toString().isNotEmpty
            ? food['image']
            : "https://images.unsplash.com/photo-1604382354936-07c5d9983bd3";

    return InkWell(
      onTap: () => _openProtectedPage('/delivery_food'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  imageUrl.trim(),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    print(error);
                    return const Icon(Icons.broken_image, size: 50);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food['name'] ?? "Food Item",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${food['price']}",
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const Icon(Icons.add_circle,
                          color: Colors.black, size: 24),
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

  Widget _buildModernFeature(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: Icon(icon, color: Colors.red, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
