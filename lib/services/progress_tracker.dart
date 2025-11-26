import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/question.dart';
import 'difficulty_estimator.dart';

class ProgressTracker {
  static const String _progressKey = 'user_learning_progress';
  static const String _statsKey = 'learning_statistics';

  // 用户学习统计
  late LearningStatistics _statistics;

  Future<void> init() async {
    await _loadStatistics();
  }

  // 记录题目完成情况
  Future<void> recordQuestionCompletion(
    Question question,
    bool isCorrect,
    Duration solveTime,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // 更新统计数据
    _statistics.totalQuestions++;
    if (isCorrect) _statistics.correctQuestions++;
    _statistics.totalTimeSpent += solveTime.inSeconds;

    // 记录难度分布
    final difficulty = DifficultyEstimator.estimateQuestionDifficulty(question);
    _statistics.difficultyDistribution[difficulty] =
        (_statistics.difficultyDistribution[difficulty] ?? 0) + 1;

    // 保存统计数据
    await prefs.setString(_statsKey, jsonEncode(_statistics.toJson()));

    // 更新进度数据
    final progressData = await _loadProgressData();
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (!progressData.containsKey(today)) {
      progressData[today] = DailyProgress();
    }

    final dailyProgress = progressData[today]!;
    dailyProgress.questionsCompleted++;
    if (isCorrect) dailyProgress.correctAnswers++;
    dailyProgress.timeSpent += solveTime.inSeconds;

    await prefs.setString(_progressKey, jsonEncode(progressData));
  }

  // 获取学习统计
  Future<LearningStatistics> getStatistics() async {
    return _statistics;
  }

  // 获取最近N天的进度
  Future<Map<String, DailyProgress>> getRecentProgress(int days) async {
    final progressData = await _loadProgressData();
    final now = DateTime.now();
    final result = <String, DailyProgress>{};

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      result[dateStr] = progressData[dateStr] ?? DailyProgress();
    }

    return result;
  }

  // 获取建议的下一步学习内容
  Future<LearningRecommendation> getRecommendation() async {
    final stats = await getStatistics();
    final accuracy = stats.correctQuestions / stats.totalQuestions;
    final averageTime = stats.totalTimeSpent / stats.totalQuestions;

    // 根据准确率和平均用时评估用户水平
    int estimatedLevel = _estimateUserLevel(accuracy, averageTime);

    // 获取推荐的难度等级
    final recommendedLevels = DifficultyEstimator.recommendDifficultyLevels(
      estimatedLevel,
    );

    return LearningRecommendation(
      currentLevel: estimatedLevel,
      recommendedDifficulties: recommendedLevels,
      focusAreas: _identifyFocusAreas(stats),
    );
  }

  // 加载统计数据
  Future<void> _loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey);

    if (statsJson != null) {
      final Map<String, dynamic> data = jsonDecode(statsJson);
      _statistics = LearningStatistics.fromJson(data);
    } else {
      _statistics = LearningStatistics();
    }
  }

  // 加载进度数据
  Future<Map<String, DailyProgress>> _loadProgressData() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString(_progressKey);

    if (progressJson != null) {
      final Map<String, dynamic> data = jsonDecode(progressJson);
      return data.map(
        (key, value) => MapEntry(
          key,
          DailyProgress.fromJson(value as Map<String, dynamic>),
        ),
      );
    }

    return {};
  }

  // 评估用户水平
  int _estimateUserLevel(double accuracy, double averageTime) {
    // 基于准确率的基础分数
    double score = accuracy * 5;

    // 根据平均用时调整分数
    if (averageTime < 60) {
      // 小于1分钟
      score += 1;
    } else if (averageTime > 300) {
      // 大于5分钟
      score -= 1;
    }

    // 确保分数在1-5之间
    return score.round().clamp(1, 5);
  }

  // 识别需要重点关注的领域
  List<String> _identifyFocusAreas(LearningStatistics stats) {
    final focusAreas = <String>[];

    // 分析难度分布
    final distribution = stats.difficultyDistribution;
    int maxDifficulty = 0;
    int maxCount = 0;

    distribution.forEach((difficulty, count) {
      if (count > maxCount) {
        maxCount = count;
        maxDifficulty = difficulty;
      }
    });

    // 根据数据给出建议
    if (stats.correctQuestions / stats.totalQuestions < 0.6) {
      focusAreas.add('提高基础知识掌握');
    }

    if (maxDifficulty <= 2 && stats.totalQuestions > 20) {
      focusAreas.add('尝试更具挑战性的题目');
    }

    if (stats.totalQuestions < 10) {
      focusAreas.add('增加练习量');
    }

    return focusAreas;
  }
}

class LearningStatistics {
  int totalQuestions;
  int correctQuestions;
  int totalTimeSpent; // 以秒为单位
  Map<int, int> difficultyDistribution; // 难度等级 -> 题目数量

  LearningStatistics({
    this.totalQuestions = 0,
    this.correctQuestions = 0,
    this.totalTimeSpent = 0,
    Map<int, int>? difficultyDistribution,
  }) : difficultyDistribution = difficultyDistribution ?? {};

  Map<String, dynamic> toJson() {
    return {
      'totalQuestions': totalQuestions,
      'correctQuestions': correctQuestions,
      'totalTimeSpent': totalTimeSpent,
      'difficultyDistribution': difficultyDistribution,
    };
  }

  factory LearningStatistics.fromJson(Map<String, dynamic> json) {
    return LearningStatistics(
      totalQuestions: json['totalQuestions'] as int,
      correctQuestions: json['correctQuestions'] as int,
      totalTimeSpent: json['totalTimeSpent'] as int,
      difficultyDistribution: Map<int, int>.from(
        json['difficultyDistribution'] as Map,
      ),
    );
  }
}

class DailyProgress {
  int questionsCompleted;
  int correctAnswers;
  int timeSpent; // 以秒为单位

  DailyProgress({
    this.questionsCompleted = 0,
    this.correctAnswers = 0,
    this.timeSpent = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionsCompleted': questionsCompleted,
      'correctAnswers': correctAnswers,
      'timeSpent': timeSpent,
    };
  }

  factory DailyProgress.fromJson(Map<String, dynamic> json) {
    return DailyProgress(
      questionsCompleted: json['questionsCompleted'] as int,
      correctAnswers: json['correctAnswers'] as int,
      timeSpent: json['timeSpent'] as int,
    );
  }
}

class LearningRecommendation {
  final int currentLevel;
  final List<int> recommendedDifficulties;
  final List<String> focusAreas;

  LearningRecommendation({
    required this.currentLevel,
    required this.recommendedDifficulties,
    required this.focusAreas,
  });
}
