class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'student' hoặc 'tutor'
  final String? avatarUrl;
  final String? phone;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    this.phone,
  });

  // Factory constructor để tạo từ JSON
  // API trả về: user_id (int), full_name, phone_number, avatar_url
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Xử lý avatar_url
    String? avatarUrl;
    final rawAvatarUrl = json['avatar_url'] ?? json['avatarUrl'];
    if (rawAvatarUrl != null && rawAvatarUrl is String) {
      final cleaned = rawAvatarUrl.trim();
      // Chỉ set nếu là chuỗi hợp lệ (không phải "null", "[null]", hoặc rỗng)
      if (cleaned.isNotEmpty && 
          cleaned != 'null' && 
          cleaned != '[null]' && 
          cleaned != 'None') {
        avatarUrl = cleaned;
      }
    }

    return UserModel(
      // API trả về user_id là int, cần convert sang String
      id: json['user_id']?.toString() ?? 
          json['id']?.toString() ?? 
          json['_id']?.toString() ?? 
          '',
      email: json['email'] ?? '',
      // API dùng full_name (snake_case)
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      role: json['role'] ?? 'student',
      // API dùng avatar_url (snake_case)
      avatarUrl: avatarUrl, // <-- Dùng giá trị đã làm sạch
      // API dùng phone_number (snake_case)
      phone: json['phone_number'] ?? json['phone'],
    );
  }

  // Chuyển đổi sang JSON (giữ format internal cho app)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role,
      'avatarUrl': avatarUrl,
      'phone': phone,
    };
  }

  // Copy with method để cập nhật thông tin
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? avatarUrl,
    String? phone,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
    );
  }
}
