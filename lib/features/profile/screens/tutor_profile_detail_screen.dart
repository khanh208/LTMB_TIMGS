// lib/features/profile/screens/tutor_profile_detail_screen.dart

import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/tutor_detail_model.dart';
import '../../../core/models/review_model.dart';
import '../../../core/models/subject_model.dart';
import '../../../core/utils/error_handler.dart'; // <-- THÊM
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/avatar_widget.dart'; // <-- THÊM

class TutorProfileDetailScreen extends StatefulWidget {
  final String tutorId;

  const TutorProfileDetailScreen({super.key, required this.tutorId});

  @override
  State<TutorProfileDetailScreen> createState() => _TutorProfileDetailScreenState();
}

class _TutorProfileDetailScreenState extends State<TutorProfileDetailScreen> {
  final ApiService _apiService = ApiService();
  
  TutorDetailModel? _tutorDetail;
  bool _isLoading = true;
  bool _isFavorited = false; // (Sẽ implement với API saved-tutors sau)
  bool _hasError = false; // <-- Đổi từ String? _error

  @override
  void initState() {
    super.initState();
    _loadTutorDetail();
    _checkIfFavorited(); // <-- THÊM: Kiểm tra xem đã lưu chưa
  }

  // THÊM MỚI: Kiểm tra xem gia sư đã được lưu chưa
  Future<void> _checkIfFavorited() async {
    try {
      final isSaved = await _apiService.isTutorSaved(widget.tutorId);
      if (mounted) {
        setState(() {
          _isFavorited = isSaved;
        });
      }
    } catch (e) {
      debugPrint('⚠️ [TutorDetail] Error checking saved status: $e');
      // Không hiển thị lỗi, chỉ log
    }
  }

  Future<void> _loadTutorDetail() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final tutorData = await _apiService.getTutorDetail(widget.tutorId);
      
      if (mounted) {
        setState(() {
          _tutorDetail = TutorDetailModel.fromJson(tutorData);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        
        // Hiển thị popup thông báo lỗi
        ErrorHandler.showErrorDialogFromException(
          context,
          e,
          onRetry: _loadTutorDetail,
        );
      }
    }
  }

