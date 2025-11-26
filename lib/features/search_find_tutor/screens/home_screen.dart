// lib/features/search_find_tutor/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'search_screen.dart';
import '../../profile/screens/tutor_profile_detail_screen.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/tutor_model.dart';
import '../../../core/utils/error_handler.dart';
import 'dart:io'; // <-- THÊM
import 'dart:convert'; // <-- Đã có rồi
import '../../../core/widgets/avatar_image_helper.dart'; // <-- THÊM

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Keys để reload từng section
  final Map<String, GlobalKey<_HomeSectionState>> _sectionKeys = {};

  @override
  void initState() {
    super.initState();
    // Tạo keys cho các sections
    _sectionKeys['recommended'] = GlobalKey<_HomeSectionState>();
    _sectionKeys['rankings'] = GlobalKey<_HomeSectionState>();
    _sectionKeys['top_rated'] = GlobalKey<_HomeSectionState>();
    _sectionKeys['popular'] = GlobalKey<_HomeSectionState>();
    _sectionKeys['new'] = GlobalKey<_HomeSectionState>();
    _sectionKeys['tin_hoc'] = GlobalKey<_HomeSectionState>();
    _sectionKeys['ngoai_ngu'] = GlobalKey<_HomeSectionState>();
    _sectionKeys['ky_nang_mem'] = GlobalKey<_HomeSectionState>();
    _sectionKeys['pho_thong'] = GlobalKey<_HomeSectionState>();
    _sectionKeys['tieu_hoc'] = GlobalKey<_HomeSectionState>();
  }

  // --- Hàm điều hướng ---
  void _navigateToSearch(BuildContext context, {String? categoryKey}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(initialCategory: categoryKey),
      ),
    );
  }

  // --- Hàm Build Thanh Tìm kiếm ---
  Widget _buildFakeSearchBar(BuildContext context) {
    return InkWell(
      onTap: () {
        _navigateToSearch(context);
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

  // Hàm reload tất cả sections
  Future<void> _refreshAllSections() async {
    // Reload tất cả các sections
    for (var key in _sectionKeys.values) {
      key.currentState?.reload();
    }
    // Đợi một chút để các API calls hoàn thành
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshAllSections,
          displacement: 20, // <-- THÊM: Giảm khoảng cách
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics( // <-- THAY ĐỔI: Từ AlwaysScrollableScrollPhysics
              parent: AlwaysScrollableScrollPhysics(), // <-- Cho phép scroll luôn
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Thanh tìm kiếm
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _buildFakeSearchBar(context),
                ),
                
                // 2. Danh sách sections
                _HomeSection(
                  key: _sectionKeys['recommended'],
                  title: "Đề xuất cho bạn",
                  categoryKey: null,
                  onSeeMorePressed: (category) => _navigateToSearch(context, categoryKey: category),
                ),

                _HomeSection(
                  key: _sectionKeys['rankings'],
                  title: "Bảng xếp hạng Gia sư",
                  categoryKey: null,
                  onSeeMorePressed: (category) => _navigateToSearch(context, categoryKey: category),
                ),

                _HomeSection(
                  key: _sectionKeys['top_rated'],
                  title: "Gia sư Đánh giá cao",
                  categoryKey: null,
                  onSeeMorePressed: (category) => _navigateToSearch(context, categoryKey: category),
                ),

                _HomeSection(
                  key: _sectionKeys['popular'],
                  title: "Nhiều lượt đăng ký",
                  categoryKey: null,
                  onSeeMorePressed: (category) => _navigateToSearch(context, categoryKey: category),
                ),
                
                _HomeSection(
                  key: _sectionKeys['new'],
                  title: "Mới trên MentorMatch",
                  categoryKey: null,
                  onSeeMorePressed: (category) => _navigateToSearch(context, categoryKey: category),
                ),

                _HomeSection(
                  key: _sectionKeys['tin_hoc'],
                  title: "Gia sư Tin học",
                  categoryKey: "tin_hoc",
                  onSeeMorePressed: (category) => _navigateToSearch(context, categoryKey: category),
                ),

                _HomeSection(
                  key: _sectionKeys['ngoai_ngu'],
                  title: "Gia sư Ngoại ngữ",
                  categoryKey: "ngoai_ngu",
                  onSeeMorePressed: (category) => _navigateToSearch(context, categoryKey: category),
                ),

                _HomeSection(
                  key: _sectionKeys['ky_nang_mem'],
                  title: "Kỹ năng mềm",
                  categoryKey: "ky_nang_mem",
                  onSeeMorePressed: (category) => _navigateToSearch(context, categoryKey: category),
                ),

                _HomeSection(
                  key: _sectionKeys['pho_thong'],
                  title: "Gia sư Phổ thông",
                  categoryKey: "pho_thong",
                  onSeeMorePressed: (category) => _navigateToSearch(context, categoryKey: category),
                ),

                _HomeSection(
                  key: _sectionKeys['tieu_hoc'],
                  title: "Gia sư Tiểu học",
                  categoryKey: "tieu_hoc",
                  onSeeMorePressed: (category) => _navigateToSearch(context, categoryKey: category),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- WIDGET CHO MỘT "MỤC LỚN" ---
class _HomeSection extends StatefulWidget {
  final String title;
  final String? categoryKey;
  final Function(String?) onSeeMorePressed;

  const _HomeSection({
    super.key,
    required this.title,
    this.categoryKey,
    required this.onSeeMorePressed,
  });

  @override
  State<_HomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends State<_HomeSection> {
  final ApiService _apiService = ApiService();
  List<TutorModel> _tutors = [];
  bool _isLoading = true;
  bool _hasError = false; // <-- Đổi từ String? _error sang bool _hasError

  @override
  void initState() {
    super.initState();
    _loadTutors();
  }

  Future<void> _loadTutors() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final tutorsData = await _apiService.getTutors(
        category: widget.categoryKey,
      );
      
      if (mounted) {
        setState(() {
          _tutors = tutorsData.map((json) => TutorModel.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _tutors = []; // Hiển thị empty state
        });
        
        // Hiển thị popup thông báo lỗi
        ErrorHandler.showErrorDialogFromException(
          context,
          e,
          onRetry: _loadTutors,
        );
      }
    }
  }

  // Method để reload từ bên ngoài (được gọi từ RefreshIndicator)
  void reload() {
    _loadTutors();
  }

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
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => widget.onSeeMorePressed(widget.categoryKey),
                child: const Text("Xem thêm"),
              ),
            ],
          ),
        ),

        // 2. --- DANH SÁCH CUỘN NGANG (GRIDVIEW 2 HÀNG) ---
        SizedBox(
          height: 230,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _tutors.isEmpty
                  ? const Center(
                      child: Text(
                        'Không có gia sư nào',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: (110 / 180),
                      ),
                      itemCount: _tutors.length > 8 ? 8 : _tutors.length,
                      itemBuilder: (context, index) {
                        return _TutorCardMini(tutor: _tutors[index]);
                      },
                    ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// --- WIDGET CHO THẺ GIA SƯ THU NHỎ ---
class _TutorCardMini extends StatelessWidget {
  final TutorModel tutor;
  
  const _TutorCardMini({required this.tutor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TutorProfileDetailScreen(tutorId: tutor.userId),
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
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Ảnh (bên trái) - CẬP NHẬT
            Container(
              width: 80,
              height: double.infinity,
              color: Colors.grey[200],
              child: tutor.avatarUrl != null && AvatarImageHelper.getImageProvider(tutor.avatarUrl) != null
                  ? Image(
                      image: AvatarImageHelper.getImageProvider(tutor.avatarUrl)!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, size: 40, color: Colors.grey);
                      },
                    )
                  : const Icon(Icons.person, size: 40, color: Colors.grey),
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
                      tutor.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tutor.bio != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        tutor.bio!,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          tutor.ratingValue.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}