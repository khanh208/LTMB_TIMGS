import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/error_handler.dart';

class ProposalDetailScreen extends StatefulWidget {
  final String groupId;

  const ProposalDetailScreen({super.key, required this.groupId});

  @override
  State<ProposalDetailScreen> createState() => _ProposalDetailScreenState();
}

class _ProposalDetailScreenState extends State<ProposalDetailScreen> {
  final ApiService _apiService = ApiService();

  Map<String, dynamic>? _proposalData;
  bool _isLoading = true;
  bool _isPaying = false;
  bool _isRejecting = false;
  @override
  void initState() {
    super.initState();
    _loadProposal();
  }

  Future<void> _loadProposal() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _apiService.getScheduleProposal(widget.groupId);

      if (mounted) {
        setState(() {
          _proposalData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ErrorHandler.showErrorDialogFromException(
          context,
          e,
          onRetry: _loadProposal,
        );
      }
    }
  }

  Future<void> _handleReject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Từ chối đề xuất'),
        content: const Text(
            'Bạn có chắc chắn muốn từ chối và hủy toàn bộ lịch trong đề xuất này?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Giữ lại')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isRejecting = true);

    try {
      await _apiService.rejectScheduleProposal(widget.groupId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Đã từ chối đề xuất lịch học.'),
            backgroundColor: Colors.redAccent),
      );
      Navigator.pop(
          context, true); 
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRejecting = false);
      ErrorHandler.showErrorDialogFromException(context, e);
    }
  }

  Future<void> _handlePayment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận thanh toán'),
        content: Text(
          'Bạn có chắc chắn muốn thanh toán ${_formatCurrency(_proposalData!['totalAmount'])}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isPaying = true;
    });

    try {
      final result = await _apiService.payScheduleProposal(widget.groupId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Thanh toán thành công! Tổng tiền: ${_formatCurrency(result['totalAmount'])}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPaying = false;
        });

        ErrorHandler.showErrorDialogFromException(
          context,
          e,
          onRetry: _handlePayment,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đề xuất lịch học'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _proposalData == null
              ? const Center(child: Text('Không tìm thấy đề xuất'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tổng tiền',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatCurrency(
                                        _proposalData!['totalAmount']),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Số buổi học: ${(_proposalData!['schedules'] as List).length}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          const Text(
                            'Danh sách buổi học',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          ...((_proposalData!['schedules'] as List)
                              .map((schedule) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(schedule['subject_name'] ?? ''),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Ngày: ${_formatScheduleDate(schedule['start_time'])}'),
                                    Text(
                                        'Giờ: ${_formatScheduleTime(schedule['start_time'])}'),
                                    Text(
                                        'Gia sư: ${schedule['tutor_name'] ?? ''}'),
                                    Text(
                                      'Giá: ${_formatCurrency(int.tryParse(schedule['price']?.toString().replaceAll('.', '') ?? '0') ?? 0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList()),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: (_isPaying || _isRejecting)
                                  ? null
                                  : _handleReject,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              child: _isRejecting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.red),
                                    )
                                  : const Text('Từ chối đề xuất'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isPaying ? null : _handlePayment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: _isPaying
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text('Thanh toán',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  String _formatCurrency(int amount) {
    return '${(amount / 1000).toStringAsFixed(0)}k VNĐ';
  }

  String _formatScheduleDate(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _formatScheduleTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }
}
