


// lib/features/schedule/models/schedule_event_model.dart

class ScheduleEventModel {
  final String scheduleId;
  final String tutorUserId;
  final String studentUserId;
  final String subjectId;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final String tutorName;
  final String studentName;
  final String subjectName;

  ScheduleEventModel({
    required this.scheduleId,
    required this.tutorUserId,
    required this.studentUserId,
    required this.subjectId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.tutorName,
    required this.studentName,
    required this.subjectName,
  });

  factory ScheduleEventModel.fromJson(Map<String, dynamic> json) {
    return ScheduleEventModel(
      scheduleId: json['schedule_id']?.toString() ?? '',
      tutorUserId: json['tutor_user_id']?.toString() ?? '',
      studentUserId: json['student_user_id']?.toString() ?? '',
      subjectId: json['subject_id']?.toString() ?? '',
      startTime: DateTime.parse(json['start_time'] ?? ''),
      endTime: DateTime.parse(json['end_time'] ?? ''),
      status: json['status'] ?? 'pending',
      tutorName: json['tutor_name'] ?? '',
      studentName: json['student_name'] ?? '',
      subjectName: json['subject_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schedule_id': scheduleId,
      'tutor_user_id': tutorUserId,
      'student_user_id': studentUserId,
      'subject_id': subjectId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status,
      'tutor_name': tutorName,
      'student_name': studentName,
      'subject_name': subjectName,
    };
  }

  String get formattedTime {
    final startHour = startTime.hour.toString().padLeft(2, '0');
    final startMinute = startTime.minute.toString().padLeft(2, '0');
    final endHour = endTime.hour.toString().padLeft(2, '0');
    final endMinute = endTime.minute.toString().padLeft(2, '0');
    return '$startHour:$startMinute - $endHour:$endMinute';
  }

  String get formattedDate {
    return '${startTime.day}/${startTime.month}/${startTime.year}';
  }
}