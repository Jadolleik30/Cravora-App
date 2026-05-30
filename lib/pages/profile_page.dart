import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../session.dart';
import '../widgets/user_drawer.dart';
import '../config.dart';
import '../widgets/notification_bell.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController(text: Session.userName);
  final TextEditingController _emailController = TextEditingController(text: Session.userEmail);
  final TextEditingController _phoneController = TextEditingController(text: Session.userPhone);
  final TextEditingController _addressController = TextEditingController(text: Session.userAddress);
  final TextEditingController _dobController = TextEditingController(text: Session.userDOB);
  final TextEditingController _genderController = TextEditingController(text: Session.userGender);
  bool _isLoading = false;

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl + "update_profile.php"),
        body: {
          "user_id": Session.userId.toString(),
          "name": _nameController.text,
          "phone": _phoneController.text,
          "address": _addressController.text,
          "dob": _dobController.text,
          "gender": _genderController.text,
        },
      );

      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        Session.login(data['user']); // Update local session
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile updated successfully!"), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message']), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating profile"), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Account", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          NotificationBell(),
          SizedBox(width: 10),
        ],
      ),
      drawer: UserDrawer(),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.grey.shade100,
                          backgroundImage: NetworkImage(
                            _genderController.text == "Female"
                                ? "https://cdn-icons-png.flaticon.com/512/6997/6997662.png"
                                : "https://www.w3schools.com/howto/img_avatar.png",
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Text(Session.userName ?? "User Name", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  Text(Session.userEmail ?? "user@example.com", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  // Points Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stars, color: Colors.amber.shade800, size: 20),
                        SizedBox(width: 8),
                        Text("${Session.userPoints} Cravora Points", style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Personal Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  SizedBox(height: 20),
                  _buildModernField(_nameController, "Full Name", Icons.person_outline),
                  SizedBox(height: 15),
                  _buildModernField(_emailController, "Email", Icons.email_outlined, readOnly: true),
                  SizedBox(height: 15),
                  _buildModernField(_phoneController, "Phone Number", Icons.phone_android_outlined, keyboardType: TextInputType.phone),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildDatePickerField()),
                      SizedBox(width: 15),
                      Expanded(child: _buildGenderField()),
                    ],
                  ),
                  SizedBox(height: 15),
                  _buildModernField(_addressController, "Delivery Address", Icons.location_on_outlined, maxLines: 2),
                  
                  SizedBox(height: 35),
                  _isLoading
                      ? Center(child: CircularProgressIndicator(color: Colors.red))
                      : ElevatedButton(
                          onPressed: _updateProfile,
                          child: Text("Save Changes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                        ),
                  
                  SizedBox(height: 15),
                  OutlinedButton(
                    onPressed: () {
                      Session.logout();
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                    },
                    child: Text("Sign Out", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      minimumSize: Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernField(TextEditingController controller, String label, IconData icon, {bool readOnly = false, int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.black87),
            filled: true,
            fillColor: readOnly ? Colors.grey.shade50 : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField() {
    return InkWell(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            _dobController.text = pickedDate.toString().split(' ')[0];
          });
        }
      },
      child: AbsorbPointer(
        child: _buildModernField(_dobController, "Date of Birth", Icons.calendar_today_outlined),
      ),
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Gender", style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: ["Male", "Female"].contains(_genderController.text) ? _genderController.text : null,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.people_outline, color: Colors.black87),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
            contentPadding: EdgeInsets.symmetric(horizontal: 15),
          ),
          items: ["Male", "Female"].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) => setState(() => _genderController.text = newValue!),
        ),
      ],
    );
  }
}
