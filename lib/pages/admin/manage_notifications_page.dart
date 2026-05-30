import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../../widgets/admin_drawer.dart';

class ManageNotificationsPage extends StatefulWidget {
  @override
  _ManageNotificationsPageState createState() => _ManageNotificationsPageState();
}

class _ManageNotificationsPageState extends State<ManageNotificationsPage> {
  List notifications = [];
  List users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchNotifications(),
      _fetchUsers(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchNotifications() async {
    try {
      final response = await http.get(Uri.parse(Config.baseUrl + "get_notifications.php?is_admin=true"));
      final res = json.decode(response.body);
      if (res['status'] == 'success') {
        notifications = res['data'];
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    }
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await http.get(Uri.parse(Config.baseUrl + "get_users.php"));
      users = json.decode(response.body);
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  Future<void> _deleteNotification(int id) async {
    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl + "delete_notification.php"),
        body: {"id": id.toString()},
      );
      final res = json.decode(response.body);
      if (res['status'] == 'success') {
        _fetchNotifications();
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Notification deleted")));
      }
    } catch (e) {}
  }

  Future<void> _showNotificationDialog([Map? notification]) {
    final titleController = TextEditingController(text: notification?['title']);
    final messageController = TextEditingController(text: notification?['message']);
    String? selectedUserId = notification?['user_id']?.toString();

    return showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(notification == null ? "Add Notification" : "Edit Notification"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedUserId,
                  decoration: InputDecoration(labelText: "Target User"),
                  items: [
                    DropdownMenuItem(value: null, child: Text("All Users")),
                    ...users.map((u) => DropdownMenuItem(
                      value: u['id'].toString(),
                      child: Text(u['name']),
                    )),
                  ],
                  onChanged: (v) => setDialogState(() => selectedUserId = v),
                ),
                TextField(controller: titleController, decoration: InputDecoration(labelText: "Title")),
                TextField(
                  controller: messageController,
                  decoration: InputDecoration(labelText: "Message"),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                Map<String, String> body = {
                  "user_id": selectedUserId ?? "null",
                  "title": titleController.text,
                  "message": messageController.text,
                };
                
                String url = Config.baseUrl + (notification == null ? "add_notification.php" : "update_notification.php");
                if (notification != null) body["id"] = notification['id'].toString();

                final response = await http.post(Uri.parse(url), body: body);
                final res = json.decode(response.body);
                
                if (res['status'] == 'success') {
                  Navigator.pop(ctx);
                  _fetchNotifications();
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
                }
              },
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Notifications"),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
      ),
      drawer: AdminDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey.shade900,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _showNotificationDialog(),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final note = notifications[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(note['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(note['message']),
                        SizedBox(height: 5),
                        Text(
                          "To: ${note['user_name'] ?? 'All Users'}",
                          style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showNotificationDialog(note),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteNotification(int.parse(note['id'].toString())),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
