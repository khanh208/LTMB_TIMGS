import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../../../core/providers/auth_provider.dart'; 
import '../../../core/providers/navigation_provider.dart';

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userRole = authProvider.userRole ?? 'student';
        
        // Xây dựng screens và navItems dựa trên role
        List<Widget> screens;
        List<BottomNavigationBarItem> navItems;
        
        if (userRole == 'student') {
          screens = const [
            HomeScreen(),
            MyScheduleScreen(),
            ChatListScreen(),
            MyProfileScreen(),
          ];
          navItems = const [
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
        } else {
          screens = const [
            TutorDashboardScreen(),
            MyScheduleScreen(),
            ChatListScreen(),
            MyProfileScreen(),
          ];
          navItems = const [
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
        
        return Consumer<NavigationProvider>(
          builder: (context, navProvider, child) {
            // Xử lý navigation từ provider
            if (navProvider.targetTabIndex != null && 
                navProvider.targetTabIndex != _selectedIndex) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _selectedIndex = navProvider.targetTabIndex!;
                });
                // Reset targetTabIndex sau khi đã xử lý
                navProvider.clearTargetTab();
              });
            }
            
            return Scaffold(
              body: _selectedIndex < screens.length 
                  ? screens[_selectedIndex] 
                  : screens[0],
              bottomNavigationBar: BottomNavigationBar(
                items: navItems,
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