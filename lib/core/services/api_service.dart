// lib/core/services/api_service.dart
import 'dart:convert';
import 'dart:async';
import 'dart:io'; // <-- THÊM cho SocketException
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Custom Exception class
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorType; // 'network', 'timeout', 'server', 'client', 'unknown'

  ApiException({
    required this.message,
    this.statusCode,
    this.errorType,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return '[$statusCode] $message';
    }
    return message;
  }
}

class ApiService {
  // 1. ĐỊA CHỈ IP CỦA BACKEND
  // Dùng 10.0.2.2 cho máy ảo Android
  final String _baseUrl = "http://localhost:3000/api";

  // Helper method để lấy token từ SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Helper method để tạo headers với token
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Helper để throw exception với thông tin rõ ràng
  void _handleError(dynamic error, String operation) {
    if (error is SocketException) {
      throw ApiException(
        message: 'Không có kết nối internet',
        errorType: 'network',
      );
    } else if (error is TimeoutException) {
      throw ApiException(
        message: 'Kết nối quá lâu',
        errorType: 'timeout',
      );
    } else if (error is http.ClientException) {
      throw ApiException(
        message: 'Lỗi kết nối mạng',
        errorType: 'network',
      );
    } else if (error is FormatException) {
      throw ApiException(
        message: 'Dữ liệu không đúng định dạng',
        errorType: 'client',
      );
    } else if (error is ApiException) {
      throw error; // <-- THAY ĐỔI: throw error thay vì rethrow
    } else {
      throw ApiException(
        message: error.toString().replaceAll('Exception: ', ''),
        errorType: 'unknown',
      );
    }
  }

