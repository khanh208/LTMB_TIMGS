import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'features/main_navigation/screens/main_nav_screen.dart';
import 'features/profile/screens/settings_screen.dart'; 
import 'features/authentication/screens/onboarding_screen.dart';
import 'features/authentication/screens/login_screen.dart';
import 'features/authentication/screens/splash_screen.dart'; 
import 'features/profile/screens/edit_tutor_profile_screen.dart'; 
import 'features/authentication/screens/register_screen.dart';
import 'features/dashboard/screens/tutor_dashboard_screen.dart';
import 'features/earnings/screens/earnings_screen.dart';
import 'features/profile/screens/edit_account_screen.dart';
import 'features/profile/screens/notification_settings_screen.dart';
import 'features/profile/screens/change_password_screen.dart';
import 'features/profile/screens/saved_tutors_screen.dart';
import 'features/profile/screens/wallet_screen.dart';
import 'features/authentication/screens/forgot_password_screen.dart';
import 'features/profile/screens/reviews_list_screen.dart'; 
import 'features/schedule/screens/create_proposal_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MentorMatch: Gia Sư Việt',
      debugShowCheckedModeBanner: false,
      
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), 
        Locale('vi', 'VN'), 
      ],
      locale: const Locale('vi', 'VN'), 
      
      theme: ThemeData(
        primaryColor: const Color(0xFF22A45D), 
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF22A45D), 
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

      home: const SplashScreen(),

      routes: {
        '/main': (context) => const MainNavigationScreen(),
        '/login': (context) => const LoginScreen(), 
        '/register': (context) => const RegisterScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/edit_tutor_profile': (context) => const EditTutorProfileScreen(),
        '/tutor_dashboard': (context) => const TutorDashboardScreen(),
        '/earnings_management': (context) => const EarningsScreen(),
        '/edit_account': (context) => const EditAccountScreen(),
        '/notification_settings': (context) => const NotificationSettingsScreen(),
        '/change_password': (context) => const ChangePasswordScreen(),
        '/saved_tutors': (context) => const SavedTutorsScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/reviews_list': (context) => const ReviewsListScreen(),
        '/create_proposal': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return CreateProposalScreen(
            studentId: args['studentId']!,
            studentName: args['studentName']!,
          );
        },
      },
    );
  }
}