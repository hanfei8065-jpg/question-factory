// [LEARNEST_FOCUS_MODE_V11.0_TOTAL_ALIGNED] - 题型/权重/逻辑全对齐定稿版
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../models/question.dart';
import 'app_session_summary_page.dart';

class AppFocusModePage extends StatefulWidget {
  final String subjectId;
  final String grade;
  final String lang;
  final String questionType; // 接收：choice, fill_in, word_problem
  final int questionLimit;
  final String topic;

  const AppFocusModePage({
    super.key,
    required this.subjectId,
    required this.grade,
    required this.lang,
    required this.questionType,
    required this.questionLimit,
    required this.topic,
  });

  @override
  State<AppFocusModePage> createState() => _AppFocusModePageState();
}

class _AppFocusModePageState extends State<AppFocusModePage>
    with TickerProviderStateMixin {
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _correctCount = 0;
  Timer? _timer;
  int _totalTimeSpent = 0;
  bool _isLoading = true;
  String? _selectedAnswer;
  bool _isShowingExplanation = false; // 用于填空和应用题

  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _loadQuestionsFromSupabase();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  // --- 🚀 数据请求逻辑：多维参数精准对齐 ---
  Future<void> _loadQuestionsFromSupabase() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      // 查询条件：subject_id, grade_id, lang, type
      final response = await supabase
          .from('questions')
          .select()
          .eq('subject_id', widget.subjectId.toLowerCase())
          .eq('grade_id', widget.grade)
          .eq('lang', widget.lang)
          .eq('type', widget.questionType)
          .order('id', ascending: false)
          .limit(widget.questionLimit);

      if (response != null && (response as List).isNotEmpty) {
        final List<Question> loaded =
            response.map((data) => Question.fromMap(data)).toList();
        if (mounted) {
          setState(() {
            _questions = loaded;
            _isLoading = false;
          });
          _fadeController.forward();
          _startGlobalTimer();
        }
      } else {
        _handleEmptyResult();
      }
    } catch (e) {
      _handleError(e.toString());
    }
  }

  void _startGlobalTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) setState(() => _totalTimeSpent++);
    });
  }

  // --- 答题逻辑：区分题型 ---
  void _handleChoiceAnswer(String option) {
    if (_selectedAnswer != null) return;
    setState(() => _selectedAnswer = option);
    if (option == _questions[_currentIndex].answer) _correctCount++;
    _proceedToNext();
  }

  void _proceedToNext() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        if (_currentIndex < _questions.length - 1) {
          _fadeController.reverse().then((_) {
            setState(() {
              _currentIndex++;
              _selectedAnswer = null;
              _isShowingExplanation = false;
            });
            _fadeController.forward();
          });
        } else {
          _finishSession();
        }
      }
    });
  }

  void _finishSession() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (ctx) => SessionSummaryPage(
          correctCount: _correctCount,
          totalCount: _questions.length,
          timeSpent: _totalTimeSpent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: Color(0xFFE82127))));
    if (_questions.isEmpty)
      return const Scaffold(body: Center(child: Text("库中暂无匹配题目")));

    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFF2F2F7),
                color: const Color(0xFFE82127),
                minHeight: 3),
            _buildTopNav(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeController,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTag(question.tags?.first ?? "GENERAL"),
                      Text(question.content,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.4)),
                      const SizedBox(height: 48),
                      // ✅ 重点：根据题型渲染不同界面
                      if (widget.questionType == 'choice')
                        ...question.options.map((opt) => _buildOptionCard(opt))
                      else
                        _buildNonChoiceArea(question),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI 组件：非选择题（填空/应用题）展示区 ---
  Widget _buildNonChoiceArea(Question question) {
    return Column(
      children: [
        if (!_isShowingExplanation)
          _TeslaButton(
            label: "查看解析与答案",
            onTap: () => setState(() => _isShowingExplanation = true),
            color: const Color(0xFF1D1D1F),
            textColor: Colors.white,
          ),
        if (_isShowingExplanation)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("正确答案",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFFE82127))),
                const SizedBox(height: 8),
                Text(question.answer,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(height: 40),
                const Text("解题思路",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(question.explanation ?? "暂无解析内容",
                    style: const TextStyle(fontSize: 16, height: 1.6)),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                        child: _TeslaButton(
                            label: "我做对了",
                            onTap: () {
                              _correctCount++;
                              _proceedToNext();
                            },
                            color: Colors.green,
                            textColor: Colors.white)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _TeslaButton(
                            label: "下一题",
                            onTap: _proceedToNext,
                            color: Colors.black12,
                            textColor: Colors.black54)),
                  ],
                )
              ],
            ),
          ),
      ],
    );
  }

  // ... 辅助组件 (保持原有 Tesla 风格) ...
  Widget _buildOptionCard(String text) {
    bool isSelected = _selectedAnswer == text;
    return GestureDetector(
      onTap: () => _handleChoiceAnswer(text),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFF1D1D1F) : const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            Expanded(
                child: Text(text,
                    style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 17))),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNav() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context)),
          Text("${_currentIndex + 1} / ${_questions.length}",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const Icon(Icons.share, color: Colors.transparent),
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: const Color(0xFFE82127).withOpacity(0.1),
          borderRadius: BorderRadius.circular(6)),
      child: Text(tag.toUpperCase(),
          style: const TextStyle(
              color: Color(0xFFE82127),
              fontSize: 10,
              fontWeight: FontWeight.bold)),
    );
  }

  void _handleEmptyResult() {
    setState(() => _isLoading = false);
    Navigator.pop(context);
  }

  void _handleError(String e) {
    setState(() => _isLoading = false);
    print("Error: $e");
  }
}

// Tesla 风格按钮
class _TeslaButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;
  const _TeslaButton(
      {required this.label,
      required this.onTap,
      required this.color,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(16)),
        child: Center(
            child: Text(label,
                style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16))),
      ),
    );
  }
}
