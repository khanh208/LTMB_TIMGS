// lib/features/main_navigation/screens/main_nav_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../../../core/providers/auth_provider.dart'; 
import '../../../core/providers/navigation_provider.dart';

// Import các màn hình CHÍNH
import '../../search_find_tutor/screens/home_screen.dart';
import '../../schedule/screens/my_schedule_screen.dart';
import '../../profile/screens/my_profile_screen.dart';
import '../../chat/screens/chat_list_screen.dart';
import '../../dashboard/screens/tutor_dashboard_screen.dart';
import '../../placeholder_screens.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  late List<Widget> _screens;
  late List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();
    _buildNavigation();
  }

  void _buildNavigation() {
    // Lấy userRole từ Provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userRole = authProvider.userRole ?? 'student';

    // --- CẤU HÌNH CHO HỌC VIÊN ---
    if (userRole == 'student') {
      _screens = const [
        HomeScreen(),
        MyScheduleScreen(),
        ChatListScreen(),
        MyProfileScreen(),
      ];
      _navItems = const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled),
            label: "Trang chủ"),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: "Lịch học"),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: "Tin nhắn"),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Hồ sơ"),
      ];

      // --- CẤU HÌNH CHO GIA SƯ ---
    } else if (userRole == 'tutor') {
      _screens = const [
        TutorDashboardScreen(),
        MyScheduleScreen(),
        ChatListScreen(),
        MyProfileScreen(),
      ];
      _navItems = const [
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: "Dashboard"),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: "Lịch dạy"),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: "Tin nhắn"),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Hồ sơ"),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        _buildNavigation();
        
        // Listen NavigationProvider để chuyển tab khi cần
        return Consumer<NavigationProvider>(
          builder: (context, navProvider, child) {
            // Nếu có target tab, chuyển đến tab đó
            if (navProvider.targetTabIndex != null && 
                navProvider.targetTabIndex != _selectedIndex) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _selectedIndex = navProvider.targetTabIndex!;
                });
              });
            }
            
            return Scaffold(
              body: _screens[_selectedIndex],
              bottomNavigationBar: BottomNavigationBar(
                items: _navItems,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Theme.of(context).primaryColor,
                unselectedItemColor: Colors.grey[600],
                showUnselectedLabels: true,
                backgroundColor: Colors.white,
                elevation: 5,
              ),
            );
          },
        );
      },
    );
  }
}