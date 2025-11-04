// lib/main.dart

import 'package:flutter/material.dart';
import 'app.dart'; // Import file app.dart của chúng ta
import 'package:intl/date_symbol_data_local.dart'; // <<< 1. IMPORT DÒNG NÀY

// (Bạn sẽ cần import Firebase sau này)
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart'; 

void main() async { // 2. ĐẢM BẢO CÓ `async`
  
  WidgetsFlutterBinding.ensureInitialized();

  // ----- BẠN SẼ THÊM FIREBASE VÀO ĐÂY SAU NÀY -----
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // ---------------------------------------------

  // <<< 3. THÊM DÒNG NÀY ĐỂ NẠP TIẾNG VIỆT >>>
  await initializeDateFormatting('vi_VN', null);

  // Chạy widget App (định nghĩa trong app.dart)
  runApp(const App());
}