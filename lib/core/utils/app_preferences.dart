import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyToken = 'token';
  static const String _keyUser = 'user';

  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  static Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, true);
  }

  static Future<bool> hasLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    final user = prefs.getString(_keyUser);
    return token != null && user != null;
  }
}
