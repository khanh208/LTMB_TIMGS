
import 'package:flutter/material.dart';
import 'search_screen.dart';
import 'dart:math';
import '../../profile/screens/tutor_profile_detail_screen.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/tutor_model.dart';
import '../../../core/utils/error_handler.dart';
import 'dart:io'; 
import 'dart:convert'; 
import '../../../core/widgets/avatar_image_helper.dart'; 
import 'package:provider/provider.dart'; 
import '../../../core/providers/auth_provider.dart'; 
import '../../schedule/models/schedule_event_model.dart'; 
import '../../schedule/screens/proposal_detail_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<String, GlobalKey<_HomeSectionState>> _sectionKeys = {};

  Map<String, List<ScheduleEventModel>> _pendingPaymentProposals = {};
  bool _isLoadingProposals = false;
  final ApiService _apiService = ApiService(); 

  @override
  void initState() {
    super.initState();
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
    
    _loadPendingPaymentProposals();
  }

  void _navigateToSearch(BuildContext context, {String? categoryKey}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(initialCategory: categoryKey),
      ),
    );
  }

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

  Future<void> _refreshAllSections() async {
    _loadPendingPaymentProposals();
    
    for (var key in _sectionKeys.values) {
      key.currentState?.reload();
    }
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _loadPendingPaymentProposals() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userRole = authProvider.userRole;
    
    if (userRole != 'student') return;

    setState(() {
      _isLoadingProposals = true;
    });

    try {
      final schedulesData = await _apiService.getSchedules();
      
      debugPrint('📋 [Home] Total schedules from API: ${schedulesData.length}');
      
      if (mounted) {
        final pendingPaymentSchedules = schedulesData
            .map((json) => ScheduleEventModel.fromJson(json))
            .where((schedule) => schedule.status == 'pending_payment')
            .toList();

        debugPrint('📋 [Home] Pending payment schedules count: ${pendingPaymentSchedules.length}');

        final Map<String, List<ScheduleEventModel>> groupedProposals = {};
        for (var schedule in pendingPaymentSchedules) {
          final groupId = schedule.bookingGroupId ?? 'unknown_${schedule.scheduleId}';
          if (!groupedProposals.containsKey(groupId)) {
            groupedProposals[groupId] = [];
          }
          groupedProposals[groupId]!.add(schedule);
        }

        debugPrint('📋 [Home] Grouped proposals count: ${groupedProposals.length}');

        setState(() {
          _pendingPaymentProposals = groupedProposals;
          _isLoadingProposals = false;
        });
      }
    } catch (e) {
      debugPrint('❌ [Home] Error loading pending proposals: $e');
      if (mounted) {
        setState(() {
          _isLoadingProposals = false;
        });
      }
    }
  }

  void _navigateToProposalDetail(ScheduleEventModel schedule) {
    if (schedule.bookingGroupId == null || schedule.bookingGroupId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy thông tin đề xuất'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProposalDetailScreen(
          groupId: schedule.bookingGroupId!,
        ),
      ),
    ).then((reload) {
      if (reload == true) {
        _loadPendingPaymentProposals();
      }
    });
  }

  Widget _buildPendingPaymentSection() {
    if (_isLoadingProposals) {
      return Container(
        color: Colors.orange.shade50,
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_pendingPaymentProposals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.orange.shade50,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.payment, color: Colors.orange, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Đề xuất chờ thanh toán',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_pendingPaymentProposals.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...(_pendingPaymentProposals.entries.take(3).map((entry) {
            final schedules = entry.value;
            final firstSchedule = schedules.first;
            final totalSlots = schedules.length;

            return Card(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              elevation: 2,
              child: InkWell(
                onTap: () {
                  _navigateToProposalDetail(firstSchedule);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  firstSchedule.subjectName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Gia sư: ${firstSchedule.tutorName}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$totalSlots buổi',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...(schedules.take(3).map((schedule) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                '${schedule.formattedDate} - ${schedule.formattedTime}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        );
                      })),
                      if (schedules.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'và ${schedules.length - 3} buổi khác...',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _navigateToProposalDetail(firstSchedule);
                          },
                          icon: const Icon(Icons.payment, size: 18),
                          label: const Text('Xem chi tiết & Thanh toán'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          })),
          if (_pendingPaymentProposals.length > 3)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: TextButton(
                  onPressed: () {
                  },
                  child: Text(
                    'Xem tất cả (${_pendingPaymentProposals.length} đề xuất)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userRole = authProvider.userRole ?? 'student';
        
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _refreshAllSections,
              displacement: 20,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: _buildFakeSearchBar(context),
                    ),
                    
                    if (userRole == 'student')
                      _buildPendingPaymentSection(),
                    
                    _HomeSection(
                      key: _sectionKeys['recommended'],
                      title: "Đề xuất cho bạn",
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

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
  bool _hasError = false; 

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
      final tutorsData = await _apiService.getTutors(category: widget.categoryKey);
       if (!mounted) return;

       final random = Random(); // có thể khai báo static để tái sử dụng
       final tutors = tutorsData.map((json) => TutorModel.fromJson(json)).toList();
       tutors.shuffle(random); // xáo trộn vị trí

       setState(() {
         _tutors = tutors;
         _isLoading = false;
       });
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _tutors = []; 
        });
        
        ErrorHandler.showErrorDialogFromException(
          context,
          e,
          onRetry: _loadTutors,
        );
      }
    }
  }

  void reload() {
    _loadTutors();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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