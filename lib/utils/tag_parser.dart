/// 📚 TagParser - 双语标签解析工具
///
/// 功能：将工厂生成的双语标签解析为英文和中文两部分
/// 格式：支持 "English (Chinese)" 或 "English（Chinese）" 格式
///
/// 使用示例：
/// ```dart
/// final parsed = TagParser.parse("Kinematics (运动学)");
/// print(parsed['en']); // "Kinematics"
/// print(parsed['zh']); // "运动学"
/// ```
class TagParser {
  /// 解析双语标签
  ///
  /// Parameters:
  /// - [rawTag]: 原始标签字符串，例如 "Linear Equations (一元一次方程)"
  ///
  /// Returns:
  /// - Map<String, String>: 包含 'en' (英文) 和 'zh' (中文) 键值对
  ///
  /// Examples:
  /// ```dart
  /// parse("Kinematics (运动学)")
  /// // => {'en': 'Kinematics', 'zh': '运动学'}
  ///
  /// parse("Mathematics")
  /// // => {'en': 'Mathematics', 'zh': ''}
  ///
  /// parse("物理（Physics）")  // 中文在前也支持
  /// // => {'en': 'Physics', 'zh': '物理'}
  /// ```
  static Map<String, String> parse(String rawTag) {
    if (rawTag.isEmpty) {
      return {'en': '', 'zh': ''};
    }

    // 正则表达式：匹配圆括号或中文全角括号内的内容
    // 支持格式：
    // 1. "English (Chinese)"
    // 2. "English（Chinese）" (中文全角括号)
    // 3. "Chinese (English)" (顺序相反)
    final regex = RegExp(r'^(.+?)[（(](.+?)[)）]$');
    final match = regex.firstMatch(rawTag.trim());

    if (match != null) {
      final part1 = match.group(1)!.trim();
      final part2 = match.group(2)!.trim();

      // 智能判断哪个是英文，哪个是中文
      // 简单规则：包含中文字符的为中文部分
      final chinesePattern = RegExp(r'[\u4e00-\u9fa5]');

      if (chinesePattern.hasMatch(part1)) {
        // 第一部分是中文
        return {'en': part2, 'zh': part1};
      } else {
        // 第一部分是英文（标准格式）
        return {'en': part1, 'zh': part2};
      }
    } else {
      // 没有括号，返回原始标签作为英文，中文为空
      return {'en': rawTag.trim(), 'zh': ''};
    }
  }

  /// 批量解析标签列表
  ///
  /// Parameters:
  /// - [tags]: 原始标签列表
  ///
  /// Returns:
  /// - List<Map<String, String>>: 解析后的标签列表
  ///
  /// Example:
  /// ```dart
  /// final tags = [
  ///   "Linear Equations (一元一次方程)",
  ///   "Slope (斜率)",
  ///   "Mathematics"
  /// ];
  /// final parsed = TagParser.parseList(tags);
  /// // => [
  /// //   {'en': 'Linear Equations', 'zh': '一元一次方程'},
  /// //   {'en': 'Slope', 'zh': '斜率'},
  /// //   {'en': 'Mathematics', 'zh': ''}
  /// // ]
  /// ```
  static List<Map<String, String>> parseList(List<String> tags) {
    return tags.map((tag) => parse(tag)).toList();
  }

  /// 检查标签是否为双语格式
  ///
  /// Parameters:
  /// - [rawTag]: 原始标签字符串
  ///
  /// Returns:
  /// - bool: true 表示包含双语，false 表示仅单语
  ///
  /// Example:
  /// ```dart
  /// isBilingual("Kinematics (运动学)");  // true
  /// isBilingual("Mathematics");          // false
  /// ```
  static bool isBilingual(String rawTag) {
    final parsed = parse(rawTag);
    return parsed['zh']!.isNotEmpty;
  }

  /// 获取标签的显示文本（根据语言偏好）
  ///
  /// Parameters:
  /// - [rawTag]: 原始标签字符串
  /// - [preferChinese]: 是否优先显示中文（默认 false）
  ///
  /// Returns:
  /// - String: 显示文本
  ///
  /// Example:
  /// ```dart
  /// getDisplayText("Kinematics (运动学)", preferChinese: false);  // "Kinematics"
  /// getDisplayText("Kinematics (运动学)", preferChinese: true);   // "运动学"
  /// getDisplayText("Mathematics", preferChinese: true);           // "Mathematics"
  /// ```
  static String getDisplayText(String rawTag, {bool preferChinese = false}) {
    final parsed = parse(rawTag);

    if (preferChinese && parsed['zh']!.isNotEmpty) {
      return parsed['zh']!;
    }

    return parsed['en']!;
  }
}
