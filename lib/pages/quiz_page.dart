import 'package:flutter/material.dart';
import '../models/level.dart';
import '../models/question.dart';
import '../data/question_generator.dart';

import 'quiz_result_page.dart';

class QuizPage extends StatefulWidget {
  final Level level;

  const QuizPage({super.key, required this.level});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage>
    with SingleTickerProviderStateMixin {
  late List<Question> questions;
  int currentIndex = 0;
  String? selectedAnswer;
  bool hasSubmitted = false;
  int streak = 0;
  int score = 0;
  bool showExplanation = false;

  // 动画控制器
  late AnimationController _resultAnimController;
  @override
  void initState() {
    super.initState();
    // 获取关卡题目
    final allQuestions = QuestionGenerator.generateAllQuestions();
    questions = widget.level.questionIds
        .map((id) => allQuestions.firstWhere((q) => q.id == id))
        .toList();

    // 初始化动画
    _resultAnimController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _resultAnimController.dispose();
    super.dispose();
  }

  void _handleAnswer(String answer) {
    if (hasSubmitted) return;
    setState(() {
      selectedAnswer = answer;
    });
  }

  void _submitAnswer() {
    if (selectedAnswer == null || hasSubmitted) return;

    final isCorrect = selectedAnswer == questions[currentIndex].answer;

    setState(() {
      hasSubmitted = true;
      if (isCorrect) {
        streak++;
        // 连续答对加倍得分
        score += (streak >= 3 ? 20 : 10);
      } else {
        streak = 0;
      }
    });

    // 显示结果动画
    _resultAnimController.forward();
  }

  void _nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedAnswer = null;
        hasSubmitted = false;
        showExplanation = false;
      });
      _resultAnimController.reset();
    } else {
      // 完成所有题目，跳转到结果页
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultPage(
            level: widget.level,
            score: score,
            totalQuestions: questions.length,
            stars: _calculateStars(),
          ),
        ),
      );
    }
  }

  int _calculateStars() {
    final percentage = score / (questions.length * 10);
    if (percentage >= 0.9) return 3;
    if (percentage >= 0.7) return 2;
    if (percentage >= 0.5) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              '第${currentIndex + 1}题',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              ' / ',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              '${questions.length}',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        actions: [
          // 连击次数
          if (streak > 0)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB800).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Color(0xFFFFB800),
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$streak',
                    style: const TextStyle(
                      color: Color(0xFFFFB800),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 题目内容
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 难度指示器
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        final isActive = index < question.difficulty;
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.star,
                            size: 16,
                            color: isActive
                                ? const Color(0xFFFFB800)
                                : const Color(0xFFE5E7EB),
                          ),
                        );
                      }),
                      const Spacer(),
                      // 知识点标签
                      ...question.tags.take(2).map((tag) {
                        return Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: const Color(0xFF2563EB).withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 题目
                  Text(
                    question.content,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.5,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 选项
            ...question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = selectedAnswer == option;
              final showResult = hasSubmitted && isSelected;
              final isCorrect = option == question.answer;

              Color backgroundColor = Colors.white;
              Color borderColor = const Color(0xFFE5E7EB);
              if (showResult) {
                backgroundColor = isCorrect
                    ? const Color(0xFF10B981).withOpacity(0.1)
                    : const Color(0xFFEF4444).withOpacity(0.1);
                borderColor = isCorrect
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444);
              } else if (isSelected) {
                backgroundColor = const Color(0xFF2563EB).withOpacity(0.1);
                borderColor = const Color(0xFF2563EB);
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: hasSubmitted ? null : () => _handleAnswer(option),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: backgroundColor,
                              border: Border.all(color: borderColor, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index),
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          if (showResult)
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            // 提交/下一题按钮
            if (!hasSubmitted)
              ElevatedButton(
                onPressed: selectedAnswer == null ? null : _submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '提交答案',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            else ...[
              // 解析
              if (!showExplanation)
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      showExplanation = true;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF2563EB), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '查看解析',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              if (showExplanation) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📝 解析',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        question.explanation,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  currentIndex < questions.length - 1 ? '下一题' : '完成',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
