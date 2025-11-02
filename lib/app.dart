// lib/app.dart
// (File bạn đã tạo, giờ cập nhật lại)

import 'package:flutter/material.dart';
import 'features/main_navigation/screens/main_nav_screen.dart';
// Import 2 file mới của chúng ta
import 'features/profile/screens/settings_screen.dart'; 
import 'features/authentication/screens/onboarding_screen.dart';
import 'features/authentication/screens/login_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MentorMatch: Gia Sư Việt',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        // DÙNG MÀU XANH CỦA BẠN LÀM MÀU CHỦ ĐẠO
        primaryColor: const Color(0xFF22A45D), // Màu xanh trong code của bạn
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF22A45D), // Dùng màu này
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black
          ),
        ),
      ),

      // --- CẬP NHẬT ĐƯỜNG DẪN ---
      
      // 1. Đổi 'home' thành OnboardingScreen
      home: const OnboardingScreen(), 

      // 2. Định nghĩa các đường dẫn
      routes: {
        '/main': (context) => const MainNavigationScreen(),
        '/login': (context) => const LoginScreen(), // Thêm đường dẫn login
        // '/register': (context) => const RegisterScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}