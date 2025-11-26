import 'package:flutter/material.dart';
import 'package:learnest_fresh/models/question.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  final SharedPreferences _prefs;
  Subject _currentSubject = Subject.math;
  bool _isPro = false;
  int _gems = 0;
  int _experience = 0;
  int _streakDays = 0;
  DateTime? _lastActiveDate;

  AppState(this._prefs) {
    _loadState();
  }

  Subject get currentSubject => _currentSubject;
  bool get isPro => _isPro;
  int get gems => _gems;
  int get experience => _experience;
  int get streakDays => _streakDays;
  DateTime? get lastActiveDate => _lastActiveDate;

  void _loadState() {
    _currentSubject = Subject.values[_prefs.getInt('currentSubject') ?? 0];
    _isPro = _prefs.getBool('isPro') ?? false;
    _gems = _prefs.getInt('gems') ?? 0;
  }

  void _saveState() {
    _prefs.setInt('currentSubject', _currentSubject.index);
    _prefs.setBool('isPro', _isPro);
    _prefs.setInt('gems', _gems);
    _prefs.setInt('experience', _experience);
    _prefs.setInt('streakDays', _streakDays);
    if (_lastActiveDate != null) {
      _prefs.setString('lastActiveDate', _lastActiveDate!.toIso8601String());
    }
  }

  void setCurrentSubject(Subject subject) {
    _currentSubject = subject;
    _saveState();
    notifyListeners();
  }

  void addGems(int amount) {
    _gems += amount;
    _saveState();
    notifyListeners();
    notifyListeners();
  }

  List<Question> getQuestionsByTopic(String topic) {
    // TODO: 实现从数据库获取题目
    return [];
  }

  // 升级到Pro版本
  Future<bool> upgradeToPro() async {
    try {
      // TODO: 实现支付逻辑
      _isPro = true;
      _saveState();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
