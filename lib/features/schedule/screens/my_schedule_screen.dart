// lib/features/schedule/screens/my_schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // Import package

class MyScheduleScreen extends StatefulWidget {
  const MyScheduleScreen({super.key});

  @override
  State<MyScheduleScreen> createState() => _MyScheduleScreenState();
}

class _MyScheduleScreenState extends State<MyScheduleScreen> {
  // (Giả lập vai trò, sau này bạn sẽ lấy từ state)
  final String _userRole = 'student'; 

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now(); // Ngày đang được focus
  DateTime? _selectedDay; // Ngày đang được chọn (có thể null)

  // (Dữ liệu giả lập cho các buổi học - Dùng để hiển thị "dấu chấm")
  // Bạn sẽ lấy dữ liệu này từ API/Firebase
  final Map<DateTime, List<String>> _events = {
    DateTime.utc(2025, 11, 10): ['Buổi học Toán', 'Buổi học Lý'],
    DateTime.utc(2025, 11, 15): ['Buổi học Hóa'],
    DateTime.utc(2025, 11, 20): ['Buổi học Tiếng Anh'],
  };

  // Hàm lấy các sự kiện cho một ngày (cho "dấu chấm")
  List<String> _getEventsForDay(DateTime day) {
    // Chuyển đổi ngày để so sánh (loại bỏ thông tin giờ)
    final dayUtc = DateTime.utc(day.year, day.month, day.day);
    return _events[dayUtc] ?? []; // Trả về danh sách sự kiện hoặc list rỗng
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay; // Chọn ngày hôm nay làm ngày mặc định
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_userRole == 'student' ? "Lịch học của tôi" : "Lịch dạy của tôi"),
      ),
      body: Column(
        children: [
          // --- 1. LỊCH XEM (CALENDAR VIEW) ---
          TableCalendar(
            locale: 'vi_VN', // (Bạn cần thêm package intl: để có tiếng Việt)
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              // Dùng để làm nổi bật ngày được chọn
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              // Hàm chạy khi người dùng bấm vào một ngày
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // Cập nhật ngày focus
              });
            },
            onFormatChanged: (format) {
              // Cho phép đổi qua lại (tháng, 2 tuần, tuần)
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              // Khi người dùng vuốt sang tháng khác
              _focusedDay = focusedDay;
            },
            // --- Đánh dấu các ngày có sự kiện ---
            eventLoader: _getEventsForDay, 
            calendarStyle: const CalendarStyle(
              // Tùy chỉnh dấu chấm (marker)
              markersMaxCount: 1, // Chỉ hiển thị 1 dấu chấm dù có nhiều sự kiện
              markerDecoration: BoxDecoration(
                color: Colors.red, // Màu của dấu chấm
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          const Divider(height: 1),
          const SizedBox(height: 16),

          // --- 2. DANH SÁCH AGENDA (AGENDA LIST) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Lịch học ngày ${_selectedDay?.day}/${_selectedDay?.month}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _buildAgendaList(),
          ),
        ],
      ),
    );
  }

  // --- HÀM BUILD DANH SÁCH AGENDA ---
  Widget _buildAgendaList() {
    // Lấy danh sách sự kiện của ngày đã chọn
    final events = _getEventsForDay(_selectedDay ?? DateTime.now());

    if (events.isEmpty) {
      return const Center(
        child: Text("Không có buổi học nào vào ngày này."),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        // Đây là "Thẻ Buổi học" (Session Card)
        return _SessionCard(
          eventName: events[index],
          userRole: _userRole,
        );
      },
    );
  }
}

// --- WIDGET THẺ BUỔI HỌC (SESSION CARD) ---
class _SessionCard extends StatelessWidget {
  final String eventName;
  final String userRole;

  const _SessionCard({required this.eventName, required this.userRole});

  @override
  Widget build(BuildContext context) {
    bool isStudent = userRole == 'student';

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
              // Thông tin chính
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "19:00 - 21:00", // (Dữ liệu giả)
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      eventName, // (Tên môn học/buổi học)
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    // Hiển thị thông tin theo vai trò
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.grey[300],
                          child: const Icon(Icons.person, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isStudent ? "Gia sư: Nguyễn Văn A" : "Học viên: Trần Thị B",
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Trạng thái
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Đã xác nhận",
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}