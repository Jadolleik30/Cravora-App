import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../config.dart';
import '../session.dart';
import '../widgets/user_drawer.dart';
import '../widgets/notification_bell.dart';

class SupportPage extends StatefulWidget {
  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List messages = [];
  Timer? _timer;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) => _fetchMessages());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse(
            Config.baseUrl + "get_messages.php?user_id=${Session.userId}"),
      );
      if (mounted) {
        final newMessages = json.decode(response.body);
        if (newMessages.length != messages.length) {
          setState(() {
            messages = newMessages;
          });
          _scrollToBottom();
        }
      }
    } catch (e) {}
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;
    String msg = _messageController.text.trim();
    _messageController.clear();

    setState(() => _isSending = true);
    try {
      await http.post(
        Uri.parse(Config.baseUrl + "send_message.php"),
        body: {
          "sender_id": Session.userId.toString(),
          "message": msg,
        },
      );
      _fetchMessages();
    } catch (e) {}
    setState(() => _isSending = false);
  }

  Future<void> _clearChat() async {
    try {
      await http.post(
        Uri.parse(Config.baseUrl + "clear_chat.php"),
        body: {"user_id": Session.userId.toString()},
      );
      setState(() => messages = []);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Cravora Support",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18)),
            Row(
              children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: Colors.green, shape: BoxShape.circle)),
                SizedBox(width: 5),
                Text("Online",
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: Colors.white70),
            onPressed: () => _confirmClearChat(),
          ),
          NotificationBell(),
          SizedBox(width: 10),
        ],
      ),
      drawer: UserDrawer(),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    physics: BouncingScrollPhysics(),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      bool isMe = msg['sender_id'].toString() ==
                          Session.userId.toString();
                      return _buildMessageBubble(msg, isMe);
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
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
            decoration:
                BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.chat_bubble_outline_rounded,
                size: 60, color: Colors.red.shade100),
          ),
          SizedBox(height: 20),
          Text("How can we help?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          SizedBox(height: 10),
          Text("Our team is here to assist you\n24 hours a day.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic msg, bool isMe) {
    String time = "";
    try {
      DateTime dt = DateTime.parse(msg['created_at']);
      time = "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {}

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? Colors.red : Colors.white,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomRight: isMe ? Radius.circular(2) : Radius.circular(20),
                bottomLeft: isMe ? Radius.circular(20) : Radius.circular(2),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 5))
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  msg['message'],
                  style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 15,
                      height: 1.4),
                ),
                SizedBox(height: 5),
                Text(
                  time,
                  style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white70 : Colors.grey,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: Offset(0, -5))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(25)),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 15),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: 15),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration:
                  BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Icon(Icons.send_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Clear Chat History?"),
        content: Text(
            "This action cannot be undone. All messages will be permanently deleted."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cancel", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              _clearChat();
              Navigator.pop(ctx);
            },
            child: Text("Clear Everything",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
