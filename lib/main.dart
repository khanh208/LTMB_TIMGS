
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'app.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/providers/auth_provider.dart'; 
import 'core/providers/navigation_provider.dart';


void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();


  await initializeDateFormatting('vi_VN', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: const App(),
    ),
  );
}