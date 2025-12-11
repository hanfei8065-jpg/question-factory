import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 主题管理服务
/// 支持: 浅色模式、深色模式、跟随系统
class ThemeService {
  static const String _key = 'theme_mode';
  static SharedPreferences? _prefs;
  static ThemeMode _themeMode = ThemeMode.system;
  static final List<VoidCallback> _listeners = [];

  static ThemeMode get themeMode => _themeMode;

  /// 初始化服务
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedMode = _prefs?.getString(_key);

    if (savedMode == 'light') {
      _themeMode = ThemeMode.light;
    } else if (savedMode == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
  }

  /// 设置主题模式
  static Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    String modeString;
    if (mode == ThemeMode.light) {
      modeString = 'light';
    } else if (mode == ThemeMode.dark) {
      modeString = 'dark';
    } else {
      modeString = 'system';
    }

    await _prefs?.setString(_key, modeString);
    _notifyListeners();
  }

  /// 添加监听器
  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// 移除监听器
  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// 通知所有监听器
  static void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }
}
