import 'package:flutter/material.dart';

/// Learnest 设计语言系统
/// 参照微信、抖音、WhatsApp等大厂设计规范
class AppTheme {
  // ==================== 品牌色系统 ====================
  
  /// 主品牌色 - Learnest Green
  static const Color brandPrimary = Color(0xFF00A86B);
  
  /// 品牌渐变色（深绿到浅绿）
  static const Color brandGradientStart = Color(0xFF00C879);
  static const Color brandGradientEnd = Color(0xFF00A86B);
  
  /// 次要品牌色
  static const Color brandSecondary = Color(0xFF4CAF50);
  
  /// 品牌色-浅色变体（用于背景、hover等）
  static const Color brandLight = Color(0xFFE8F5F1);
  static const Color brandLighter = Color(0xFFF4FAF8);
  
  /// 品牌色-深色变体（用于按压、active等）
  static const Color brandDark = Color(0xFF008F5C);
  
  // ==================== 功能色系统 ====================
  
  /// 成功色 - 微信绿
  static const Color success = Color(0xFF07C160);
  static const Color successGreen = Color(0xFF07C160);  // 别名
  static const Color successLight = Color(0xFFE7F8F0);
  
  /// 警告色 - 抖音橙
  static const Color warning = Color(0xFFFF6B00);
  static const Color warningLight = Color(0xFFFFF4E5);
  
  /// 错误色 - 微信红
  static const Color error = Color(0xFFFA5151);
  static const Color errorLight = Color(0xFFFFEDED);
  
  /// 信息色
  static const Color info = Color(0xFF1989FA);
  static const Color infoLight = Color(0xFFE8F4FF);
  
  // ==================== 中性色系统 ====================
  
  /// 背景色系统
  static const Color background = Color(0xFFE8E8E8);  // 启动页底色
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundGray = Color(0xFFF7F8FA);  // 微信风格浅灰
  static const Color backgroundLight = Color(0xFFF7F8FA);  // 浅色背景
  static const Color backgroundCard = Color(0xFFFFFFFF);
  
  /// 表面色
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  
  /// 文本色系统（参照微信）
  static const Color textPrimary = Color(0xFF181818);      // 主文本
  static const Color textSecondary = Color(0xFF656565);    // 次要文本
  static const Color textTertiary = Color(0xFF969696);     // 三级文本
  static const Color textQuaternary = Color(0xFFB2B2B2);   // 四级文本/禁用
  static const Color textPlaceholder = Color(0xFFBBBBBB);  // 占位符
  static const Color textWhite = Color(0xFFFFFFFF);        // 白色文本
  
  /// 边框色系统
  static const Color border = Color(0xFFE5E5E5);           // 标准边框
  static const Color borderLight = Color(0xFFF0F0F0);      // 浅色边框
  static const Color borderDark = Color(0xFFD6D6D6);       // 深色边框
  
  /// 分割线
  static const Color divider = Color(0xFFEBEDF0);          // 微信风格分割线
  static const Color dividerLight = Color(0xFFF7F8FA);
  
  /// 遮罩色
  static const Color overlay = Color(0x80000000);          // 50% 黑色遮罩
  static const Color overlayLight = Color(0x40000000);     // 25% 黑色遮罩
  
  // ==================== 圆角系统 ====================
  
  static const double radiusXS = 4.0;    // 超小圆角 - 标签、徽章
  static const double radiusS = 6.0;     // 小圆角 - 按钮、输入框（抖音风格）
  static const double radiusM = 8.0;     // 中圆角 - 卡片、对话框
  static const double radiusL = 12.0;    // 大圆角 - 大卡片、底部弹窗
  static const double radiusXL = 16.0;   // 超大圆角 - 图片、特殊卡片
  static const double radiusXXL = 24.0;  // 特大圆角 - 全屏模态
  static const double radiusFull = 999.0; // 完全圆角 - 胶囊按钮
  
  // ==================== 间距系统（8pt网格）====================
  
  static const double spacing0 = 0.0;
  static const double spacing2 = 2.0;    // 超微小间距
  static const double spacing4 = 4.0;    // 微小间距 - 紧凑元素
  static const double spacing8 = 8.0;    // 小间距 - 元素内部
  static const double spacing12 = 12.0;  // 中小间距 - 相关元素
  static const double spacing16 = 16.0;  // 标准间距 - 常用（微信标准）
  static const double spacing20 = 20.0;  // 中间距 - 区块间
  static const double spacing24 = 24.0;  // 大间距 - 页面边距
  static const double spacing32 = 32.0;  // 超大间距 - 主要区块
  static const double spacing40 = 40.0;  // 特大间距 - 页面分组
  static const double spacing48 = 48.0;  // 巨大间距 - 页面顶部
  
