// lib/features/chat/screens/chat_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/message_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/error_handler.dart';
import 'chat_bubble.dart';

class ChatDetailScreen extends StatefulWidget {
  final String recipientName;
  final String recipientId;
  final String? roomId;

  const ChatDetailScreen({
    super.key,
    required this.recipientName,
    required this.recipientId,
    this.roomId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    if (widget.roomId != null && widget.roomId!.isNotEmpty) {
      _loadMessages();
      _markAsRead(); // <-- THÊM MỚI: Đánh dấu đã đọc ngay khi vào
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMessages() async {
    if (widget.roomId == null || widget.roomId!.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final messagesData = await _apiService.getChatMessages(widget.roomId!);
      
      if (mounted) {
        setState(() {
          _messages = messagesData
              .map((json) => MessageModel.fromJson(json))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _messages = []; // Hiển thị empty state
        });
        
        // Hiển thị popup thông báo lỗi
        ErrorHandler.showErrorDialogFromException(
          context,
          e,
          onRetry: _loadMessages,
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) {
      return;
    }

    if (widget.roomId == null || widget.roomId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể gửi tin nhắn: Thiếu room ID')),
      );
      return;
    }

    final messageText = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _isSending = true;
    });

    try {
      // Gửi tin nhắn lên API
      await _apiService.sendMessage(widget.roomId!, messageText);
      
      // Reload messages để lấy tin nhắn mới nhất
      await _loadMessages();
      
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
        
        // Khôi phục text nếu gửi thất bại
        _messageController.text = messageText;
        
        // Hiển thị popup thông báo lỗi
        ErrorHandler.showErrorDialogFromException(
          context,
          e,
          onRetry: _sendMessage,
        );
      }
    }
  }

  // THÊM MỚI: Đánh dấu room là đã đọc (fire & forget)
  void _markAsRead() {
    if (widget.roomId == null || widget.roomId!.isEmpty) return;
    
    // Gọi API nhưng không đợi response (fire & forget)
    _apiService.markChatRoomAsRead(widget.roomId!);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.user?.id ?? ''; // <-- SỬA: userId thành id

    return Scaffold(
      appBar: AppBar(
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Text(
                          'Chưa có tin nhắn nào',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadMessages,
                        child: ListView.builder(
                          reverse: true, // Tin nhắn mới nhất ở dưới
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages.reversed.toList()[index];
                            final bool isSender = message.senderUserId == currentUserId;
                            
                            return ChatBubble(
                              message: message.messageText,
                              isSender: isSender,
                            );
                          },
                        ),
                      ),
          ),

          // --- 2. KHUNG NHẬP TIN NHẮN ---
          _buildMessageInputField(),
        ],
      ),
    );
  }

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
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                enabled: !_isSending,
                decoration: const InputDecoration(
                  hintText: "Nhập tin nhắn...",
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            if (_isSending)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
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