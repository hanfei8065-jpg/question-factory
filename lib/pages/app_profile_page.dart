import 'package:flutter/material.dart';
import 'package:learnest_fresh/services/theme_service.dart';
import 'app_learning_report_page.dart';
import 'app_mistake_book_page.dart';
import 'app_review_manager_page.dart';

class AppProfilePage extends StatelessWidget {
  const AppProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('我的'),
        backgroundColor: const Color(0xFF07C160),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 用户头像卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF07C160),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Learnist 学习者',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '继续努力，每天进步一点点！',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 学习数据板块标题
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              '学习数据',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),

          // 三大数据入口
          _buildDataMenuItem(
            context,
            icon: Icons.assessment,
            iconColor: const Color(0xFF3B82F6),
            title: '学习报告',
            subtitle: '查看学习统计和进度',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LearningReportPage()),
            ),
          ),

          _buildDataMenuItem(
            context,
            icon: Icons.library_books,
            iconColor: const Color(0xFFEF4444),
            title: '错题本',
            subtitle: '复习做错的题目',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MistakeBookPage()),
            ),
          ),

          _buildDataMenuItem(
            context,
            icon: Icons.schedule,
            iconColor: const Color(0xFF10B981),
            title: '复习计划',
            subtitle: '智能复习提醒',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReviewManagerPage()),
            ),
          ),

          const SizedBox(height: 24),

          // 其他功能板块
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              '更多功能',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),

          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: '设置',
            onTap: () {
              _showThemeDialog(context);
            },
          ),

          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            title: '帮助与反馈',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('帮助功能开发中...')));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF64748B)),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final currentMode = ThemeService.themeMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('外观设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.wb_sunny_outlined),
              title: const Text('浅色模式'),
              trailing: currentMode == ThemeMode.light
                  ? const Icon(Icons.check, color: Color(0xFF07C160))
                  : null,
              onTap: () async {
                await ThemeService.setThemeMode(ThemeMode.light);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('已切换到浅色模式')));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.nightlight_outlined),
              title: const Text('深色模式'),
              trailing: currentMode == ThemeMode.dark
                  ? const Icon(Icons.check, color: Color(0xFF07C160))
                  : null,
              onTap: () async {
                await ThemeService.setThemeMode(ThemeMode.dark);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('已切换到深色模式')));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_auto_outlined),
              title: const Text('跟随系统'),
              trailing: currentMode == ThemeMode.system
                  ? const Icon(Icons.check, color: Color(0xFF07C160))
                  : null,
              onTap: () async {
                await ThemeService.setThemeMode(ThemeMode.system);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('已设置为跟随系统')));
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
