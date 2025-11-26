import 'package:flutter/material.dart';
import 'package:learnest_fresh/pages/camera_page.dart';
import 'package:learnest_fresh/pages/question_bank_page.dart';
import 'package:learnest_fresh/pages/ai_teacher_page.dart';
import 'package:learnest_fresh/pages/learning_report_page.dart';
import 'package:learnest_fresh/pages/profile_page.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    CameraPage(),
    QuestionBankPage(topic: ''),
    AITeacherPage(),
    LearningReportPage(),
    ProfilePage(),
  ];

  final List<Map<String, dynamic>> _navItems = const [
    {'icon': Icons.camera_alt, 'label': '拍题'},
    {'icon': Icons.emoji_events, 'label': '题库'},
    {'icon': Icons.psychology, 'label': 'AI名师'},
    {'icon': Icons.analytics, 'label': '统计'},
    {'icon': Icons.person, 'label': '我的'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                return _buildNavItem(
                  icon: _navItems[index]['icon'],
                  label: _navItems[index]['label'],
                  isSelected: _currentIndex == index,
                  onTap: () => setState(() => _currentIndex = index),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF00A86B)
                  : const Color(0xFF9CA3AF),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? const Color(0xFF00A86B)
                    : const Color(0xFF9CA3AF),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
