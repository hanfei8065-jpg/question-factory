import 'package:shared_preferences.dart';
import 'dart:convert';

class LearningAnalytics {
  // 学习时间分析
  static const String _timeStatsKey = 'learning_time_stats';
  // 错题分析
  static const String _mistakeStatsKey = 'mistake_stats';
  // 知识点掌握度
  static const String _topicMasteryKey = 'topic_mastery';
  // 学习习惯分析
  static const String _learningHabitsKey = 'learning_habits';

  // 记录学习时间
  static Future<void> recordLearningTime(String topic, int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    final stats = _getTimeStats(prefs);

    if (!stats.containsKey(topic)) {
      stats[topic] = TimeStats();
    }

    final topicStats = stats[topic]!;
    topicStats.totalMinutes += minutes;
    topicStats.sessions++;

    // 记录学习高峰时间
    final hour = DateTime.now().hour;
    topicStats.peakHours[hour] = (topicStats.peakHours[hour] ?? 0) + 1;

    await prefs.setString(_timeStatsKey, jsonEncode(stats));
  }

  // 记录错题
  static Future<void> recordMistake(
    String topic,
    String questionId,
    String reason,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final stats = _getMistakeStats(prefs);

    if (!stats.containsKey(topic)) {
      stats[topic] = MistakeStats();
    }

    final topicStats = stats[topic]!;
    topicStats.mistakeCount++;
    topicStats.reasons[reason] = (topicStats.reasons[reason] ?? 0) + 1;

    if (!topicStats.questionIds.contains(questionId)) {
      topicStats.questionIds.add(questionId);
    }

    await prefs.setString(_mistakeStatsKey, jsonEncode(stats));
  }

  // 更新知识点掌握度
  static Future<void> updateTopicMastery(String topic, double score) async {
    final prefs = await SharedPreferences.getInstance();
    final mastery = _getTopicMastery(prefs);

    if (!mastery.containsKey(topic)) {
      mastery[topic] = TopicMastery();
    }

    final topicMastery = mastery[topic]!;
    topicMastery.scores.add(score);
    topicMastery.updatedAt = DateTime.now();

    // 计算进步率
    if (topicMastery.scores.length >= 2) {
      final previousScore = topicMastery.scores[topicMastery.scores.length - 2];
      topicMastery.progressRate = (score - previousScore) / previousScore * 100;
    }

    await prefs.setString(_topicMasteryKey, jsonEncode(mastery));
  }

  // 记录学习习惯
  static Future<void> recordLearningHabit(LearningActivity activity) async {
    final prefs = await SharedPreferences.getInstance();
    final habits = _getLearningHabits(prefs);

    final date = DateTime.now();
    final dateKey = '${date.year}-${date.month}-${date.day}';

    if (!habits.containsKey(dateKey)) {
      habits[dateKey] = DailyHabits();
    }

    final dailyHabits = habits[dateKey]!;

    switch (activity.type) {
      case ActivityType.study:
        dailyHabits.studyTime += activity.duration;
        break;
      case ActivityType.review:
        dailyHabits.reviewTime += activity.duration;
        break;
      case ActivityType.practice:
        dailyHabits.practiceCount++;
        break;
    }

    dailyHabits.activities.add(activity);

    await prefs.setString(_learningHabitsKey, jsonEncode(habits));
  }

  // 获取学习建议
  static Future<List<LearningAdvice>> getPersonalizedAdvice() async {
    final prefs = await SharedPreferences.getInstance();
    final timeStats = _getTimeStats(prefs);
    final mistakeStats = _getMistakeStats(prefs);
    final mastery = _getTopicMastery(prefs);
    final habits = _getLearningHabits(prefs);

    final advice = <LearningAdvice>[];

    // 分析学习时间分布
    final totalTime = timeStats.values
        .map((stats) => stats.totalMinutes)
        .fold(0, (a, b) => a + b);

    if (totalTime < 120) {
      // 每天少于2小时
      advice.add(
        LearningAdvice(
          type: AdviceType.timeManagement,
          message: '建议每天保持2-3小时的学习时间',
          priority: 1,
        ),
      );
    }

    // 分析错题模式
    for (final topic in mistakeStats.keys) {
      final stats = mistakeStats[topic]!;
      if (stats.mistakeCount > 10) {
        final mostCommonReason = stats.reasons.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;

        advice.add(
          LearningAdvice(
            type: AdviceType.errorPattern,
            message: '在$topic上常见错误原因是$mostCommonReason，建议重点关注',
            priority: 2,
          ),
        );
      }
    }

    // 分析知识点掌握
    for (final topic in mastery.keys) {
      final topicMastery = mastery[topic]!;
      if (topicMastery.getAverageScore() < 70) {
        advice.add(
          LearningAdvice(
            type: AdviceType.weakTopic,
            message: '$topic的掌握度较低，需要加强练习',
            priority: 3,
          ),
        );
      }
    }

    // 分析学习习惯
    final recentHabits = _getRecentHabits(habits);
    if (recentHabits.reviewTime / recentHabits.studyTime < 0.3) {
      advice.add(
        LearningAdvice(
          type: AdviceType.studyHabit,
          message: '复习时间占比较少，建议增加复习频率',
          priority: 2,
        ),
      );
    }

    // 按优先级排序
    advice.sort((a, b) => a.priority.compareTo(b.priority));

    return advice;
  }

  // 辅助方法
  static Map<String, TimeStats> _getTimeStats(SharedPreferences prefs) {
    final json = prefs.getString(_timeStatsKey);
    if (json == null) return {};

    final Map<String, dynamic> data = jsonDecode(json);
    return data.map(
      (key, value) =>
          MapEntry(key, TimeStats.fromJson(value as Map<String, dynamic>)),
    );
  }

