import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../session.dart';
import '../widgets/user_drawer.dart';

class RewardsPage extends StatefulWidget {
  @override
  _RewardsPageState createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  List vouchers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVouchers();
  }

  Future<void> _fetchVouchers() async {
    try {
      final response =
          await http.get(Uri.parse(Config.baseUrl + "get_vouchers.php"));
      if (mounted) {
        setState(() {
          vouchers = json.decode(response.body);
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
        title: Text("Cravora Rewards",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.red.shade700,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: UserDrawer(),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            // Premium Points Header
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade900, Colors.red.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 10))
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        shape: BoxShape.circle),
                    child: Icon(Icons.stars_rounded,
                        color: Colors.white, size: 50),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "${Session.userPoints}",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2),
                  ),
                  Text(
                    "TOTAL CRAVORA POINTS",
                    style: TextStyle(
                        color: Colors.red.shade50,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2),
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(10)),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (Session.userPoints % 500) / 500,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Colors.white, Colors.red.shade100]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "${500 - (Session.userPoints % 500)} points until your next \$5 reward",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Active Vouchers",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w900)),
                      Icon(Icons.local_offer_outlined, color: Colors.red),
                    ],
                  ),
                  SizedBox(height: 20),
                  _isLoading
                      ? Center(
                          child: CircularProgressIndicator(color: Colors.red))
                      : vouchers.isEmpty
                          ? _buildEmptyVouchers()
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: vouchers.length,
                              itemBuilder: (ctx, i) {
                                final v = vouchers[i];
                                return _buildVoucherCard(v);
                              },
                            ),
                  SizedBox(height: 30),
                  _buildLoyaltyPerksSection(),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyVouchers() {
    return Container(
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
          color: Colors.grey.shade50, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Icon(Icons.confirmation_number_outlined,
              size: 50, color: Colors.grey.shade300),
          SizedBox(height: 15),
          Text("No vouchers yet",
              style:
                  TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildVoucherCard(dynamic v) {
    bool isPercentage = v['discount_type'] == 'percentage';

    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 100,
              color: Colors.red,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isPercentage
                        ? "${v['discount_value']}%"
                        : "\$${v['discount_value']}",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20),
                  ),
                  Text("OFF",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v['code'],
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: 1)),
                    SizedBox(height: 4),
                    Text("Min. Order: \$${v['min_order_value']}",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text("Expires: ${v['expiry_date']}",
                        style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: IconButton(
                icon: Icon(Icons.copy_rounded, color: Colors.red),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Code ${v['code']} copied!",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.black,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoyaltyPerksSection() {
    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.red.shade700, size: 20),
              SizedBox(width: 10),
              Text("Member Perks",
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Colors.red.shade800)),
            ],
          ),
          SizedBox(height: 20),
          _buildPerkItem(
              Icons.paid_outlined, "Earn 1 point for every \$1 spent"),
          _buildPerkItem(
              Icons.card_giftcard, "Convert 500 points to \$5 discount"),
          _buildPerkItem(
              Icons.flash_on_outlined, "Priority delivery for Gold members"),
        ],
      ),
    );
  }

  Widget _buildPerkItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.red.shade700),
          SizedBox(width: 12),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                      color: Colors.red.shade800,
                      fontSize: 13,
                      fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
