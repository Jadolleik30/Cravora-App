import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../session.dart';
import '../widgets/notification_bell.dart';
import '../widgets/user_drawer.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final user = await Session.getUser();
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse(Config.baseUrl + "get_notifications.php?user_id=${user['id']}"),
      );
      
      if (mounted) {
        final res = json.decode(response.body);
        setState(() {
          if (res['status'] == 'success') {
            notifications = res['data'] ?? [];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markRead(dynamic notificationId, {bool all = false}) async {
    final user = await Session.getUser();
    if (user == null) return;

    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl + "mark_read.php"),
        body: {
          "user_id": user['id'].toString(),
          "notification_id": notificationId?.toString() ?? "",
          "all": all.toString(),
        },
      );
      final res = json.decode(response.body);
      if (res['status'] == 'success') {
        _fetchNotifications();
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    int unreadCount = notifications.where((n) => n['is_read'].toString() == '0').length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Alerts", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: Icon(Icons.done_all, color: Colors.white),
              onPressed: () => _markRead(null, all: true),
              tooltip: "Mark all as read",
            ),
          SizedBox(width: 10),
        ],
      ),
      drawer: UserDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.red))
          : notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  color: Colors.red,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    physics: BouncingScrollPhysics(),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final note = notifications[index];
                      bool isRead = note['is_read'].toString() == '1';
                      bool isGlobal = note['user_id'] == null;

                      return _buildNotificationCard(note, isRead, isGlobal);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle),
            child: Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey.shade300),
          ),
          SizedBox(height: 20),
          Text("All caught up!", style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w900)),
          Text("No new notifications for you", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(dynamic note, bool isRead, bool isGlobal) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : Colors.red.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isRead ? Colors.grey.shade100 : Colors.red.withOpacity(0.1)),
        boxShadow: isRead ? [] : [BoxShadow(color: Colors.red.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: InkWell(
        onTap: isRead ? null : () => _markRead(note['id']),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isRead ? Colors.grey.shade50 : Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isGlobal ? Icons.campaign : Icons.notifications,
                  color: isRead ? Colors.grey : Colors.red,
                  size: 24,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            note['title'],
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.bold : FontWeight.w900,
                              fontSize: 16,
                              color: isRead ? Colors.black87 : Colors.black,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      note['message'],
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.4),
                    ),
                    SizedBox(height: 10),
                    Text(
                      note['created_at'],
                      style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
