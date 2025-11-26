// 核心主题
enum Subject { math, physics, chemistry }

class ThemeConstants {
  static const Map<Subject, String> subjectNames = {
    Subject.math: '数学',
    Subject.physics: '物理',
    Subject.chemistry: '化学',
  };

  static const Map<Subject, String> subjectIcons = {
    Subject.math: '📐',
    Subject.physics: '🔬',
    Subject.chemistry: '⚗️',
  };

  // 主题颜色
  static const primaryColor = Color(0xFF00A86B);
  static const errorColor = Color(0xFFFF1744);
  static const warningColor = Color(0xFFFFB300);

  // 边距和圆角
  static const defaultPadding = 16.0;
  static const defaultRadius = 12.0;

  // 动画时间
  static const animationDuration = Duration(milliseconds: 300);
}
