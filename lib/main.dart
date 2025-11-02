// lib/main.dart

import 'package:flutter/material.dart';
import 'app.dart'; // Import file app.dart của chúng ta

// Bạn sẽ cần import Firebase sau này
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart'; // File này do Firebase CLI tạo ra

void main() async {
  // Đảm bảo Flutter đã sẵn sàng trước khi chạy code
  WidgetsFlutterBinding.ensureInitialized();

  // ----- BẠN SẼ THÊM FIREBASE VÀO ĐÂY SAU NÀY -----
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // ---------------------------------------------

  // Chạy widget App (định nghĩa trong app.dart)
  runApp(const App());
} 