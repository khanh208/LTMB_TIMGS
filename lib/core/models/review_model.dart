class ReviewModel {
  final String reviewId;
  final int rating;
  final String comment;
  final String? createdAt;
  final String studentName;

  ReviewModel({
    required this.reviewId,
    required this.rating,
    required this.comment,
    this.createdAt,
    required this.studentName,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      reviewId: json['review_id']?.toString() ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: json['created_at'],
      studentName: json['student_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'review_id': reviewId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt,
      'student_name': studentName,
    };
  }
}