import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../chat/screens/chat_detail_screen.dart';

const String _supportAdminId = '0';
const String _supportAdminName = 'Tổng đài viên';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _openSupportDialog(BuildContext context) {
    final TextEditingController messageController = TextEditingController();
    final apiService = ApiService();

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isSending = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tổng đài hỗ trợ'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mô tả nhanh vấn đề bạn gặp phải. '
                    'Tổng đài viên sẽ phản hồi trong ít phút.',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: messageController,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Ví dụ: Tôi cần hỗ trợ về thanh toán...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Đóng'),
                ),
                ElevatedButton.icon(
                  onPressed: isSending
                      ? null
                      : () async {
                          final message = messageController.text.trim();
                          if (message.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Vui lòng nhập nội dung cần hỗ trợ'),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isSending = true;
                          });

                          try {
                            final result = await apiService.sendConnectionRequest(
                              _supportAdminId,
                              message,
                            );

                            final roomData = result['data'];
                            String? roomId;
                            if (roomData != null && roomData['room'] != null) {
                              final roomIdRaw = roomData['room']['room_id'];
                              if (roomIdRaw != null) {
                                roomId = roomIdRaw.toString();
                              }
                            }

                            Navigator.of(dialogContext).pop();

                            if (roomId == null || roomId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Không thể mở cuộc trò chuyện hỗ trợ. Vui lòng thử lại.'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatDetailScreen(
                                  recipientName: _supportAdminName,
                                  recipientId: _supportAdminId,
                                  roomId: roomId,
                                  enableScheduleAction: false,
                                ),
                              ),
                            );
                          } catch (e) {
                            setDialogState(() {
                              isSending = false;
                            });

                            ErrorHandler.showErrorDialogFromException(
                              dialogContext,
                              e,
                              onRetry: () {
                                Navigator.of(dialogContext).pop();
                                _openSupportDialog(context);
                              },
                            );
                            return;
                          }

                        },
                  icon: isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.headset_mic_outlined),
                  label: const Text('Gửi yêu cầu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userRole = authProvider.userRole ?? 'student';
        
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
                    Navigator.pushNamed(context, '/edit_account');
                  },
                ),
                
                if (userRole == 'tutor')
                  ListTile(
                    leading: const Icon(Icons.edit_note_outlined),
                    title: const Text("Chỉnh sửa Hồ sơ công khai"),
                    subtitle: const Text("Kinh nghiệm, môn học, giá tiền..."),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {
                      Navigator.pushNamed(context, '/edit_tutor_profile');
                    },
                  ),

                const Divider(height: 20, thickness: 1, indent: 16, endIndent: 16),

                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text("Thay đổi mật khẩu"),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    Navigator.pushNamed(context, '/change_password');
                   },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_none_outlined),
                  title: const Text("Quản lý thông báo"),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () { 
                    Navigator.pushNamed(context, '/notification_settings');
                   },
                ),
                
                const Divider(height: 20, thickness: 1, indent: 16, endIndent: 16),
                
                ListTile(
                  leading: const Icon(Icons.support_agent_outlined),
                  title: const Text("Tổng đài hỗ trợ"),
                  subtitle: const Text("Chat với admin để được trợ giúp"),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () => _openSupportDialog(context),
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text("Trợ giúp & Phản hồi"),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text("Về ứng dụng"),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}