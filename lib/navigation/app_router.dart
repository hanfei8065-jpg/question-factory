import 'package:flutter/material.dart';
import '../pages/onboarding_page.dart';
import '../pages/camera_page.dart';
import '../pages/question_bank_page.dart';
import '../pages/ai_teacher_page.dart';
import '../pages/learning_report_page.dart';
import '../pages/profile_page.dart';
import '../pages/batch_photo_mode.dart';
import '../pages/advanced_calculator_page.dart';
import '../pages/handwriting_workspace_page.dart';
import '../pages/review_manager_page.dart';
import '../pages/solution_analysis_page.dart';
import '../pages/practice_recommendation_page.dart';
import '../pages/learning_progress_page.dart';
import '../models/solution_step.dart';
import '../models/knowledge_point.dart';
import '../models/difficulty_level.dart';
import '../models/user_progress.dart';
import '../navigation/main_navigator.dart';

class AppRouter {
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String camera = '/camera';
  static const String questionBank = '/question-bank';
  static const String aiTeacher = '/ai-teacher';
  static const String learningReport = '/learning-report';
  static const String profile = '/profile';
  static const String batchMode = '/batch-mode';
  static const String calculator = '/calculator';
  static const String handwriting = '/handwriting';
  static const String review = '/review';
  static const String solution = '/solution';
  static const String practice = '/practice';
  static const String progress = '/progress';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case home:
        return MaterialPageRoute(builder: (_) => const MainNavigator());
      case camera:
        return MaterialPageRoute(builder: (_) => const CameraPage());
      case questionBank:
        return MaterialPageRoute(
          builder: (_) => const QuestionBankPage(topic: ''),
        );
      case aiTeacher:
        return MaterialPageRoute(builder: (_) => const AITeacherPage());
      case learningReport:
        return MaterialPageRoute(builder: (_) => const LearningReportPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case batchMode:
        return MaterialPageRoute(builder: (_) => const BatchPhotoMode());
      case calculator:
        return MaterialPageRoute(
          builder: (_) => const AdvancedCalculatorPage(),
        );
      case handwriting:
        return MaterialPageRoute(
          builder: (_) => const HandwritingWorkspacePage(),
        );
      case review:
        return MaterialPageRoute(builder: (_) => const ReviewManagerPage());
      case solution:
        return MaterialPageRoute(
          builder: (_) => SolutionAnalysisPage(
            steps: settings.arguments as List<SolutionStep>,
            knowledgePoints: [],
          ),
        );
      case practice:
        return MaterialPageRoute(
          builder: (_) => PracticeRecommendationPage(
            masterPoints: settings.arguments as List<KnowledgePoint>,
            weakPoints: [],
            currentLevel: DifficultyLevel(
              level: 1,
              name: '基础',
              description: '基础题型练习',
              characteristics: [],
              recommendedTopics: [],
              recommendedDailyCount: 10,
            ),
          ),
        );
      case progress:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => LearningProgressPage(
            progress: args['progress'] as UserProgress,
            knowledgePoints: args['knowledgePoints'] as List<KnowledgePoint>,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
