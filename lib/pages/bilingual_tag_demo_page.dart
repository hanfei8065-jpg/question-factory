import 'package:flutter/material.dart';
import '../widgets/bilingual_tag.dart';

/// 📱 双语标签演示页面
///
/// 用于展示各种标签样式和使用场景
class BilingualTagDemoPage extends StatelessWidget {
  const BilingualTagDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('双语标签演示'),
        backgroundColor: const Color(0xFF07C160),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========================================
            // 1. 标准双语标签
            // ========================================
            _buildSection(
              title: '1. 标准双语标签',
              description: '工厂生成的标准格式',
              child: BilingualTagRow(
                tags: const [
                  'Linear Equations (一元一次方程)',
                  'Slope (斜率)',
                  'Graphing (函数图像)',
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ========================================
            // 2. 物理标签示例
            // ========================================
            _buildSection(
              title: '2. 物理学标签',
              description: '牛顿力学相关',
              child: BilingualTagRow(
                tags: const [
                  'Kinematics (运动学)',
                  'Velocity (速度)',
                  'Acceleration (加速度)',
                  "Newton's Laws (牛顿定律)",
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ========================================
            // 3. 化学标签示例
            // ========================================
            _buildSection(
              title: '3. 化学标签',
              description: '元素周期表相关',
              child: BilingualTagRow(
                tags: const [
                  'Chemical Bonds (化学键)',
                  'Periodic Table (元素周期表)',
                  'Ionic Compounds (离子化合物)',
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ========================================
            // 4. 紧凑模式
            // ========================================
            _buildSection(
              title: '4. 紧凑模式',
              description: '节省空间，仅显示英文',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  BilingualTag(tag: 'Linear Equations (一元一次方程)', compact: true),
                  BilingualTag(tag: 'Slope (斜率)', compact: true),
                  BilingualTag(
                    tag: 'Kinematics (运动学)',
                    compact: true,
                    preferChinese: true, // 优先显示中文
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ========================================
            // 5. 限制显示数量
            // ========================================
            _buildSection(
              title: '5. 限制显示数量',
              description: '最多显示3个标签 + "more" 提示',
              child: BilingualTagRow(
                tags: const [
                  'Linear Equations (一元一次方程)',
                  'Slope (斜率)',
                  'Graphing (函数图像)',
                  'Quadratic Functions (二次函数)',
                  'Parabola (抛物线)',
                ],
                maxTags: 3,
              ),
            ),

            const SizedBox(height: 24),

            // ========================================
            // 6. 带标题的标签区域
            // ========================================
            _buildSection(
              title: '6. 标签区域组件',
              description: '包含标题和图标',
              child: const TagSection(
                title: 'Knowledge Points',
                icon: Icons.bookmark,
                tags: [
                  'Linear Equations (一元一次方程)',
                  'Slope (斜率)',
                  'Graphing (函数图像)',
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ========================================
            // 7. 单语言标签（回退模式）
            // ========================================
            _buildSection(
              title: '7. 单语言标签',
              description: '没有中文翻译时的显示',
              child: BilingualTagRow(
                tags: const ['Mathematics', 'Grade 10', 'Advanced'],
              ),
            ),

            const SizedBox(height: 24),

            // ========================================
            // 8. 混合标签
            // ========================================
            _buildSection(
              title: '8. 混合标签',
              description: '双语和单语言混合',
              child: BilingualTagRow(
                tags: const [
                  'Linear Equations (一元一次方程)',
                  'Mathematics',
                  'Slope (斜率)',
                  'Grade 10',
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ========================================
            // 使用说明
            // ========================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF07C160).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF07C160),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '使用说明',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• 标签格式: "English (Chinese)"\n'
                    '• 学生看英文，家长看中文\n'
                    '• 工厂自动生成，零维护成本\n'
                    '• 支持紧凑模式和限制数量\n'
                    '• 自动回退到单语言模式',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            description,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
