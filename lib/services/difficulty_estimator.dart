import 'dart:math';
import '../models/question.dart';

class DifficultyEstimator {
  static const int _minDifficulty = 1;
  static const int _maxDifficulty = 5;

  // 根据题目内容和解答过程估算难度
  static int estimateQuestionDifficulty(Question question) {
    int baseScore = _calculateBaseScore(question);
    int complexityScore = _calculateComplexityScore(question);
    int finalScore = _normalizeDifficulty(baseScore + complexityScore);
    return finalScore;
  }

  // 根据基础特征计算分数
  static int _calculateBaseScore(Question question) {
    int score = 0;

    // 检查题目长度
    if (question.content.length > 200)
      score += 2;
    else if (question.content.length > 100)
      score += 1;

    // 检查是否包含特定关键词
    final complexityKeywords = [
      '证明',
      '推导',
      '分析',
      '论证',
      'prove',
      'derive',
      'analyze',
      '综合',
      '探究',
      '研究',
    ];

    for (var keyword in complexityKeywords) {
      if (question.content.contains(keyword)) {
        score += 1;
        break;
      }
    }

    return score;
  }

  // 根据解答复杂度计算分数
  static int _calculateComplexityScore(Question question) {
    int score = 0;

    // 检查解答步骤数量
    if ((question.solution?.steps.length ?? 0) > 3) {
      score += 2;
    } else if ((question.solution?.steps.length ?? 0) > 1) {
      score += 1;
    }

    // 检查是否包含数学公式或特殊符号
    final mathSymbols = [
      '∫',
      '∑',
      '∏',
      '√',
      '∞',
      'sin',
      'cos',
      'tan',
      'log',
      'lim',
      '→',
      '≠',
      '≥',
      '≤',
    ];

    for (var symbol in mathSymbols) {
      if (question.content.contains(symbol)) {
        score += 1;
        break;
      }
    }

    return score;
  }

  // 将分数标准化到1-5的范围内
  static int _normalizeDifficulty(int rawScore) {
    return max(
      _minDifficulty,
      min(_maxDifficulty, (rawScore / 2).round() + _minDifficulty),
    );
  }

  // 根据用户水平推荐题目难度
  static List<int> recommendDifficultyLevels(int userLevel) {
    final recommended = <int>[];

    // 主要推荐当前水平的题目
    recommended.add(userLevel);

    // 适当推荐略高和略低难度的题目
    if (userLevel > _minDifficulty) {
      recommended.add(userLevel - 1);
    }
    if (userLevel < _maxDifficulty) {
      recommended.add(userLevel + 1);
    }

    return recommended;
  }
}
