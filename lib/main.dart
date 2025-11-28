import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'pages/splash_screen.dart';
import 'pages/app_question_bank_page.dart';
import 'pages/app_camera_page.dart';
import 'pages/app_profile_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const LearnistApp());
}

class LearnistApp extends StatefulWidget {
  const LearnistApp({super.key});

  @override
  State<LearnistApp> createState() => _LearnistAppState();
}

class _LearnistAppState extends State<LearnistApp> {
  Locale _locale = const Locale('zh'); // 默认中文

  void _changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learnist.AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        primaryColor: const Color(0xFF358373),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF358373),
          primary: const Color(0xFF358373),
          secondary: const Color(0xFF5FCEB3),
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      locale: _locale,
  // 本地化相关配置已移除，直接硬编码中文
      home: const SplashScreen(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  final void Function(Locale)? onLocaleChange;
  const MainNavigator({super.key, this.onLocaleChange});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<Locale> _locales = const [
    Locale('zh'),
    Locale('en'),
    Locale('ja'),
    Locale('es'),
  ];

  final List<String> _localeNames = const ['中文', 'English', '日本語', 'Español'];

  final List<Widget> _pages = [
    const AppCameraPage(),
    const AppQuestionBankPage(),
    const AppProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final List<BottomNavigationBarItem> _items = [
      BottomNavigationBarItem(
        icon: const Icon(Icons.camera_alt_rounded, size: 32),
        label: '拍题',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.menu_book_rounded),
        label: '题库',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person_rounded),
        label: '我的',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('题库', style: const TextStyle(color: Color(0xFF358373))),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.language, color: Color(0xFF358373)),
            onSelected: (idx) {
              widget.onLocaleChange?.call(_locales[idx]);
            },
            itemBuilder: (context) => List.generate(
              _locales.length,
              (idx) =>
                  PopupMenuItem(value: idx, child: Text(_localeNames[idx])),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: _items,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF358373),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          elevation: 0,
        ),
      ),
    );
  }
}
