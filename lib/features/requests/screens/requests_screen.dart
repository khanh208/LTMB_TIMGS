// lib/features/requests/screens/requests_screen.dart

import 'package:flutter/material.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  // --- DỮ LIỆU TẠM THỜI (MOCK DATA) ---
  // Bạn sẽ lấy dữ liệu này từ CSDL.
  // Chúng ta dùng List<Map> để có thể xóa item khi tương tác.
  final List<Map<String, String>> _pendingRequests = [
    {
      'id': 'req_01',
      'studentName': 'Lê Văn A',
      'message': 'Muốn đăng ký học môn: Luyện thi Toán 12',
      'timestamp': '2 giờ trước',
    },
    {
      'id': 'req_02',
      'studentName': 'Trần Thị B',
      'message': 'Muốn đăng ký học môn: Tiếng Anh Giao tiếp',
      'timestamp': 'Hôm qua',
    },
    {
      'id': 'req_03',
      'studentName': 'Nguyễn Văn C',
      'message': 'Muốn đăng ký học môn: Lập trình Flutter',
      'timestamp': '3 ngày trước',
    },
  ];
  
  // (Dữ liệu giả lập cho lịch sử)
  final List<Map<String, String>> _historyRequests = [
    {
      'id': 'req_04',
      'studentName': 'Phạm Thị D',
      'message': 'Muốn đăng ký học môn: Hóa 10',
      'status': 'Đã chấp nhận'
    },
  ];

  // Hàm xử lý khi bấm "Chấp nhận"
  void _acceptRequest(String requestId) {
    setState(() {
      // (Xử lý logic CSDL ở đây)
      // ...
      
      // Xóa item khỏi danh sách "Đang chờ" (Giả lập)
      _pendingRequests.removeWhere((req) => req['id'] == requestId);
      
      // (Bạn có thể thêm vào danh sách Lịch sử)
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã chấp nhận yêu cầu!"), backgroundColor: Colors.green),
      );
    });
  }

  // Hàm xử lý khi bấm "Từ chối"
  void _declineRequest(String requestId) {
     setState(() {
      // (Xử lý logic CSDL ở đây)
      // ...
       
      _pendingRequests.removeWhere((req) => req['id'] == requestId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã từ chối yêu cầu."), backgroundColor: Colors.red),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng DefaultTabController để quản lý TabBar
    return DefaultTabController(
      length: 2, // 2 Tab
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Yêu cầu Kết nối"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Đang chờ"),
              Tab(text: "Lịch sử"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- NỘI DUNG TAB 1: ĐANG CHỜ ---
            _buildPendingList(),
            
            // --- NỘI DUNG TAB 2: LỊCH SỬ ---
            _buildHistoryList(),
          ],
        ),
      ),
    );
  }

  // Widget cho danh sách "Đang chờ"
  Widget _buildPendingList() {
    if (_pendingRequests.isEmpty) {
      return const Center(
        child: Text("Bạn không có yêu cầu nào đang chờ.", style: TextStyle(color: Colors.grey)),
      );
    }
    
    return ListView.builder(
      itemCount: _pendingRequests.length,
      itemBuilder: (context, index) {
        final request = _pendingRequests[index];
        return _RequestCard(
          studentName: request['studentName']!,
          message: request['message']!,
          timestamp: request['timestamp']!,
          onAccept: () => _acceptRequest(request['id']!),
          onDecline: () => _declineRequest(request['id']!),
        );
      },
    );
  }

  // Widget cho danh sách "Lịch sử"
  Widget _buildHistoryList() {
    if (_historyRequests.isEmpty) {
      return const Center(
        child: Text("Không có lịch sử nào.", style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: _historyRequests.length,
      itemBuilder: (context, index) {
        final request = _historyRequests[index];
        // (Bạn có thể thiết kế thẻ Lịch sử riêng)
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(request['studentName']!),
          subtitle: Text(request['message']!),
          trailing: Text(
            request['status']!,
            style: TextStyle(
              color: request['status'] == 'Đã chấp nhận' ? Colors.green : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}


// --- WIDGET TÙY CHỈNH CHO THẺ YÊU CẦU ---
class _RequestCard extends StatelessWidget {
  final String studentName;
  final String message;
  final String timestamp;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _RequestCard({
    required this.studentName,
    required this.message,
    required this.timestamp,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin Học viên
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        timestamp,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Nội dung tin nhắn
            Text(
              message,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 16),

            // Hai nút hành động
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Từ chối"),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Chấp nhận"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}