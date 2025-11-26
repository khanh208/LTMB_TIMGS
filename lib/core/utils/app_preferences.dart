import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyToken = 'token';
  static const String _keyUser = 'user';

  // Kiểm tra xem onboarding đã được xem chưa
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  // Đánh dấu onboarding đã được xem
  static Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, true);
  }

  // Kiểm tra xem có token và user info không (đã đăng nhập)
  static Future<bool> hasLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    final user = prefs.getString(_keyUser);
    return token != null && user != null;
  }
}
