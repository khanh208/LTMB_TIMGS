// lib/features/profile/screens/my_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../../../core/models/user_model.dart';
import '../../../core/providers/auth_provider.dart'; 
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../../core/widgets/avatar_widget.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load thông tin user từ API khi mở màn hình
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Chỉ load nếu đã đăng nhập
    if (authProvider.isLoggedIn) {
      setState(() {
        _isLoading = true;
      });

      try {
        await authProvider.loadCurrentUser();
      } catch (e) {
        // Xử lý lỗi (có thể token hết hạn)
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
        AvatarWidget( // <-- THAY THẾ CircleAvatar
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

  Widget _buildRoleSpecificContent(BuildContext context, String? userRole) {
    if (userRole == 'student') {
      // Nội dung của Học viên
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
    } else {
      // Nội dung của Gia sư - Không có gì đặc biệt
      return const SizedBox.shrink();
    }
  }

  // --- Widget các mục Cài đặt (THÊM MỚI) ---
  Widget _buildSettingsContent(BuildContext context) {
    return Column(
      children: [
        // Chỉnh sửa thông tin tài khoản
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
        
        // Thay đổi mật khẩu
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text("Thay đổi mật khẩu"),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          onTap: () {
            Navigator.pushNamed(context, '/change_password');
          },
        ),
        
        // Quản lý thông báo
        ListTile(
          leading: const Icon(Icons.notifications_none_outlined),
          title: const Text("Quản lý thông báo"),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          onTap: () { 
            Navigator.pushNamed(context, '/notification_settings');
          },
        ),
        
        const Divider(height: 20, thickness: 1, indent: 16, endIndent: 16),
        
        // Trợ giúp & Phản hồi
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text("Trợ giúp & Phản hồi"),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          onTap: () { 
            // TODO: Điều hướng đến màn hình trợ giúp
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tính năng đang phát triển')),
            );
          },
        ),
        
        // Về ứng dụng
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text("Về ứng dụng"),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          onTap: () { 
            // TODO: Điều hướng đến màn hình về ứng dụng
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tính năng đang phát triển')),
            );
          },
        ),
      ],
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
              // XÓA nút settings, chỉ giữ nút refresh
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadUserInfo,
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildCommonUserInfo(context, user),
                      _buildRoleSpecificContent(context, userRole),
                      _buildSettingsContent(context), // <-- THÊM MỚI: Các mục cài đặt
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
                                context, '/login', (route) => false);
                          }
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