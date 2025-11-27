class SubjectModel {
  final String subjectId;
  final String name;
  final String category;

  SubjectModel({
    required this.subjectId,
    required this.name,
    required this.category,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      subjectId: json['subject_id']?.toString() ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject_id': subjectId,
      'name': name,
      'category': category,
    };
  }
}