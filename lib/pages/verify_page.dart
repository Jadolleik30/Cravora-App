import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

class VerifyPage extends StatefulWidget {

  final String email;
  final String code;

  VerifyPage({
    required this.email,
    required this.code,
  });

  @override
  _VerifyPageState createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {

  final TextEditingController _codeController =
  TextEditingController();

  bool _isLoading = false;

  Future<void> verifyEmail() async {

    if (_codeController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Enter verification code"),
        ),
      );

      return;
    }

    setState(() => _isLoading = true);

    try {

      final response = await http.post(
        Uri.parse(Config.baseUrl + "verify_email.php"),
        body: {
          "email": widget.email,
          "code": _codeController.text,
        },
      );

      final data = json.decode(response.body);

      if (data['status'] == 'success') {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Email verified successfully"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacementNamed(context, '/login');

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: Colors.red,
          ),
        );
      }

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Connection error"),
          backgroundColor: Colors.red,
        ),
      );

    } finally {

      setState(() => _isLoading = false);
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
              "Demo code: ${widget.code}",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            SizedBox(height: 30),

            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter Code",
                border: OutlineInputBorder(),
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
          ],
        ),
      ),
    );
  }
}