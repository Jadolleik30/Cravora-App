import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../session.dart';

class VerifyPage extends StatefulWidget {
  final String email;

  VerifyPage({
    required this.email,
  });

  @override
  _VerifyPageState createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;

  Future<void> verifyEmail() async {
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter verification code")),
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

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        if (data['user'] != null) {
          Session.login(data['user']);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Email verified successfully"),
            backgroundColor: Colors.green,
          ),
        );

        if (!Session.profileCompleted) {
          Navigator.pushNamedAndRemoveUntil(context, '/profile', (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
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

      final data = json.decode(response.body);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? "Verification code sent"),
          backgroundColor: data['status'] == 'success' ? Colors.green : Colors.red,
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
      appBar: AppBar(
        title: Text("Verify Email"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Verification Code",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Enter the 6-digit code sent to ${widget.email}",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: "Enter Code",
                border: OutlineInputBorder(),
                counterText: "",
              ),
            ),
            SizedBox(height: 25),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: verifyEmail,
                    child: Text("Verify"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 55),
                    ),
                  ),
            SizedBox(height: 12),
            TextButton(
              onPressed: _isResending ? null : resendCode,
              child: Text(_isResending ? "Sending..." : "Resend Code"),
            ),
          ],
        ),
      ),
    );
  }
}
