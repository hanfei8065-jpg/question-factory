import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'camera_page.dart';

/// 主页面 - 包含底部导航栏
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const CameraPage(),           // 拍题
    const QuestionBankPage(),     // 题库
    const AITutorPage(),          // AI名师
    const ProfilePage(),          // 我的
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.brandPrimary,
        unselectedItemColor: AppTheme.textTertiary,
        selectedLabelStyle: TextStyle(
          fontSize: AppTheme.fontSizeXS,
          fontWeight: AppTheme.fontWeightMedium,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: AppTheme.fontSizeXS,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            activeIcon: Icon(Icons.camera_alt),
            label: '拍题',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            activeIcon: Icon(Icons.library_books),
            label: '题库',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'AI名师',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

/// 题库页面（占位）
class QuestionBankPage extends StatelessWidget {
  const QuestionBankPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('题库'),
        backgroundColor: AppTheme.brandPrimary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books,
              size: 80,
              color: AppTheme.textTertiary,
            ),
            SizedBox(height: AppTheme.spacing16),
            Text(
              '题库功能',
              style: TextStyle(
                fontSize: AppTheme.fontSizeXL,
                fontWeight: AppTheme.fontWeightBold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: AppTheme.spacing8),
            Text(
              '敬请期待',
              style: TextStyle(
                fontSize: AppTheme.fontSizeM,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// AI名师页面（占位）
class AITutorPage extends StatelessWidget {
  const AITutorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI名师'),
        backgroundColor: AppTheme.brandPrimary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 80,
              color: AppTheme.textTertiary,
            ),
            SizedBox(height: AppTheme.spacing16),
            Text(
              'AI名师功能',
              style: TextStyle(
                fontSize: AppTheme.fontSizeXL,
                fontWeight: AppTheme.fontWeightBold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: AppTheme.spacing8),
            Text(
              '敬请期待',
              style: TextStyle(
                fontSize: AppTheme.fontSizeM,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 我的页面（占位）
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        backgroundColor: AppTheme.brandPrimary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 80,
              color: AppTheme.textTertiary,
            ),
            SizedBox(height: AppTheme.spacing16),
            Text(
              '个人中心',
              style: TextStyle(
                fontSize: AppTheme.fontSizeXL,
                fontWeight: AppTheme.fontWeightBold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: AppTheme.spacing8),
            Text(
              '包含历史记录、练习统计等',
              style: TextStyle(
                fontSize: AppTheme.fontSizeM,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
