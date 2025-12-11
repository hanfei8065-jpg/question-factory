import 'package:flutter/material.dart';
import '../theme/theme.dart';
// import '../widgets/braun_calculator.dart'; // 已删除
import 'calculator_page.dart'; // 引入刚才创建的全屏计算器

/// 计算器选择页 - 4种高端仿真计算器
class CalculatorSelectionPage extends StatelessWidget {
  const CalculatorSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: AppBar(
        title: const Text('选择计算器'),
        // 保持原来的品牌色，或者统一用 WeChat Green (0xFF07C160)
        backgroundColor: const Color(0xFF07C160),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildCalculatorCard(
            context,
            title: '基础计算器',
            subtitle: '适合小学生',
            icon: Icons.calculate_outlined,
            color: const Color(0xFF4CAF50), // Green
            variant: CalculatorVariant.classic,
          ),
          _buildCalculatorCard(
            context,
            title: '科学计算器',
            subtitle: '适合初高中',
            icon: Icons.functions,
            color: const Color(0xFF2196F3), // Blue
            variant: CalculatorVariant.dark, // 对应深色科学风格
          ),
          _buildCalculatorCard(
            context,
            title: '高级函数',
            subtitle: '适合大学',
            icon: Icons.auto_graph,
            color: const Color(0xFFFF9800), // Orange
            variant: CalculatorVariant.blue, // 对应蓝色风格
          ),
          _buildCalculatorCard(
            context,
            title: '图形计算器',
            subtitle: '函数绘图',
            icon: Icons.show_chart,
            color: const Color(0xFF9C27B0), // Purple
            variant: CalculatorVariant.gold, // 对应金色风格
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
    required CalculatorVariant variant,
  }) {
    return GestureDetector(
      onTap: () {
        // 跳转到全屏计算器页
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CalculatorPage(variant: variant)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
