  // lib/features/dashboard/screens/tutor_dashboard_screen.dart

import 'package:flutter/material.dart';

class TutorDashboardScreen extends StatelessWidget {
  const TutorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Quản lý"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Lưới Thống kê Nhanh
            _buildStatsGrid(context),
            const SizedBox(height: 24),

            // 2. Lịch học Sắp tới
            _buildUpcomingSchedule(context),
            const SizedBox(height: 24),

            // 3. Đánh giá Mới
            _buildNewReviews(context),
          ],
        ),
      ),
    );
  }

  // --- Widget Lưới Thống kê ---
  Widget _buildStatsGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tổng quan Tháng 11", // (Lấy tháng hiện tại)
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Dùng GridView để hiển thị 2 cột
        GridView.count(
          crossAxisCount: 2, // 2 cột
          shrinkWrap: true, // Để GridView không chiếm toàn bộ màn hình
          physics: const NeverScrollableScrollPhysics(), // Tắt cuộn của GridView
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _StatCard(
              title: "Doanh thu (VND)",
              value: "5,200,000",
              icon: Icons.attach_money,
              color: Colors.green,
            ),
            _StatCard(
              title: "Học viên Mới",
              value: "3",
              icon: Icons.person_add_alt_1,
              color: Colors.blue,
            ),
            _StatCard(
              title: "Buổi học Hoàn thành",
              value: "22",
              icon: Icons.check_circle,
              color: Colors.orange,
            ),
            _StatCard(
              title: "Yêu cầu Chờ",
              value: "2", // Lấy từ tab Yêu cầu
              icon: Icons.inbox,
              color: Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  // --- Widget Lịch học Sắp tới ---
  Widget _buildUpcomingSchedule(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Lịch học Sắp tới",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // (Đây là dữ liệu giả, bạn sẽ lấy từ CSDL)
        _SessionTile(
          title: "Học viên: Lê Văn A",
          subtitle: "Môn: Toán 12 - (Hôm nay, 19:00)",
          onTap: () { /* (Điều hướng đến chi tiết lịch) */ },
        ),
        _SessionTile(
          title: "Học viên: Trần Thị B",
          subtitle: "Môn: Tiếng Anh - (Ngày mai, 18:00)",
          onTap: () { /* (Điều hướng đến chi tiết lịch) */ },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () { /* (Điều hướng đến Tab Lịch Dạy) */ },
            child: const Text("Xem tất cả lịch"),
          ),
        ),
      ],
    );
  }
  
  // --- Widget Đánh giá Mới ---
  Widget _buildNewReviews(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Đánh giá Mới",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // (Dữ liệu giả)
        _ReviewTile(
          studentName: "Nguyễn Văn C",
          rating: 5,
          comment: "Thầy dạy rất dễ hiểu!",
        ),
      ],
    );
  }
}

// --- Widget Card Thống kê ---
class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: color),
            const Spacer(),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// --- Widget Tile Lịch học (Giả) ---
class _SessionTile extends StatelessWidget {
  final String title, subtitle;
  final VoidCallback onTap;
  const _SessionTile({required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.calendar_today)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
    );
  }
}

// --- Widget Tile Đánh giá (Giả) ---
class _ReviewTile extends StatelessWidget {
  final String studentName;
  final int rating;
  final String comment;
  const _ReviewTile({required this.studentName, required this.rating, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              const Icon(Icons.star, color: Colors.amber, size: 16),
              Text("$rating.0")
            ]),
            const SizedBox(height: 8),
            Text(comment, style: const TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}