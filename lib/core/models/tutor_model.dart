class TutorModel {
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final String? bio;
  final String pricePerHour;
  final String averageRating;
  final bool isVerified;

  TutorModel({
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    this.bio,
    required this.pricePerHour,
    required this.averageRating,
    required this.isVerified,
  });

  // Factory constructor để tạo từ JSON
  factory TutorModel.fromJson(Map<String, dynamic> json) {
    // Xử lý avatar_url
    String? avatarUrl;
    final rawAvatarUrl = json['avatar_url'];
    if (rawAvatarUrl != null && rawAvatarUrl is String) {
      final cleaned = rawAvatarUrl.trim();
      if (cleaned.isNotEmpty && 
          cleaned != 'null' && 
          cleaned != '[null]' && 
          cleaned != 'None') {
        avatarUrl = cleaned;
      }
    }

    return TutorModel(
      userId: json['user_id']?.toString() ?? '',
      fullName: json['full_name'] ?? '',
      avatarUrl: avatarUrl, // <-- Dùng giá trị đã làm sạch
      bio: json['bio'],
      pricePerHour: json['price_per_hour'] ?? '0.00',
      averageRating: json['average_rating'] ?? '0.00',
      isVerified: json['is_verified'] ?? false,
    );
  }

  // Chuyển đổi sang JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'price_per_hour': pricePerHour,
      'average_rating': averageRating,
      'is_verified': isVerified,
    };
  }

  // Format giá tiền để hiển thị
  String get formattedPrice {
    final price = double.tryParse(pricePerHour) ?? 0.0;
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M VND/h';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K VND/h';
    } else {
      return '${price.toStringAsFixed(0)} VND/h';
    }
  }

  // Format rating để hiển thị
  double get ratingValue {
    return double.tryParse(averageRating) ?? 0.0;
  }
}