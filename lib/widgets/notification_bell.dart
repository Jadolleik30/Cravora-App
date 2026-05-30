import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../config.dart';
import '../session.dart';

class NotificationBell extends StatefulWidget {
  @override
  _NotificationBellState createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int _unreadCount = 0;
  List _notifications = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    // Refresh every 30 seconds
    _timer = Timer.periodic(Duration(seconds: 30), (timer) => _fetchNotifications());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchNotifications() async {
    try {
      final user = await Session.getUser();
      if (user == null) return;

      final response = await http.get(
        Uri.parse(Config.baseUrl + "get_notifications.php?user_id=${user['id']}"),
      );
      final res = json.decode(response.body);
      if (res['status'] == 'success') {
        if (mounted) {
          setState(() {
            _notifications = res['data'];
            _unreadCount = _notifications.where((n) => n['is_read'].toString() == '0').length;
          });
        }
      }
    } catch (e) {
      print("Error fetching notifications: $e");
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
    } catch (e) {
      print("Error marking read: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      icon: Stack(
        children: [
          Icon(Icons.notifications, color: Colors.white, size: 28),
          if (_unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red, width: 1),
                ),
                constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '$_unreadCount',
                  style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      onSelected: (value) {
        if (value == 'view_all') {
          Navigator.pushNamed(context, '/notifications').then((_) => _fetchNotifications());
        } else if (value.startsWith('note_')) {
          final id = value.replaceFirst('note_', '');
          _markRead(id);
        }
      },
      itemBuilder: (context) {
        List<PopupMenuEntry<String>> items = [];

        // Header with buttons
        items.add(
          PopupMenuItem<String>(
            enabled: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                TextButton(
                  onPressed: () {
                    _markRead(null, all: true);
                    Navigator.pop(context);
                  },
                  child: Text("Read All", style: TextStyle(fontSize: 12, color: Colors.blue)),
                ),
              ],
            ),
          ),
        );
        items.add(PopupMenuDivider());

        if (_notifications.isEmpty) {
          items.add(
            PopupMenuItem<String>(
              enabled: false,
              child: Container(
                width: 250,
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text("No notifications", style: TextStyle(color: Colors.grey, fontSize: 13))),
              ),
            ),
          );
        } else {
          // Show last 5 notifications
          for (var note in _notifications.take(5)) {
            bool isRead = note['is_read'].toString() == '1';
            items.add(
              PopupMenuItem<String>(
                value: 'note_${note['id']}',
                child: Container(
                  width: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (!isRead)
                            Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                          if (!isRead) SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              note['title'],
                              style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        note['message'],
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(note['created_at'], style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                    ],
                  ),
                ),
              ),
            );
            items.add(PopupMenuDivider());
          }
        }

        // Footer
        items.add(
          PopupMenuItem<String>(
            value: 'view_all',
            child: Center(child: Text("View All Notifications", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
          ),
        );

        return items;
      },
    );
  }
}