  // ==================== 阴影系统 ====================
  
  /// 微小阴影 - 悬浮元素（微信风格）
  static List<BoxShadow> get shadowXS => [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.04),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];
  
  /// 小阴影 - 卡片
  static List<BoxShadow> get shadowS => [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.06),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  /// 中阴影 - 按钮、输入框
  static List<BoxShadow> get shadowM => [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  /// 大阴影 - 对话框、抽屉
  static List<BoxShadow> get shadowL => [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  /// 超大阴影 - 模态框
  static List<BoxShadow> get shadowXL => [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.16),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];
  
  /// 品牌色阴影 - 主按钮（抖音风格）
  static List<BoxShadow> get shadowBrand => [
    BoxShadow(
      color: brandPrimary.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
  
  // ==================== 渐变系统 ====================
  
  /// 品牌渐变（主按钮）
  static const LinearGradient gradientBrand = LinearGradient(
    colors: [brandGradientStart, brandGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// 成功渐变
  static const LinearGradient gradientSuccess = LinearGradient(
    colors: [Color(0xFF07C160), Color(0xFF06AE56)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// 背景渐变（页面背景）
  static const LinearGradient gradientBackground = LinearGradient(
    colors: [Color(0xFFF7F8FA), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // ==================== 透明度系统 ====================
  
  static const double opacityDisabled = 0.4;    // 禁用状态
  static const double opacityHint = 0.6;        // 提示文本
  static const double opacityPressed = 0.8;     // 按压状态
  static const double opacityHover = 0.9;       // 悬停状态
  static const double opacityOverlay = 0.5;     // 遮罩
  
  // ==================== 动画时长（参照微信/抖音）====================
  
  static const Duration durationInstant = Duration(milliseconds: 100);   // 即时反馈
  static const Duration durationFast = Duration(milliseconds: 200);      // 快速动画
  static const Duration durationNormal = Duration(milliseconds: 300);    // 标准动画
  static const Duration durationSlow = Duration(milliseconds: 400);      // 慢速动画
  static const Duration durationVerySlow = Duration(milliseconds: 600);  // 特慢动画
  
  // ==================== 字体系统 ====================
  
  /// 字体大小（参照微信）
  static const double fontSizeXS = 10.0;   // 辅助信息
  static const double fontSizeS = 12.0;    // 次要信息
  static const double fontSizeM = 14.0;    // 正文（微信标准）
  static const double fontSizeL = 16.0;    // 小标题
  static const double fontSizeXL = 18.0;   // 标题
  static const double fontSizeXXL = 20.0;  // 大标题
  static const double fontSizeHuge = 24.0; // 特大标题
  
  /// 字重
  static const FontWeight fontWeightRegular = FontWeight.w400;   // 常规
  static const FontWeight fontWeightMedium = FontWeight.w500;    // 中等
  static const FontWeight fontWeightSemibold = FontWeight.w600;  // 半粗
  static const FontWeight fontWeightBold = FontWeight.w700;      // 粗体
  
  /// 行高
  static const double lineHeightTight = 1.2;    // 紧凑
  static const double lineHeightNormal = 1.5;   // 标准
  static const double lineHeightLoose = 1.8;    // 宽松
  
  // ==================== 尺寸系统 ====================
  
  /// 图标尺寸
  static const double iconSizeXS = 14.0;
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 20.0;
  static const double iconSizeL = 24.0;
  static const double iconSizeXL = 32.0;
  static const double iconSizeXXL = 48.0;
  
  /// 按钮高度
  static const double buttonHeightS = 32.0;    // 小按钮
  static const double buttonHeightM = 44.0;    // 标准按钮（微信）
  static const double buttonHeightL = 48.0;    // 大按钮
  static const double buttonHeightXL = 56.0;   // 超大按钮（抖音）
  
  /// 输入框高度
  static const double inputHeightS = 32.0;
  static const double inputHeightM = 44.0;
  static const double inputHeightL = 48.0;
  
  /// 底部导航栏高度
  static const double navBarHeight = 50.0;     // 微信标准
  
  /// 顶部导航栏高度
  static const double appBarHeight = 44.0;     // iOS标准
  
  // ==================== Z-index 系统 ====================
  
  static const int zIndexBase = 0;          // 基础层
  static const int zIndexDropdown = 1000;   // 下拉菜单
  static const int zIndexSticky = 1020;     // 吸顶元素
  static const int zIndexFixed = 1030;      // 固定元素
  static const int zIndexOverlay = 1040;    // 遮罩层
  static const int zIndexModal = 1050;      // 模态框
  static const int zIndexPopover = 1060;    // 气泡提示
  static const int zIndexToast = 1070;      // 轻提示
  static const int zIndexTooltip = 1080;    // 工具提示
}
