import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 翻译服务 - 唯一的语言文本来源
/// Single Source of Truth for ALL UI Text
/// 支持: 英语(en-default) 中文(zh) 日语(ja) 西班牙语(es)
class Tr {
  /// 当前语言
  static final ValueNotifier<String> locale = ValueNotifier<String>('en');

  /// 支持的语言列表
  static const List<Map<String, String>> supportedLocales = [
    {'code': 'en', 'name': 'English', 'flag': '��'},
    {'code': 'zh', 'name': '中文', 'flag': '��'},
    {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
  ];

  /// 所有翻译键值对 (从JSON加载)
  static Map<String, dynamic> _translations = {};
  static bool _initialized = false;

  /// 初始化 - 加载当前语言的JSON
  static Future<void> init() async {
    if (_initialized) return;
    await _loadTranslations(locale.value);
    _initialized = true;

    // 监听语言切换
    locale.addListener(() async {
      await _loadTranslations(locale.value);
    });
  }

  /// 从assets加载JSON文件
  static Future<void> _loadTranslations(String lang) async {
    try {
      final jsonString = await rootBundle.loadString('assets/i18n/$lang.json');
      _translations = json.decode(jsonString);
    } catch (e) {
      // 如果加载失败,回退到英文
      if (lang != 'en') {
        final fallback = await rootBundle.loadString('assets/i18n/en.json');
        _translations = json.decode(fallback);
      }
    }
  }

  /// 获取翻译文本
  static String get(String key) {
    if (!_initialized) {
      return key; // 未初始化时返回key
    }
    return _translations[key] ?? key;
  }

  /// 切换语言
  static void setLocale(String newLocale) {
    final isSupported = supportedLocales.any((l) => l['code'] == newLocale);
    if (isSupported) {
      locale.value = newLocale;
    }
  }

  /// 获取语言图标
  static String getFlag(String localeCode) {
    final localeInfo = supportedLocales.firstWhere(
      (l) => l['code'] == localeCode,
      orElse: () => {'code': '', 'name': '', 'flag': '�'},
    );
    return localeInfo['flag'] ?? '🌐';
  }
}