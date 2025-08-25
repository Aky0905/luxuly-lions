import 'package:flutter/foundation.dart';

class AreaState extends ChangeNotifier {
  String _currentArea = '전체';
  String get currentArea => _currentArea;

  void setArea(String area) {
    if (_currentArea == area) return;
    _currentArea = area;
    notifyListeners();
  }
}