  static Map<String, MistakeStats> _getMistakeStats(SharedPreferences prefs) {
    final json = prefs.getString(_mistakeStatsKey);
    if (json == null) return {};

    final Map<String, dynamic> data = jsonDecode(json);
    return data.map(
      (key, value) =>
          MapEntry(key, MistakeStats.fromJson(value as Map<String, dynamic>)),
    );
  }

  static Map<String, TopicMastery> _getTopicMastery(SharedPreferences prefs) {
    final json = prefs.getString(_topicMasteryKey);
    if (json == null) return {};

    final Map<String, dynamic> data = jsonDecode(json);
    return data.map(
      (key, value) =>
          MapEntry(key, TopicMastery.fromJson(value as Map<String, dynamic>)),
    );
  }

  static Map<String, DailyHabits> _getLearningHabits(SharedPreferences prefs) {
    final json = prefs.getString(_learningHabitsKey);
    if (json == null) return {};

    final Map<String, dynamic> data = jsonDecode(json);
    return data.map(
      (key, value) =>
          MapEntry(key, DailyHabits.fromJson(value as Map<String, dynamic>)),
    );
  }

  static AggregatedHabits _getRecentHabits(Map<String, DailyHabits> habits) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    return habits.entries
        .where((entry) {
          final date = DateTime.parse(entry.key);
          return date.isAfter(sevenDaysAgo);
        })
        .map((entry) => entry.value)
        .fold(AggregatedHabits(), (agg, habits) => agg..add(habits));
  }
}

// 数据模型
class TimeStats {
  int totalMinutes;
  int sessions;
  Map<int, int> peakHours;

  TimeStats({
    this.totalMinutes = 0,
    this.sessions = 0,
    Map<int, int>? peakHours,
  }) : peakHours = peakHours ?? {};

  Map<String, dynamic> toJson() => {
    'totalMinutes': totalMinutes,
    'sessions': sessions,
    'peakHours': peakHours,
  };

  factory TimeStats.fromJson(Map<String, dynamic> json) => TimeStats(
    totalMinutes: json['totalMinutes'] as int,
    sessions: json['sessions'] as int,
    peakHours: Map<int, int>.from(json['peakHours'] as Map),
  );
}

class MistakeStats {
  int mistakeCount;
  Map<String, int> reasons;
  List<String> questionIds;

  MistakeStats({
    this.mistakeCount = 0,
    Map<String, int>? reasons,
    List<String>? questionIds,
  }) : reasons = reasons ?? {},
       questionIds = questionIds ?? [];

  Map<String, dynamic> toJson() => {
    'mistakeCount': mistakeCount,
    'reasons': reasons,
    'questionIds': questionIds,
  };

  factory MistakeStats.fromJson(Map<String, dynamic> json) => MistakeStats(
    mistakeCount: json['mistakeCount'] as int,
    reasons: Map<String, int>.from(json['reasons'] as Map),
    questionIds: List<String>.from(json['questionIds'] as List),
  );
}

class TopicMastery {
  List<double> scores;
  double progressRate;
  DateTime updatedAt;

  TopicMastery({
    List<double>? scores,
    this.progressRate = 0.0,
    DateTime? updatedAt,
  }) : scores = scores ?? [],
       updatedAt = updatedAt ?? DateTime.now();

  double getAverageScore() {
    if (scores.isEmpty) return 0.0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  Map<String, dynamic> toJson() => {
    'scores': scores,
    'progressRate': progressRate,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory TopicMastery.fromJson(Map<String, dynamic> json) => TopicMastery(
    scores: List<double>.from(json['scores'] as List),
    progressRate: json['progressRate'] as double,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}

enum ActivityType { study, review, practice }

class LearningActivity {
  final ActivityType type;
  final int duration;
  final DateTime timestamp;
  final String? topic;
  final Map<String, dynamic>? metadata;

  LearningActivity({
    required this.type,
    required this.duration,
    DateTime? timestamp,
    this.topic,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'duration': duration,
    'timestamp': timestamp.toIso8601String(),
    'topic': topic,
    'metadata': metadata,
  };

  factory LearningActivity.fromJson(Map<String, dynamic> json) {
    return LearningActivity(
      type: ActivityType.values.firstWhere((e) => e.toString() == json['type']),
      duration: json['duration'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      topic: json['topic'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

class DailyHabits {
  int studyTime;
  int reviewTime;
  int practiceCount;
  List<LearningActivity> activities;

  DailyHabits({
    this.studyTime = 0,
    this.reviewTime = 0,
    this.practiceCount = 0,
    List<LearningActivity>? activities,
  }) : activities = activities ?? [];

  Map<String, dynamic> toJson() => {
    'studyTime': studyTime,
    'reviewTime': reviewTime,
    'practiceCount': practiceCount,
    'activities': activities.map((a) => a.toJson()).toList(),
  };

  factory DailyHabits.fromJson(Map<String, dynamic> json) => DailyHabits(
    studyTime: json['studyTime'] as int,
    reviewTime: json['reviewTime'] as int,
    practiceCount: json['practiceCount'] as int,
    activities: (json['activities'] as List)
        .map((a) => LearningActivity.fromJson(a as Map<String, dynamic>))
        .toList(),
  );
}

class AggregatedHabits {
  int studyTime = 0;
  int reviewTime = 0;
  int practiceCount = 0;

  void add(DailyHabits habits) {
    studyTime += habits.studyTime;
    reviewTime += habits.reviewTime;
    practiceCount += habits.practiceCount;
  }
}

enum AdviceType { timeManagement, errorPattern, weakTopic, studyHabit }

class LearningAdvice {
  final AdviceType type;
  final String message;
  final int priority; // 1-5，1最高优先级

  LearningAdvice({
    required this.type,
    required this.message,
    required this.priority,
  });
}
