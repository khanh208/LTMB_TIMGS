// lib/features/profile/screens/tutor_profile_detail_screen.dart

import 'package:flutter/material.dart';

class TutorProfileDetailScreen extends StatefulWidget {
  // Chúng ta sẽ cần ID của gia sư để tải dữ liệu
  final String tutorId;

  const TutorProfileDetailScreen({super.key, required this.tutorId});

  @override
  State<TutorProfileDetailScreen> createState() => _TutorProfileDetailScreenState();
}

class _TutorProfileDetailScreenState extends State<TutorProfileDetailScreen> {
  bool _isFavorited = false; // (State giả lập cho nút "Lưu lại")

  // --- NÚT HÀNH ĐỘNG CHÍNH (GỬI YÊU CẦU) ---
  Widget _buildBottomActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12).copyWith(
        bottom: MediaQuery.of(context).viewInsets.bottom + 12, // An toàn
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // --- XỬ LÝ GỬI YÊU CẦU KẾT NỐI/ĐĂNG KÝ HỌC ---
          // (Hiển thị popup xác nhận, sau đó gửi request lên CSDL)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đã gửi yêu cầu kết nối!"))
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text("Gửi yêu cầu Kết nối", style: TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Thanh AppBar
      appBar: AppBar(
        title: const Text("Hồ sơ Gia sư"),
        actions: [
          // --- NÚT "LƯU LẠI" (YÊU THÍCH) ---
          IconButton(
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited ? Colors.red : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isFavorited = !_isFavorited;
                // (Xử lý logic lưu vào danh sách yêu thích)
              });
            },
          ),
        ],
      ),
      
      // Nút hành động chính
      bottomNavigationBar: _buildBottomActionButtons(),

      // Nội dung chi tiết
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. THÔNG TIN CƠ BẢN ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Gia sư Nguyễn Văn A", // (Tải từ CSDL)
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            SizedBox(width: 4),
                            Text("4.9", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(" (120 đánh giá)", style: TextStyle(fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(indent: 20, endIndent: 20),

            // --- 2. GIỚI THIỆU ---
            _buildSection(
              context,
              icon: Icons.info_outline,
              title: "Giới thiệu",
              content: const Text(
                "Đã có 5 năm kinh nghiệm luyện thi Đại học môn Toán. Cam kết... (Đây là phần bio/giới thiệu của gia sư)",
                style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
              ),
            ),

            // --- 3. MÔN HỌC ---
            _buildSection(
              context,
              icon: Icons.book_outlined,
              title: "Môn học & Kỹ năng",
              content: Wrap( // Dùng Wrap để hiển thị các tag
                spacing: 8,
                runSpacing: 8,
                children: const [
                  Chip(label: Text("Toán 12")),
                  Chip(label: Text("Luyện thi THPT")),
                  Chip(label: Text("Tin học")),
                  Chip(label: Text("Lập trình Flutter")),
                ],
              ),
            ),

            // --- 4. BẰNG CẤP (chưa có) ---
            // (Bạn sẽ thêm phần hiển thị ảnh bằng cấp ở đây)
            
            // --- 5. ĐÁNH GIÁ CỦA HỌC VIÊN ---
            _buildSection(
              context,
              icon: Icons.reviews_outlined,
              title: "Đánh giá từ Học viên",
              content: Column(
                children: [
                  // (Đây là item đánh giá giả lập)
                  _buildReviewItem(),
                  _buildReviewItem(),
                  TextButton(
                    onPressed: () { /* (Điều hướng đến màn hình xem tất cả đánh giá) */ },
                    child: const Text("Xem tất cả 120 đánh giá"),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Tái sử dụng cho các mục
  Widget _buildSection(BuildContext context, {required IconData icon, required String title, required Widget content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  // Widget giả lập cho 1 item đánh giá
  Widget _buildReviewItem() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              CircleAvatar(radius: 15, child: Icon(Icons.person, size: 16)),
              SizedBox(width: 8),
              Text("Trần Thị B", style: TextStyle(fontWeight: FontWeight.bold)),
              Spacer(),
              Icon(Icons.star, color: Colors.amber, size: 16),
              Text("5.0"),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Thầy dạy rất dễ hiểu, em tiến bộ rất nhanh!",
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }
}