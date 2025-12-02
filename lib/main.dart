import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'pages/app_question_bank_page.dart';
import 'pages/app_camera_page.dart';
import 'pages/app_profile_page.dart';
import 'services/user_progress_service.dart';
import 'services/translation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 1. Load .env file
  try {
    await dotenv.load(fileName: '.env');
    print('✅ .env loaded successfully');
  } catch (e) {
    print('⚠️ Failed to load .env: $e');
  }

  // ✅ 2. Initialize Supabase
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseKey = dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';

  if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
        debug: true, // 开发模式下显示日志
      );
      print('✅ Supabase initialized: $supabaseUrl');
    } catch (e) {
      print('❌ Failed to initialize Supabase: $e');
    }
  } else {
    print('⚠️ SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY not found in .env');
  }

  // 3. Initialize UserProgressService
  await UserProgressService().init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const LearnistApp());
}

class LearnistApp extends StatelessWidget {
  const LearnistApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap with ValueListenableBuilder for instant language switching
    return ValueListenableBuilder<String>(
      valueListenable: Tr.currentLocale,
      builder: (context, locale, child) {
        return MaterialApp(
          title: 'Learnist.AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme, // Using AppTheme with WeChat color standards
          home: const MainNavigator(),
        );
      },
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AppCameraPage(),
    const AppQuestionBankPage(),
    const AppProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF07C160),
        unselectedItemColor: const Color(0xFF191919),
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.normal,
        ),
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 0 ? Icons.camera_alt : Icons.camera_alt_outlined,
              size: 26,
            ),
            label: Tr.g('nav_scan'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 1 ? Icons.menu_book : Icons.menu_book_outlined,
              size: 26,
            ),
            label: Tr.g('nav_arena'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 2 ? Icons.person : Icons.person_outline,
              size: 26,
            ),
            label: Tr.g('nav_profile'),
          ),
        ],
      ),
    );
  }
}
