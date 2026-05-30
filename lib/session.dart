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
  static bool isVerified = false;
  static bool profileCompleted = false;

  static bool _isTrue(dynamic value) {
    if (value == true) return true;
    final normalized = value?.toString().trim().toLowerCase();
    return normalized == '1' || normalized == 'true';
  }

  static String? _stringOrNull(dynamic value) {
    if (value == null) return null;
    final text = value.toString();
    return text == 'null' ? null : text;
  }

  static Future<Map<String, dynamic>?> getUser() async {
    if (!isLoggedIn || userId == null) return null;
    return {
      'id': userId,
      'name': userName,
      'email': userEmail,
      'role': userRole,
      'phone': userPhone,
      'address': userAddress,
      'dob': userDOB,
      'gender': userGender,
      'points': userPoints,
      'is_verified': isVerified ? 1 : 0,
      'profile_completed': profileCompleted ? 1 : 0,
    };
  }

  // Cart management
  static int? activeRestaurantId;
  static String? activeRestaurantName;
  static List<Map<String, dynamic>> cartItems = [];

  static double get cartTotal => cartItems.fold(
      0, (sum, item) => sum + (itemPrice(item) * itemQuantity(item)));
  static int get cartItemCount =>
      cartItems.fold(0, (sum, item) => sum + itemQuantity(item));

  static double itemPrice(Map item) {
    final price = double.tryParse(item['price'].toString()) ?? 0;
    final discount = double.tryParse(item['discount']?.toString() ?? "");
    return discount != null && discount > 0 && discount < price
        ? discount
        : price;
  }

  static int itemQuantity(Map item) {
    final quantity = int.tryParse(item['quantity']?.toString() ?? "1") ?? 1;
    return quantity < 1 ? 1 : quantity;
  }

  static void login(Map user) {
    userId = int.tryParse(user['id']?.toString() ?? '');
    userName = _stringOrNull(user['name']);
    userEmail = _stringOrNull(user['email']);
    userRole = _stringOrNull(user['role']) ?? 'user';
    userPhone = _stringOrNull(user['phone']);
    userAddress = _stringOrNull(user['address']);
    userDOB = _stringOrNull(user['dob']);
    userGender = _stringOrNull(user['gender']);
    userPoints = int.tryParse(user['points']?.toString() ?? "0") ?? 0;
    isVerified =
        user.containsKey('is_verified') ? _isTrue(user['is_verified']) : true;
    profileCompleted = isProfileComplete();
    isLoggedIn = userId != null && (userEmail ?? '').isNotEmpty;
  }

  static void addToCart(Map<String, dynamic> item) {
    int restId = int.tryParse(item['restaurant_id'].toString()) ?? 0;
    if (activeRestaurantId != null && activeRestaurantId != restId) {
      // Logic for different restaurant should be handled by UI (showing dialog)
      return;
    }
    activeRestaurantId = restId;
    activeRestaurantName = item['restaurant_name'];

    final itemId = item['id']?.toString();
    final existingIndex = cartItems
        .indexWhere((cartItem) => cartItem['id']?.toString() == itemId);
    if (itemId != null && existingIndex >= 0) {
      final existing = cartItems[existingIndex];
      existing['quantity'] = itemQuantity(existing) + 1;
    } else {
      cartItems.add({...item, 'quantity': itemQuantity(item)});
    }
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
    userRole = null;
    userPoints = 0;
    isVerified = false;
    profileCompleted = false;
    clearCart();
  }

  static bool isProfileComplete() {
    return (userName ?? '').trim().isNotEmpty &&
        (userPhone ?? '').trim().isNotEmpty &&
        (userAddress ?? '').trim().isNotEmpty &&
        (userDOB ?? '').trim().isNotEmpty &&
        (userGender ?? '').trim().isNotEmpty;
  }
}
