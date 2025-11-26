// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'app.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/providers/auth_provider.dart'; 
import 'core/providers/navigation_provider.dart';

// (Bạn sẽ cần import Firebase sau này)
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart'; 

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  // ----- BẠN SẼ THÊM FIREBASE VÀO ĐÂY SAU NÀY -----
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // ---------------------------------------------

  // <<< 3. THÊM DÒNG NÀY ĐỂ NẠP TIẾNG VIỆT >>>
  await initializeDateFormatting('vi_VN', null);

  // Wrap App với Provider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        // Có thể thêm các Provider khác ở đây
      ],
      child: const App(),
    ),
  );
}