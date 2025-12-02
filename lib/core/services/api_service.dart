import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// --- CUSTOM EXCEPTION CLASS ---
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

// --- MAIN API SERVICE CLASS ---
class ApiService {
  // ⚠️ QUAN TRỌNG: Thay đổi IP này theo mạng của bạn (dùng ipconfig/ifconfig để xem)
  // Nếu chạy máy ảo Android: dùng 10.0.2.2
  // Nếu chạy máy thật: dùng IP LAN (VD: 192.168.1.67)
  final String _baseUrl = "http://172.20.10.4:3000/api";

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

  // --- XỬ LÝ LỖI CHUNG ---
  void _handleError(dynamic error, String operation) {
    debugPrint('❌ [API Error] $operation: $error');
    if (error is SocketException) {
      throw ApiException(
          message: 'Không có kết nối internet', errorType: 'network');
    } else if (error is TimeoutException) {
      throw ApiException(message: 'Kết nối quá lâu', errorType: 'timeout');
    } else if (error is http.ClientException) {
      throw ApiException(message: 'Lỗi kết nối mạng', errorType: 'network');
    } else if (error is FormatException) {
      throw ApiException(
          message: 'Dữ liệu không đúng định dạng', errorType: 'client');
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
      errorMessage = 'Lỗi server (${response.statusCode})';
    }

    throw ApiException(
      message: errorMessage,
      statusCode: response.statusCode,
      errorType: response.statusCode >= 500 ? 'server' : 'client',
    );
  }

  // ===========================================================================
  // 1. AUTHENTICATION (Xác thực)
  // ===========================================================================

