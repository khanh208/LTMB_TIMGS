// lib/features/profile/screens/edit_account_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/error_handler.dart'; // <-- THÊM
import 'dart:io'; // <-- THÊM
import 'package:image_picker/image_picker.dart'; // <-- THÊM (cần thêm vào pubspec.yaml)
import '../../../core/services/api_service.dart'; // <-- THÊM
import '../../../core/widgets/avatar_widget.dart'; // <-- THÊM

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  // Dùng controller để quản lý
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasError = false; // <-- Đổi từ String? _error

  final ApiService _apiService = ApiService(); // <-- THÊM
  final ImagePicker _imagePicker = ImagePicker(); // <-- THÊM
  File? _selectedImageFile; // <-- THÊM: File ảnh đã chọn
  String? _uploadedAvatarUrl; // <-- THÊM: Avatar URL sau khi upload

  @override
  void initState() {
    super.initState();
    
    // Lấy dữ liệu từ AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');

    // Load thông tin mới nhất từ API
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.loadCurrentUser();
      
      final user = authProvider.user;
      if (user != null && mounted) {
        setState(() {
          _nameController.text = user.fullName;
          _phoneController.text = user.phone ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Hiển thị popup thông báo lỗi
        ErrorHandler.showErrorDialogFromException(
          context,
          e,
          onRetry: _loadUserInfo,
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateCurrentUserInfo(
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty  // <-- SỬA: phone -> phoneNumber
            ? null 
            : _phoneController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thông tin thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        // Hiển thị popup thông báo lỗi
        ErrorHandler.showErrorDialogFromException(
          context,
          e,
          onRetry: _saveChanges,
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

  // THÊM MỚI: Method để chọn ảnh
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery, // Có thể thêm option chụp ảnh
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
          _uploadedAvatarUrl = null; // Reset uploaded URL
        });

        // Tự động upload ngay sau khi chọn ảnh
        await _uploadAvatar();
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

  // THÊM MỚI: Method để upload avatar
  Future<void> _uploadAvatar() async {
    if (_selectedImageFile == null) return;

    setState(() {
      _isSaving = true; // Dùng flag _isSaving để hiển thị loading
    });

    try {
      final avatarUrl = await _apiService.uploadAvatar(_selectedImageFile!);
      
      // Cập nhật avatar URL và user trong AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateCurrentUserInfo(
        fullName: null, // Không thay đổi
        phoneNumber: null, // Không thay đổi
        avatarUrl: avatarUrl, // <-- Cần thêm parameter này vào updateCurrentUserInfo
      );

      if (mounted) {
        setState(() {
          _uploadedAvatarUrl = avatarUrl;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật ảnh đại diện thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ErrorHandler.showErrorDialogFromException(
          context,
          e,
          onRetry: _uploadAvatar,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        // Ưu tiên hiển thị avatar đã upload, sau đó là avatar từ user
        final displayAvatarUrl = _uploadedAvatarUrl ?? user?.avatarUrl;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Chỉnh sửa tài khoản"),
            actions: [
              // Nút Lưu
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
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: _saveChanges,
                ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // --- PHẦN CHỈNH SỬA AVATAR (CẬP NHẬT) ---
                        Stack(
                          children: [
                            // Hiển thị ảnh đã chọn hoặc avatar hiện tại
                            _selectedImageFile != null
                                ? CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.grey,
                                    backgroundImage: FileImage(_selectedImageFile!),
                                  )
                                : AvatarWidget(
                                    avatarUrl: displayAvatarUrl,
                                    radius: 60,
                                  ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                child: IconButton(
                                  icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                  onPressed: _isSaving ? null : _pickImage, // <-- CẬP NHẬT
                                ),
                              ),
                            )
                          ],
                        ),
                        if (_isSaving && _selectedImageFile != null) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Đang tải ảnh lên...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                        const SizedBox(height: 32),

                        // --- CÁC TRƯỜNG THÔNG TIN ---
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: "Họ và tên",
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => 
                              (value == null || value.trim().isEmpty) 
                                  ? 'Không được bỏ trống' 
                                  : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: "Số điện thoại",
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                          ),
                          // Không bắt buộc
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          readOnly: true, // Thường email không cho sửa
                          decoration: InputDecoration(
                            labelText: "Email (Không thể sửa)",
                            prefixIcon: const Icon(Icons.email),
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}