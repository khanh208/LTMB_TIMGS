// lib/features/profile/screens/edit_account_screen.dart

import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    
    // --- ĐÂY LÀ PHẦN "ĐỒNG BỘ" ---
    // (Giả lập: Lấy dữ liệu hiện tại của người dùng)
    // Sau này, bạn sẽ lấy dữ liệu này từ Provider/Bloc/Firebase
    _nameController = TextEditingController(text: "Tên Người Dùng (Tải từ CSDL)");
    _phoneController = TextEditingController(text: "0912345678");
    _emailController = TextEditingController(text: "user.email@example.com");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // (Xử lý logic lưu dữ liệu mới lên CSDL tại đây)
      // ...
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã cập nhật thông tin!"))
      );
      Navigator.pop(context); // Quay lại màn hình Settings
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh sửa tài khoản"),
        actions: [
          // Nút Lưu
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- PHẦN CHỈNH SỬA AVATAR ---
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                    // (Bạn sẽ dùng NetworkImage hoặc FileImage ở đây)
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        onPressed: () {
                          // (Xử lý logic chọn/chụp ảnh mới)
                        },
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 32),

              // --- CÁC TRƯỜNG THÔNG TIN ---
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Họ và tên",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Không được bỏ trống' : null,
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
  }
}