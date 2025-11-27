import 'package:flutter/foundation.dart';

class NavigationProvider extends ChangeNotifier {
  int? _targetTabIndex;
  DateTime? _targetDate;

  int? get targetTabIndex => _targetTabIndex;
  DateTime? get targetDate => _targetDate;

  void navigateToScheduleTab({DateTime? selectDate}) {
    _targetTabIndex = 1;
    _targetDate = selectDate;
    notifyListeners();
    
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
