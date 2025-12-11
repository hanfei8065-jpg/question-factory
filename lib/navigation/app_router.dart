import 'package:flutter/material.dart';
import '../pages/app_camera_page.dart';
import '../pages/app_explore_setup_page.dart';
import '../pages/app_learning_report_page.dart';
import '../pages/app_profile_page.dart';
// import '../pages/advanced_calculator_page.dart'; // DELETED
// import '../pages/handwriting_workspace_page.dart'; // DELETED
import '../pages/app_review_manager_page.dart';
// import '../pages/solution_analysis_page.dart'; // DELETED
// import '../pages/practice_recommendation_page.dart'; // DELETED
// import '../pages/learning_progress_page.dart'; // DELETED
import '../models/solution_step.dart';
import '../models/knowledge_point.dart';
import '../models/difficulty_level.dart';
import '../models/user_progress.dart';
import '../navigation/main_navigator.dart';

class AppRouter {
  static const String home = '/';
  static const String camera = '/camera';
  static const String questionBank = '/question-bank';
  static const String learningReport = '/learning-report';
  static const String profile = '/profile';
  static const String calculator = '/calculator';
  static const String handwriting = '/handwriting';
  static const String review = '/review';
  static const String solution = '/solution';
  static const String practice = '/practice';
  static const String progress = '/progress';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const MainNavigator());
      case camera:
        return MaterialPageRoute(builder: (_) => const AppCameraPage());
      case questionBank:
        return MaterialPageRoute(builder: (_) => const AppQuestionBankPage());
      case learningReport:
        return MaterialPageRoute(builder: (_) => const LearningReportPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const AppProfilePage());
      case calculator:
        // DELETED: AdvancedCalculatorPage
        throw UnimplementedError('Calculator page not implemented');
      case handwriting:
        // DELETED: HandwritingWorkspacePage
        throw UnimplementedError('Handwriting page not implemented');
      case review:
        return MaterialPageRoute(builder: (_) => const ReviewManagerPage());
      case solution:
        // DELETED: SolutionAnalysisPage
        throw UnimplementedError('Solution analysis page not implemented');
      case practice:
        // DELETED: PracticeRecommendationPage
        throw UnimplementedError(
          'Practice recommendation page not implemented',
        );
      case progress:
        // DELETED: LearningProgressPage
        throw UnimplementedError('Learning progress page not implemented');
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
