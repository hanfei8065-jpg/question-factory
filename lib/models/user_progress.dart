import 'dart:convert';

enum PracticeStatus {
  notStarted,
  inProgress,
  needMorePractice,
  needReview,
  mastered,
}

class UserProgress {
  final String userId;
  final String currentLevelId;
  final int goldCoin;
  final int exp;
  final int streakDays;
  final List<String> wrongQuestionIds;
  final Map<String, int> levelStars; // 关卡ID -> 星级（0-3）
  final List<String> completedLevels;
  final List<String> unlockedWorlds;
  final Map<String, dynamic> achievements; // 成就系统
  final DateTime lastPlayDate;

  // 新增学习进度跟踪字段
  final Map<String, double> knowledgePointMastery; // 知识点ID -> 掌握度(0.0-1.0)
  final Map<String, List<double>> masteryHistory; // 知识点ID -> 掌握度历史记录
  final Map<String, int> practiceCount; // 知识点ID -> 练习次数
  final Map<String, DateTime> lastPracticeDate; // 知识点ID -> 最后练习时间
  final Map<String, List<DateTime>> practiceHistory; // 知识点ID -> 练习历史

  UserProgress({
    required this.userId,
    required this.currentLevelId,
    required this.goldCoin,
    required this.exp,
    required this.streakDays,
    required this.wrongQuestionIds,
    required this.levelStars,
    required this.completedLevels,
    required this.unlockedWorlds,
    required this.achievements,
    required this.lastPlayDate,
    this.knowledgePointMastery = const {},
    this.masteryHistory = const {},
    this.practiceCount = const {},
    this.lastPracticeDate = const {},
    this.practiceHistory = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentLevelId': currentLevelId,
      'goldCoin': goldCoin,
      'exp': exp,
      'streakDays': streakDays,
      'wrongQuestionIds': wrongQuestionIds,
      'levelStars': levelStars,
      'completedLevels': completedLevels,
      'unlockedWorlds': unlockedWorlds,
      'achievements': achievements,
      'lastPlayDate': lastPlayDate.toIso8601String(),
      'knowledgePointMastery': knowledgePointMastery,
      'masteryHistory': masteryHistory.map(
        (key, value) => MapEntry(key, value.toList()),
      ),
      'practiceCount': practiceCount,
      'lastPracticeDate': lastPracticeDate.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
      'practiceHistory': practiceHistory.map(
        (key, value) =>
            MapEntry(key, value.map((date) => date.toIso8601String()).toList()),
      ),
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userId: json['userId'],
      currentLevelId: json['currentLevelId'],
      goldCoin: json['goldCoin'],
      exp: json['exp'],
      streakDays: json['streakDays'],
      wrongQuestionIds: List<String>.from(json['wrongQuestionIds']),
      levelStars: Map<String, int>.from(json['levelStars']),
      completedLevels: List<String>.from(json['completedLevels']),
      unlockedWorlds: List<String>.from(json['unlockedWorlds']),
      achievements: json['achievements'],
      lastPlayDate: DateTime.parse(json['lastPlayDate']),
      knowledgePointMastery: Map<String, double>.from(
        json['knowledgePointMastery'] ?? {},
      ),
      masteryHistory:
          (json['masteryHistory'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, List<double>.from(value)),
          ) ??
          {},
      practiceCount: Map<String, int>.from(json['practiceCount'] ?? {}),
      lastPracticeDate:
          (json['lastPracticeDate'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, DateTime.parse(value)),
          ) ??
          {},
      practiceHistory:
          (json['practiceHistory'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              (value as List).map((date) => DateTime.parse(date)).toList(),
            ),
          ) ??
          {},
    );
  }

