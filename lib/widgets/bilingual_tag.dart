import 'package:flutter/material.dart';
import '../utils/tag_parser.dart';

/// 🏷️ BilingualTag - 双语标签显示组件
///
/// 功能：以精美的 Chip 样式显示双语标签
/// 设计：WeChat 绿色主题，上英文下中文的布局
///
/// 使用示例：
/// ```dart
/// BilingualTag(tag: "Kinematics (运动学)")
/// ```
class BilingualTag extends StatelessWidget {
  final String tag;
  final bool compact; // 紧凑模式（仅显示英文或中文）
  final bool preferChinese; // 在紧凑模式下优先显示中文

  const BilingualTag({
    super.key,
    required this.tag,
    this.compact = false,
    this.preferChinese = false,
  });

  @override
  Widget build(BuildContext context) {
    final parsed = TagParser.parse(tag);
    final hasZh = parsed['zh']!.isNotEmpty;

    // 紧凑模式：仅显示一行文本
    if (compact) {
      final displayText = preferChinese && hasZh
          ? parsed['zh']!
          : parsed['en']!;
      return _buildCompactTag(displayText);
    }

    // 标准模式：双行显示
    if (hasZh) {
      return _buildBilingualTag(parsed['en']!, parsed['zh']!);
    } else {
      // 仅有英文的情况
      return _buildSingleLanguageTag(parsed['en']!);
    }
  }

  /// 构建双语标签 (标准模式)
  Widget _buildBilingualTag(String en, String zh) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4), // Light Green 背景
        border: Border.all(
          color: const Color(0xFF07C160).withOpacity(0.3), // WeChat Green 边框
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 英文部分
          Text(
            en,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B), // Dark Grey
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          // 中文部分
          Text(
            zh,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Color(0xFF64748B), // Grey
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 构建单语言标签（仅英文）
  Widget _buildSingleLanguageTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        border: Border.all(
          color: const Color(0xFF07C160).withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 构建紧凑标签（用于空间有限的场景）
  Widget _buildCompactTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        border: Border.all(
          color: const Color(0xFF07C160).withOpacity(0.2),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Color(0xFF475569),
        ),
      ),
    );
  }
}

/// 🏷️ BilingualTagRow - 标签行组件
///
/// 功能：自动换行显示多个标签
///
/// 使用示例：
/// ```dart
/// BilingualTagRow(
///   tags: ["Kinematics (运动学)", "Velocity (速度)", "Acceleration (加速度)"],
/// )
/// ```
class BilingualTagRow extends StatelessWidget {
  final List<String> tags;
  final double spacing; // 标签间距
  final double runSpacing; // 行间距
  final bool compact; // 紧凑模式
  final int? maxTags; // 最多显示标签数（null = 显示全部）

  const BilingualTagRow({
    super.key,
    required this.tags,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.compact = false,
    this.maxTags,
  });

  @override
  Widget build(BuildContext context) {
    // 过滤空标签
    final validTags = tags.where((tag) => tag.trim().isNotEmpty).toList();

    if (validTags.isEmpty) {
      return const SizedBox.shrink();
    }

    // 限制显示数量
    final displayTags = maxTags != null && validTags.length > maxTags!
        ? validTags.take(maxTags!).toList()
        : validTags;

    final hasMore = maxTags != null && validTags.length > maxTags!;

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        ...displayTags.map((tag) => BilingualTag(tag: tag, compact: compact)),
        // 显示 "+N more" 指示器
        if (hasMore)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '+${validTags.length - maxTags!} more',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

/// 🏷️ TagSection - 带标题的标签区域组件
///
/// 功能：显示标签区域标题 + 标签列表
///
/// 使用示例：
/// ```dart
/// TagSection(
///   title: "Knowledge Points",
///   tags: ["Linear Equations (一元一次方程)", "Slope (斜率)"],
/// )
/// ```
class TagSection extends StatelessWidget {
  final String title;
  final List<String> tags;
  final IconData? icon;
  final double spacing;
  final double runSpacing;

  const TagSection({
    super.key,
    required this.title,
    required this.tags,
    this.icon,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: const Color(0xFF07C160)),
              const SizedBox(width: 6),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 标签列表
        BilingualTagRow(tags: tags, spacing: spacing, runSpacing: runSpacing),
      ],
    );
  }
}
