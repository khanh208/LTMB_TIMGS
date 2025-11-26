import 'package:flutter/foundation.dart';

class NavigationProvider extends ChangeNotifier {
  int? _targetTabIndex;
  DateTime? _targetDate;

  int? get targetTabIndex => _targetTabIndex;
  DateTime? get targetDate => _targetDate;

  // Method để Dashboard gọi khi muốn navigate đến tab Lịch học
  void navigateToScheduleTab({DateTime? selectDate}) {
    _targetTabIndex = 1; // Index của tab Lịch học (Dashboard=0, Schedule=1, Chat=2, Profile=3)
    _targetDate = selectDate;
    notifyListeners();
    
    // Reset sau khi notify
    Future.delayed(const Duration(milliseconds: 100), () {
      _targetTabIndex = null;
      _targetDate = null;
    });
  }

  void clearTarget() {
    _targetTabIndex = null;
    _targetDate = null;
    notifyListeners();
  }
}