  // --- NÚT HÀNH ĐỘNG CHÍNH (GỬI YÊU CẦU) ---
  Widget _buildBottomActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12).copyWith(
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
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
          _showConnectionRequestDialog();
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

  // --- POPUP GỬI YÊU CẦU KẾT NỐI ---
  Future<void> _showConnectionRequestDialog() async {
    final TextEditingController messageController = TextEditingController();
    bool isSending = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Gửi yêu cầu kết nối',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nhập tin nhắn cho gia sư:',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: messageController,
                      enabled: !isSending,
                      maxLines: 8, // <-- TEXT INPUT TO
                      minLines: 6, // <-- TEXT INPUT TO
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: Em muốn học Lập trình Flutter, thầy còn slot không ạ?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      autofocus: true,
                    ),
                  ],
                ),
              ),
              actions: [
                if (isSending)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        child: const Text('Hủy'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final message = messageController.text.trim();
                          if (message.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('Vui lòng nhập tin nhắn'),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isSending = true;
                          });

                          try {
                            // Gửi yêu cầu kết nối
                            await _apiService.sendConnectionRequest(
                              widget.tutorId,
                              message,
                            );

                            if (mounted) {
                              Navigator.of(dialogContext).pop();
                              
                              // Hiển thị thông báo thành công
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã gửi yêu cầu kết nối!'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );

                              // TODO: Có thể cần reload chat rooms để đồng bộ tin nhắn
                              // Nếu có callback hoặc provider để refresh chat list
                            }
                          } catch (e) {
                            setDialogState(() {
                              isSending = false;
                            });

                            if (mounted) {
                              ErrorHandler.showErrorDialogFromException(
                                dialogContext,
                                e,
                                onRetry: () async {
                                  // Retry logic
                                  setDialogState(() {
                                    isSending = true;
                                  });
                                  try {
                                    await _apiService.sendConnectionRequest(
                                      widget.tutorId,
                                      messageController.text.trim(),
                                    );
                                    if (mounted) {
                                      Navigator.of(dialogContext).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Đã gửi yêu cầu kết nối!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (retryError) {
                                    setDialogState(() {
                                      isSending = false;
                                    });
                                  }
                                },
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Gửi'),
                      ),
                    ],
                  ),
              ],
            );
          },
        );
      },
    );
  }

  // THÊM MỚI: Toggle favorite
  Future<void> _toggleFavorite() async {
    final wasFavorited = _isFavorited;
    
    // Optimistic update
    setState(() {
      _isFavorited = !_isFavorited;
    });

    try {
      await _apiService.toggleSavedTutor(
        widget.tutorId,
        isSaved: wasFavorited, // Nếu đã favorite thì remove, chưa thì add
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              wasFavorited 
                  ? "Đã xóa khỏi danh sách đã lưu"
                  : "Đã lưu gia sư",
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Rollback nếu có lỗi
      if (mounted) {
        setState(() {
          _isFavorited = wasFavorited;
        });

        ErrorHandler.showErrorDialogFromException(
          context,
          e,
          onRetry: _toggleFavorite,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError || _tutorDetail == null) {
      // Hiển thị giao diện mặc định (empty state)
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết Gia sư')),
        body: const Center(
          child: Text(
            'Không thể tải thông tin gia sư',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ sơ Gia sư"),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited ? Colors.red : Colors.grey,
            ),
            onPressed: _toggleFavorite, // <-- CẬP NHẬT: Gọi method mới
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionButtons(),
      body: _tutorDetail == null
          ? const Center(child: Text('Không tìm thấy thông tin gia sư'))
          : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- 1. THÔNG TIN CƠ BẢN ---
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                AvatarWidget( // <-- THAY THẾ CircleAvatar
                                  avatarUrl: _tutorDetail!.avatarUrl,
                                  radius: 40,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _tutorDetail!.fullName,
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (_tutorDetail!.isVerified)
                                            const Icon(
                                              Icons.verified,
                                              color: Colors.blue,
                                              size: 20,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 20),
                                          const SizedBox(width: 4),
                                          Text(
                                            _tutorDetail!.ratingValue.toStringAsFixed(1),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            " (${_tutorDetail!.reviewCount} đánh giá)",
                                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _tutorDetail!.formattedPrice,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(indent: 20, endIndent: 20),

                          // --- 2. GIỚI THIỆU ---
                          if (_tutorDetail!.bio != null && _tutorDetail!.bio!.isNotEmpty)
                            _buildSection(
                              context,
                              icon: Icons.info_outline,
                              title: "Giới thiệu",
                              content: Text(
                                _tutorDetail!.bio!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.5,
                                  color: Colors.black87,
                                ),
                              ),
                            ),

                          // --- 3. MÔN HỌC ---
                          if (_tutorDetail!.subjects.isNotEmpty)
                            _buildSection(
                              context,
                              icon: Icons.book_outlined,
                              title: "Môn học & Kỹ năng",
                              content: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _tutorDetail!.subjects.map((subject) {
                                  return Chip(
                                    label: Text(subject.name),
                                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                    labelStyle: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                          // --- 4. BẰNG CẤP (chưa có trong API) ---
                          // (Sẽ thêm sau nếu API có)

                          // --- 5. ĐÁNH GIÁ CỦA HỌC VIÊN ---
                          if (_tutorDetail!.reviews.isNotEmpty)
                            _buildSection(
                              context,
                              icon: Icons.reviews_outlined,
                              title: "Đánh giá từ Học viên",
                              content: Column(
                                children: [
                                  // Hiển thị tối đa 3 reviews đầu tiên
                                  ..._tutorDetail!.reviews.take(3).map((review) {
                                    return _buildReviewItem(review);
                                  }),
                                  if (_tutorDetail!.reviews.length > 3)
                                    TextButton(
                                      onPressed: () {
                                        // (Điều hướng đến màn hình xem tất cả đánh giá)
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Xem tất cả ${_tutorDetail!.reviewCount} đánh giá',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text("Xem tất cả ${_tutorDetail!.reviewCount} đánh giá"),
                                    ),
                                ],
                              ),
                            )
                          else
                            _buildSection(
                              context,
                              icon: Icons.reviews_outlined,
                              title: "Đánh giá từ Học viên",
                              content: const Text(
                                "Chưa có đánh giá nào",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                        ],
                      ),
                    ),
    );
  }

  // Widget Tái sử dụng cho các mục
  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget content,
  }) {
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

  // Widget cho 1 item đánh giá
  Widget _buildReviewItem(ReviewModel review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 15, child: Icon(Icons.person, size: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  review.studentName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(review.rating.toString()),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: const TextStyle(color: Colors.black87),
          ),
          if (review.createdAt != null) ...[
            const SizedBox(height: 4),
            Text(
              review.createdAt!,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }
}