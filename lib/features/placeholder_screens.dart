// lib/features/placeholder_screens.dart
// File này chứa các màn hình giả lập cho các tab

import 'package:flutter/material.dart';

class SearchScreenPlaceholder extends StatelessWidget {
  const SearchScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Tab Tìm kiếm (Học viên)"));
  }
}

class MyCoursesScreenPlaceholder extends StatelessWidget {
  const MyCoursesScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Lịch học đã đăng kí với gia sư (Học viên)"));
  }
}

class RequestsScreenPlaceholder extends StatelessWidget {
  const RequestsScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Tab Yêu cầu (Gia sư)"));
  }
}

class TutorSchedulePlaceholder extends StatelessWidget {
  const TutorSchedulePlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Tab Lịch dạy (Gia sư)"));
  }
}

class ChatScreenPlaceholder extends StatelessWidget {
  const ChatScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Tab Tin nhắn (Dùng chung)"));
  }
}

class ProfileScreenPlaceholder extends StatelessWidget {
  const ProfileScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Tab Hồ sơ (Dùng chung)"));
  }
}