import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../../session.dart';
import '../../widgets/admin_drawer.dart';

class ManageUsersPage extends StatefulWidget {
  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  List users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await http.get(Uri.parse(Config.baseUrl + "get_users.php"));
      setState(() {
        users = json.decode(response.body);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser(int id) async {
    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl + "admin_delete.php"),
        body: {"table": "users", "id": id.toString()},
      );
      final res = json.decode(response.body);
      if (res['status'] == 'success') {
        _fetchUsers();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User deleted")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
      }
    } catch (e) {}
  }

  Future<void> _showUserDialog([Map? user]) {
    final nameController = TextEditingController(text: user?['name']);
    final emailController = TextEditingController(text: user?['email']);
    final roleController = TextEditingController(text: user?['role'] ?? 'user');
    final passwordController = TextEditingController();

    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(user == null ? "Add User" : "Edit User"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
              TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
              if (user == null) TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
              DropdownButtonFormField<String>(
                value: roleController.text,
                items: ["user", "admin"].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (v) => roleController.text = v!,
                decoration: InputDecoration(labelText: "Role"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Map<String, String> body = {
                "table": "users",
                "id": user?['id']?.toString() ?? "",
                "name": nameController.text,
                "email": emailController.text,
                "role": roleController.text,
              };
              if (user == null) body["password"] = passwordController.text;
              
              await http.post(Uri.parse(Config.baseUrl + "admin_save.php"), body: body);
              Navigator.pop(ctx);
              _fetchUsers();
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _viewUserDetails(Map user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("User Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${user['name']}", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Email: ${user['email']}"),
            Text("Role: ${user['role']}"),
            Text("Phone: ${user['phone'] ?? 'N/A'}"),
            Text("Address: ${user['address'] ?? 'N/A'}"),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Close"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Users"), backgroundColor: Colors.blueGrey.shade900, foregroundColor: Colors.white),
      drawer: AdminDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey.shade900,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _showUserDialog(),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              bool isAccountAdmin = user['role'] == 'admin';
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(user['name']),
                  subtitle: Text("${user['email']} - ${user['role']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.visibility, color: Colors.green), onPressed: () => _viewUserDetails(user)),
                      if (!isAccountAdmin) ...[
                        IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => _showUserDialog(user)),
                        IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteUser(int.parse(user['id'].toString()))),
                      ]
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}
