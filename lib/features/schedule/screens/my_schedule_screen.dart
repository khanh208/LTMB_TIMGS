// lib/features/schedule/screens/my_schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:table_calendar/table_calendar.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/error_handler.dart';
import '../models/schedule_event_model.dart';
import '../../../core/providers/navigation_provider.dart';

class MyScheduleScreen extends StatefulWidget {
  const MyScheduleScreen({super.key});

  @override
  State<MyScheduleScreen> createState() => _MyScheduleScreenState();
}

class _MyScheduleScreenState extends State<MyScheduleScreen> {
  final ApiService _apiService = ApiService();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<ScheduleEventModel> _allSchedules = [];
  bool _isLoading = true;
  bool _hasError = false;

  // Map để lưu events cho calendar (key: DateTime, value: List of event names)
  Map<DateTime, List<String>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final schedulesData = await _apiService.getSchedules();

      if (mounted) {
        setState(() {
          _allSchedules = schedulesData
              .map((json) => ScheduleEventModel.fromJson(json))
              .toList();

          // Tạo events map cho calendar
          _events = {};
          for (var schedule in _allSchedules) {
            final day = DateTime.utc(
              schedule.startTime.year,
              schedule.startTime.month,
              schedule.startTime.day,
            );
            if (_events.containsKey(day)) {
              _events[day]!.add(schedule.subjectName);
            } else {
              _events[day] = [schedule.subjectName];
            }
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _allSchedules = [];
          _events = {};
        });

        // Hiển thị popup thông báo lỗi
        ErrorHandler.showErrorDialogFromException(
          context,
          e,
          onRetry: _loadSchedules,
        );
      }
    }
  }

  List<String> _getEventsForDay(DateTime day) {
    final dayUtc = DateTime.utc(day.year, day.month, day.day);
    return _events[dayUtc] ?? [];
  }

  List<ScheduleEventModel> _getSchedulesForDay(DateTime? day) {
    if (day == null) return [];
    
    return _allSchedules.where((schedule) {
      final scheduleDay = DateTime.utc(
        schedule.startTime.year,
        schedule.startTime.month,
        schedule.startTime.day,
      );
      final selectedDayUtc = DateTime.utc(day.year, day.month, day.day);
      return scheduleDay == selectedDayUtc;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userRole = authProvider.userRole ?? 'student';
        
        // Listen NavigationProvider để chọn ngày khi navigate từ Dashboard
        return Consumer<NavigationProvider>(
          builder: (context, navProvider, child) {
            // Nếu có target date, chọn ngày đó
            if (navProvider.targetDate != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _selectedDay = navProvider.targetDate;
                  _focusedDay = navProvider.targetDate!;
                });
                navProvider.clearTarget(); // Clear sau khi đã chọn
              });
            }
            
            return Scaffold(
              appBar: AppBar(
                title: Text(userRole == 'student' ? "Lịch học của tôi" : "Lịch dạy của tôi"),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadSchedules,
                  ),
                ],
              ),
              body: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        TableCalendar(
                          locale: 'vi_VN',
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          calendarFormat: _calendarFormat,
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          onFormatChanged: (format) {
                            setState(() {
                              _calendarFormat = format;
                            });
                          },
                          onPageChanged: (focusedDay) {
                            setState(() {
                              _focusedDay = focusedDay;
                            });
                          },
                          eventLoader: _getEventsForDay,
                          calendarStyle: const CalendarStyle(
                            markersMaxCount: 1,
                            markerDecoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        
                        const Divider(height: 1),
                        const SizedBox(height: 16),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "Lịch học ngày ${_selectedDay?.day}/${_selectedDay?.month}",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: _buildAgendaList(userRole),
                        ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildAgendaList(String userRole) {
    final schedulesForDay = _getSchedulesForDay(_selectedDay);

    if (schedulesForDay.isEmpty) {
      return const Center(
        child: Text(
          "Không có buổi học nào vào ngày này.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: schedulesForDay.length,
      itemBuilder: (context, index) {
        return _SessionCard(
          schedule: schedulesForDay[index],
          userRole: userRole,
        );
      },
    );
  }
}

// --- WIDGET THẺ BUỔI HỌC (SESSION CARD) ---
class _SessionCard extends StatelessWidget {
  final ScheduleEventModel schedule;
  final String userRole;

  const _SessionCard({
    required this.schedule,
    required this.userRole,
  });

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'completed':
        return 'Đã hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = userRole == 'student';
    final otherPersonName = isStudent ? schedule.tutorName : schedule.studentName;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // (Điều hướng đến màn hình Chi tiết Buổi học)
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.formattedTime,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      schedule.subjectName,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.grey[300],
                          child: const Icon(Icons.person, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isStudent ? "Gia sư: $otherPersonName" : "Học viên: $otherPersonName",
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(schedule.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(schedule.status),
                      style: TextStyle(
                        color: _getStatusColor(schedule.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}