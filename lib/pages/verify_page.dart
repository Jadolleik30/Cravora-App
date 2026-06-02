import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../session.dart';

class VerifyPage extends StatefulWidget {
  final String email;
  final String? message;

  VerifyPage({
    required this.email,
    this.message,
  });

  @override
  _VerifyPageState createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;
  late String _pageMessage;

  @override
  void initState() {
    super.initState();
    _pageMessage = widget.message ??
        "Account created. Check your email for the verification code. If you did not receive it, press Resend Code.";
  }

  Map<String, dynamic>? _decodeJson(String body) {
    if (body.trim().isEmpty) return null;

    try {
      final decoded = json.decode(body);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Future<void> verifyEmail() async {
    final code = _codeController.text.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter the 6-digit verification code")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl + "verify_email.php"),
        body: {
          "email": widget.email,
          "code": code,
        },
      );

      final data = _decodeJson(response.body);
      if (data == null) {
        throw FormatException("Invalid server response");
      }

      if (data['status'] == 'success') {
        final user = data['user'];
        if (user is Map) {
          Session.login(Map<String, dynamic>.from(user));
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Email verified successfully"),
            backgroundColor: Colors.green,
          ),
        );

        if (!Session.isLoggedIn) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        } else if (!Session.profileCompleted) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/profile', (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, '/delivery', (route) => false);
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Invalid verification code"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Connection error"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> resendCode() async {
    setState(() => _isResending = true);

    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl + "resend_code.php"),
        body: {
          "email": widget.email,
        },
      );

      final data = _decodeJson(response.body);
      if (data == null) {
        throw FormatException("Invalid server response");
      }

      if (!mounted) return;
      if (data['status'] == 'success' && data['email_sent'] == true) {
        setState(() {
          _pageMessage = "A new verification code was sent to ${widget.email}.";
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? "Verification code sent"),
          backgroundColor:
              data['status'] == 'success' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Connection error"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Verify Email"),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.mark_email_read_outlined,
                  color: Colors.red, size: 42),
            ),
            SizedBox(height: 30),
            Text(
              "Verification Code",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 10),
            Text(
              _pageMessage,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10),
            Text(
              widget.email,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                labelText: "Enter Code",
                prefixIcon: Icon(Icons.password_outlined, color: Colors.red),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
                counterText: "",
              ),
            ),
            SizedBox(height: 25),
            _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.red))
                : ElevatedButton(
                    onPressed: verifyEmail,
                    child: Text("Verify"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 55),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
            SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: _isResending ? null : resendCode,
                child: Text(
                  _isResending ? "Sending..." : "Resend Code",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
