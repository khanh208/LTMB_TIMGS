import 'dart:convert';
import 'dart:async';
import 'dart:io'; 
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorType; 

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
  final String _baseUrl = "http://localhost:3000/api";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

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
      throw error; 
    } else {
      throw ApiException(
        message: error.toString().replaceAll('Exception: ', ''),
        errorType: 'unknown',
      );
    }
  }

  void _handleHttpResponse(http.Response response, String operation) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return; 
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
      _handleError(e, 'register'); 
      rethrow;
    }
  }

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
      _handleError(e, 'login'); 
      rethrow;
    }
  }

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
      _handleError(e, 'getCurrentUser'); 
      rethrow;
    }
  }

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
      _handleError(e, 'updateCurrentUser'); 
      rethrow;
    }
  }

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
      return [];
    }
  }

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
      rethrow; 
    }
  }

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

  Future<Map<String, dynamic>> checkChatConnection(String targetUserId) async {
    try {
      debugPrint('📤 [API] checkChatConnection - targetUserId: $targetUserId');
      
      final response = await http
          .get(
            Uri.parse('$_baseUrl/chat/check/$targetUserId'),
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'checkChatConnection');

      final responseBody = jsonDecode(response.body);
      debugPrint('✅ [API] checkChatConnection success: $responseBody');
      return Map<String, dynamic>.from(responseBody);
    } catch (e) {
      _handleError(e, 'checkChatConnection');
      rethrow;
    }
  }

  Future<String> uploadAvatar(File imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      
      final extension = imageFile.path.split('.').last.toLowerCase();
      String mimeType = 'image/png'; 
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
          'avatarBase64': base64DataUrl, 
        }),
      ).timeout(const Duration(seconds: 30)); 

      _handleHttpResponse(response, 'uploadAvatar');

      final jsonResp = jsonDecode(response.body);
      return jsonResp['avatarUrl'] ?? '';
    } catch (e) {
      _handleError(e, 'uploadAvatar');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMyReviews(String tutorId) async {
    try {
      final tutorDetail = await getTutorDetail(tutorId);
      
      if (tutorDetail.containsKey('reviews') && tutorDetail['reviews'] is List) {
        return List<Map<String, dynamic>>.from(tutorDetail['reviews']);
      }
      
      return [];
    } catch (e) {
      _handleError(e, 'getMyReviews');
      return [];
    }
  }

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

  Future<Map<String, dynamic>> addSavedTutor(String tutorId) async {
    try {
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
        'tutorId': cleanTutorId, 
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

  Future<Map<String, dynamic>> removeSavedTutor(String tutorId) async {
    try {
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
            Uri.parse('$_baseUrl/users/saved-tutors/$cleanTutorId'), 
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

  Future<Map<String, dynamic>> toggleSavedTutor(String tutorId, {required bool isSaved}) async {
    if (isSaved) {
      return await removeSavedTutor(tutorId);
    } else {
      return await addSavedTutor(tutorId);
    }
  }

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
          .timeout(const Duration(seconds: 5)); 

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ [API] markChatRoomAsRead success');
      } else {
        debugPrint('⚠️ [API] markChatRoomAsRead - Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ [API] markChatRoomAsRead error (ignored): $e');
    }
  }

  Future<Map<String, dynamic>> updateTutorProfile({
    required String bio,
    required int pricePerHour,
    required List<int> subjects,
    required List<Map<String, dynamic>> certificates, 
  }) async {
    try {
      debugPrint('📤 [API] updateTutorProfile - bio: ${bio.substring(0, bio.length > 50 ? 50 : bio.length)}..., price: $pricePerHour, subjects: $subjects, certificates: ${certificates.length}');

      final body = {
        'bio': bio,
        'price_per_hour': pricePerHour,
        'subjects': subjects,
        'certificates': certificates,
      };

      final response = await http
          .put(
            Uri.parse('$_baseUrl/tutors/my-profile'),
            headers: await _getAuthHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30)); 

      _handleHttpResponse(response, 'updateTutorProfile');

      final responseBody = jsonDecode(response.body);
      debugPrint('✅ [API] updateTutorProfile success');
      return Map<String, dynamic>.from(responseBody);
    } catch (e) {
      _handleError(e, 'updateTutorProfile');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMyTutorProfile() async {
    try {
      debugPrint('📤 [API] getMyTutorProfile');
      
      final response = await http
          .get(
            Uri.parse('$_baseUrl/tutors/me/profile'),
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'getMyTutorProfile');

      final responseBody = jsonDecode(response.body);
      debugPrint('✅ [API] getMyTutorProfile success');
      return Map<String, dynamic>.from(responseBody);
    } catch (e) {
      _handleError(e, 'getMyTutorProfile');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getSubjects() async {
    try {
      debugPrint('📤 [API] getSubjects');
      
      final response = await http
          .get(
            Uri.parse('$_baseUrl/subjects'),
            headers: await _getAuthHeaders(), 
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'getSubjects');

      final responseBody = jsonDecode(response.body);
      if (responseBody is List) {
        debugPrint('✅ [API] getSubjects success: count=${responseBody.length}');
        return List<Map<String, dynamic>>.from(responseBody);
      }
      return [];
    } catch (e) {
      _handleError(e, 'getSubjects');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createScheduleProposal({
    required String studentId,
    required String subjectId,
    required List<Map<String, String>> slots, 
  }) async {
    try {
      debugPrint('📤 [API] createScheduleProposal - studentId: $studentId, subjectId: $subjectId');
      
      final response = await http
          .post(
            Uri.parse('$_baseUrl/schedule/proposal'),
            headers: await _getAuthHeaders(),
            body: jsonEncode({
              'studentId': studentId,
              'subjectId': subjectId,
              'slots': slots,
            }),
          )
          .timeout(const Duration(seconds: 30));

      _handleHttpResponse(response, 'createScheduleProposal');

      final responseBody = jsonDecode(response.body);
      debugPrint('✅ [API] createScheduleProposal success: groupId=${responseBody['groupId']}');
      return Map<String, dynamic>.from(responseBody);
    } catch (e) {
      _handleError(e, 'createScheduleProposal');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> rejectScheduleProposal(String groupId) async {
    try {
      debugPrint('📤 [API] rejectScheduleProposal - groupId: $groupId');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/schedule/reject'),
            headers: await _getAuthHeaders(),
            body: jsonEncode({'groupId': groupId}),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'rejectScheduleProposal');

      final responseBody = jsonDecode(response.body);
      debugPrint('✅ [API] rejectScheduleProposal success');
      return Map<String, dynamic>.from(responseBody);
    } catch (e) {
      _handleError(e, 'rejectScheduleProposal');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getScheduleProposal(String groupId) async {
    try {
      debugPrint('📤 [API] getScheduleProposal - groupId: $groupId');
      
      final response = await http
          .get(
            Uri.parse('$_baseUrl/schedule/proposal/$groupId'),
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'getScheduleProposal');

      final responseBody = jsonDecode(response.body);
      debugPrint('✅ [API] getScheduleProposal success');
      return Map<String, dynamic>.from(responseBody);
    } catch (e) {
      _handleError(e, 'getScheduleProposal');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> payScheduleProposal(String groupId) async {
    try {
      debugPrint('📤 [API] payScheduleProposal - groupId: $groupId');
      
      final response = await http
          .post(
            Uri.parse('$_baseUrl/schedule/payment'),
            headers: await _getAuthHeaders(),
            body: jsonEncode({
              'groupId': groupId,
            }),
          )
          .timeout(const Duration(seconds: 30));

      _handleHttpResponse(response, 'payScheduleProposal');

      final responseBody = jsonDecode(response.body);
      debugPrint('✅ [API] payScheduleProposal success: totalAmount=${responseBody['totalAmount']}');
      return Map<String, dynamic>.from(responseBody);
    } catch (e) {
      _handleError(e, 'payScheduleProposal');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateScheduleStatus({
    required String scheduleId,
    required String status, 
  }) async {
    try {
      debugPrint('📤 [API] updateScheduleStatus - scheduleId: $scheduleId, status: $status');
      
      final response = await http
          .put(
            Uri.parse('$_baseUrl/schedule/$scheduleId'),
            headers: await _getAuthHeaders(),
            body: jsonEncode({
              'status': status,
            }),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'updateScheduleStatus');

      final responseBody = jsonDecode(response.body);
      debugPrint('✅ [API] updateScheduleStatus success');
      return Map<String, dynamic>.from(responseBody);
    } catch (e) {
      _handleError(e, 'updateScheduleStatus');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> linkWallet({
    required String accountType, 
    required String accountNumber,
    required String accountName,
  }) async {
    try {
      debugPrint('📤 [API] linkWallet - accountType: $accountType, accountNumber: $accountNumber');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/wallet/link'),
            headers: await _getAuthHeaders(),
            body: jsonEncode({
              'accountType': accountType,
              'accountNumber': accountNumber,
              'accountName': accountName,
            }),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'linkWallet');

      final responseBody = jsonDecode(response.body);
      debugPrint('✅ [API] linkWallet success');
      return Map<String, dynamic>.from(responseBody);
    } catch (e) {
      _handleError(e, 'linkWallet');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> depositWallet({
    required int amount,
    required String source, 
  }) async {
    try {
      debugPrint('📤 [API] depositWallet - amount: $amount, source: $source');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/wallet/deposit'),
            headers: await _getAuthHeaders(),
            body: jsonEncode({
              'amount': amount,
              'source': source,
            }),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'depositWallet');

      final responseBody = jsonDecode(response.body);
      debugPrint('✅ [API] depositWallet success');
      return Map<String, dynamic>.from(responseBody);
    } catch (e) {
      _handleError(e, 'depositWallet');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getWalletBalance() async {
    try {
      debugPrint('📤 [API] getWalletBalance');

      final response = await http
          .get(
            Uri.parse('$_baseUrl/wallet/balance'),
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'getWalletBalance');

      final responseBody = jsonDecode(response.body);
      debugPrint('✅ [API] getWalletBalance success: balance=${responseBody['balance']}');
      return Map<String, dynamic>.from(responseBody);
    } catch (e) {
      _handleError(e, 'getWalletBalance');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getWalletTransactions() async {
    try {
      debugPrint('📤 [API] getWalletTransactions');

      final response = await http
          .get(
            Uri.parse('$_baseUrl/wallet/transactions'),
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'getWalletTransactions');

      final responseBody = jsonDecode(response.body);
      if (responseBody is List) {
        debugPrint('✅ [API] getWalletTransactions success: count=${responseBody.length}');
        return List<Map<String, dynamic>>.from(responseBody);
      }
      return [];
    } catch (e) {
      _handleError(e, 'getWalletTransactions');
      rethrow;
    }
  }

  // --- GET /api/wallet/accounts ---
  // Lấy danh sách các ví đã liên kết
  Future<List<Map<String, dynamic>>> getWalletAccounts() async {
    try {
      debugPrint('📤 [API] getWalletAccounts');

      final response = await http
          .get(
            Uri.parse('$_baseUrl/wallet/accounts'),
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'getWalletAccounts');

      final responseBody = jsonDecode(response.body);
      if (responseBody is List) {
        debugPrint('✅ [API] getWalletAccounts success: count=${responseBody.length}');
        return List<Map<String, dynamic>>.from(responseBody);
      }
      return [];
    } catch (e) {
      _handleError(e, 'getWalletAccounts');
      rethrow;
    }
  }
}