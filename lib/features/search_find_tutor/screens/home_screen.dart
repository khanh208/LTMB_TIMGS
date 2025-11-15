// lib/features/search_find_tutor/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'search_screen.dart'; // Import màn hình search
import '../../profile/screens/tutor_profile_detail_screen.dart';
      
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // --- Hàm điều hướng (tạo 1 lần, dùng nhiều nơi) ---
  void _navigateToSearch(BuildContext context, {String? categoryKey}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(initialCategory: categoryKey),
      ),
    );
  }

  // --- Hàm Build Thanh Tìm kiếm "Giả" ---
  Widget _buildFakeSearchBar(BuildContext context) {
    return InkWell(
      onTap: () {
        // 1. Khi bấm vào thanh search "Giả"
        _navigateToSearch(context); // Gọi hàm điều hướng không có category
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text(
              "Tìm gia sư, môn học...",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Thanh tìm kiếm "Giả"
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _buildFakeSearchBar(context),
              ),
              
              // 2. --- DANH SÁCH DANH MỤC ĐẦY ĐỦ ---
              
              _HomeSection(
                title: "Đề xuất cho bạn",
                categoryKey: "recommended",
                onSeeMorePressed: (category) => _navigateToSearch(context, categoryKey: category),
              ),

              // --- MỤC MỚI BẠN VỪA THÊM ---
              _HomeSection(
                title: "Bảng xếp hạng Gia sư",
                categoryKey: "rankings",
                onSeeMorePressed: (category) => _navigateToSearch(context, categoryKey: category),
              ),
              // -----------------------------

              _HomeSection(
                title: "Gia sư Đánh giá cao",
                categoryKey: "top_rated",
                onSeeMorePressed: (category) => _navigateToSearch(context, categoryKey: category),
              ),

              _HomeSection(
                title: "Nhiều lượt đăng ký",
                categoryKey: "popular",
                onSeeMorePressed: (category) => _navigateToSearch(context, categoryKey: category),
              ),
              
              _HomeSection(
                title: "Mới trên MentorMatch",
                categoryKey: "new",
                onSeeMorePressed: (category) => _navigateToSearch(context, categoryKey: category),
              ),

              _HomeSection(
                title: "Gia sư Tin học",
                categoryKey: "tin_hoc",
                onSeeMorePressed: (category) => _navigateToSearch(context, categoryKey: category),
              ),

              _HomeSection(
                title: "Gia sư Ngoại ngữ",
                categoryKey: "ngoai_ngu",
                onSeeMorePressed: (category) => _navigateToSearch(context, categoryKey: category),
              ),

              // --- MỤC MỚI BẠN VỪA THÊM ---
              _HomeSection(
                title: "Kỹ năng mềm",
                categoryKey: "ky_nang_mem",
                onSeeMorePressed: (category) => _navigateToSearch(context, categoryKey: category),
              ),
              // -----------------------------

              _HomeSection(
                title: "Gia sư Phổ thông",
                categoryKey: "pho_thong",
                onSeeMorePressed: (category) => _navigateToSearch(context, categoryKey: category),
              ),

              _HomeSection(
                title: "Gia sư Tiểu học",
                categoryKey: "tieu_hoc",
                onSeeMorePressed: (category) => _navigateToSearch(context, categoryKey: category),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- (CÁC WIDGET BÊN DƯỚI NÀY GIỮ NGUYÊN) ---

// --- WIDGET CHO MỘT "MỤC LỚN" ---
class _HomeSection extends StatelessWidget {
  final String title;
  final String categoryKey;
  final Function(String) onSeeMorePressed;

  const _HomeSection({
    required this.title,
    required this.categoryKey,
    required this.onSeeMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Tiêu đề và Nút "Xem thêm"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => onSeeMorePressed(categoryKey),
                child: const Text("Xem thêm"),
              ),
            ],
          ),
        ),

        // 2. --- DANH SÁCH CUỘN NGANG (GRIDVIEW 2 HÀNG) ---
        SizedBox(
          height: 230, 
          child: GridView.builder(
            scrollDirection: Axis.horizontal, // Cuộn ngang
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 HÀNG (2 item trên dưới)
              mainAxisSpacing: 10,  
              crossAxisSpacing: 10, 
              childAspectRatio: (110 / 180), 
            ),
            itemCount: 8, // Giả lập 8 gia sư
            itemBuilder: (context, index) {
              return _TutorCardMini(index: index);
            },
          ),
        ),
        const SizedBox(height: 24), // Khoảng cách giữa các mục
      ],
    );
  }
}

// --- WIDGET CHO THẺ GIA SƯ THU NHỎ ---
class _TutorCardMini extends StatelessWidget {
  final int index;
  const _TutorCardMini({required this.index});

  @override
  Widget build(BuildContext context) {
    return InkWell( // 1. BỌC BẰNG INKWELL
      onTap: () {
        // 2. THÊM HÀNH ĐỘNG ONTAP
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TutorProfileDetailScreen(tutorId: 'id_gia_su_${index + 1}'), // (Truyền ID)
          ),
        );
      },  
      child: Container(
      width: 180, 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ]
      ),
      clipBehavior: Clip.antiAlias, 
      child: Row( 
        children: [
          // Ảnh (bên trái)
          Container(
            width: 80,
            height: double.infinity,
            color: Colors.grey[200],
            child: const Icon(Icons.person, size: 40, color: Colors.grey),
          ),
          
          // Thông tin (bên phải)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Gia sư ${index + 1}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Môn Tin học", // (Dữ liệu giả)
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text("4.9", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
    );
  }
}