  Future<Map<String, dynamic>> register(
      String email, String password, String fullName, String role) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'fullName': fullName,
              'role': role,
            }),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'register');
      return jsonDecode(response.body);
    } catch (e) {
      _handleError(e, 'register');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'login');
      return jsonDecode(response.body);
    } catch (e) {
      _handleError(e, 'login');
      rethrow;
    }
  }

  // ===========================================================================
  // 2. USER & PROFILE
  // ===========================================================================

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/users/me'),
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'getCurrentUser');
      return jsonDecode(response.body);
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
      return jsonDecode(response.body);
    } catch (e) {
      _handleError(e, 'updateCurrentUser');
      rethrow;
    }
  }

  // Upload Avatar dùng Base64
  Future<String> uploadAvatar(File imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final extension = imageFile.path.split('.').last.toLowerCase();
      String mimeType = 'image/png';
      if (extension == 'jpg' || extension == 'jpeg') mimeType = 'image/jpeg';

      final base64DataUrl = 'data:$mimeType;base64,$base64Image';

      final response = await http
          .post(
            Uri.parse('$_baseUrl/users/avatar'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'avatarBase64': base64DataUrl}),
          )
          .timeout(const Duration(seconds: 30));

      _handleHttpResponse(response, 'uploadAvatar');
      return jsonDecode(response.body)['avatarUrl'] ?? '';
    } catch (e) {
      _handleError(e, 'uploadAvatar');
      rethrow;
    }
  }

  // ===========================================================================
  // 3. TUTOR & SEARCH
  // ===========================================================================

  // ✅ FIX: Thêm hàm getTutors (thiếu)
  Future<List<Map<String, dynamic>>> getTutors({String? category}) async {
    try {
      final queryParams = <String, String>{};
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      final uri =
          Uri.parse('$_baseUrl/tutors').replace(queryParameters: queryParams);
      debugPrint('📤 [API] getTutors - URI: $uri');

      final response = await http
          .get(
            uri,
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'getTutors');
      final body = jsonDecode(response.body);
      return (body is List) ? List<Map<String, dynamic>>.from(body) : [];
    } catch (e) {
      _handleError(e, 'getTutors');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchTutors({
    String? search,
    String? category,
    double? minRating,
    double? maxPrice,
    String? sortBy,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (category != null && category.isNotEmpty)
      queryParams['category'] = category;
    if (minRating != null) queryParams['minRating'] = minRating.toString();
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
    if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    // Logic Fallback (nếu API search mới chưa hoạt động thì gọi API cũ)
    final searchUri = Uri.parse('$_baseUrl/tutors/search')
        .replace(queryParameters: queryParams);
    final fallbackUri = Uri.parse('$_baseUrl/tutors').replace(queryParameters: {
      if (search != null) 'search': search,
      if (category != null) 'category': category,
    });

    try {
      debugPrint('📤 [API] searchTutors - Trying: $searchUri');
      final response = await http
          .get(searchUri, headers: await _getAuthHeaders())
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is List) return List<Map<String, dynamic>>.from(body);
        if (body is Map && body.containsKey('data'))
          return List<Map<String, dynamic>>.from(body['data']);
        return [];
      } else if (response.statusCode == 404) {
        debugPrint('⚠️ [API] 404, trying fallback: $fallbackUri');
        final fbResponse =
            await http.get(fallbackUri, headers: await _getAuthHeaders());
        if (fbResponse.statusCode == 200) {
          final body = jsonDecode(fbResponse.body);
          if (body is List) return List<Map<String, dynamic>>.from(body);
        }
      }
      return [];
    } catch (e) {
      debugPrint('❌ [API] Search Error: $e');
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
      return jsonDecode(response.body);
    } catch (e) {
      _handleError(e, 'getTutorDetail');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateTutorProfile({
    required String bio,
    required int pricePerHour,
    required List<int> subjects,
    required List<Map<String, dynamic>> certificates,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/tutors/my-profile'),
            headers: await _getAuthHeaders(),
            body: jsonEncode({
              'bio': bio,
              'price_per_hour': pricePerHour,
              'subjects': subjects,
              'certificates': certificates,
            }),
          )
          .timeout(const Duration(seconds: 30));

      _handleHttpResponse(response, 'updateTutorProfile');
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } catch (e) {
      _handleError(e, 'updateTutorProfile');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMyTutorProfile() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/tutors/me/profile'),
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'getMyTutorProfile');
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } catch (e) {
      _handleError(e, 'getMyTutorProfile');
      rethrow;
    }
  }

  // ===========================================================================
  // 4. REVIEWS (Đánh giá) - ✅ FIX: Thêm hàm getMyReviews
  // ===========================================================================

  Future<List<Map<String, dynamic>>> getMyReviews(String tutorId) async {
    try {
      debugPrint('📤 [API] getMyReviews - tutorId: $tutorId');
      final response = await http
          .get(
            Uri.parse('$_baseUrl/reviews/tutor/$tutorId'),
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'getMyReviews');
      final body = jsonDecode(response.body);
      return (body is List) ? List<Map<String, dynamic>>.from(body) : [];
    } catch (e) {
      debugPrint('⚠️ [API] getMyReviews error: $e');
      return [];
    }
  }

  // ===========================================================================
  // 5. CHAT
  // ===========================================================================

  Future<List<Map<String, dynamic>>> getChatRooms() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/chat/rooms'),
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'getChatRooms');
      final body = jsonDecode(response.body);
      return (body is List) ? List<Map<String, dynamic>>.from(body) : [];
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
      final body = jsonDecode(response.body);
      return (body is List) ? List<Map<String, dynamic>>.from(body) : [];
    } catch (e) {
      _handleError(e, 'getChatMessages');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendMessage(
      String roomId, String messageText) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/rooms/$roomId'),
            headers: await _getAuthHeaders(),
            body: jsonEncode({'messageText': messageText}),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'sendMessage');
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } catch (e) {
      _handleError(e, 'sendMessage');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendConnectionRequest(
      String tutorId, String message) async {
    try {
      // API này giờ là Connect & Message luôn
      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/connect'),
            headers: await _getAuthHeaders(),
            body: jsonEncode({'tutorId': tutorId, 'messageText': message}),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'sendConnectionRequest');
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } catch (e) {
      _handleError(e, 'sendConnectionRequest');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkChatConnection(String targetUserId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/chat/check/$targetUserId'),
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'checkChatConnection');
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } catch (e) {
      _handleError(e, 'checkChatConnection');
      rethrow;
    }
  }

  Future<void> markChatRoomAsRead(String roomId) async {
    try {
      await http.put(
        Uri.parse('$_baseUrl/chat/rooms/$roomId/read'),
        headers: await _getAuthHeaders(),
      );
    } catch (_) {}
  }

  // ===========================================================================
  // 6. SCHEDULE (Lịch học)
  // ===========================================================================

  Future<List<Map<String, dynamic>>> getSchedules() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/schedule'),
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return [];
      final body = jsonDecode(response.body);
      return (body is List) ? List<Map<String, dynamic>>.from(body) : [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> createScheduleProposal({
    required String studentId,
    required String subjectId,
    required List<Map<String, String>> slots,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/schedule/proposal'),
            headers: await _getAuthHeaders(),
            body: jsonEncode({
              'studentId': studentId,
              'subjectId': subjectId,
              'slots': slots
            }),
          )
          .timeout(const Duration(seconds: 30));

      _handleHttpResponse(response, 'createScheduleProposal');
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } catch (e) {
      _handleError(e, 'createScheduleProposal');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getScheduleProposal(String groupId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/schedule/proposal/$groupId'),
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'getScheduleProposal');
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } catch (e) {
      _handleError(e, 'getScheduleProposal');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> payScheduleProposal(String groupId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/schedule/payment'),
            headers: await _getAuthHeaders(),
            body: jsonEncode({'groupId': groupId}),
          )
          .timeout(const Duration(seconds: 30));

      _handleHttpResponse(response, 'payScheduleProposal');
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } catch (e) {
      _handleError(e, 'payScheduleProposal');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> rejectScheduleProposal(String groupId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/schedule/reject'),
            headers: await _getAuthHeaders(),
            body: jsonEncode({'groupId': groupId}),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'rejectScheduleProposal');
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } catch (e) {
      _handleError(e, 'rejectScheduleProposal');
      rethrow;
    }
  }

  // ===========================================================================
  // 7. WALLET (Ví tiền) - ĐÃ BỔ SUNG ĐẦY ĐỦ
  // ===========================================================================

  // Hàm lấy số dư (fix lỗi thiếu hàm getWalletBalance)
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
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } catch (e) {
      _handleError(e, 'getWalletBalance');
      rethrow;
    }
  }

  // Hàm lấy lịch sử giao dịch (fix lỗi thiếu hàm getWalletTransactions)
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
      final body = jsonDecode(response.body);
      return (body is List) ? List<Map<String, dynamic>>.from(body) : [];
    } catch (e) {
      _handleError(e, 'getWalletTransactions');
      return [];
    }
  }

  // Hàm nạp tiền (fix lỗi thiếu hàm mockWalletDeposit)
  Future<void> mockWalletDeposit(double amount) async {
    try {
      debugPrint('📤 [API] mockWalletDeposit - amount: $amount');
      final response = await http
          .post(
            Uri.parse('$_baseUrl/wallet/deposit'),
            headers: await _getAuthHeaders(),
            body: jsonEncode({
              'amount': amount,
              'source': 'Momo Mock App',
            }),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'mockWalletDeposit');
      debugPrint('✅ [API] mockWalletDeposit success');
    } catch (e) {
      _handleError(e, 'mockWalletDeposit');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getLinkedAccounts() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/wallet/accounts'),
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'getLinkedAccounts');
      final body = jsonDecode(response.body);
      return (body is List) ? List<Map<String, dynamic>>.from(body) : [];
    } catch (e) {
      return [];
    }
  }

  Future<void> linkAccount(Map<String, String> accountData) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/wallet/link'),
            headers: await _getAuthHeaders(),
            body: jsonEncode(accountData),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'linkAccount');
    } catch (e) {
      _handleError(e, 'linkAccount');
      rethrow;
    }
  }

  // ===========================================================================
  // 8. SAVED TUTORS - ✅ FIX: Thêm hàm toggleSavedTutor
  // ===========================================================================

  Future<List<Map<String, dynamic>>> getSavedTutors() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/users/saved-tutors'),
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'getSavedTutors');
      final body = jsonDecode(response.body);
      if (body is List) return List<Map<String, dynamic>>.from(body);
      // Xử lý trường hợp backend trả về object {tutors: []}
      if (body is Map && body.containsKey('tutors'))
        return List<Map<String, dynamic>>.from(body['tutors']);
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> addSavedTutor(String tutorId) async {
    try {
      await http
          .post(
            Uri.parse('$_baseUrl/users/saved-tutors'),
            headers: await _getAuthHeaders(),
            body: jsonEncode({'tutorId': tutorId}),
          )
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      _handleError(e, 'addSavedTutor');
      rethrow;
    }
  }

  Future<void> removeSavedTutor(String tutorId) async {
    try {
      await http
          .delete(
            Uri.parse('$_baseUrl/users/saved-tutors/$tutorId'),
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      _handleError(e, 'removeSavedTutor');
      rethrow;
    }
  }

  // ✅ FIX: Thêm hàm toggleSavedTutor (thiếu)
  Future<void> toggleSavedTutor(String tutorId, {required bool isSaved}) async {
    try {
      if (isSaved) {
        await removeSavedTutor(tutorId);
      } else {
        await addSavedTutor(tutorId);
      }
    } catch (e) {
      _handleError(e, 'toggleSavedTutor');
      rethrow;
    }
  }

  Future<bool> isTutorSaved(String tutorId) async {
    try {
      final list = await getSavedTutors();
      return list.any((t) =>
          t['user_id']?.toString() == tutorId ||
          t['tutor_id']?.toString() == tutorId ||
          t['id']?.toString() == tutorId);
    } catch (e) {
      return false;
    }
  }

  // ===========================================================================
  // 9. SUBJECTS
  // ===========================================================================

  Future<List<Map<String, dynamic>>> getSubjects() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/subjects'),
            headers: await _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      _handleHttpResponse(response, 'getSubjects');
      final body = jsonDecode(response.body);
      return (body is List) ? List<Map<String, dynamic>>.from(body) : [];
    } catch (e) {
      return [];
    }
  }
}
