import 'package:flutter/material.dart';
import 'dart:async';
import '../models/question.dart';
import 'app_session_summary_page.dart';

class AppQuestionArenaPage extends StatefulWidget {
  final String subjectId;
  final String grade;
  final int questionLimit;
  final String topic;

  const AppQuestionArenaPage({
    super.key,
    required this.subjectId,
    required this.grade,
    required this.questionLimit,
    this.topic = 'General',
  });

  @override
  State<AppQuestionArenaPage> createState() => _AppQuestionArenaPageState();
}

class _AppQuestionArenaPageState extends State<AppQuestionArenaPage> {
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _correctCount = 0;
  Timer? _timer;
  int _timeRemaining = 0;
  bool _isLoading = true;
  int _totalTimeSpent = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);

    // Mock data for now (will be replaced with real API call)
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _questions = _fetchMockQuestions();
      _isLoading = false;
    });

    if (_questions.isNotEmpty) {
      _startTimer();
    }
  }

  List<Question> _fetchMockQuestions() {
    // Map subject string to enum
    Subject subjectEnum = Subject.math;
    if (widget.subjectId.toLowerCase().contains('phys')) {
      subjectEnum = Subject.physics;
    } else if (widget.subjectId.toLowerCase().contains('chem')) {
      subjectEnum = Subject.chemistry;
    }

    // 答案随机化: A/B/C/D均匀分布
    final answers = ['A', 'B', 'C', 'D'];

    return List.generate(widget.questionLimit.clamp(1, 20), (index) {
      // 随机选择正确答案
      final correctAnswerLetter = answers[index % 4]; // 循环分布,确保均匀
      final correctAnswer =
          '$correctAnswerLetter) Option ${answers.indexOf(correctAnswerLetter) + 1}';

      return Question(
        id: 'q${index + 1}',
        content: _getMockQuestionContent(index),
        subject: subjectEnum,
        grade: int.tryParse(widget.grade) ?? 10,
        type: QuestionType.choice,
        difficulty: 3, // Medium
        tags: [widget.topic, widget.grade],
        options: ['A) Option 1', 'B) Option 2', 'C) Option 3', 'D) Option 4'],
        answer: correctAnswer, // 随机答案而非固定A
        explanation: 'This is the correct answer because...',
      );
    });
  }

  String _getMockQuestionContent(int index) {
    final samples = [
      'Solve for x: 2x + 5 = 13',
      'What is the derivative of x²?',
      'Find the area of a circle with radius 5',
      'Simplify: (x + 2)(x - 3)',
      'Calculate: ∫ x dx',
    ];
    return samples[index % samples.length];
  }

  void _startTimer() {
    if (_currentIndex >= _questions.length) return;

    // Fixed timer: 30 seconds per question
    _timeRemaining = 30;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
          _totalTimeSpent++;
        } else {
          _nextQuestion(); // Auto-advance when time's up
        }
      });
    });
  }

  void _answerQuestion(bool isCorrect) {
    if (isCorrect) {
      _correctCount++;
    }

    _timer?.cancel();

    // Brief pause to show result
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _startTimer();
    } else {
      _finishSession();
    }
  }

  void _finishSession() {
    _timer?.cancel();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SessionSummaryPage(
          correctCount: _correctCount,
          totalCount: _questions.length,
          timeSpent: _totalTimeSpent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF07C160)),
              SizedBox(height: 16),
              Text('Loading questions...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'No questions available',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;
    // Fixed 30 seconds per question
    final timerProgress = _timeRemaining / 30.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Progress
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Question ${_currentIndex + 1}/${_questions.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_timeRemaining}s',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _timeRemaining < 10
                              ? Colors.red
                              : const Color(0xFF07C160),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Question Progress
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF07C160),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Timer Progress
                  LinearProgressIndicator(
                    value: timerProgress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      timerProgress > 0.5
                          ? const Color(0xFF07C160)
                          : timerProgress > 0.25
                          ? Colors.orange
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            // Question Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Question Text
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        question.content,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ),

                    // Image (if present) - using imagePath instead of svgDiagram
                    if (question.imagePath != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            '[Image Diagram]',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Answer Options (options is never null in current model)
                    ...question.options.map(
                      (option) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildOptionButton(option),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String option) {
    final currentQuestion = _questions[_currentIndex];

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E293B),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          elevation: 0,
        ),
        onPressed: () {
          // 正确判定: 比较用户选择的选项和题目的正确答案
          final isCorrect = option == currentQuestion.answer;
          _answerQuestion(isCorrect);
        },
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(option, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
