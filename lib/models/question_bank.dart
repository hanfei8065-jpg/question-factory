// [LEARNEST_QUESTION_MODEL_V11.0_TOTAL_ALIGNED]
import 'dart:convert';

class Question {
  final String id;
  final String content;
  final List<String> options;
  final String answer;
  final String? explanation; // 应用题的解析，允许为空
  final List<String> tags;
  final String subjectId; // 学科：math, physics...
  final String gradeId; // 年级：grade10...
  final String type; // 题型：choice, fill_in, word_problem
  final String lang; // 语言：zh, en
  final int difficulty; // 难度：1, 2, 3
  final int coins; // 奖励金币
  final int exp; // 奖励经验

  Question({
    required this.id,
    required this.content,
    required this.options,
    required this.answer,
    this.explanation,
    required this.tags,
    required this.subjectId,
    required this.gradeId,
    required this.type,
    required this.lang,
    required this.difficulty,
    this.coins = 10,
    this.exp = 10,
  });

  // 从数据库 Map 转换为 Dart 对象
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id']?.toString() ?? '',
      content: map['content'] ?? '',
      // 处理数据库中可能是 JSON 字符串或数组的情况
      options: map['options'] is String
          ? List<String>.from(jsonDecode(map['options']))
          : List<String>.from(map['options'] ?? []),
      answer: map['answer'] ?? '',
      explanation: map['explanation'],
      tags: map['tags'] is String
          ? List<String>.from(jsonDecode(map['tags']))
          : List<String>.from(map['tags'] ?? []),
      subjectId: map['subject_id'] ?? '',
      gradeId: map['grade_id'] ?? '',
      type: map['type'] ?? 'choice',
      lang: map['lang'] ?? 'zh',
      difficulty: map['difficulty'] ?? 1,
      coins: map['coins'] ?? 10,
      exp: map['exp'] ?? 10,
    );
  }

  Map<String, dynamic> toMap() => {
        'content': content,
        'options': options,
        'answer': answer,
        'explanation': explanation,
        'tags': tags,
        'subject_id': subjectId,
        'grade_id': gradeId,
        'type': type,
        'lang': lang,
        'difficulty': difficulty,
        'coins': coins,
        'exp': exp,
      };
}

// 保留你原有的 Level 和 UserProgress 结构，但移除对旧枚举的依赖
class Level {
  final String id;
  final int worldId;
  final int levelNumber;
  final List<String> questionIds;
  final int requiredStars;
  final int rewardCoins;
  final int rewardExp;

  Level({
    required this.id,
    required this.worldId,
    required this.levelNumber,
    required this.questionIds,
    required this.requiredStars,
    required this.rewardCoins,
    required this.rewardExp,
  });

  factory Level.fromJson(Map<String, dynamic> json) => Level(
        id: json['id'],
        worldId: json['worldId'],
        levelNumber: json['levelNumber'],
        questionIds: List<String>.from(json['questionIds']),
        requiredStars: json['requiredStars'],
        rewardCoins: json['rewardCoins'],
        rewardExp: json['rewardExp'],
      );
}

// UserProgress 类你可以保持不变，它主要处理本地逻辑
