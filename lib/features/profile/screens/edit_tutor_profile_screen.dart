    // lib/features/profile/screens/edit_tutor_profile_screen.dart

import 'package:flutter/material.dart';

class EditTutorProfileScreen extends StatefulWidget {
  const EditTutorProfileScreen({super.key});

  @override
  State<EditTutorProfileScreen> createState() => _EditTutorProfileScreenState();
}

class _EditTutorProfileScreenState extends State<EditTutorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // (Controllers cho các trường)
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh sửa Hồ sơ Công khai"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // (Xử lý lưu thông tin)
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã lưu hồ sơ!"))
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: "Giá tiền (VND / giờ)",
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              const Text("Môn học của bạn:", style: TextStyle(fontSize: 16)),
              // (Bạn sẽ thêm Multi-Select Chip Group ở đây)
              
              const SizedBox(height: 20),
              const Text("Bằng cấp/Chứng chỉ:", style: TextStyle(fontSize: 16)),
              // (Bạn sẽ thêm Image Uploader ở đây)
            ],
          ),
        ),
      ),
    );
  }
}