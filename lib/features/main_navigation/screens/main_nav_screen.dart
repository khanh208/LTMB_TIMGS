// lib/features/main_navigation/screens/main_nav_screen.dart

import 'package:flutter/material.dart';
import '../../placeholder_screens.dart'; 
import '../../search_find_tutor/screens/home_screen.dart'; 
import '../../profile/screens/my_profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final String _userRole = 'student'; 

  late List<Widget> _screens;
  late List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();
    
    // --- CẤU HÌNH CHO HỌC VIÊN (ĐÃ THAY ĐỔI) ---
    if (_userRole == 'student') {
      _screens = const [
        HomeScreen(), 
        
        // !!! 1. THAY THẾ TAB THỨ 2 !!!
        MyCoursesScreenPlaceholder(), // Thay vì WishlistScreenPlaceholder()
        
        ChatScreenPlaceholder(),
        MyProfileScreen(),
      ];
      _navItems = const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), 
            activeIcon: Icon(Icons.home_filled), 
            label: "Trang chủ"
        ),

        // !!! 2. THAY THẾ TAB THỨ 2 !!!
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined), 
            activeIcon: Icon(Icons.calendar_month),
            label: "Lịch học" // Tên tab mới
        ),

        BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: "Tin nhắn"
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Hồ sơ"
        ),
      ];
    
    // --- CẤU HÌNH CHO GIA SƯ (Giữ nguyên) ---
    } else if (_userRole == 'tutor') {
      _screens = const [
        RequestsScreenPlaceholder(),
        TutorSchedulePlaceholder(),
        ChatScreenPlaceholder(),
        MyProfileScreen(),
      ];
      _navItems = const [
        BottomNavigationBarItem(
            icon: Icon(Icons.inbox_outlined), 
            activeIcon: Icon(Icons.inbox), 
            label: "Yêu cầu"
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: "Lịch dạy"
        ),
        // (Các tab còn lại giữ nguyên...)
        BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: "Tin nhắn"
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Hồ sơ"
        ),
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
  }
}