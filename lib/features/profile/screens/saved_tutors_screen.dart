// lib/features/profile/screens/saved_tutors_screen.dart

import 'package:flutter/material.dart';
import '../../profile/screens/tutor_profile_detail_screen.dart';
import '../../../core/services/api_service.dart'; // <-- THÊM
import '../../../core/models/tutor_model.dart'; // <-- THÊM
import '../../../core/utils/error_handler.dart'; // <-- THÊM
import '../../../core/widgets/avatar_widget.dart'; // <-- THÊM

class SavedTutorsScreen extends StatefulWidget {
  const SavedTutorsScreen({super.key});

  @override 
  State<SavedTutorsScreen> createState() => _SavedTutorsScreenState();
}

class _SavedTutorsScreenState extends State<SavedTutorsScreen> {
  final ApiService _apiService = ApiService();
  List<TutorModel> _savedTutors = []; // <-- THAY ĐỔI: Dùng TutorModel
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadSavedTutors();
  }

  Future<void> _loadSavedTutors() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final tutorsData = await _apiService.getSavedTutors();
      
      if (mounted) {
        setState(() {
          _savedTutors = tutorsData
              .map((json) => TutorModel.fromJson(json))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _savedTutors = [];
        });
        
        ErrorHandler.showErrorDialogFromException(
          context,
          e,
          onRetry: _loadSavedTutors,
        );
      }
    }
  }

  Future<void> _removeFavorite(String tutorId) async {
    try {
      await _apiService.toggleSavedTutor(tutorId, isSaved: true); // isSaved: true = remove
      
      if (mounted) {
        setState(() {
          _savedTutors.removeWhere((tutor) => tutor.userId == tutorId);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đã xóa khỏi danh sách đã lưu."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorDialogFromException(
          context,
          e,
          onRetry: () => _removeFavorite(tutorId),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gia sư đã lưu"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError || _savedTutors.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadSavedTutors,
                  child: _buildTutorList(),
                ),
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
            _hasError ? "Không thể tải danh sách" : "Chưa có gia sư nào",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            _hasError 
                ? "Vui lòng thử lại"
                : "Hãy bấm vào biểu tượng trái tim\n trên hồ sơ gia sư để lưu lại.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          if (_hasError) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSavedTutors,
              child: const Text('Thử lại'),
            ),
          ],
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
            leading: AvatarWidget(
              avatarUrl: tutor.avatarUrl,
              radius: 25,
            ),
            title: Text(
              tutor.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tutor.bio != null)
                  Text(
                    tutor.bio!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(tutor.ratingValue.toStringAsFixed(1)),
                    const SizedBox(width: 16),
                    Text(
                      tutor.formattedPrice,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              tooltip: "Bỏ lưu",
              onPressed: () => _removeFavorite(tutor.userId),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TutorProfileDetailScreen(tutorId: tutor.userId),
                ),
              );
            },
          ),
        );
      },
    );
  }
}