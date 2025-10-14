import 'package:flutter/material.dart';

class AppDataProvider extends ChangeNotifier {
  int _currentTab = 0;
  int get currentTab => _currentTab;
  void changeTab(int tabIndex) {
    _currentTab = tabIndex;
    notifyListeners();
  }
}
