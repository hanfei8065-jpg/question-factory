class DifficultyLevel {
  final int level; // 1-5表示难度级别
  final String name; // 难度等级名称
  final String description; // 难度等级描述
  final List<String> characteristics; // 该难度的题目特征
  final List<String> recommendedTopics; // 推荐练习的知识点
  final int recommendedDailyCount; // 每日推荐练习题数

  DifficultyLevel({
    required this.level,
    required this.name,
    required this.description,
    required this.characteristics,
    required this.recommendedTopics,
    required this.recommendedDailyCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'name': name,
      'description': description,
      'characteristics': characteristics,
      'recommendedTopics': recommendedTopics,
      'recommendedDailyCount': recommendedDailyCount,
    };
  }

  factory DifficultyLevel.fromJson(Map<String, dynamic> json) {
    return DifficultyLevel(
      level: json['level'],
      name: json['name'],
      description: json['description'],
      characteristics: List<String>.from(json['characteristics']),
      recommendedTopics: List<String>.from(json['recommendedTopics']),
      recommendedDailyCount: json['recommendedDailyCount'],
    );
  }
}
