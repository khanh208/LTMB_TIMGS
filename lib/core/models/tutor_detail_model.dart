import 'subject_model.dart';
import 'review_model.dart';
import 'tutor_certificate_model.dart';

class TutorDetailModel {
  final String userId;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? bio;
  final String pricePerHour;
  final String averageRating;
  final bool isVerified;
  final List<SubjectModel> subjects;
  final List<ReviewModel> reviews;
  final List<TutorCertificateModel> certificates;

  TutorDetailModel({
    required this.userId,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.bio,
    required this.pricePerHour,
    required this.averageRating,
    required this.isVerified,
    required this.subjects,
    required this.reviews,
    this.certificates = const [],
  });

  factory TutorDetailModel.fromJson(Map<String, dynamic> json) {
    return TutorDetailModel(
      userId: json['user_id']?.toString() ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'],
      phoneNumber: json['phone_number'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      pricePerHour: json['price_per_hour'] ?? '0.00',
      averageRating: json['average_rating'] ?? '0.00',
      isVerified: json['is_verified'] ?? false,
      subjects: json['subjects'] != null
          ? (json['subjects'] as List)
              .map((item) => SubjectModel.fromJson(item))
              .toList()
          : [],
      reviews: json['reviews'] != null
          ? (json['reviews'] as List)
              .map((item) => ReviewModel.fromJson(item))
              .toList()
          : [],
      certificates: json['certificates'] != null
          ? (json['certificates'] as List)
              .map((item) => TutorCertificateModel.fromJson(item))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
      'bio': bio,
      'price_per_hour': pricePerHour,
      'average_rating': averageRating,
      'is_verified': isVerified,
      'subjects': subjects.map((s) => s.toJson()).toList(),
      'reviews': reviews.map((r) => r.toJson()).toList(),
      'certificates': certificates.map((c) => c.toJson()).toList(),
    };
  }

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

  double get ratingValue {
    return double.tryParse(averageRating) ?? 0.0;
  }

  int get reviewCount => reviews.length;
}
