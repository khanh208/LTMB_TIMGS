// lib/features/chat/screens/chat_detail_screen.dart

import 'package:flutter/material.dart';

import 'chat_bubble.dart';

class ChatDetailScreen extends StatefulWidget {
  final String recipientName; // Tên người bạn đang chat
  final String recipientId;   // ID của người bạn đang chat

  const ChatDetailScreen({
    super.key,
    required this.recipientName,
    required this.recipientId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  
  // Dữ liệu giả lập cho danh sách tin nhắn
  // (Bạn sẽ thay thế bằng StreamBuilder từ Firebase)
  final List<Map<String, dynamic>> _messages = [
    {'senderId': 'other_user', 'message': 'Chào em, em muốn học môn gì?'},
    {'senderId': 'my_user_id', 'message': 'Dạ em muốn học Lập trình Flutter ạ.'},
    {'senderId': 'other_user', 'message': 'Ok em. Lịch của em thế nào?'},
    {'senderId': 'my_user_id', 'message': 'Em rảnh tối T3, T5 ạ. Thầy xem có sắp xếp được không ạ.'},
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) {
      return; // Không gửi tin nhắn rỗng
    }
    
    // (Xử lý logic gửi tin nhắn lên Firebase tại đây)
    
    // Giả lập thêm tin nhắn vào danh sách
    setState(() {
      _messages.add({
        'senderId': 'my_user_id',
        'message': _messageController.text.trim(),
      });
    });

    _messageController.clear(); // Xóa text trong ô nhập
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Tiêu đề là tên và avatar của người nhận
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(widget.recipientName),
          ],
        ),
      ),
      body: Column(
        children: [
          // --- 1. DANH SÁCH TIN NHẮN ---
          Expanded(
            child: ListView.builder(
              reverse: true, // Hiển thị tin nhắn mới nhất ở dưới cùng
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                // Sắp xếp lại để hiển thị đúng (vì reverse = true)
                final messageData = _messages.reversed.toList()[index];
                final bool isSender = messageData['senderId'] == 'my_user_id';
                
                return ChatBubble(
                  message: messageData['message'],
                  isSender: isSender,
                );
              },
            ),
          ),

          // --- 2. KHUNG NHẬP TIN NHẮN ---
          _buildMessageInputField(),
        ],
      ),
    );
  }

  // --- Widget Khung nhập tin nhắn ---
  Widget _buildMessageInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea( // Để tránh thanh điều hướng của hệ thống (nếu có)
        child: Row(
          children: [
            // Ô nhập text
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: "Nhập tin nhắn...",
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: null, // Cho phép xuống dòng
              ),
            ),
            // Nút Gửi
            IconButton(
              icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
} 