class MessageModel {
  final String messageId;
  final String roomId;
  final String senderUserId;
  final String messageText;
  final DateTime sentAt;

  MessageModel({
    required this.messageId,
    required this.roomId,
    required this.senderUserId,
    required this.messageText,
    required this.sentAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['message_id']?.toString() ?? '',
      roomId: json['room_id']?.toString() ?? '',
      senderUserId: json['sender_user_id']?.toString() ?? '',
      messageText: json['message_text'] ?? '',
      sentAt: DateTime.parse(json['sent_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'room_id': roomId,
      'sender_user_id': senderUserId,
      'message_text': messageText,
      'sent_at': sentAt.toIso8601String(),
    };
  }
}   