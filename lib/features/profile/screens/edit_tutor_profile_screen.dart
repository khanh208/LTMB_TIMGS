
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/models/certificate_model.dart';
import '../../../core/models/subject_model.dart';
import '../../../core/models/tutor_detail_model.dart';
import '../../../core/models/tutor_certificate_model.dart';

class EditTutorProfileScreen extends StatefulWidget {
  const EditTutorProfileScreen({super.key});

  @override
  State<EditTutorProfileScreen> createState() => _EditTutorProfileScreenState();
}

class _EditTutorProfileScreenState extends State<EditTutorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  List<int> _selectedSubjectIds = []; 
  List<CertificateModel> _certificateImages = []; 
  bool _isLoading = true; 
  bool _isSaving = false;
  List<Map<String, dynamic>> _availableSubjects = []; 

  @override
  void initState() {
    super.initState();
    _loadData(); 
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final futures = await Future.wait([
        _apiService.getSubjects(),
        _apiService.getMyTutorProfile(),
      ]);

      final subjectsData = futures[0] as List<Map<String, dynamic>>;
      final profileData = futures[1] as Map<String, dynamic>;

      final tutorDetail = TutorDetailModel.fromJson(profileData);

      if (mounted) {
        setState(() {
          _availableSubjects = subjectsData;
          _bioController.text = tutorDetail.bio ?? '';
          _priceController.text = tutorDetail.pricePerHour.split('.').first; 
          
          _selectedSubjectIds = tutorDetail.subjects
              .map((s) => int.tryParse(s.subjectId) ?? 0)
              .where((id) => id > 0)
              .toList();

          _certificateImages = tutorDetail.certificates.map((cert) {
            return CertificateModel(
              title: cert.title,
              imageBase64: cert.imageUrl, 
            );
          }).toList();

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ErrorHandler.showErrorDialogFromException(
          context,
          e,
          onRetry: _loadData,
        );
      }
    }
  }

  Future<String> _fileToBase64DataUrl(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);
    
    final extension = imageFile.path.split('.').last.toLowerCase();
    String mimeType = 'image/png'; 
    if (extension == 'jpg' || extension == 'jpeg') {
      mimeType = 'image/jpeg';
    } else if (extension == 'png') {
      mimeType = 'image/png';
    } else if (extension == 'gif') {
      mimeType = 'image/gif';
    } else if (extension == 'webp') {
      mimeType = 'image/webp';
    }
    
    return 'data:$mimeType;base64,$base64Image';
  }

  Future<void> _pickCertificateImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        final base64DataUrl = await _fileToBase64DataUrl(imageFile);

        setState(() {
          _certificateImages.add(
            CertificateModel(
              title: null, 
              imageBase64: base64DataUrl,
            ),
          );
        });

        _showCertificateTitleDialog(_certificateImages.length - 1);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorDialogFromException(
          context,
          e,
          onRetry: null,
        );
      }
    }
  }

  void _showCertificateTitleDialog(int index) {
    final titleController = TextEditingController();
    if (_certificateImages[index].title != null) {
      titleController.text = _certificateImages[index].title!;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nhập tên bằng cấp'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            hintText: 'VD: Chứng chỉ IELTS 8.0',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _certificateImages[index] = CertificateModel(
                  title: titleController.text.trim(),
                  imageBase64: _certificateImages[index].imageBase64,
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _removeCertificate(int index) {
    setState(() {
      _certificateImages.removeAt(index);
    });
  }

  void _toggleSubject(int subjectId) {
    setState(() {
      if (_selectedSubjectIds.contains(subjectId)) {
        _selectedSubjectIds.remove(subjectId);
      } else {
        _selectedSubjectIds.add(subjectId);
      }
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSubjectIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một môn học'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final priceText = _priceController.text.trim();
    if (priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập giá tiền'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final pricePerHour = int.tryParse(priceText.replaceAll(',', ''));
    if (pricePerHour == null || pricePerHour <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giá tiền không hợp lệ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final certificatesJson = _certificateImages.map((cert) => cert.toJson()).toList();

      await _apiService.updateTutorProfile(
        bio: _bioController.text.trim(),
        pricePerHour: pricePerHour,
        subjects: _selectedSubjectIds,
        certificates: certificatesJson,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật hồ sơ thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorDialogFromException(
          context,
          e,
          onRetry: _saveProfile,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh sửa Hồ sơ Công khai"),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: "Giới thiệu / Bio",
                        hintText: "Hãy viết một đoạn giới thiệu ấn tượng...",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập giới thiệu';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: "Giá tiền (VND / giờ)",
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                        hintText: "300000",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập giá tiền';
                        }
                        final price = int.tryParse(value.replaceAll(',', ''));
                        if (price == null || price <= 0) {
                          return 'Giá tiền không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Môn học của bạn:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableSubjects.map((subject) {
                        final subjectIdRaw = subject['subject_id'] ?? subject['id'];
                        int subjectId;
                        
                        if (subjectIdRaw == null) {
                          return null; 
                        } else if (subjectIdRaw is int) {
                          subjectId = subjectIdRaw;
                        } else {
                          final parsed = int.tryParse(subjectIdRaw.toString());
                          if (parsed == null || parsed <= 0) {
                            return null; 
                          }
                          subjectId = parsed;
                        }
                        
                        final isSelected = _selectedSubjectIds.contains(subjectId);
                        return FilterChip(
                          label: Text(subject['name']?.toString() ?? ''),
                          selected: isSelected,
                          onSelected: (_) => _toggleSubject(subjectId),
                          selectedColor: Theme.of(context).primaryColor.withOpacity(0.3),
                          checkmarkColor: Theme.of(context).primaryColor,
                        );
                      }).whereType<FilterChip>().toList(), 
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Bằng cấp/Chứng chỉ:",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: _pickCertificateImage,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Thêm ảnh'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (_certificateImages.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Chưa có ảnh bằng cấp nào',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _certificateImages.length,
                        itemBuilder: (context, index) {
                          final cert = _certificateImages[index];
                          final base64String = cert.imageBase64.split(',').last;
                          final imageBytes = base64Decode(base64String);
                          final imageProvider = MemoryImage(imageBytes);

                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(8),
                                        ),
                                        child: Image(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: () => _showCertificateTitleDialog(index),
                                        child: Text(
                                          cert.title ?? 'Nhấn để nhập tên',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: cert.title == null
                                                ? Colors.grey
                                                : Colors.black,
                                            fontStyle: cert.title == null
                                                ? FontStyle.italic
                                                : FontStyle.normal,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  color: Colors.red,
                                  onPressed: () => _removeCertificate(index),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}