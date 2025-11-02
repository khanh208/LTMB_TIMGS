import 'package:flutter/material.dart';

// Đổi tên từ LoginScreenPlaceholder thành LoginScreen
class LoginScreen extends StatelessWidget { 
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Màn hình Đăng nhập")), // Sửa tiêu đề
      body: Center(
        child: ElevatedButton(
          child: const Text("Đăng nhập và đi đến Trang chủ"),
          onPressed: () {
            // Điều hướng đến màn hình chính
            Navigator.pushReplacementNamed(context, '/main');
          },
        ),
      ),
    );
  }
}