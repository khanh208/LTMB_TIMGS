// lib/features/profile/screens/reviews_list_screen.dart

import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/review_model.dart';
import '../../../core/utils/error_handler.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';

class ReviewsListScreen extends StatefulWidget {
  const ReviewsListScreen({super.key});

  @override
  State<ReviewsListScreen> createState() => _ReviewsListScreenState();
}

class _ReviewsListScreenState extends State<ReviewsListScreen> {
  final ApiService _apiService = ApiService();
  List<ReviewModel> _reviews = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Lấy tutorId từ AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final tutorId = authProvider.user?.id;
      
      if (tutorId == null || tutorId.isEmpty) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _reviews = [];
        });
        return;
      }

      final reviewsData = await _apiService.getMyReviews(tutorId);
      
      if (mounted) {
        setState(() {
          _reviews = reviewsData
              .map((json) => ReviewModel.fromJson(json))
              .toList()
            ..sort((a, b) {
              // Sắp xếp theo thời gian tạo (mới nhất trước)
              if (a.createdAt != null && b.createdAt != null) {
                return b.createdAt!.compareTo(a.createdAt!);
              }
              return 0;
            });
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _reviews = [];
        });
        
        ErrorHandler.showErrorDialogFromException(
          context,
          e,
          onRetry: _loadReviews,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tất cả đánh giá"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError || _reviews.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.reviews_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _hasError 
                            ? 'Không thể tải đánh giá'
                            : 'Chưa có đánh giá nào',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (_hasError) ...[
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadReviews,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReviews,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reviews.length,
                    itemBuilder: (context, index) {
                      final review = _reviews[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey[300],
                                    child: const Icon(Icons.person, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          review.studentName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (review.createdAt != null)
                                          Text(
                                            review.createdAt!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 20),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${review.rating}.0',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                review.comment,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}