  // Helper để xử lý HTTP response
  void _handleHttpResponse(http.Response response, String operation) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return; // Success
    }

    String errorMessage;
    try {
      final responseBody = jsonDecode(response.body);
      errorMessage = responseBody['message'] ?? 'Đã xảy ra lỗi';
    } catch (e) {
      errorMessage = 'Đã xảy ra lỗi';
    }

    String errorType = 'server';
    if (response.statusCode >= 400 && response.statusCode < 500) {
      errorType = 'client';
    }

    throw ApiException(
      message: errorMessage,
      statusCode: response.statusCode,
      errorType: errorType,
    );
  }

  // --- HÀM ĐĂNG KÝ ---
  Future<Map<String, dynamic>> register(
      String email, String password, String fullName, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'fullName': fullName,
          'role': role,
        }),
      ).timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'register');

      final responseBody = jsonDecode(response.body);
      return responseBody;
    } catch (e) {
      _handleError(e, 'register'); // <-- Không cần rethrow
      rethrow;
    }
  }

  // --- HÀM ĐĂNG NHẬP ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'login');

      final responseBody = jsonDecode(response.body);
      return responseBody;
    } catch (e) {
      _handleError(e, 'login'); // <-- Không cần rethrow
      rethrow;
    }
  }

  // --- GET /api/users/me ---
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/users/me'),
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'getCurrentUser');

      final responseBody = jsonDecode(response.body);
      return responseBody;
    } catch (e) {
      _handleError(e, 'getCurrentUser'); // <-- Không cần rethrow
      rethrow;
    }
  }

  // --- PUT /api/users/me ---
  Future<Map<String, dynamic>> updateCurrentUser(
      Map<String, dynamic> userData) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/users/me'),
            headers: await _getAuthHeaders(),
            body: jsonEncode(userData),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'updateCurrentUser');

      final responseBody = jsonDecode(response.body);
      return responseBody;
    } catch (e) {
      _handleError(e, 'updateCurrentUser'); // <-- _handleError đã throw rồi, không cần rethrow
      rethrow;
    }
  }

  // --- GET /api/tutors ---
  Future<List<Map<String, dynamic>>> getTutors({
    String? category,
    String? search,
    String? sortBy,
  }) async {
    final queryParams = <String, String>{};
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParams['sortBy'] = sortBy;
    }

    final uri = Uri.parse('$_baseUrl/tutors')
        .replace(queryParameters: queryParams);

    try {
      final response = await http
          .get(
            uri,
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      // Nếu lỗi, trả về empty list thay vì throw
      if (response.statusCode != 200) {
        debugPrint('⚠️ [API] getTutors - Error ${response.statusCode}, returning empty list');
        return [];
      }

      final responseBody = jsonDecode(response.body);
      if (responseBody is List) {
        return List<Map<String, dynamic>>.from(responseBody);
      }
      return [];
    } catch (e) {
      debugPrint('❌ [API] getTutors - Error: $e');
      // Trả về empty list thay vì throw để không break UI
      return [];
    }
  }

  // --- GET /api/tutors/:tutorId ---
  Future<Map<String, dynamic>> getTutorDetail(String tutorId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/tutors/$tutorId'),
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'getTutorDetail');

      final responseBody = jsonDecode(response.body);
      return responseBody;
    } catch (e) {
      _handleError(e, 'getTutorDetail');
      rethrow;
    }
  }

  // --- GET /api/chat/rooms ---
  Future<List<Map<String, dynamic>>> getChatRooms() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/chat/rooms'),
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'getChatRooms');

      final responseBody = jsonDecode(response.body);
      if (responseBody is List) {
        return List<Map<String, dynamic>>.from(responseBody);
      }
      return [];
    } catch (e) {
      _handleError(e, 'getChatRooms');
      rethrow; // <-- THAY ĐỔI: throw lại exception để screen có thể catch và hiển thị popup
    }
  }

  // --- GET /api/chat/rooms/:roomId ---
  Future<List<Map<String, dynamic>>> getChatMessages(String roomId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/chat/rooms/$roomId'),
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'getChatMessages');

      final responseBody = jsonDecode(response.body);
      if (responseBody is List) {
        return List<Map<String, dynamic>>.from(responseBody);
      }
      return [];
    } catch (e) {
      _handleError(e, 'getChatMessages');
      rethrow;
    }
  }

  // --- POST /api/chat/rooms/:roomId ---
  Future<Map<String, dynamic>> sendMessage(String roomId, String messageText) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/rooms/$roomId'),
            headers: await _getAuthHeaders(),
            body: jsonEncode({
              'messageText': messageText,
            }),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'sendMessage');

      final responseBody = jsonDecode(response.body);
      return Map<String, dynamic>.from(responseBody);
    } catch (e) {
      _handleError(e, 'sendMessage');
      rethrow;
    }
  }

  // --- GET /api/schedule ---
  // Lấy danh sách lịch học/lịch dạy của người dùng
  Future<List<Map<String, dynamic>>> getSchedules() async {
    final uri = Uri.parse('$_baseUrl/schedule');

    debugPrint('🌐 [API] getSchedules - REQUEST: ${uri.toString()}');
    debugPrint('🌐 [API] getSchedules - Headers: ${await _getAuthHeaders()}');

    try {
      final response = await http
          .get(
            uri,
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      // Nếu lỗi, trả về empty list
      if (response.statusCode != 200) {
        debugPrint('⚠️ [API] getSchedules - Error ${response.statusCode}, returning empty list');
        return [];
      }

      final responseBody = jsonDecode(response.body);
      if (responseBody is List) {
        debugPrint('✅ [API] getSchedules - SUCCESS: count=${responseBody.length}');
        return List<Map<String, dynamic>>.from(responseBody);
      }
      return [];
    } catch (e) {
      debugPrint('❌ [API] getSchedules - Error: $e');
      return [];
    }
  }

  // --- POST /api/chat/connect ---
  // Gửi yêu cầu kết nối từ học viên đến gia sư
  // Backend sẽ tự động tạo room nếu chưa có và gửi tin nhắn đầu tiên
  Future<Map<String, dynamic>> sendConnectionRequest(String tutorId, String message) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/connect'),
            headers: await _getAuthHeaders(),
            body: jsonEncode({
              'tutorId': tutorId,
              'messageText': message,
            }),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'sendConnectionRequest');

      final responseBody = jsonDecode(response.body);
      return Map<String, dynamic>.from(responseBody);
    } catch (e) {
      _handleError(e, 'sendConnectionRequest');
      rethrow;
    }
  }

  Future<String> uploadAvatar(File imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      
      // API yêu cầu format "data:image/png;base64,..."
      // Cần detect mime type từ file extension
      final extension = imageFile.path.split('.').last.toLowerCase();
      String mimeType = 'image/png'; // default
      if (extension == 'jpg' || extension == 'jpeg') {
        mimeType = 'image/jpeg';
      } else if (extension == 'png') {
        mimeType = 'image/png';
      } else if (extension == 'gif') {
        mimeType = 'image/gif';
      } else if (extension == 'webp') {
        mimeType = 'image/webp';
      }
      
      final base64DataUrl = 'data:$mimeType;base64,$base64Image';

      final response = await http.post(
        Uri.parse('$_baseUrl/users/avatar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'avatarBase64': base64DataUrl, // <-- Gửi với format data URL
        }),
      ).timeout(const Duration(seconds: 30)); // Tăng timeout cho upload ảnh

      _handleHttpResponse(response, 'uploadAvatar');

      final jsonResp = jsonDecode(response.body);
      return jsonResp['avatarUrl'] ?? '';
    } catch (e) {
      _handleError(e, 'uploadAvatar');
      rethrow;
    }
  }

  // --- GET reviews của gia sư ---
  // Sử dụng getTutorDetail với tutorId của chính mình để lấy reviews
  Future<List<Map<String, dynamic>>> getMyReviews(String tutorId) async {
    try {
      // Gọi getTutorDetail để lấy thông tin gia sư (bao gồm reviews)
      final tutorDetail = await getTutorDetail(tutorId);
      
      // Lấy phần reviews từ response
      if (tutorDetail.containsKey('reviews') && tutorDetail['reviews'] is List) {
        return List<Map<String, dynamic>>.from(tutorDetail['reviews']);
      }
      
      return [];
    } catch (e) {
      _handleError(e, 'getMyReviews');
      return [];
    }
  }

  // --- GET /api/users/saved-tutors ---
  // Lấy danh sách gia sư đã lưu của user hiện tại
  Future<List<Map<String, dynamic>>> getSavedTutors() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/users/saved-tutors'),
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'getSavedTutors');

      final responseBody = jsonDecode(response.body);
      
      // API có thể trả về array trực tiếp hoặc có wrapper
      if (responseBody is List) {
        return List<Map<String, dynamic>>.from(responseBody);
      } else if (responseBody is Map && responseBody.containsKey('tutors')) {
        return List<Map<String, dynamic>>.from(responseBody['tutors']);
      }
      
      return [];
    } catch (e) {
      debugPrint('⚠️ [API] Error loading saved tutors: $e');
      return [];
    }
  }

  // --- POST /api/users/saved-tutors ---
  // Thêm gia sư vào danh sách đã lưu
  Future<Map<String, dynamic>> addSavedTutor(String tutorId) async {
    try {
      // Validate tutorId
      if (tutorId.isEmpty || tutorId.trim().isEmpty) {
        throw ApiException(
          message: 'ID gia sư không hợp lệ',
          statusCode: 400,
          errorType: 'client',
        );
      }

      final cleanTutorId = tutorId.trim();
      debugPrint('📤 [API] addSavedTutor - tutorId: $cleanTutorId');

      final requestBody = {
        'tutorId': cleanTutorId, // camelCase như API yêu cầu
      };

      debugPrint('📤 [API] Request body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/users/saved-tutors'),
            headers: await _getAuthHeaders(),
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'addSavedTutor');

      final responseBody = jsonDecode(response.body);
      debugPrint('✅ [API] addSavedTutor success: $responseBody');
      return Map<String, dynamic>.from(responseBody);
    } catch (e) {
      debugPrint('❌ [API] addSavedTutor error: $e');
      _handleError(e, 'addSavedTutor');
      rethrow;
    }
  }

  // --- DELETE /api/users/saved-tutors/:tutorId ---
  // Xóa gia sư khỏi danh sách đã lưu
  Future<Map<String, dynamic>> removeSavedTutor(String tutorId) async {
    try {
      // Validate tutorId
      if (tutorId.isEmpty || tutorId.trim().isEmpty) {
        throw ApiException(
          message: 'ID gia sư không hợp lệ',
          statusCode: 400,
          errorType: 'client',
        );
      }

      final cleanTutorId = tutorId.trim();
      debugPrint('📤 [API] removeSavedTutor - tutorId: $cleanTutorId');

      final response = await http
          .delete(
            Uri.parse('$_baseUrl/users/saved-tutors/$cleanTutorId'), // <-- tutorId trong URL
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'removeSavedTutor');

      final responseBody = jsonDecode(response.body);
      debugPrint('✅ [API] removeSavedTutor success: $responseBody');
      return Map<String, dynamic>.from(responseBody);
    } catch (e) {
      debugPrint('❌ [API] removeSavedTutor error: $e');
      _handleError(e, 'removeSavedTutor');
      rethrow;
    }
  }

  // --- Toggle saved tutor (wrapper method) ---
  // Thêm hoặc xóa gia sư dựa trên trạng thái hiện tại
  Future<Map<String, dynamic>> toggleSavedTutor(String tutorId, {required bool isSaved}) async {
    if (isSaved) {
      // Nếu đã lưu, thì xóa (DELETE)
      return await removeSavedTutor(tutorId);
    } else {
      // Nếu chưa lưu, thì thêm (POST)
      return await addSavedTutor(tutorId);
    }
  }

  // --- Kiểm tra xem gia sư đã được lưu chưa ---
  // Có thể dùng getSavedTutors() và check, hoặc có API riêng
  Future<bool> isTutorSaved(String tutorId) async {
    try {
      final savedTutors = await getSavedTutors();
      return savedTutors.any((tutor) => 
        tutor['user_id']?.toString() == tutorId || 
        tutor['tutor_id']?.toString() == tutorId ||
        tutor['id']?.toString() == tutorId
      );
    } catch (e) {
      debugPrint('⚠️ [API] Error checking saved tutor: $e');
      return false;
    }
  }

  // --- PUT /api/chat/rooms/:roomId/read ---
  // Đánh dấu tin nhắn trong room là đã đọc
  Future<void> markChatRoomAsRead(String roomId) async {
    try {
      if (roomId.isEmpty || roomId.trim().isEmpty) {
        debugPrint('⚠️ [API] markChatRoomAsRead - Invalid roomId');
        return;
      }

      final cleanRoomId = roomId.trim();
      debugPrint('📤 [API] markChatRoomAsRead - roomId: $cleanRoomId');

      final response = await http
          .put(
            Uri.parse('$_baseUrl/chat/rooms/$cleanRoomId/read'),
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 5)); // Timeout ngắn vì fire & forget

      // Không throw exception, chỉ log (fire & forget)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ [API] markChatRoomAsRead success');
      } else {
        debugPrint('⚠️ [API] markChatRoomAsRead - Status: ${response.statusCode}');
      }
    } catch (e) {
      // Không throw, chỉ log (fire & forget)
      debugPrint('⚠️ [API] markChatRoomAsRead error (ignored): $e');
    }
  }
}