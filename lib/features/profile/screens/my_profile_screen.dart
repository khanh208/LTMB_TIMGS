// lib/features/profile/screens/my_profile_screen.dart
import 'package:flutter/material.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  // (Giả lập vai trò)
  final String _userRole = 'student'; // <-- Thử đổi 'student' thành 'tutor'

  // --- 1. PHẦN DÙNG CHUNG: Thông tin User ---
  Widget _buildCommonUserInfo(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 12),
        const Text(
          "Tên Người Dùng", // (Lấy từ user model)
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          "user.email@example.com", // (Lấy từ user model)
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // --- 2. PHẦN TÁCH BIỆT: Nội dung theo vai trò ---
  Widget _buildRoleSpecificContent(BuildContext context) {
    if (_userRole == 'student') {
      // Nội dung của Học viên
      return Column(
        children: [
          // (Chức năng "Lịch học của tôi" đã chuyển ra tab chính)
          // (Chúng ta giữ "Gia sư đã lưu" ở đây vì tab Yêu thích đã bị xóa)
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text("Gia sư đã lưu"),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () { 
              Navigator.pushNamed(context, '/saved_tutors');  
             },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text("Ví của tôi"),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () { 
              Navigator.pushNamed(context, '/wallet');  
             },
          ),
        ],
      );
    } else {
      // Nội dung của Gia sư
      return Column(
        children: [
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text("Dashboard (Quản lý)"),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () { 
              Navigator.pushNamed(context, '/tutor_dashboard');
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money_outlined),
            title: const Text("Quản lý Thu nhập"),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () { 
              Navigator.pushNamed(context, '/earnings_management');
             },
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ sơ của tôi"),
        // Nút Cài đặt điều hướng đến màn hình SettingsScreen
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // --- ĐIỀU HƯỚNG ĐẾN MÀN HÌNH CÀI ĐẶT ---
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Phần Chung
            _buildCommonUserInfo(context),
            const Divider(),
            
            // 2. Phần Tách biệt (Nội dung thay đổi)
            _buildRoleSpecificContent(context),
            
            const Divider(),
            
            // 3. Phần Chung: Nút Đăng xuất
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Đăng xuất",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}