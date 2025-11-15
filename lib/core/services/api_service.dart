// lib/core/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 1. ĐỊA CHỈ IP CỦA BACKEND
  // Dùng 10.0.2.2 cho máy ảo Android
  final String _baseUrl = "http://localhost:3000/api/auth";

  // --- HÀM ĐĂNG KÝ ---
  Future<Map<String, dynamic>> register(
      String email, String password, String fullName, String role) async {
    
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'fullName': fullName,
        'role': role,
      }),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 201) {
      // Đăng ký thành công
      return responseBody;
    } else {
      // Đăng ký thất bại, ném ra lỗi
      throw Exception(responseBody['message'] ?? 'Đăng ký thất bại');
    }
  }

  // --- HÀM ĐĂNG NHẬP ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Đăng nhập thành công, LƯU TOKEN
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', responseBody['token']);
      // (Bạn cũng có thể lưu thông tin user nếu cần)
      // await prefs.setString('user', jsonEncode(responseBody['user']));
      
      return responseBody;
    } else {
      // Đăng nhập thất bại
      throw Exception(responseBody['message'] ?? 'Email hoặc mật khẩu không chính xác');
    }
  }
}