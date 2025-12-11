import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/user_progress_service.dart';
import 'services/translation_service.dart';
import 'services/theme_service.dart';
import 'pages/app_home_page.dart';

void main() async {
  // 1. Critical: Bind Engine
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Lock Orientation (Portrait)
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 3. Load Env
  await dotenv.load(fileName: ".env");

  // 4. Init Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '', // Use what works
  );

  // 5. Init Services (Fixes the "Bad State" crash)
  await UserProgressService().init();

  // 6. Init Translation Service (Load JSON)
  await Tr.init();

  // 7. Init Theme Service
  await ThemeService.init();

  // 8. Run App
  runApp(const LearnistApp());
}

class LearnistApp extends StatefulWidget {
  const LearnistApp({super.key});

  @override
  State<LearnistApp> createState() => _LearnistAppState();
}

class _LearnistAppState extends State<LearnistApp> {
  @override
  void initState() {
    super.initState();
    ThemeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: Tr.locale,
      builder: (context, locale, child) {
        return MaterialApp(
          title: 'Learnist.AI',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF07C160),
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF07C160),
            scaffoldBackgroundColor: Colors.black,
            useMaterial3: true,
          ),
          themeMode: ThemeService.themeMode,
          home: const AppHomePage(),
        );
      },
    );
  }
}
