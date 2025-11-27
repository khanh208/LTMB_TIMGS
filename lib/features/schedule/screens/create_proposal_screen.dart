
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/models/subject_model.dart';
import '../../../core/models/tutor_detail_model.dart';

class CreateProposalScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const CreateProposalScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<CreateProposalScreen> createState() => _CreateProposalScreenState();
}

class _CreateProposalScreenState extends State<CreateProposalScreen> {
  final ApiService _apiService = ApiService();
  
  List<SubjectModel> _availableSubjects = [];
  bool _isLoadingSubjects = true;
  
  SubjectModel? _selectedSubject;
  
  final List<_TimeSlot> _selectedSlots = [];
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadMySubjects(); 
  }

  Future<void> _loadMySubjects() async {
    setState(() {
      _isLoadingSubjects = true;
    });

    try {
      final profileData = await _apiService.getMyTutorProfile();
      
      List<SubjectModel> subjects = [];
      if (profileData['subjects'] != null) {
        subjects = (profileData['subjects'] as List)
            .map((item) => SubjectModel.fromJson(item))
            .toList();
      }

      if (mounted) {
        setState(() {
          _availableSubjects = subjects;
          _isLoadingSubjects = false;
        });

        if (subjects.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bạn chưa có môn học nào trong hồ sơ. Vui lòng cập nhật hồ sơ trước.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSubjects = false;
        });
        
        ErrorHandler.showErrorDialogFromException(
          context,
          e,
          onRetry: _loadMySubjects,
        );
      }
    }
  }

  Future<void> _showSubjectPicker() async {
    if (_availableSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có môn học nào để chọn'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final selected = await showModalBottomSheet<SubjectModel>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Chọn môn học',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _availableSubjects.length,
                itemBuilder: (context, index) {
                  final subject = _availableSubjects[index];
                  final isSelected = _selectedSubject?.subjectId == subject.subjectId;
                  
                  return ListTile(
                    title: Text(subject.name),
                    subtitle: Text(subject.category),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    selected: isSelected,
                    onTap: () {
                      Navigator.pop(context, subject);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedSubject = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo đề xuất lịch học'),
      ),
      body: _isLoadingSubjects
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStudentInfoCard(),
                  
                  const SizedBox(height: 16),
                  
                  _buildSubjectSelector(),
                  
                  const SizedBox(height: 24),
                  
                  _buildSlotsList(),
                  
                  const SizedBox(height: 16),
                  
                  ElevatedButton.icon(
                    onPressed: _showAddSlotDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm khung giờ'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  ElevatedButton(
                    onPressed: _canSubmit() && !_isSubmitting
                        ? _submitProposal
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Gửi đề xuất',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStudentInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              child: Icon(Icons.person),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Học viên',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    widget.studentName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectSelector() {
    return Card(
      child: InkWell(
        onTap: _showSubjectPicker,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.book, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chọn môn học',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedSubject?.name ?? 'Chưa chọn môn học',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _selectedSubject != null
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlotsList() {
    if (_selectedSlots.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Chưa có khung giờ nào được chọn',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh sách khung giờ (${_selectedSlots.length})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...(_selectedSlots.asMap().entries.map((entry) {
          final index = entry.key;
          final slot = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text('Buổi ${index + 1}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ngày: ${_formatDate(slot.startTime)}'),
                  Text('Giờ: ${_formatTime(slot.startTime)} - ${_formatTime(slot.endTime)}'),
                  Text(
                    'Thời lượng: ${_calculateDuration(slot.startTime, slot.endTime)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _selectedSlots.removeAt(index);
                  });
                },
              ),
            ),
          );
        }).toList()),
      ],
    );
  }

  void _showAddSlotDialog() {
    DateTime? selectedDate;
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Thêm khung giờ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Chọn ngày'),
                  subtitle: Text(
                    selectedDate == null
                        ? 'Chưa chọn'
                        : _formatDate(selectedDate!),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      locale: const Locale('vi', 'VN'),
                    );
                    if (date != null) {
                      setDialogState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                
                if (selectedDate != null) ...[
                  ListTile(
                    title: const Text('Giờ bắt đầu'),
                    subtitle: Text(
                      startTime == null
                          ? 'Chưa chọn'
                          : startTime!.format(context),
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setDialogState(() {
                          startTime = time;
                        });
                      }
                    },
                  ),
                  
                  if (startTime != null)
                    ListTile(
                      title: const Text('Giờ kết thúc'),
                      subtitle: Text(
                        endTime == null
                            ? 'Chưa chọn'
                            : endTime!.format(context),
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: startTime!.hour,
                            minute: startTime!.minute + 30 > 59
                                ? 59
                                : startTime!.minute + 30,
                          ),
                        );
                        if (time != null) {
                          final startMinutes =
                              startTime!.hour * 60 + startTime!.minute;
                          final endMinutes = time.hour * 60 + time.minute;
                          if (endMinutes <= startMinutes) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Giờ kết thúc phải sau giờ bắt đầu'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          setDialogState(() {
                            endTime = time;
                          });
                        }
                      },
                    ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: (selectedDate != null &&
                      startTime != null &&
                      endTime != null)
                  ? () {
                      final start = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        startTime!.hour,
                        startTime!.minute,
                      );
                      final end = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        endTime!.hour,
                        endTime!.minute,
                      );

                      setState(() {
                        _selectedSlots.add(_TimeSlot(start, end));
                      });
                      Navigator.pop(context);
                    }
                  : null,
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  bool _canSubmit() {
    return _selectedSubject != null && _selectedSlots.isNotEmpty;
  }

  Future<void> _submitProposal() async {
    if (!_canSubmit()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn môn học và ít nhất một khung giờ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final slots = _selectedSlots.map((slot) {
        return {
          'startTime': slot.startTime.toIso8601String(),
          'endTime': slot.endTime.toIso8601String(),
        };
      }).toList();

      final result = await _apiService.createScheduleProposal(
        studentId: widget.studentId,
        subjectId: _selectedSubject!.subjectId, 
        slots: slots,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã gửi đề xuất thành công! Tổng tiền: ${_formatCurrency(result['totalAmount'] ?? 0)}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorDialogFromException(
          context,
          e,
          onRetry: _submitProposal,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _calculateDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '$hours giờ $minutes phút';
    } else if (hours > 0) {
      return '$hours giờ';
    } else {
      return '$minutes phút';
    }
  }

  String _formatCurrency(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M VNĐ';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k VNĐ';
    } else {
      return '$amount VNĐ';
    }
  }
}

class _TimeSlot {
  final DateTime startTime;
  final DateTime endTime;

  _TimeSlot(this.startTime, this.endTime);
}