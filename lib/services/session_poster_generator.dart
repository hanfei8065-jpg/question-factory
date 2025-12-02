import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';

/// 📸 Session Poster Generator - 病毒式传播海报生成器
///
/// 功能：
/// 1. 将学习报告生成精美海报
/// 2. WeChat 绿色渐变背景
/// 3. 包含成绩、XP、励志语录
/// 4. 一键分享到社交平台
class SessionPosterGenerator {
  /// 🎨 生成并分享学习报告海报
  static Future<void> shareReport({
    required BuildContext context,
    required int score,
    required int totalQuestions,
    required int xpEarned,
    required double accuracy,
    String subjectName = 'Mathematics',
  }) async {
    try {
      // 1. 生成海报图片
      final posterFile = await _generatePoster(
        score: score,
        totalQuestions: totalQuestions,
        xpEarned: xpEarned,
        accuracy: accuracy,
        subjectName: subjectName,
      );

      // 2. 分享海报
      final shareText =
          '''
🎉 我在 Learnest.AI 完成了一场学习挑战！

📊 正确率: ${accuracy.toStringAsFixed(1)}%
✅ 完成题目: $score/$totalQuestions
⭐ 获得经验: +$xpEarned XP

一起来挑战吧！
''';

      await Share.shareXFiles(
        [XFile(posterFile.path)],
        text: shareText,
        subject: 'Learnest 学习战报',
      );
    } catch (e) {
      // 错误处理
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分享失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }

  /// 🖼️ 生成海报图片文件
  static Future<File> _generatePoster({
    required int score,
    required int totalQuestions,
    required int xpEarned,
    required double accuracy,
    required String subjectName,
  }) async {
    final controller = ScreenshotController();

    // 生成高清截图 (3x 像素密度)
    final Uint8List imageBytes = await controller.captureFromWidget(
      _buildPosterWidget(
        score: score,
        totalQuestions: totalQuestions,
        xpEarned: xpEarned,
        accuracy: accuracy,
        subjectName: subjectName,
      ),
      pixelRatio: 3.0, // 高清输出
      context: null,
    );

    // 保存到临时文件
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${tempDir.path}/learnest_report_$timestamp.png');
    await file.writeAsBytes(imageBytes);

    return file;
  }

  /// 🎨 构建海报 Widget
  static Widget _buildPosterWidget({
    required int score,
    required int totalQuestions,
    required int xpEarned,
    required double accuracy,
    required String subjectName,
  }) {
    // 根据正确率选择颜色
    Color scoreColor;
    String performanceEmoji;
    String motivationalQuote;

    if (accuracy >= 90) {
      scoreColor = const Color(0xFF07C160); // Green
      performanceEmoji = '🌟';
      motivationalQuote = 'Knowledge is Power!';
    } else if (accuracy >= 80) {
      scoreColor = const Color(0xFF07C160);
      performanceEmoji = '💪';
      motivationalQuote = 'Great Progress!';
    } else if (accuracy >= 70) {
      scoreColor = const Color(0xFFFFA500); // Orange
      performanceEmoji = '📚';
      motivationalQuote = 'Keep Going!';
    } else if (accuracy >= 60) {
      scoreColor = const Color(0xFFFFA500);
      performanceEmoji = '🔥';
      motivationalQuote = 'Practice Makes Perfect!';
    } else {
      scoreColor = const Color(0xFFFF4D4F); // Red
      performanceEmoji = '💡';
      motivationalQuote = 'Every Mistake is a Lesson!';
    }

    return Container(
      width: 750, // 适合社交媒体的尺寸 (iPhone X 宽度)
      height: 1334, // 黄金比例 16:9
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF07C160), // WeChat Green
            Color(0xFF38EF7D), // Light Green
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ========================================
              // 1. 顶部 Logo 和标题
              // ========================================
              Column(
                children: [
                  Text(
                    'Learnest.AI',
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'LEARNING REPORT',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ],
              ),

              // ========================================
              // 2. 中间成绩卡片
              // ========================================
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 科目名称
                    Text(
                      subjectName,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 大号分数显示
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          performanceEmoji,
                          style: const TextStyle(fontSize: 64),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${accuracy.toStringAsFixed(1)}%',
                              style: GoogleFonts.poppins(
                                fontSize: 72,
                                fontWeight: FontWeight.bold,
                                color: scoreColor,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              'ACCURACY',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // 分隔线
                    Container(
                      height: 1,
                      width: double.infinity,
                      color: const Color(0xFFE2E8F0),
                    ),

                    const SizedBox(height: 32),

                    // 统计数据行
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: '✅',
                          label: 'CORRECT',
                          value: '$score/$totalQuestions',
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: const Color(0xFFE2E8F0),
                        ),
                        _buildStatItem(
                          icon: '⭐',
                          label: 'XP EARNED',
                          value: '+$xpEarned',
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // 励志语录
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '"$motivationalQuote"',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // ========================================
              // 3. 底部下载提示
              // ========================================
              Column(
                children: [
                  // QR Code 占位符（未来可添加真实二维码）
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.qr_code_2,
                          size: 60,
                          color: Color(0xFF07C160),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'SCAN ME',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF64748B),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Download Learnest.AI',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your AI Learning Companion',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📊 构建统计项 Widget
  static Widget _buildStatItem({
    required String icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF94A3B8),
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
