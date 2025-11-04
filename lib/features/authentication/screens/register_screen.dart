// lib/features/authentication/screens/register_screen.dart

import 'package:flutter/material.dart';
  import '../widgets/role_selection_screen.dart'; // Import widget chọn vai trò

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // State cho Bước 1: Chọn vai trò
  String? _selectedRole; // 'student' hoặc 'tutor'
  bool _showRoleSelection = true; // Bắt đầu bằng việc chọn vai trò

  // State cho Bước 2: Điền thông tin
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- Hàm xử lý Đăng ký ---
  void _register() {
    if (_formKey.currentState!.validate()) {
      // (Xử lý logic đăng ký với Firebase Auth và Firestore tại đây)
      print("Đăng ký vai trò: $_selectedRole");
      print("Tên: ${_nameController.text}");
      print("Email: ${_emailController.text}");

      // Giả lập đăng ký thành công và quay về Login
      Navigator.pushReplacementNamed(context, '/login'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showRoleSelection ? "Chọn vai trò của bạn" : "Đăng ký tài khoản"),
        leading: _showRoleSelection
            ? null // Ẩn nút back ở bước 1
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _showRoleSelection = true; // Quay lại bước chọn vai trò
                  });
                },
              ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: _showRoleSelection ? _buildRoleSelectionStep() : _buildRegistrationFormStep(),
      ),
    );
  }

  // --- Widget cho Bước 1: Chọn vai trò ---
  Widget _buildRoleSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bạn là ai?",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Chọn vai trò phù hợp nhất với bạn để chúng tôi cá nhân hóa trải nghiệm.",
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        const SizedBox(height: 32),
        RoleSelectionCard(
          title: "Học viên",
          description: "Tìm kiếm gia sư phù hợp, đăng ký lớp học và theo dõi tiến độ.",
          icon: Icons.school_outlined,
          isSelected: _selectedRole == 'student',
          onTap: () {
            setState(() {
              _selectedRole = 'student';
            });
          },
        ),
        const SizedBox(height: 16),
        RoleSelectionCard(
          title: "Gia sư",
          description: "Chia sẻ kiến thức, tìm kiếm học viên và quản lý lịch dạy.",
          icon: Icons.person_search_outlined,
          isSelected: _selectedRole == 'tutor',
          onTap: () {
            setState(() {
              _selectedRole = 'tutor';
            });
          },
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _selectedRole == null
                ? null
                : () {
                    setState(() {
                      _showRoleSelection = false; // Chuyển sang bước điền form
                    });
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Tiếp tục", style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }

  // --- Widget cho Bước 2: Điền form đăng ký ---
  Widget _buildRegistrationFormStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Đăng ký với tư cách ${_selectedRole == 'student' ? 'Học viên' : 'Gia sư'}",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Họ và tên",
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập họ và tên' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            validator: (value) => (value == null || !value.contains('@')) ? 'Email không hợp lệ' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Mật khẩu",
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(),
            ),
            validator: (value) => (value == null || value.length < 6) ? 'Mật khẩu phải có ít nhất 6 ký tự' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Xác nhận mật khẩu",
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(),
            ),
            validator: (value) => (value != _passwordController.text) ? 'Mật khẩu không khớp' : null,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Đăng ký", style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Đã có tài khoản?"),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login'); 
                },
                child: Text(
                  "Đăng nhập",
                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}