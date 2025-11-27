class CertificateModel {
  final String? title; 
  final String imageBase64; 

  CertificateModel({
    this.title,
    required this.imageBase64,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title ?? '',
      'imageBase64': imageBase64,
    };
  }
}