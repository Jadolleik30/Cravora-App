import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../session.dart';
import '../widgets/public_drawer.dart';
import 'verify_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields"), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl + "login.php"),
        body: {
          "email": _emailController.text,
          "password": _passwordController.text,
        },
      );

      final data = json.decode(response.body);
      if (data['status'] == "success") {
        Session.login(data['user']);
        if (Session.userRole == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
        } else if (!Session.profileCompleted) {
          Navigator.pushReplacementNamed(context, '/profile');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else if (data['status'] == "unverified") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message']), backgroundColor: Colors.orange));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyPage(
              email: data['email'] ?? _emailController.text.trim(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message']), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Connection Error"), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: PublicDrawer(),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20)),
                child: Icon(Icons.lock_person_outlined, color: Colors.red, size: 40),
              ),
              SizedBox(height: 30),
              Text(
                "Welcome Back!",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.black),
              ),
              Text(
                "Login to continue your foodie journey",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 50),
              
              // Email Field
              _buildModernInput(
                controller: _emailController,
                label: "Email Address",
                hint: "you@example.com",
                icon: Icons.alternate_email,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 25),
              
              // Password Field
              _buildModernInput(
                controller: _passwordController,
                label: "Password",
                hint: "••••••••",
                icon: Icons.lock_outline,
                obscure: _obscurePassword,
                suffix: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              
              
              SizedBox(height: 30),
              
              _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.red))
                  : ElevatedButton(
                      onPressed: _login,
                      child: Text("Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                    ),
              
              SizedBox(height: 20),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("New to Cravora?", style: TextStyle(color: Colors.grey.shade600)),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
                    child: Text("Create Account", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
        SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: Colors.red.shade400),
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }
}
