import 'dart:async'; // ✅ 新增：用于 Timer
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // ✅ SVG 支持
import '../services/user_progress_service.dart';
import '../services/question_service.dart'; // ✅ 新增：QuestionService
import '../models/question.dart'; // ✅ 新增：Question 模型
import 'session_summary_page.dart'; // ✅✅ 新增：Session Summary
import '../widgets/bilingual_tag.dart'; // ✅ 新增：双语标签组件

class AppQuestionArenaPage extends StatefulWidget {
  final String subjectId; // e.g., 'math', 'physics', 'review'
  final String? grade; // e.g., 'G10', 'G11', null for review
  final String? topic; // e.g., 'Quadratic Functions', 'mistakes'
  final int questionLimit; // e.g., 5, 10, 20

  const AppQuestionArenaPage({
    super.key,
    required this.subjectId,
    this.grade,
    this.topic,
    this.questionLimit = 5,
  });

  @override
  State<AppQuestionArenaPage> createState() => _AppQuestionArenaPageState();
}

class _AppQuestionArenaPageState extends State<AppQuestionArenaPage> {
  final _progressService = UserProgressService();
  final _questionService = QuestionService(); // ✅ 新增：Question Service 实例

  int current = 0;
  int combo = 0;
  bool showExplanation = false;
  int? selectedIdx;
  bool isCorrect = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> questions = [];

  // ✅ 新增：倒计时相关
  Timer? _countdownTimer;
  int _remainingSeconds = 0;
  int _totalSeconds = 0; // 用于计算进度条百分比

  // ✅ 新增：错误处理
  String? _errorMessage;

