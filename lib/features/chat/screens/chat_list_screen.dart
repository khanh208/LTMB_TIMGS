// lib/features/chat/screens/chat_list_screen.dart

import 'package:flutter/material.dart';
import 'chat_detail_screen.dart'; // Import màn hình chi tiết

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  // Dữ liệu giả lập cho danh sách chat
  // (Bạn sẽ thay thế bằng Stream/Future từ Firebase)
  final List<Map<String, String>> _conversations = const [
    {
      'id': 'tutor_01',
      'name': 'Gia sư Nguyễn Văn A',
      'lastMessage': 'Ok em. Hẹn 7h tối mai nhé.',
      'timestamp': '9:30 AM',
    },
    {
      'id': 'tutor_02',
      'name': 'Gia sư Trần Thị B',
      'lastMessage': 'Em xem lại bài tập hôm trước...',
      'timestamp': 'Hôm qua',
    },
    {
      'id': 'student_01',
      'name': 'Học viên Lê Văn C',
      'lastMessage': 'Dạ vâng, em cảm ơn thầy ạ.',
      'timestamp': 'T.bảy',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tin nhắn"),
        // (Có thể thêm nút "Tìm kiếm tin nhắn" ở đây)
      ),
      body: ListView.separated(
        itemCount: _conversations.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          indent: 70, // Thụt lề cho đường kẻ
        ),
        itemBuilder: (context, index) {
          final convo = _conversations[index];
          
          return ListTile(
            // Avatar
            leading: const CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            // Tên
            title: Text(
              convo['name']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            // Tin nhắn cuối
            subtitle: Text(
              convo['lastMessage']!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
            // Thời gian
            trailing: Text(
              convo['timestamp']!,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            // Hành động khi bấm vào
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(
                    recipientName: convo['name']!,
                    recipientId: convo['id']!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 