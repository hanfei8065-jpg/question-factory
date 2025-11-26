import 'package:flutter/material.dart';
import 'package:learnest_fresh/core/constants.dart';
import 'package:learnest_fresh/models/question.dart';
import 'package:learnest_fresh/models/world.dart';
import 'package:learnest_fresh/pages/question_bank_page.dart';
import 'package:learnest_fresh/pages/ai_teacher_page.dart';
import 'package:learnest_fresh/pages/question_result_page.dart';
import 'package:learnest_fresh/pages/camera_page.dart';
import 'package:learnest_fresh/pages/calculator_page.dart';
import 'package:learnest_fresh/pages/mistake_book_page.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  Future<T?> navigateTo<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  Future<T?> replaceTo<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  void goBack<T>([T? result]) {
    return navigatorKey.currentState!.pop(result);
  }

  // 处理拍题到题库的跳转
  void navigateToQuestionBank({
    required String topic,
    required String message,
  }) {
    navigateTo(
      '/question-bank',
      arguments: {'topic': topic, 'message': message},
    );
  }

  // 处理错题到AI讲解的跳转
  void navigateToAITeacher({
    required Question question,
    required String difficulty,
  }) {
    navigateTo(
      '/ai-teacher',
      arguments: {'question': question, 'difficulty': difficulty},
    );
  }

  // 处理AI讲解到题库的跳转
  void navigateToQuestionBankFromAI({
    required String topic,
    required int level,
  }) {
    navigateTo(
      '/question-bank',
      arguments: {
        'topic': topic,
        'level': level,
        'message': Messages.getPracticeMessage(),
      },
    );
  }

  // 处理题库到结果页的跳转
  void navigateToQuestionResult({
    required bool isCorrect,
    required String question,
    required String answer,
    required String explanation,
    required String subject,
    required String difficulty,
  }) {
    navigateTo(
      '/question-result',
      arguments: {
        'isCorrect': isCorrect,
        'question': question,
        'answer': answer,
        'explanation': explanation,
        'subject': subject,
        'difficulty': difficulty,
      },
    );
  }

  // 错题本跳转
  void navigateToMistakeBook() {
    navigateTo('/mistake-book');
  }

  // 智能相机跳转
  void navigateToCamera() {
    navigateTo('/camera');
  }

  // 计算器跳转
  void navigateToCalculator() {
    navigateTo('/calculator');
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/question-bank':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => QuestionBankPage(
            topic: args['topic'] as String,
            message: args['message'] as String?,
            level: args['level'] as int?,
          ),
        );

      case '/ai-teacher':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AITeacherPage(
            question: args['question'] as Question,
            difficulty: args['difficulty'] as String,
          ),
        );

      case '/question-result':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => QuestionResultPage(
            isCorrect: args['isCorrect'] as bool,
            question: args['question'] as String,
            answer: args['answer'] as String,
            explanation: args['explanation'] as String,
            subject: args['subject'] as String? ?? '未知科目',
            difficulty: args['difficulty'] as String? ?? '未知难度',
          ),
        );

      case '/camera':
        return MaterialPageRoute(builder: (_) => const CameraPage());

      case '/calculator':
        return MaterialPageRoute(builder: (_) => const CalculatorPage());

      case '/mistake-book':
        return MaterialPageRoute(builder: (_) => const MistakeBookPage());

      default:
        return null;
    }
  }
}
