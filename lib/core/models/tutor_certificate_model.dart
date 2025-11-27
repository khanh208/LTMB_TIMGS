class TutorCertificateModel {
  final String certificateId;
  final String title;
  final String imageUrl; 

  TutorCertificateModel({
    required this.certificateId,
    required this.title,
    required this.imageUrl,
  });

  factory TutorCertificateModel.fromJson(Map<String, dynamic> json) {
    return TutorCertificateModel(
      certificateId: json['certificate_id']?.toString() ?? '',
      title: json['title'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'certificate_id': certificateId,
      'title': title,
      'image_url': imageUrl,
    };
  }
}