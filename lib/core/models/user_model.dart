class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role; 
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? avatarUrl;
    final rawAvatarUrl = json['avatar_url'] ?? json['avatarUrl'];
    if (rawAvatarUrl != null && rawAvatarUrl is String) {
      final cleaned = rawAvatarUrl.trim();
      if (cleaned.isNotEmpty && 
          cleaned != 'null' && 
          cleaned != '[null]' && 
          cleaned != 'None') {
        avatarUrl = cleaned;
      }
    }

    return UserModel(
      id: json['user_id']?.toString() ?? 
          json['id']?.toString() ?? 
          json['_id']?.toString() ?? 
          '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      role: json['role'] ?? 'student',
      avatarUrl: avatarUrl, 
      phone: json['phone_number'] ?? json['phone'],
    );
  }

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
