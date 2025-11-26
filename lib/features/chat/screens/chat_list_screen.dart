// lib/features/chat/screens/chat_list_screen.dart

import 'package:flutter/material.dart';
import 'chat_detail_screen.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/chat_room_model.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/widgets/avatar_widget.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ApiService _apiService = ApiService();
  
  List<ChatRoomModel> _chatRooms = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  Future<void> _loadChatRooms() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final roomsData = await _apiService.getChatRooms();
      
      if (mounted) {
        setState(() {
          _chatRooms = roomsData
              .map((json) => ChatRoomModel.fromJson(json))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _chatRooms = []; // Hiển thị empty state
        });
        
        // Hiển thị popup thông báo lỗi
        ErrorHandler.showErrorDialogFromException(
          context,
          e,
          onRetry: _loadChatRooms,
        );
      }
    }
  }

  // Thêm method public để reload từ bên ngoài
  void reloadChatRooms() {
    _loadChatRooms();
  }

  // CẬP NHẬT: Reload khi quay lại từ ChatDetailScreen
  Future<void> _navigateToChatDetail(ChatRoomModel room) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          recipientName: room.recipientName,
          recipientId: room.recipientId,
          roomId: room.roomId,
        ),
      ),
    );

    // Reload danh sách khi quay lại để cập nhật unread_count
    if (mounted) {
      _loadChatRooms();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tin nhắn"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChatRooms,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chatRooms.isEmpty
              ? const Center(
                  child: Text(
                    'Chưa có cuộc trò chuyện nào',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadChatRooms,
                  child: ListView.separated(
                        itemCount: _chatRooms.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          indent: 70,
                        ),
                        itemBuilder: (context, index) {
                          final room = _chatRooms[index];
                          
                          return ListTile(
                            // Avatar
                            leading: AvatarWidget(
                              avatarUrl: room.recipientAvatar,
                              radius: 25,
                            ),
                            // Tên với badge unread
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    room.recipientName,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                // Badge đỏ nếu có tin nhắn chưa đọc
                                if (room.unreadCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      room.unreadCount > 99 ? '99+' : room.unreadCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            // Tin nhắn cuối
                            subtitle: const Text(
                              'Nhấn để xem tin nhắn',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey),
                            ),
                            // Thời gian
                            trailing: const Text(
                              '',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            // Hành động khi bấm vào
                            onTap: () => _navigateToChatDetail(room), // <-- CẬP NHẬT
                          );
                        },
                      ),
                ),
    );
  }
} 