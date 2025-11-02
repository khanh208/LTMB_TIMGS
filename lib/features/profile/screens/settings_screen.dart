// lib/features/profile/screens/settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // (Sau này lấy vai trò từ state)
    const String userRole = 'student'; 

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cài đặt"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text("Chỉnh sửa thông tin tài khoản"),
              subtitle: const Text("Tên, SĐT, Ảnh đại diện"),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                // (Điều hướng đến màn hình EditAccountInfoScreen - sẽ tạo sau)
                // Navigator.pushNamed(context, '/edit_account');
              },
            ),
            
            // Chỉ Gia sư mới thấy mục này
            if (userRole == 'tutor')
              ListTile(
                leading: const Icon(Icons.edit_note_outlined),
                title: const Text("Chỉnh sửa Hồ sơ công khai"),
                subtitle: const Text("Kinh nghiệm, môn học, giá tiền..."),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  // (Điều hướng đến màn hình EditTutorProfileScreen - sẽ tạo sau)
                  // Navigator.pushNamed(context, '/edit_tutor_profile');
                },
              ),

            const Divider(height: 20, thickness: 1, indent: 16, endIndent: 16),

            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text("Thay đổi mật khẩu"),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () { /* Điều hướng */ },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_none_outlined),
              title: const Text("Quản lý thông báo"),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () { /* Điều hướng */ },
            ),
            
            const Divider(height: 20, thickness: 1, indent: 16, endIndent: 16),
            
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text("Trợ giúp & Phản hồi"),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () { /* Điều hướng */ },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("Về ứng dụng"),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () { /* Điều hướng */ },
            ),
          ],
        ),
      ),
    );
  }
}