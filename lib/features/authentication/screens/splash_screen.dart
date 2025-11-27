import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../core/providers/auth_provider.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import '../../main_navigation/screens/main_nav_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkInitialRoute();
  }

  Future<void> _checkInitialRoute() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    debugPrint('🔄 [SplashScreen] Waiting for AuthProvider initialization...');
    await authProvider.waitForInitialization();
    debugPrint('✅ [SplashScreen] AuthProvider initialized. isLoggedIn: ${authProvider.isLoggedIn}');
    
    final isOnboardingCompleted = await AppPreferences.isOnboardingCompleted();
    debugPrint('📱 [SplashScreen] Onboarding completed: $isOnboardingCompleted');
    
    if (!isOnboardingCompleted) {
      debugPrint('➡️ [SplashScreen] Navigating to OnboardingScreen');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
      return;
    }

    if (authProvider.isLoggedIn) {
      debugPrint('➡️ [SplashScreen] User is logged in. Navigating to MainNavigationScreen');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    } else {
      debugPrint('➡️ [SplashScreen] User not logged in. Navigating to LoginScreen');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              'MentorMatch',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
