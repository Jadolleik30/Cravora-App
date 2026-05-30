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
  final TextEditingController _nameController =
  TextEditingController(text: Session.userName ?? '');
  final TextEditingController _emailController =
  TextEditingController(text: Session.userEmail ?? '');
  final TextEditingController _phoneController =
  TextEditingController(text: Session.userPhone ?? '');
  final TextEditingController _addressController =
  TextEditingController(text: Session.userAddress ?? '');
  final TextEditingController _dobController =
  TextEditingController(text: Session.userDOB ?? '');
  final TextEditingController _genderController =
  TextEditingController(text: Session.userGender ?? '');

  bool _isLoading = false;

  bool get _profileComplete {
    return _nameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        _addressController.text.trim().isNotEmpty &&
        _dobController.text.trim().isNotEmpty &&
        _genderController.text.trim().isNotEmpty;
  }

  void _showCompleteProfileMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please complete your profile first"),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (!_profileComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please complete all required profile fields"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final wasIncomplete = !Session.profileCompleted;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl + "update_profile.php"),
        body: {
          "user_id": Session.userId.toString(),
          "name": _nameController.text.trim(),
          "phone": _phoneController.text.trim(),
          "address": _addressController.text.trim(),
          "dob": _dobController.text.trim(),
          "gender": _genderController.text.trim(),
        },
      );

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        Session.login(data['user']);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );

        if (wasIncomplete) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
                (route) => false,
          );
        }
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Failed to update profile"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error updating profile"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _signOut() {
    Session.logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canLeave = Session.profileCompleted;

    return WillPopScope(
      onWillPop: () async {
        if (!canLeave) {
          _showCompleteProfileMessage();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            "Account",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          backgroundColor: Colors.orange,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          automaticallyImplyLeading: canLeave,
          actions: [
            if (canLeave) NotificationBell(),
            const SizedBox(width: 10),
          ],
        ),
        drawer: canLeave ? UserDrawer() : null,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              if (!canLeave)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  color: Colors.orangeAccent.shade100,
                  child: Text(
                    "Complete your profile to continue using Cravora.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              Container(
                padding: const EdgeInsets.all(20),
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
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Text(
                      (Session.userName ?? '').isNotEmpty
                          ? Session.userName!
                          : "User Name",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    Text(
                      (Session.userEmail ?? '').isNotEmpty
                          ? Session.userEmail!
                          : "user@example.com",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.stars,
                            color: Colors.amber.shade800,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${Session.userPoints} Cravora Points",
                            style: TextStyle(
                              color: Colors.amber.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                    const Text(
                      "Personal Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildModernField(
                      _nameController,
                      "Full Name",
                      Icons.person_outline,
                    ),

                    const SizedBox(height: 15),

                    _buildModernField(
                      _emailController,
                      "Email",
                      Icons.email_outlined,
                      readOnly: true,
                    ),

                    const SizedBox(height: 15),

                    _buildModernField(
                      _phoneController,
                      "Phone Number",
                      Icons.phone_android_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(child: _buildDatePickerField()),
                        const SizedBox(width: 15),
                        Expanded(child: _buildGenderField()),
                      ],
                    ),

                    const SizedBox(height: 15),

                    _buildModernField(
                      _addressController,
                      "Delivery Address",
                      Icons.location_on_outlined,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 35),

                    _isLoading
                        ? const Center(
                      child: CircularProgressIndicator(color: Colors.red),
                    )
                        : ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    OutlinedButton(
                      onPressed: _signOut,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Sign Out",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernField(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool readOnly = false,
        int maxLines = 1,
        TextInputType? keyboardType,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontWeight: FontWeight.bold),
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
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
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
        child: _buildModernField(
          _dobController,
          "Date of Birth",
          Icons.calendar_today_outlined,
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Gender",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          value: ["Male", "Female"].contains(_genderController.text)
              ? _genderController.text
              : null,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.people_outline, color: Colors.black87),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          ),
          items: ["Male", "Female"].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _genderController.text = newValue!;
            });
          },
        ),
      ],
    );
  }
}