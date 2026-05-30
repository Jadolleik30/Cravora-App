import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../session.dart';
import '../widgets/notification_bell.dart';

class PlaceOrderPage extends StatefulWidget {
  @override
  _PlaceOrderPageState createState() => _PlaceOrderPageState();
}

class _PlaceOrderPageState extends State<PlaceOrderPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _voucherController = TextEditingController();
  bool _isLoading = false;
  String _paymentMethod = "Credit Card";
  double _discountAmount = 0.0;
  String? _appliedVoucherCode;

  Future<void> _applyVoucher(double originalPrice) async {
    if (_voucherController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl + "validate_voucher.php"),
        body: {
          "code": _voucherController.text,
          "order_value": originalPrice.toString(),
        },
      );

      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          if (data['discount_type'] == 'percentage') {
            _discountAmount = originalPrice * (data['discount_value'] / 100);
          } else {
            _discountAmount = data['discount_value'];
          }
          _appliedVoucherCode = data['code'];
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Voucher applied! You saved \$${_discountAmount.toStringAsFixed(2)}"),
            backgroundColor: Colors.green));
      } else {
        setState(() {
          _discountAmount = 0;
          _appliedVoucherCode = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(data['message']), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error validating voucher")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmOrder() async {
    if (!Session.profileCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Complete your profile to continue using Cravora."),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pushNamed(context, '/profile');
      return;
    }

    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Please enter a delivery address"),
          backgroundColor: Colors.orange));
      return;
    }

    final items = Session.cartItems
        .map((item) => {
              "food_id": item['id'],
              "quantity": Session.itemQuantity(item),
            })
        .toList();

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl + "place_order.php"),
        body: {
          "user_id": Session.userId.toString(),
          "address": _addressController.text,
          "payment_method": _paymentMethod,
          "voucher_code": _appliedVoucherCode ?? "",
          "items": json.encode(items),
        },
      );

      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        Session.clearCart();
        Session.userPoints +=
            int.tryParse(data['points']?.toString() ?? "0") ?? 0;

        Navigator.pushNamed(
          context,
          '/confirm_payment',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(data['message']), backgroundColor: Colors.red));
        if (data['status'] == 'profile_incomplete') {
          Navigator.pushNamed(context, '/profile');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error placing order")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = Session.cartItems;
    double originalPrice = Session.cartTotal;
    double finalPrice = originalPrice - _discountAmount;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Checkout",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          NotificationBell(),
          SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              // Order Summary Section
              _buildSectionTitle("Items In Your Bag"),
              Column(
                children: cartItems
                    .map((item) => _buildModernItemCard(item))
                    .toList(),
              ),

              SizedBox(height: 30),
              _buildSectionTitle("Delivery Location"),
              _buildModernTextField(
                controller: _addressController,
                hint: "123 Street, District, City",
                icon: Icons.location_on_outlined,
              ),

              SizedBox(height: 30),
              _buildSectionTitle("Promo Code"),
              Row(
                children: [
                  Expanded(
                    child: _buildModernTextField(
                      controller: _voucherController,
                      hint: "Enter Coupon Code",
                      icon: Icons.local_offer_outlined,
                    ),
                  ),
                  SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: () => _applyVoucher(originalPrice),
                    child: Text("Apply"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),
              _buildSectionTitle("Payment Method"),
              _buildPaymentOption("Credit Card", Icons.credit_card_outlined),
              _buildPaymentOption("Cash on Delivery", Icons.payments_outlined),

              SizedBox(height: 40),
              // Price Breakdown
              _buildPriceRow("Subtotal", originalPrice),
              if (_discountAmount > 0)
                _buildPriceRow("Voucher Discount", -_discountAmount,
                    isDiscount: true),
              _buildPriceRow("Delivery Fee", 0.0, isFree: true),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Divider(color: Colors.grey.shade100, thickness: 1),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total Amount",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  Text("\$${finalPrice.toStringAsFixed(2)}",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.red)),
                ],
              ),

              SizedBox(height: 40),

              _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.red))
                  : ElevatedButton(
                      onPressed: () => _confirmOrder(),
                      child: Text("Place Order Now",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 65),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                    ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Text(title,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
    );
  }

  Widget _buildModernItemCard(Map food) {
    final quantity = Session.itemQuantity(food);
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(food['image']!,
                width: 70, height: 70, fit: BoxFit.cover),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food['name']!,
                    style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                Text(
                    quantity > 1
                        ? "Standard Portion x$quantity"
                        : "Standard Portion",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text("\$${(Session.itemPrice(food) * quantity).toStringAsFixed(2)}",
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildModernTextField(
      {required TextEditingController controller,
      required String hint,
      required IconData icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.red, size: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String value, IconData icon) {
    bool isSelected = _paymentMethod == value;
    return InkWell(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border:
              Border.all(color: isSelected ? Colors.red : Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.red : Colors.grey),
            SizedBox(width: 15),
            Expanded(
                child: Text(value,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.red : Colors.black87))),
            if (isSelected)
              Icon(Icons.check_circle, color: Colors.red, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount,
      {bool isDiscount = false, bool isFree = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: isDiscount ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.w500)),
          Text(
            isFree
                ? "FREE"
                : (isDiscount
                    ? "-\$${amount.abs().toStringAsFixed(2)}"
                    : "\$${amount.toStringAsFixed(2)}"),
            style: TextStyle(
              color: isFree
                  ? Colors.green
                  : (isDiscount ? Colors.green : Colors.black),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
