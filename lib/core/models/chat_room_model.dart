class ChatRoomModel {
  final String roomId;
  final String recipientId;
  final String recipientName;
  final String? recipientAvatar;
  final int unreadCount; // <-- THÊM MỚI

  ChatRoomModel({
    required this.roomId,
    required this.recipientId,
    required this.recipientName,
    this.recipientAvatar,
    this.unreadCount = 0, // <-- THÊM MỚI (default = 0)
  });

  // Factory constructor để tạo từ JSON
  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    // Xử lý recipient_avatar
    String? recipientAvatar;
    final rawAvatar = json['recipient_avatar'];
    if (rawAvatar != null && rawAvatar is String) {
      final cleaned = rawAvatar.trim();
      if (cleaned.isNotEmpty && 
          cleaned != 'null' && 
          cleaned != '[null]' && 
          cleaned != 'None') {
        recipientAvatar = cleaned;
      }
    }

    return ChatRoomModel(
      roomId: json['room_id']?.toString() ?? '',
      recipientId: json['recipient_id']?.toString() ?? '',
      recipientName: json['recipient_name'] ?? '',
      recipientAvatar: recipientAvatar,
      unreadCount: json['unread_count'] ?? 0, // <-- THÊM MỚI
    );
  }

  // Chuyển đổi sang JSON
  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'recipient_id': recipientId,
      'recipient_name': recipientName,
      'recipient_avatar': recipientAvatar,
      'unread_count': unreadCount, // <-- THÊM MỚI
    };
  }
}