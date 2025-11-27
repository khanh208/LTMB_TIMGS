import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../schedule/models/schedule_event_model.dart';
import '../../../core/models/review_model.dart';

class TutorDashboardScreen extends StatefulWidget {
  const TutorDashboardScreen({super.key});

  @override
  State<TutorDashboardScreen> createState() => _TutorDashboardScreenState();
}

class _TutorDashboardScreenState extends State<TutorDashboardScreen> {
  final ApiService _apiService = ApiService();
  List<ScheduleEventModel> _upcomingSchedules = [];
  bool _isLoadingSchedules = false;
  
  List<ReviewModel> _reviews = [];
  bool _isLoadingReviews = false;

  @override
  void initState() {
    super.initState();
    _loadUpcomingSchedules();
    _loadReviews(); 
  }

  Future<void> _loadUpcomingSchedules() async {
    setState(() {
      _isLoadingSchedules = true;
    });

    try {
      final schedulesData = await _apiService.getSchedules();
      
      if (mounted) {
        final now = DateTime.now();
        final upcoming = schedulesData
            .map((json) => ScheduleEventModel.fromJson(json))
            .where((schedule) => schedule.startTime.isAfter(now))
            .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));

        setState(() {
          _upcomingSchedules = upcoming.take(3).toList(); 
          _isLoadingSchedules = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSchedules = false;
          _upcomingSchedules = [];
        });
        
        debugPrint('⚠️ [Dashboard] Error loading schedules: $e');
      }
    }
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final tutorId = authProvider.user?.id;
      
      if (tutorId == null || tutorId.isEmpty) {
        setState(() {
          _isLoadingReviews = false;
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
              if (a.createdAt != null && b.createdAt != null) {
                return b.createdAt!.compareTo(a.createdAt!);
              }
              return 0;
            });
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
          _reviews = [];
        });
        
        debugPrint('⚠️ [Dashboard] Error loading reviews: $e');
      }
    }
  }

  Widget _buildPublicProfileSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/edit_tutor_profile');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Hồ sơ công khai",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Xem và chỉnh sửa hồ sơ của bạn",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tổng quan Tháng 11", 
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2, 
          shrinkWrap: true, 
          physics: const NeverScrollableScrollPhysics(), 
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/earnings_management');
              },
              child: _StatCard(
                title: "Doanh thu (VND)",
                value: "5,200,000",
                icon: Icons.attach_money,
                color: Colors.green,
              ),
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
              title: "Tin nhắn Chờ",
              value: "2", 
              icon: Icons.inbox,
              color: Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingSchedule(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Lịch học Sắp tới",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        if (_isLoadingSchedules)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_upcomingSchedules.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Chưa có lịch học sắp tới',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ..._upcomingSchedules.map((schedule) {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            final userRole = authProvider.userRole ?? 'student';
            final displayName = userRole == 'student' 
                ? schedule.tutorName 
                : schedule.studentName;
            
            return _SessionTile(
              title: "${userRole == 'student' ? 'Gia sư' : 'Học viên'}: $displayName",
              subtitle: "Môn: ${schedule.subjectName} - ${_formatScheduleTime(schedule)}",
              onTap: () {
                final navProvider = Provider.of<NavigationProvider>(context, listen: false);
                navProvider.navigateToScheduleTab(
                  selectDate: schedule.startTime,
                );
              },
            );
          }).toList(),
        
        if (!_isLoadingSchedules && _upcomingSchedules.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                final navProvider = Provider.of<NavigationProvider>(context, listen: false);
                navProvider.navigateToScheduleTab();
              },
              child: const Text("Xem tất cả lịch"),
            ),
          ),
      ],
    );
  }

  String _formatScheduleTime(ScheduleEventModel schedule) {
    final now = DateTime.now();
    final scheduleDate = schedule.startTime;
    final daysDiff = scheduleDate.difference(now).inDays;
    
    String dateStr;
    if (daysDiff == 0) {
      dateStr = 'Hôm nay';
    } else if (daysDiff == 1) {
      dateStr = 'Ngày mai';
    } else if (daysDiff == 2) {
      dateStr = 'Ngày kia';
    } else {
      dateStr = '${scheduleDate.day}/${scheduleDate.month}/${scheduleDate.year}';
    }
    
    final timeStr = '${scheduleDate.hour.toString().padLeft(2, '0')}:${scheduleDate.minute.toString().padLeft(2, '0')}';
    return '$dateStr, $timeStr';
  }

  Widget _buildNewReviews(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Đánh giá Mới",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (!_isLoadingReviews && _reviews.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/reviews_list');
                },
                child: const Text("Xem tất cả"),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (_isLoadingReviews)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Chưa có đánh giá nào',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ..._reviews.take(5).map((review) {
            return _ReviewTile(
              studentName: review.studentName,
              rating: review.rating,
              comment: review.comment,
              createdAt: review.createdAt,
            );
          }).toList(),
      ],
    );
  }

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
            _buildPublicProfileSection(context),
            const SizedBox(height: 24),
            
            _buildStatsGrid(context),
            const SizedBox(height: 24),

            _buildUpcomingSchedule(context),
            const SizedBox(height: 24),

            _buildNewReviews(context),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap; 

  const _StatCard({
    required this.title, 
    required this.value, 
    required this.icon, 
    required this.color,
    this.onTap, 
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Card(
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

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: cardContent,
      );
    }
    
    return cardContent;
  }
}

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

class _ReviewTile extends StatelessWidget {
  final String studentName;
  final int rating;
  final String comment;
  final String? createdAt; 

  const _ReviewTile({
    required this.studentName,
    required this.rating,
    required this.comment,
    this.createdAt, 
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
            if (createdAt != null) ...[
              const SizedBox(height: 4),
              Text(
                createdAt!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              comment,
              style: const TextStyle(fontStyle: FontStyle.italic),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}