class RequestModel {
  final String requestId;
  final String message;
  final String status; 
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

  String get formattedTime {
    if (createdAt == null) return '';
    return createdAt!;
  }
}