  UserProgress copyWith({
    String? currentLevelId,
    int? goldCoin,
    int? exp,
    int? streakDays,
    List<String>? wrongQuestionIds,
    Map<String, int>? levelStars,
    List<String>? completedLevels,
    List<String>? unlockedWorlds,
    Map<String, dynamic>? achievements,
    DateTime? lastPlayDate,
    Map<String, double>? knowledgePointMastery,
    Map<String, List<double>>? masteryHistory,
    Map<String, int>? practiceCount,
    Map<String, DateTime>? lastPracticeDate,
    Map<String, List<DateTime>>? practiceHistory,
  }) {
    return UserProgress(
      userId: this.userId,
      currentLevelId: currentLevelId ?? this.currentLevelId,
      goldCoin: goldCoin ?? this.goldCoin,
      exp: exp ?? this.exp,
      streakDays: streakDays ?? this.streakDays,
      wrongQuestionIds: wrongQuestionIds ?? this.wrongQuestionIds,
      levelStars: levelStars ?? this.levelStars,
      completedLevels: completedLevels ?? this.completedLevels,
      unlockedWorlds: unlockedWorlds ?? this.unlockedWorlds,
      achievements: achievements ?? this.achievements,
      lastPlayDate: lastPlayDate ?? this.lastPlayDate,
      knowledgePointMastery:
          knowledgePointMastery ?? this.knowledgePointMastery,
      masteryHistory: masteryHistory ?? this.masteryHistory,
      practiceCount: practiceCount ?? this.practiceCount,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
      practiceHistory: practiceHistory ?? this.practiceHistory,
    );
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  // 计算整体学习进度
  double calculateOverallProgress() {
    if (knowledgePointMastery.isEmpty) return 0.0;
    return knowledgePointMastery.values.reduce((a, b) => a + b) /
        knowledgePointMastery.length;
  }

  // 获取最长连续学习天数
  int getLongestStreak() {
    return streakDays; // 简单实现，实际可能需要更复杂的逻辑
  }

  // 获取每周学习趋势
  Map<DateTime, int> getWeeklyTrend() {
    final now = DateTime.now();
    final result = <DateTime, int>{};

    // 获取过去7天的日期
    for (int i = 0; i < 7; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      result[date] = 0;
    }

    // 统计每天练习的知识点数量
    for (var history in practiceHistory.values) {
      for (var date in history) {
        final practiceDate = DateTime(date.year, date.month, date.day);
        if (result.containsKey(practiceDate)) {
          result[practiceDate] = (result[practiceDate] ?? 0) + 1;
        }
      }
    }

    return result;
  }

  // 获取知识点练习状态
  PracticeStatus getPracticeStatus(String pointId) {
    if (!knowledgePointMastery.containsKey(pointId)) {
      return PracticeStatus.notStarted;
    }

    final mastery = knowledgePointMastery[pointId] ?? 0.0;
    final lastPractice = lastPracticeDate[pointId];

    if (mastery >= 0.9) {
      return PracticeStatus.mastered;
    }

    if (lastPractice != null) {
      final daysSinceLastPractice = DateTime.now()
          .difference(lastPractice)
          .inDays;

      if (daysSinceLastPractice > 7 && mastery > 0.5) {
        return PracticeStatus.needReview;
      }
    }

    if (mastery < 0.6) {
      return PracticeStatus.needMorePractice;
    }

    return PracticeStatus.inProgress;
  }

  // 更新知识点掌握度
  UserProgress updateMastery(String pointId, double newMastery) {
    if (newMastery < 0.0 || newMastery > 1.0) {
      throw ArgumentError('Mastery must be between 0.0 and 1.0');
    }

    return copyWith(
      knowledgePointMastery: Map.from(knowledgePointMastery)
        ..update(pointId, (_) => newMastery, ifAbsent: () => newMastery),
      masteryHistory: Map.from(masteryHistory)
        ..update(
          pointId,
          (list) => list..add(newMastery),
          ifAbsent: () => [newMastery],
        ),
      practiceCount: Map.from(practiceCount)
        ..update(pointId, (count) => count + 1, ifAbsent: () => 1),
      lastPracticeDate: Map.from(
        lastPracticeDate,
      )..update(pointId, (_) => DateTime.now(), ifAbsent: () => DateTime.now()),
      practiceHistory: Map.from(practiceHistory)
        ..update(
          pointId,
          (list) => list..add(DateTime.now()),
          ifAbsent: () => [DateTime.now()],
        ),
    );
  }
}
