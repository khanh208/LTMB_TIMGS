class RequestModel {
  final String requestId;
  final String message;
  final String status; // 'pending', 'accepted', 'rejected'
  final String? createdAt;
  final String studentName;
  final String? avatarUrl;

  RequestModel({
    required this.requestId,
    required this.message,
    required this.status,
    this.createdAt,
    required this.studentName,
    this.avatarUrl,
  });

  // Factory constructor để tạo từ JSON
  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      requestId: json['request_id']?.toString() ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'],
      studentName: json['student_name'] ?? '',
      avatarUrl: json['avatar_url'],
    );
  }

  // Chuyển đổi sang JSON
  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'message': message,
      'status': status,
      'created_at': createdAt,
      'student_name': studentName,
      'avatar_url': avatarUrl,
    };
  }

  // Helper để format thời gian (nếu cần)
  String get formattedTime {
    if (createdAt == null) return '';
    // TODO: Format createdAt từ ISO string sang "2 giờ trước", "Hôm qua", etc.
    return createdAt!;
  }
}