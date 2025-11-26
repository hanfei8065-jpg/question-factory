import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/test_mode_service.dart';
import 'package:learnest_fresh/pages/splash_page.dart';
import 'package:learnest_fresh/pages/camera_page.dart';
import 'package:learnest_fresh/pages/calculator_page.dart';
import 'package:learnest_fresh/pages/question_result_page.dart';
import 'package:learnest_fresh/pages/question_bank_page.dart';
import 'package:learnest_fresh/pages/ai_teacher_page.dart';
import 'package:learnest_fresh/models/question.dart' as model;
import 'package:learnest_fresh/providers/app_state.dart';
import 'package:learnest_fresh/core/constants.dart' hide Subject;
import 'package:learnest_fresh/services/navigation_service.dart';
import 'package:learnest_fresh/navigation/app_router.dart';

void main() async {
  // 加载环境变量
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppState(prefs))],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void _toggleTestMode(BuildContext context) {
    final testMode = TestModeService();
    if (testMode.isTestMode) {
      testMode.disableTestMode();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('测试模式已关闭')));
    } else {
      testMode.enableTestMode();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('测试模式已开启')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learnest AI',
      navigatorKey: NavigationService.navigatorKey,
      home: const SplashPage(),
      builder: (context, child) {
        return Scaffold(
          body: child,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _toggleTestMode(context),
            child: const Icon(Icons.bug_report),
          ),
        );
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppTheme.background,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
        ),
        buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.text,
          ),
          titleMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.text,
          ),
          titleSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.text,
          ),
          bodyLarge: TextStyle(fontSize: 16, color: AppTheme.text),
          bodyMedium: TextStyle(fontSize: 14, color: AppTheme.text),
          bodySmall: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/camera':
            return MaterialPageRoute(builder: (context) => const CameraPage());
          case '/calculator':
            return MaterialPageRoute(
              builder: (context) => const CalculatorPage(),
            );
          case '/question-result':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => QuestionResultPage(
                isCorrect: args['isCorrect'] as bool,
                question: args['question'] as String,
                answer: args['answer'] as String,
                explanation: args['explanation'] as String,
                subject: model.Subject.values
                    .firstWhere(
                      (s) =>
                          s.toString().toLowerCase() ==
                          (args['subject'] as String).toLowerCase(),
                      orElse: () => model.Subject.math,
                    )
                    .name,
                difficulty: (int.tryParse(args['difficulty'] as String) ?? 1)
                    .toString(),
              ),
            );
          default:
            return null;
        }
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

  late final List<Widget> _pages = [
    const CameraPage(),
    const QuestionBankPage(topic: '数学', message: '练习题'),
    const AITeacherPage(),
  ];

  final List<BottomNavigationBarItem> _items = const [
    BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: '拍题'),
    BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: '题库'),
    BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'AI名师'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: _items,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: const Color(0xFF6B7280),
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
