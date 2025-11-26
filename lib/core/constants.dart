import 'package:flutter/material.dart';

// 学科定义
enum Subject { math, physics, chemistry }

// 主题相关常量
class AppTheme {
  static const Color primary = Color(0xFF00A86B);
  static const Color secondary = Color(0xFF4CAF50);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color text = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  static const double borderRadius = 16.0;
  static const double padding = 16.0;
  static const double margin = 16.0;
  static const double buttonHeight = 56.0;
}

// 主题常量
class ThemeConstants {
  static const Map<Subject, String> subjectIcons = {
    Subject.math: '📐',
    Subject.physics: '🔭',
    Subject.chemistry: '⚗️',
  };

  static const Map<Subject, String> subjectNames = {
    Subject.math: '数学',
    Subject.physics: '物理',
    Subject.chemistry: '化学',
  };
}

class Messages {
  static String getNeedHelpMessage() {
    return '需要帮助吗？我们的AI老师可以为您提供一对一辅导。';
  }

  static String getPracticeMessage() {
    return '练习是提高的关键。让我们一起继续努力！';
  }

  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}

// 学科相关常量
class SubjectConstants {
  static const Map<Subject, String> names = {
    Subject.math: '数学',
    Subject.physics: '物理',
    Subject.chemistry: '化学',
  };

  static const Map<Subject, String> icons = {
    Subject.math: '📐',
    Subject.physics: '🔬',
    Subject.chemistry: '⚗️',
  };

  static const Map<Subject, List<String>> topics = {
    Subject.math: ['代数', '几何', '统计', '概率'],
    Subject.physics: ['力学', '热学', '光学', '电磁学'],
    Subject.chemistry: ['物质结构', '化学反应', '有机化学', '无机化学'],
  };
}

// 提示文案
class AppStrings {
  // 错题提示
  static String getErrorMessage(String topic) => '你在$topic上遇到了一些困难，要去专项练习吗？';

  // 需要帮助提示
  static String getNeedHelpMessage() => '看起来有点难度，需要AI名师帮你讲解吗？ 🤔';

  // 练习建议
  static String getPracticeMessage() => '知识点已经掌握了，来做几道题巩固一下吧！ 💪';

  // 鼓励文案
  static final List<String> encouragements = [
    '做得很好！继续保持 👍',
    '不要放弃，你可以的！✨',
    '慢慢来，一点一点进步 🌱',
    '真棒！越来越厉害了 🎉',
    '有问题随时问我哦 😊',
  ];
}
