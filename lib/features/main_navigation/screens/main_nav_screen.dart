// lib/features/main_navigation/screens/main_nav_screen.dart

import 'package:flutter/material.dart';

// Import các màn hình CHÍNH
import '../../search_find_tutor/screens/home_screen.dart';
import '../../schedule/screens/my_schedule_screen.dart';
import '../../profile/screens/my_profile_screen.dart';
import '../../chat/screens/chat_list_screen.dart';
import '../../requests/screens/requests_screen.dart';
// Import các màn hình PLACEHOLDER (tạm thời) 
import '../../placeholder_screens.dart'; 

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});  

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // (Giả lập vai trò, sau này bạn sẽ lấy từ state management)
  // Hãy thử đổi 'student' thành 'tutor' để kiểm tra
  final String _userRole = 'student'; 

  late List<Widget> _screens;
  late List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();
    
    // --- CẤU HÌNH CHO HỌC VIÊN ---
    if (_userRole == 'student') {
      _screens = const [
        HomeScreen(),            // Tab 1: Trang chủ (thay cho Tìm kiếm)
        MyScheduleScreen(),      // Tab 2: Lịch học (thay cho Yêu thích)
        ChatListScreen(),       // Tab 3: Tin nhắn (tạm thời)
        MyProfileScreen(),       // Tab 4: Hồ sơ (đã cập nhật)
      ];
      _navItems = const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), 
            activeIcon: Icon(Icons.home_filled),  
            label: "Trang chủ"
        ),
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
    
    // --- CẤU HÌNH CHO GIA SƯ ---
    } else if (_userRole == 'tutor') {
      _screens = const [
        RequestsScreen(), // Tab 1: Yêu cầu (tạm thời)
        MyScheduleScreen(),          // Tab 2: Lịch dạy (đã cập nhật)
        ChatListScreen(),     // Tab 3: Tin nhắn (tạm thời)
        MyProfileScreen(),           // Tab 4: Hồ sơ (đã cập nhật)
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

  // Hàm cập nhật tab được chọn
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Giao diện
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Hiển thị màn hình tương ứng với tab đã chọn
      body: _screens[_selectedIndex],
      
      // Thanh điều hướng dưới cùng
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        
        // Cài đặt quan trọng để thanh nav bar cố định
        type: BottomNavigationBarType.fixed, 
        selectedItemColor: Theme.of(context).primaryColor, // Màu khi chọn
        unselectedItemColor: Colors.grey[600], // Màu khi không chọn
        showUnselectedLabels: true, // Luôn hiển thị chữ
        backgroundColor: Colors.white,
        elevation: 5, // Đổ bóng nhẹ
      ),
    );
  }
}