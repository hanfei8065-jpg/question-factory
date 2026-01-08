import 'package:flutter/material.dart';
import 'package:learnest_fresh/pages/app_question_arena_page.dart';
import 'package:learnest_fresh/pages/app_camera_page.dart';
import 'package:learnest_fresh/pages/app_profile_page.dart';
import 'package:learnest_fresh/pages/app_splash_page.dart';
import 'package:learnest_fresh/main.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Map<String, WidgetBuilder> get routes => {
        '/splash': (context) => const AppSplashPage(),
        '/main': (context) => const MainContainer(),
        '/camera': (context) => const AppCameraPage(),
        '/explore_setup': (context) => const AppQuestionArenaPage(
              subjectId: 'math',
              grade: 'All',
              questionLimit: 10,
            ),
        '/profile': (context) => const AppProfilePage(),
      };

  static Future<T?>? navigateTo<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState
        ?.pushNamed<T>(routeName, arguments: arguments);
  }

  static void goBack() {
    return navigatorKey.currentState?.pop();
  }
}
