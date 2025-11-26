  // lib/features/profile/screens/notification_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _newMessages = true;
  bool _scheduleReminders = true;
  bool _newRequests = true;
  bool _promotions = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userRole = authProvider.userRole ?? 'student';
        
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
      },
    );
  }
}