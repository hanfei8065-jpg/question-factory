import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// 计算器选择页 - 4种高端仿真计算器
class CalculatorSelectionPage extends StatelessWidget {
  const CalculatorSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: AppBar(
        title: const Text('选择计算器'),
        backgroundColor: AppTheme.brandPrimary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(AppTheme.spacing16),
        mainAxisSpacing: AppTheme.spacing16,
        crossAxisSpacing: AppTheme.spacing16,
        children: [
          _buildCalculatorCard(
            context,
            title: '基础计算器',
            subtitle: '适合小学生',
            icon: Icons.calculate_outlined,
            color: const Color(0xFF4CAF50),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BasicCalculatorPage()),
            ),
          ),
          _buildCalculatorCard(
            context,
            title: '科学计算器',
            subtitle: '适合初高中',
            icon: Icons.functions,
            color: const Color(0xFF2196F3),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScientificCalculatorPage()),
            ),
          ),
          _buildCalculatorCard(
            context,
            title: '高级函数',
            subtitle: '适合大学',
            icon: Icons.auto_graph,
            color: const Color(0xFFFF9800),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdvancedCalculatorPage()),
            ),
          ),
          _buildCalculatorCard(
            context,
            title: '图形计算器',
            subtitle: '函数绘图',
            icon: Icons.show_chart,
            color: const Color(0xFF9C27B0),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GraphingCalculatorPage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            SizedBox(height: AppTheme.spacing12),
            Text(
              title,
              style: TextStyle(
                fontSize: AppTheme.fontSizeL,
                fontWeight: AppTheme.fontWeightBold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: AppTheme.spacing4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: AppTheme.fontSizeS,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 基础计算器（占位）
class BasicCalculatorPage extends StatelessWidget {
  const BasicCalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('基础计算器'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          '基础计算器\n开发中...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppTheme.fontSizeXL,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// 科学计算器（占位）
class ScientificCalculatorPage extends StatelessWidget {
  const ScientificCalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('科学计算器'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          '科学计算器\n开发中...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppTheme.fontSizeXL,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// 高级函数计算器（占位）
class AdvancedCalculatorPage extends StatelessWidget {
  const AdvancedCalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('高级函数计算器'),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          '高级函数计算器\n开发中...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppTheme.fontSizeXL,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// 图形计算器（占位）
class GraphingCalculatorPage extends StatelessWidget {
  const GraphingCalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('图形计算器'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          '图形计算器\n开发中...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppTheme.fontSizeXL,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
