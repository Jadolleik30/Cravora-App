import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../config.dart';
import '../../session.dart';
import '../../widgets/admin_drawer.dart';

class ManageSupportPage extends StatefulWidget {
  @override
  _ManageSupportPageState createState() => _ManageSupportPageState();
}

class _ManageSupportPageState extends State<ManageSupportPage> {
  List chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    try {
      final response = await http.get(Uri.parse(Config.baseUrl + "get_admin_chats.php"));
      setState(() {
        chats = json.decode(response.body);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _openChat(Map user) {
    // Navigate to a detail chat view for this user
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminUserChatPage(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Support Messages"), backgroundColor: Colors.blueGrey.shade900, foregroundColor: Colors.white),
      drawer: AdminDrawer(),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : chats.isEmpty 
          ? Center(child: Text("No support messages found."))
          : ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(chat['name'][0])),
                  title: Text(chat['name']),
                  subtitle: Text(chat['email']),
                  trailing: Icon(Icons.chat, color: Colors.blueGrey),
                  onTap: () => _openChat(chat),
                );
              },
            ),
    );
  }
}

class AdminUserChatPage extends StatefulWidget {
  final Map user;
  AdminUserChatPage({required this.user});

  @override
  _AdminUserChatPageState createState() => _AdminUserChatPageState();
}

class _AdminUserChatPageState extends State<AdminUserChatPage> {
  List messages = [];
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) => _fetchMessages());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl + "get_messages.php"),
        body: {"user_id": widget.user['user_id'].toString()},
      );
      if (mounted) {
        setState(() => messages = json.decode(response.body));
        _scrollToBottom();
      }
    } catch (e) {}
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_msgController.text.isEmpty) return;
    String text = _msgController.text;
    _msgController.clear();
    try {
      await http.post(
        Uri.parse(Config.baseUrl + "send_message.php"),
        body: {
          "sender_id": Session.userId.toString(),
          "receiver_id": widget.user['user_id'].toString(),
          "message": text,
        },
      );
      _fetchMessages();
    } catch (e) {}
  }

  Future<void> _deleteChat() async {
    try {
      await http.post(
        Uri.parse(Config.baseUrl + "clear_chat.php"),
        body: {"user_id": widget.user['user_id'].toString()},
      );
      Navigator.pop(context); // Go back to list after deleting
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.user['name']}"), 
        backgroundColor: Colors.blueGrey.shade900, 
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever, color: Colors.redAccent),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text("Delete Chat"),
                  content: Text("Delete all messages for this user?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
                    TextButton(onPressed: () {
                      _deleteChat();
                      Navigator.pop(ctx);
                    }, child: Text("Delete", style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(15),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final m = messages[index];
                bool isAdmin = m['sender_id'].toString() == Session.userId.toString();
                String time = "";
                try {
                  DateTime dt = DateTime.parse(m['created_at']);
                  time = "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
                } catch (e) {}

                return Column(
                  crossAxisAlignment: isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      child: Text(
                        isAdmin ? "Admin" : widget.user['name'],
                        style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Align(
                      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 2),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isAdmin ? Colors.blueGrey.shade700 : Colors.white,
                          borderRadius: BorderRadius.circular(15).copyWith(
                            bottomRight: isAdmin ? Radius.circular(0) : Radius.circular(15),
                            bottomLeft: isAdmin ? Radius.circular(15) : Radius.circular(0),
                          ),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, spreadRadius: 1)],
                          border: isAdmin ? null : Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              m['message'].toString(),
                              style: TextStyle(color: isAdmin ? Colors.white : Colors.black87),
                            ),
                            SizedBox(height: 4),
                            Text(
                              time,
                              style: TextStyle(fontSize: 9, color: isAdmin ? Colors.white70 : Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController, 
                    decoration: InputDecoration(
                      hintText: "Type a reply...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.blueGrey.shade900,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white), 
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
