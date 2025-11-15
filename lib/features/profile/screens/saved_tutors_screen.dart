// lib/features/profile/screens/saved_tutors_screen.dart

import 'package:flutter/material.dart';
import '../../profile/screens/tutor_profile_detail_screen.dart'; // Import để điều hướng

class SavedTutorsScreen extends StatefulWidget {
  const SavedTutorsScreen({super.key});

  @override 
  State<SavedTutorsScreen> createState() => _SavedTutorsScreenState();
}

class _SavedTutorsScreenState extends State<SavedTutorsScreen> {
  // --- DỮ LIỆU TẠM THỜI (MOCK DATA) ---
  // Bạn sẽ lấy danh sách này từ CSDL (ví dụ: danh sách ID gia sư đã lưu)
  final List<Map<String, String>> _savedTutors = [
    {
      'id': 'tutor_01',
      'name': 'Gia sư Nguyễn Văn A',
      'specialties': 'Toán 12, Luyện thi THPT',
    },
    {
      'id': 'tutor_02',
      'name': 'Gia sư Trần Thị B',
      'specialties': 'Tiếng Anh Giao tiếp, IELTS 7.0',
    },
  ];

  // Hàm (giả lập) bỏ yêu thích
  void _removeFavorite(String tutorId) {
    setState(() {
      _savedTutors.removeWhere((tutor) => tutor['id'] == tutorId);
      // (Xử lý logic CSDL ở đây)
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã xóa khỏi danh sách đã lưu.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gia sư đã lưu"),
      ),
      body: _savedTutors.isEmpty
          ? _buildEmptyState() // Hiển thị nếu danh sách rỗng
          : _buildTutorList(), // Hiển thị danh sách
    );
  }

  // Widget khi danh sách rỗng
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Chưa có gia sư nào",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          const Text(
            "Hãy bấm vào biểu tượng trái tim\ntrên hồ sơ gia sư để lưu lại.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Widget khi có danh sách
  Widget _buildTutorList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _savedTutors.length,
      itemBuilder: (context, index) {
        final tutor = _savedTutors[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: ListTile(
            leading: const CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(tutor['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(tutor['specialties']!),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              tooltip: "Bỏ lưu",
              onPressed: () => _removeFavorite(tutor['id']!),
            ),
            onTap: () {
              // Điều hướng đến trang chi tiết của gia sư đó
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TutorProfileDetailScreen(tutorId: tutor['id']!),
                ),
              );
            },
          ),
        );
      },
    );
  }
}