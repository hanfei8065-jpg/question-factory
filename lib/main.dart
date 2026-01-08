import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// ⬇️ 核心修复：强行指向正确的配置页文件
import 'package:learnest_fresh/pages/app_question_arena_page.dart';
// ⬇️ 确保这两个文件存在，如果报错请告诉我
import 'package:learnest_fresh/pages/app_camera_page.dart';
import 'package:learnest_fresh/pages/app_profile_page.dart';
import 'package:learnest_fresh/pages/app_splash_page.dart'; // 保持启动页

void main() {
  runApp(const LearnistApp());
}

class LearnistApp extends StatelessWidget {
  const LearnistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learnist.ai',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white, // 强制全白背景
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue, brightness: Brightness.light),
      ),
      // 这里保持原本的逻辑，先进 Splash，再进 MainContainer
      home: const MainContainer(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
    );
  }
}

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _selectedIndex = 0; // 默认首页

  // ⬇️【关键手术】：这里只允许这三个页面存在
  final List<Widget> _pages = [
    const AppCameraPage(), // 0: 拍照
    // 1: 题库配置页 (确保这里引用的类名和 app_question_arena_page.dart 里的一致)
    const AppQuestionArenaPage(
      subjectId: 'math',
      grade: 'All',
      questionLimit: 10,
    ),
    const AppProfilePage(), // 2: 个人中心
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // ⬇️ 全局唯一的 Scaffold (底座管理者)
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: Colors.white, // 纯白底座
        indicatorColor: Colors.blue.withOpacity(0.1), // 选中时淡淡的蓝色背景
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.camera_alt_outlined),
              selectedIcon: Icon(Icons.camera_alt),
              label: '拍照'),
          NavigationDestination(
              icon: Icon(Icons.library_books_outlined),
              selectedIcon: Icon(Icons.library_books),
              label: '题库'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: '我的'),
        ],
      ),
    );
  }
}
