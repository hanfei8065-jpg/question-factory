import 'dart:convert';

enum QuestionType {
  math, // 数学
  physics, // 物理
  chemistry, // 化学
}

enum Difficulty {
  easy, // 简单
  medium, // 中等
  hard, // 困难
}

class Question {
  final String id; // 题目ID
  final String content; // 题干内容
  final List<String> options; // 选项
  final String answer; // 正确答案
  final String explanation; // 解析
  final List<String> tags; // 标签
  final QuestionType type; // 科目类型
  final Difficulty difficulty; // 难度等级
  final int coins; // 答对奖励金币
  final int exp; // 答对奖励经验

  Question({
    required this.id,
    required this.content,
    required this.options,
    required this.answer,
    required this.explanation,
    required this.tags,
    required this.type,
    required this.difficulty,
    required this.coins,
    required this.exp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'options': options,
    'answer': answer,
    'explanation': explanation,
    'tags': tags,
    'type': type.toString(),
    'difficulty': difficulty.toString(),
    'coins': coins,
    'exp': exp,
  };

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    id: json['id'],
    content: json['content'],
    options: List<String>.from(json['options']),
    answer: json['answer'],
    explanation: json['explanation'],
    tags: List<String>.from(json['tags']),
    type: QuestionType.values.firstWhere((e) => e.toString() == json['type']),
    difficulty: Difficulty.values.firstWhere(
      (e) => e.toString() == json['difficulty'],
    ),
    coins: json['coins'],
    exp: json['exp'],
  );
}

class Level {
  final String id; // 关卡ID
  final int worldId; // 所属世界ID
  final int levelNumber; // 关卡编号
  final List<String> questionIds; // 包含的题目ID列表
  final int requiredStars; // 解锁需要的星星数
  final int rewardCoins; // 通关奖励金币
  final int rewardExp; // 通关奖励经验

  Level({
    required this.id,
    required this.worldId,
    required this.levelNumber,
    required this.questionIds,
    required this.requiredStars,
    required this.rewardCoins,
    required this.rewardExp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'worldId': worldId,
    'levelNumber': levelNumber,
    'questionIds': questionIds,
    'requiredStars': requiredStars,
    'rewardCoins': rewardCoins,
    'rewardExp': rewardExp,
  };

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

class UserProgress {
  final String userId; // 用户ID
  int stars; // 总星星数
  int coins; // 金币数
  int exp; // 经验值
  int currentLevel; // 当前等级
  List<String> completedLevels; // 已完成关卡ID列表
  Map<String, bool> questionStatus; // 题目答题状态 {questionId: isCorrect}
  List<String> wrongQuestions; // 错题本题目ID列表
  DateTime lastPlayTime; // 最后答题时间

  UserProgress({
    required this.userId,
    this.stars = 0,
    this.coins = 0,
    this.exp = 0,
    this.currentLevel = 1,
    List<String>? completedLevels,
    Map<String, bool>? questionStatus,
    List<String>? wrongQuestions,
    DateTime? lastPlayTime,
  }) : completedLevels = completedLevels ?? [],
       questionStatus = questionStatus ?? {},
       wrongQuestions = wrongQuestions ?? [],
       lastPlayTime = lastPlayTime ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'stars': stars,
    'coins': coins,
    'exp': exp,
    'currentLevel': currentLevel,
    'completedLevels': completedLevels,
    'questionStatus': questionStatus,
    'wrongQuestions': wrongQuestions,
    'lastPlayTime': lastPlayTime.toIso8601String(),
  };

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
    userId: json['userId'],
    stars: json['stars'],
    coins: json['coins'],
    exp: json['exp'],
    currentLevel: json['currentLevel'],
    completedLevels: List<String>.from(json['completedLevels']),
    questionStatus: Map<String, bool>.from(json['questionStatus']),
    wrongQuestions: List<String>.from(json['wrongQuestions']),
    lastPlayTime: DateTime.parse(json['lastPlayTime']),
  );

  // 添加题目到错题本
  void addWrongQuestion(String questionId) {
    if (!wrongQuestions.contains(questionId)) {
      wrongQuestions.add(questionId);
      questionStatus[questionId] = false;
    }
  }

  // 从错题本移除题目
  void removeWrongQuestion(String questionId) {
    wrongQuestions.remove(questionId);
    if (questionStatus.containsKey(questionId)) {
      questionStatus[questionId] = true;
    }
  }

  // 更新答题状态
  void updateQuestionStatus(String questionId, bool isCorrect) {
    questionStatus[questionId] = isCorrect;
    if (!isCorrect && !wrongQuestions.contains(questionId)) {
      wrongQuestions.add(questionId);
    } else if (isCorrect && wrongQuestions.contains(questionId)) {
      wrongQuestions.remove(questionId);
    }
  }

  // 完成关卡
  void completeLevel(String levelId) {
    if (!completedLevels.contains(levelId)) {
      completedLevels.add(levelId);
    }
  }

  // 添加奖励
  void addRewards({
    required int addStars,
    required int addCoins,
    required int addExp,
  }) {
    stars += addStars;
    coins += addCoins;
    exp += addExp;

    // 检查是否升级（每1000经验升一级）
    currentLevel = (exp / 1000).floor() + 1;
  }
}