  // ✅✅ 新增：Session 追踪
  int _answeredCount = 0;
  int _correctCount = 0;
  int _totalXpEarned = 0;
  List<Map<String, dynamic>> _wrongQuestions = [];

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel(); // ✅ 清理计时器
    super.dispose();
  }

  /// ✅ 从 Supabase 获取真实数据，失败时回退到 Mock
  Future<void> _fetchQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 🔥 从 Supabase 获取真实数据
      print('🌐 Fetching REAL data from Supabase...');

      List<Question> questionObjects;

      if (widget.subjectId == 'review') {
        // 复习模式：暂时使用 Math 题目
        questionObjects = await _questionService.fetchQuestions(
          subject: 'math',
          limit: widget.questionLimit,
        );
      } else {
        // 普通模式：按学科查询
        int? gradeNumber;
        if (widget.grade != null && widget.grade!.startsWith('G')) {
          gradeNumber = int.tryParse(widget.grade!.substring(1));
        }

        questionObjects = await _questionService.fetchQuestions(
          subject: widget.subjectId,
          grade: gradeNumber,
          limit: widget.questionLimit * 2, // 多获取一些备用
        );
      }

      if (questionObjects.isEmpty) {
        throw Exception(
          'No questions found in database for ${widget.subjectId}',
        );
      }

      // ✅ 将 Question 对象转换为 Map（兼容现有 UI 代码）
      final fetchedQuestions = questionObjects.map((q) {
        return {
          'question': q.content,
          'options': q.options,
          'answer': q.options.indexOf(q.answer), // 找到答案的索引
          'explanation': q.explanation,
          'timer_seconds': q.timerSeconds ?? 60, // ✅ CRITICAL: 映射 timer_seconds
        };
      }).toList();

      setState(() {
        questions = fetchedQuestions.take(widget.questionLimit).toList();
        _isLoading = false;
      });

      print('✅ Loaded ${questions.length} REAL questions from Supabase');

      // ✅ 启动第一题倒计时
      if (questions.isNotEmpty) {
        _startTimerForCurrentQuestion();
      }
    } catch (e, stackTrace) {
      print('❌ Failed to fetch questions from Supabase: $e');
      print('   Stack trace: $stackTrace');

      setState(
        () => _errorMessage =
            'Failed to load from Supabase: ${e.toString().substring(0, 50)}...',
      );

      // 🔄 Fallback: 使用 Mock 数据
      print('🔄 Falling back to MOCK data...');
      await _fetchMockQuestions();
    }
  }

  /// Mock 数据生成器（作为 fallback）
  Future<void> _fetchMockQuestions() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final generatedQuestions = _generateQuestionsBySubject(
      widget.subjectId,
      widget.grade,
      widget.topic,
      widget.questionLimit,
    );

    setState(() {
      questions = generatedQuestions;
      _isLoading = false;
    });

    // ✅ 启动第一题倒计时
    if (questions.isNotEmpty) {
      _startTimerForCurrentQuestion();
    }
  }

  /// ✅ 新增：启动当前题目的倒计时
  void _startTimerForCurrentQuestion() {
    _countdownTimer?.cancel(); // 清理旧计时器

    final currentQuestion = questions[current];
    final timerSeconds = currentQuestion['timer_seconds'] as int?;

    if (timerSeconds == null || timerSeconds <= 0) {
      // 无限时题目
      setState(() {
        _remainingSeconds = 0;
        _totalSeconds = 0;
      });
      return;
    }

    // 初始化倒计时
    setState(() {
      _remainingSeconds = timerSeconds;
      _totalSeconds = timerSeconds;
    });

    // 启动每秒更新的计时器
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        _handleTimeout(); // 时间到，自动提交错误答案
      }
    });
  }

  /// ✅ 新增：超时处理
  void _handleTimeout() {
    if (selectedIdx != null) return; // 已经选择了答案，不处理

    setState(() {
      selectedIdx = -1; // 标记为超时（无选择）
      isCorrect = false;
      showExplanation = true;
      combo = 0; // 超时清空 combo
    });

    // ✅✅ Track timeout as wrong answer
    _wrongQuestions.add(questions[current]);

    // 3秒后自动下一题
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _moveToNextQuestion();
      }
    });
  }

  /// Generate subject-specific questions based on parameters
  List<Map<String, dynamic>> _generateQuestionsBySubject(
    String subjectId,
    String? grade,
    String? topic,
    int limit,
  ) {
    if (subjectId == 'review') {
      // Revenge Mode - Mistake Review
      return _generateReviewQuestions(limit);
    }

    switch (subjectId) {
      case 'math':
        return _generateMathQuestions(grade, topic, limit);
      case 'physics':
        return _generatePhysicsQuestions(grade, topic, limit);
      case 'chemistry':
        return _generateChemistryQuestions(grade, topic, limit);
      case 'olympiad':
        return _generateOlympiadQuestions(topic, limit);
      default:
        return _generateGenericQuestions(limit);
    }
  }

  List<Map<String, dynamic>> _generateMathQuestions(
    String? grade,
    String? topic,
    int limit,
  ) {
    final pool = <Map<String, dynamic>>[
      {
        'question': 'Solve for x: 2x + 5 = 13',
        'options': ['A) 2', 'B) 4', 'C) 6', 'D) 8'],
        'answer': 1,
        'explanation': 'x = 4 because 2(4) + 5 = 13.',
        'timer_seconds': 60,
      },
      {
        'question': 'What is the derivative of x²?',
        'options': ['A) x', 'B) 2x', 'C) x²', 'D) 2'],
        'answer': 1,
        'explanation': 'd/dx(x²) = 2x by power rule.',
        'timer_seconds': 45,
      },
      {
        'question': 'Which is a quadratic function?',
        'options': ['A) y = x', 'B) y = x²', 'C) y = 2x + 1', 'D) y = 1/x'],
        'answer': 1,
        'explanation': 'y = x² is quadratic (degree 2).',
        'timer_seconds': 45,
      },
      {
        'question': 'What is the area of a circle with radius 5?',
        'options': ['A) 10π', 'B) 25π', 'C) 50π', 'D) 100π'],
        'answer': 1,
        'explanation': 'Area = πr² = π(5²) = 25π.',
        'timer_seconds': 60,
      },
      {
        'question': 'What is log₁₀(100)?',
        'options': ['A) 1', 'B) 2', 'C) 10', 'D) 100'],
        'answer': 1,
        'explanation': 'log₁₀(100) = 2 because 10² = 100.',
        'timer_seconds': 45,
      },
      {
        'question': 'Solve: x² - 4 = 0',
        'options': ['A) x = ±1', 'B) x = ±2', 'C) x = 2', 'D) x = 4'],
        'answer': 1,
        'explanation': 'x² = 4, so x = ±2.',
        'timer_seconds': 60,
      },
    ];
    return pool.take(limit).toList();
  }

  List<Map<String, dynamic>> _generatePhysicsQuestions(
    String? grade,
    String? topic,
    int limit,
  ) {
    final pool = <Map<String, dynamic>>[
      {
        'question': 'What is the unit of Force?',
        'options': ['A) Joule', 'B) Newton', 'C) Watt', 'D) Pascal'],
        'answer': 1,
        'explanation': 'Force is measured in Newtons (N).',
        'timer_seconds': 30,
      },
      {
        'question': 'What is the speed of light in vacuum?',
        'options': [
          'A) 3×10⁶ m/s',
          'B) 3×10⁸ m/s',
          'C) 3×10¹⁰ m/s',
          'D) 3×10¹² m/s',
        ],
        'answer': 1,
        'explanation': 'c = 3×10⁸ m/s.',
        'timer_seconds': 45,
      },
      {
        'question': 'What is the formula for kinetic energy?',
        'options': ['A) mgh', 'B) ½mv²', 'C) F = ma', 'D) P = VI'],
        'answer': 1,
        'explanation': 'KE = ½mv² (mass × velocity squared / 2).',
        'timer_seconds': 60,
      },
      {
        'question': 'Ohm\'s Law states:',
        'options': ['A) V = IR', 'B) F = ma', 'C) E = mc²', 'D) P = W/t'],
        'answer': 0,
        'explanation': 'Voltage = Current × Resistance.',
        'timer_seconds': 45,
      },
      {
        'question': 'What is the acceleration due to gravity on Earth?',
        'options': ['A) 9.8 m/s', 'B) 9.8 m/s²', 'C) 98 m/s²', 'D) 0.98 m/s²'],
        'answer': 1,
        'explanation': 'g = 9.8 m/s² (meters per second squared).',
        'timer_seconds': 45,
      },
    ];
    return pool.take(limit).toList();
  }

  List<Map<String, dynamic>> _generateChemistryQuestions(
    String? grade,
    String? topic,
    int limit,
  ) {
    final pool = <Map<String, dynamic>>[
      {
        'question': 'What is the atomic number of Carbon?',
        'options': ['A) 4', 'B) 6', 'C) 8', 'D) 12'],
        'answer': 1,
        'explanation': 'Carbon has 6 protons (atomic number = 6).',
        'timer_seconds': 30,
      },
      {
        'question': 'What is the chemical formula for water?',
        'options': ['A) H₂O', 'B) CO₂', 'C) O₂', 'D) H₂O₂'],
        'answer': 0,
        'explanation': 'Water is H₂O (2 hydrogen, 1 oxygen).',
        'timer_seconds': 30,
      },
      {
        'question': 'Which is a noble gas?',
        'options': ['A) Nitrogen', 'B) Oxygen', 'C) Helium', 'D) Hydrogen'],
        'answer': 2,
        'explanation': 'Helium (He) is a noble gas (Group 18).',
        'timer_seconds': 45,
      },
      {
        'question': 'What is the pH of a neutral solution?',
        'options': ['A) 0', 'B) 7', 'C) 10', 'D) 14'],
        'answer': 1,
        'explanation': 'pH 7 is neutral (pure water).',
        'timer_seconds': 30,
      },
    ];
    return pool.take(limit).toList();
  }

  List<Map<String, dynamic>> _generateOlympiadQuestions(
    String? topic,
    int limit,
  ) {
    final pool = <Map<String, dynamic>>[
      {
        'question': 'How many positive divisors does 24 have?',
        'options': ['A) 6', 'B) 8', 'C) 10', 'D) 12'],
        'answer': 1,
        'explanation': '24 = 2³ × 3¹, divisors = (3+1)(1+1) = 8.',
        'timer_seconds': 90,
      },
      {
        'question': 'In how many ways can you arrange the letters in "CAT"?',
        'options': ['A) 3', 'B) 6', 'C) 9', 'D) 12'],
        'answer': 1,
        'explanation': '3! = 6 permutations.',
        'timer_seconds': 60,
      },
      {
        'question': 'What is the sum of the first 10 natural numbers?',
        'options': ['A) 45', 'B) 50', 'C) 55', 'D) 60'],
        'answer': 2,
        'explanation': 'Sum = n(n+1)/2 = 10(11)/2 = 55.',
        'timer_seconds': 75,
      },
    ];
    return pool.take(limit).toList();
  }

  List<Map<String, dynamic>> _generateReviewQuestions(int limit) {
    // Revenge Mode - show previously incorrect questions
    return [
      {
        'question': 'Review: What is 15% of 200?',
        'options': ['A) 20', 'B) 25', 'C) 30', 'D) 35'],
        'answer': 2,
        'explanation': '15% of 200 = 0.15 × 200 = 30.',
        'timer_seconds': 45,
      },
      {
        'question': 'Review: Solve 3x = 12',
        'options': ['A) 3', 'B) 4', 'C) 5', 'D) 6'],
        'answer': 1,
        'explanation': 'x = 12/3 = 4.',
        'timer_seconds': 60,
      },
    ].take(limit).toList();
  }

  List<Map<String, dynamic>> _generateGenericQuestions(int limit) {
    return _generateMathQuestions(null, null, limit);
  }

  void handleSelect(int idx) async {
    if (selectedIdx != null) return;

    _countdownTimer?.cancel(); // ✅ 选择后立即停止计时器

    setState(() {
      selectedIdx = idx;
      isCorrect = idx == questions[current]['answer'];
      showExplanation = !isCorrect;
      combo = isCorrect ? combo + 1 : 0;
    });

    // ✅✅ Track wrong answers
    if (!isCorrect) {
      _wrongQuestions.add(questions[current]);
    }

    // Award XP for correct answer
    if (isCorrect) {
      _correctCount++; // ✅✅ Track correct count
      const xpPerQuestion = 20;
      await _progressService.addXP(xpPerQuestion);
      await _progressService.incrementSolved();
      await _progressService.updateStreak();
      _totalXpEarned += xpPerQuestion; // ✅✅ Track total XP
    }

    // ✅✅ Move to next question (for both correct and wrong answers)
    if (isCorrect) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _moveToNextQuestion();
        }
      });
    } else {
      // For wrong answers, wait 2 seconds to show explanation
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _moveToNextQuestion();
        }
      });
    }
  }

  /// ✅✅ 新增：移动到下一题的统一方法（带Session结束检测）
  void _moveToNextQuestion() {
    _answeredCount++; // ✅✅ Increment answered count

    // ✅✅ Check if session is complete
    if (_answeredCount >= widget.questionLimit) {
      _countdownTimer?.cancel(); // Stop timer

      // Navigate to Session Summary
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SessionSummaryPage(
            score: _correctCount,
            totalQuestions: widget.questionLimit,
            xpEarned: _totalXpEarned,
            wrongQuestions: _wrongQuestions,
            subjectId: widget.subjectId,
          ),
        ),
      );
      return; // ✅✅ STOP here - don't continue to next question
    }

    // ✅ Continue to next question (modulo keeps cycling within loaded questions)
    setState(() {
      current = (current + 1) % questions.length;
      selectedIdx = null;
      showExplanation = false;
    });
    _startTimerForCurrentQuestion(); // ✅ 启动新题目的倒计时
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state while fetching questions
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF07C160)),
              const SizedBox(height: 16),
              const Text(
                '🌐 Loading from Supabase...',
                style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    '⚠️ $_errorMessage\nFalling back to mock data...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFFA500),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Handle empty questions
    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF1E293B)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text(
            'No questions available',
            style: TextStyle(fontSize: 18, color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    final q = questions[current];
    final isReviewMode = widget.subjectId == 'review';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Review Mode Banner (if applicable)
            if (isReviewMode)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF9800).withOpacity(0.9),
                      const Color(0xFFFFA500).withOpacity(0.9),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.sports_martial_arts,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '🔥 REVENGE MODE - Review Your Mistakes',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF1E293B),
                      size: 28,
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: combo > 0
                          ? const Color(0xFF07C160)
                          : const Color(0xFFFFA500),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Combo x$combo',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Question Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ✅ 倒计时进度条（微信VI配色）
                  if (_totalSeconds > 0)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: LinearProgressIndicator(
                        value: _remainingSeconds / _totalSeconds,
                        minHeight: 4,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _remainingSeconds / _totalSeconds > 0.5
                              ? const Color(0xFF07C160) // 微信绿 >50%
                              : _remainingSeconds / _totalSeconds > 0.2
                              ? const Color(0xFFFFA500) // 橙色 20-50%
                              : const Color(0xFFFF4D4F), // 红色 <20%
                        ),
                      ),
                    ),

                  // ✅ 题目内容 + 计时器文字
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 计时器文字显示
                        if (_totalSeconds > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox.shrink(),
                              Row(
                                children: [
                                  const Text(
                                    '⏱️',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_remainingSeconds ~/ 60}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          _remainingSeconds / _totalSeconds >
                                              0.5
                                          ? const Color(0xFF07C160)
                                          : _remainingSeconds / _totalSeconds >
                                                0.2
                                          ? const Color(0xFFFFA500)
                                          : const Color(0xFFFF4D4F),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        if (_totalSeconds > 0) const SizedBox(height: 12),

                        // ✅ SVG 图表 (Visual Question Bank)
                        if (q['svg_diagram'] != null &&
                            (q['svg_diagram'] as String).isNotEmpty) ...[
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: SvgPicture.string(
                                q['svg_diagram'],
                                height: 200,
                                placeholderBuilder: (context) => Container(
                                  height: 200,
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // 题目文字
                        Text(
                          q['question'],
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                          ),
                        ),

                        // ✅ 新增：双语标签显示
                        if (q['tags'] != null &&
                            (q['tags'] as List).isNotEmpty) ...[
                          const SizedBox(height: 16),
                          BilingualTagRow(
                            tags: List<String>.from(q['tags']),
                            spacing: 8,
                            runSpacing: 8,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Option Buttons
            ...List.generate(4, (idx) {
              final opt = q['options'][idx];
              Color borderColor = Colors.grey.shade300;
              Color fillColor = Colors.white;
              Color textColor = const Color(0xFF1E293B);
              if (selectedIdx != null) {
                if (idx == selectedIdx) {
                  if (isCorrect) {
                    borderColor = const Color(0xFF07C160);
                    fillColor = const Color(0xFF07C160);
                    textColor = Colors.white;
                  } else {
                    borderColor = const Color(0xFFEF4444);
                    fillColor = const Color(0xFFEF4444);
                    textColor = Colors.white;
                  }
                }
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                child: GestureDetector(
                  onTap: () => handleSelect(idx),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: Text(
                      opt,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              );
            }),
            // Mini Explanation
            if (showExplanation)
              Container(
                margin: const EdgeInsets.only(top: 18, left: 20, right: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  q['explanation'],
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
