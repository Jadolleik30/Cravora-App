class Session {
  static bool isLoggedIn = false;
  static String? userName;
  static String? userEmail;
  static int? userId;
  static String? userPhone;
  static String? userAddress;
  static String? userDOB;
  static String? userGender;
  static String? userRole;
  static int userPoints = 0;
  static Future<Map<String, dynamic>?> getUser() async {
    if (!isLoggedIn || userId == null) return null;
    return {
      'id': userId,
      'name': userName,
      'email': userEmail,
      'role': userRole,
    };
  }
  
  // Cart management
  static int? activeRestaurantId;
  static String? activeRestaurantName;
  static List<Map<String, dynamic>> cartItems = [];

  static double get cartTotal => cartItems.fold(0, (sum, item) => sum + (double.tryParse(item['price'].toString()) ?? 0));

  static void login(Map user) {
    isLoggedIn = true;
    userId = int.tryParse(user['id'].toString());
    userName = user['name'];
    userEmail = user['email'];
    userRole = user['role'] ?? 'user';
    userPhone = user['phone'];
    userAddress = user['address'];
    userDOB = user['dob'];
    userGender = user['gender'];
    userPoints = int.tryParse(user['points']?.toString() ?? "0") ?? 0;
  }

  static void addToCart(Map<String, dynamic> item) {
    int restId = int.tryParse(item['restaurant_id'].toString()) ?? 0;
    if (activeRestaurantId != null && activeRestaurantId != restId) {
      // Logic for different restaurant should be handled by UI (showing dialog)
      return;
    }
    activeRestaurantId = restId;
    activeRestaurantName = item['restaurant_name'];
    cartItems.add(item);
  }

  static void clearCart() {
    cartItems.clear();
    activeRestaurantId = null;
    activeRestaurantName = null;
  }

  static void logout() {
    isLoggedIn = false;
    userId = null;
    userName = null;
    userEmail = null;
    userPhone = null;
    userAddress = null;
    userDOB = null;
    userGender = null;
    clearCart();
  }
}
