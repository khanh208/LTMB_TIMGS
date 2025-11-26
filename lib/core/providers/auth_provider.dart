import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _token;
  bool _isInitialized = false;

  UserModel? get user => _user;
  String? get userRole => _user?.role;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get token => _token;
  bool get isInitialized => _isInitialized;

  bool get isStudent => _user?.role == 'student';
  
  bool get isTutor => _user?.role == 'tutor';

  final ApiService _apiService = ApiService();

  AuthProvider() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userJson = prefs.getString('user');

      if (token != null && userJson != null) {
        _token = token;
        try {
          _user = UserModel.fromJson(jsonDecode(userJson));
          debugPrint('✅ [AuthProvider] Loaded user from storage: ${_user?.email}');
        } catch (e) {
          debugPrint('❌ [AuthProvider] Error parsing user from storage: $e');
        }
      } else {
        debugPrint('⚠️ [AuthProvider] No token or user found in storage');
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [AuthProvider] Error loading user from storage: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> waitForInitialization() async {
    while (!_isInitialized) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.login(email, password);
      
      _token = result['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);

      if (result['user'] != null) {
        _user = UserModel.fromJson(result['user']);
      } else {
        debugPrint('Warning: API login response không có user object');
        _user = UserModel(
          id: result['user_id']?.toString() ?? '',
          email: result['email'] ?? email,
          fullName: result['full_name'] ?? 'User',
          role: result['role'] ?? 'student',
          avatarUrl: result['avatar_url'],
          phone: result['phone_number'],
        );
      }

      if (_user != null) {
        await prefs.setString('user', jsonEncode(_user!.toJson()));
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> register(String email, String password, String fullName, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.register(email, password, fullName, role);
      
      if (result['user'] != null && result['token'] != null) {
        _token = result['token'];
        _user = UserModel.fromJson(result['user']);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user', jsonEncode(_user!.toJson()));
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadCurrentUser() async {
    if (_token == null) {
      debugPrint('No token available to load user info');
      return;
    }

    try {
      final result = await _apiService.getCurrentUser();
      
      _user = UserModel.fromJson(result);
      
      await _saveUserToStorage(); 
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading current user: $e');
      rethrow;
    }
  }

  Future<void> updateCurrentUserInfo({
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    if (_token == null) {
      throw Exception('Chưa đăng nhập');
    }

    try {
      final userData = <String, dynamic>{};
      if (fullName != null) {
        userData['fullName'] = fullName;
      }
      if (phoneNumber != null) {
        userData['phoneNumber'] = phoneNumber;
      }
      if (avatarUrl != null) {
        userData['avatarUrl'] = avatarUrl; 
      }

      final result = await _apiService.updateCurrentUser(userData); 
      
      _user = UserModel.fromJson(result);
      
      await _saveUserToStorage();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user info: $e');
      rethrow;
    }
  }

  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    _saveUserToStorage();
    notifyListeners();
  }

  Future<void> _saveUserToStorage() async {
    if (_user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(_user!.toJson()));
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    
    notifyListeners();
  }

  // Set user role (nếu cần thay đổi role)
  void setUserRole(String role) {
    if (_user != null) {
      _user = _user!.copyWith(role: role);
      _saveUserToStorage();
      notifyListeners();
    }
  }
}