import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/tutor_detail_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../chat/screens/chat_detail_screen.dart';

const String _supportAdminId = '0';
const String _supportAdminName = 'Tổng đài viên';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  TutorDetailModel? _tutorProfile;
  bool _isTutorProfileLoading = false;
  bool _tutorProfileNotFound = false;
  String? _tutorProfileError;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isLoggedIn) {
      setState(() {
        _isLoading = true;
      });

      try {
        await authProvider.loadCurrentUser();

        if (authProvider.userRole == 'tutor') {
          await _loadTutorProfile();
        } else {
          setState(() {
            _tutorProfile = null;
            _tutorProfileNotFound = false;
            _tutorProfileError = null;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể tải thông tin: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildCommonUserInfo(BuildContext context, UserModel? user) {
    return Column(
      children: [
        const SizedBox(height: 20),
        AvatarWidget( 
          avatarUrl: user?.avatarUrl,
          radius: 50,
        ),
        const SizedBox(height: 12),
        Text(
          user?.fullName ?? "Tên Người Dùng",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          user?.email ?? "user.email@example.com",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        if (user?.phone != null) ...[
          const SizedBox(height: 4),
          Text(
            user!.phone!,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> _loadTutorProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.userRole != 'tutor') {
      return;
    }

    setState(() {
      _isTutorProfileLoading = true;
      _tutorProfileError = null;
      _tutorProfileNotFound = false;
    });

    try {
      final profileData = await _apiService.getMyTutorProfile();
      final tutorDetail = TutorDetailModel.fromJson(profileData);

      if (!mounted) return;

      setState(() {
        _tutorProfile = tutorDetail;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 404) {
        setState(() {
          _tutorProfile = null;
          _tutorProfileNotFound = true;
        });
      } else {
        setState(() {
          _tutorProfileError = e.message;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _tutorProfileError = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isTutorProfileLoading = false;
      });
    }
  }

  Future<void> _openEditTutorProfile() async {
    await Navigator.pushNamed(context, '/edit_tutor_profile');
    if (mounted) {
      _loadTutorProfile();
    }
  }

  Widget _buildRoleSpecificContent(BuildContext context, String? userRole) {
    if (userRole == 'student') {
      return Column(
        children: [
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
    }

    if (userRole == 'tutor') {
      return Column(
        children: [
          _buildTutorStatusSection(context),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.edit_note_outlined),
            title: const Text("Quản lý hồ sơ công khai"),
            subtitle: const Text("Bio, môn học, bằng cấp"),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: _openEditTutorProfile,
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
    }

    return const SizedBox.shrink();
  }

  Widget _buildTutorStatusSection(BuildContext context) {
    if (_isTutorProfileLoading) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: const [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Đang kiểm tra trạng thái hồ sơ...',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_tutorProfileError != null) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Không tải được hồ sơ',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _tutorProfileError!,
                style: TextStyle(color: Colors.red.shade700),
              ),
              TextButton.icon(
                onPressed: _loadTutorProfile,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_tutorProfileNotFound || _tutorProfile == null) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.blue.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.assignment_late_outlined, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Chưa có hồ sơ công khai',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Bạn cần hoàn thiện hồ sơ và bằng cấp để xuất hiện trong kết quả tìm kiếm.',
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _openEditTutorProfile,
                child: const Text('Hoàn thiện hồ sơ ngay'),
              ),
            ],
          ),
        ),
      );
    }

    final isVerified = _tutorProfile!.isVerified;
    final Color baseColor = isVerified ? Colors.green.shade50 : Colors.orange.shade50;
    final Color accentColor = isVerified ? Colors.green.shade700 : Colors.orange.shade700;
    final IconData statusIcon = isVerified ? Icons.verified : Icons.hourglass_top_rounded;
    final String statusTitle = isVerified ? 'Hồ sơ đã xác thực' : 'Hồ sơ đang chờ duyệt';
    final String statusMessage = isVerified
        ? 'Hồ sơ của bạn đã được duyệt. Bạn có thể nhận học viên và xuất hiện trong kết quả tìm kiếm.'
        : 'Đội ngũ admin đang kiểm tra hồ sơ của bạn. Bạn vẫn có thể chỉnh sửa nếu cần thay đổi thông tin.';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: baseColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(statusIcon, color: accentColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusTitle,
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusMessage,
                        style: TextStyle(color: accentColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text(
                    isVerified ? 'Đã duyệt' : 'Chờ duyệt',
                    style: TextStyle(
                      color: isVerified ? Colors.green.shade900 : Colors.orange.shade900,
                    ),
                  ),
                  backgroundColor: isVerified ? Colors.green.shade100 : Colors.orange.shade100,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('${_tutorProfile!.certificates.length} bằng cấp'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _openEditTutorProfile,
              icon: const Icon(Icons.edit),
              label: Text(isVerified ? 'Cập nhật hồ sơ' : 'Chỉnh sửa hồ sơ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context) {
    return Column(
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
        
        const Divider(height: 1),
        
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
          onTap: () { 
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tính năng đang phát triển')),
            );
          },
        ),
        
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text("Về ứng dụng"),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          onTap: () { 
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tính năng đang phát triển')),
            );
          },
        ),
      ],
    );
  }

  void _openSupportDialog(BuildContext context) {
    final TextEditingController messageController = TextEditingController();

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
                            final result = await _apiService.sendConnectionRequest(
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
                                  content: Text(
                                    'Không thể mở cuộc trò chuyện hỗ trợ. Vui lòng thử lại.',
                                  ),
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

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Có lỗi xảy ra: $e'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
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
        final user = authProvider.user;
        final userRole = authProvider.userRole;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Hồ sơ của tôi"),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadUserInfo,
                tooltip: 'Làm mới',
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadUserInfo,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildCommonUserInfo(context, user),
                        _buildRoleSpecificContent(context, userRole),
                        const SizedBox(height: 12),
                        _buildSettingsContent(context),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text(
                            "Đăng xuất",
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () async {
                            await authProvider.logout();
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
                            }
                          },
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