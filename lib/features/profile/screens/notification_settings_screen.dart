  // lib/features/profile/screens/notification_settings_screen.dart

import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // (Giả lập vai trò, sau này lấy từ state)
  final String _userRole = 'student';

  // (Giả lập giá trị cài đặt)
  bool _newMessages = true;
  bool _scheduleReminders = true;
  bool _newRequests = true; // (Chỉ dùng cho Gia sư)
  bool _promotions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý thông báo"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SwitchListTile(
              title: const Text("Tin nhắn mới"),
              subtitle: const Text("Nhận thông báo khi có tin nhắn mới."),
              value: _newMessages,
              onChanged: (bool value) {
                setState(() {
                  _newMessages = value;
                  // (Xử lý logic lưu cài đặt)
                });
              },
            ),
            SwitchListTile(
              title: const Text("Nhắc nhở lịch học"),
              subtitle: const Text("Nhận thông báo trước buổi học/buổi dạy."),
              value: _scheduleReminders,
              onChanged: (bool value) {
                setState(() {
                  _scheduleReminders = value;
                });
              },
            ),
            
            // Chỉ hiển thị cho Gia sư
            if (_userRole == 'tutor')
              SwitchListTile(
                title: const Text("Yêu cầu kết nối mới"),
                subtitle: const Text("Nhận thông báo khi Học viên gửi yêu cầu."),
                value: _newRequests,
                onChanged: (bool value) {
                  setState(() {
                    _newRequests = value;
                  });
                },
              ),
              
            const Divider(),
            
            SwitchListTile(
              title: const Text("Ưu đãi & Tin tức"),
              subtitle: const Text("Nhận thông báo về các chương trình khuyến mãi."),
              value: _promotions,
              onChanged: (bool value) {
                setState(() {
                  _promotions = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}