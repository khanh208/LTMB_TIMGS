// lib/features/chat/widgets/chat_bubble.dart

import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSender; // true: bạn gửi, false: bạn nhận

  const ChatBubble({
    super.key,
    required this.message,
    required this.isSender,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Căn lề bong bóng (phải/trái)
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSender
              ? Theme.of(context).primaryColor // Màu của người gửi
              : Colors.grey[200], // Màu của người nhận
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isSender ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight: isSender ? const Radius.circular(0) : const Radius.circular(16),
          ),
        ),
        // Giới hạn chiều rộng của bong bóng
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isSender ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}