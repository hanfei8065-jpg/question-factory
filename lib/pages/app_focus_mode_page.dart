// [LEARNEST_FOCUS_MODE_PAGE_V8.0_TOTAL_RESTORE] - 100% 原始逻辑还原 + Supabase 修复版
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import '../models/question.dart';
import 'app_session_summary_page.dart';

class AppFocusModePage extends StatefulWidget {
  final String subjectId;
  final String grade;
  final int questionLimit;
  final String topic;

  const AppFocusModePage({
    super.key,
    required this.subjectId,
    required this.grade,
    required this.questionLimit,
    required this.topic,
  });

  @override
  State<AppFocusModePage> createState() => _AppFocusModePageState();
}

class _AppFocusModePageState extends State<AppFocusModePage>
    with TickerProviderStateMixin {
  // --- 核心业务状态 ---
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _correctCount = 0;
  Timer? _timer;
  int _totalTimeSpent = 0;
  bool _isLoading = true;
  String? _selectedAnswer;

  // 动画控制：确保题目切换时有母语级顺滑感
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

  // --- 🚀 核心逻辑：母语级多语言检索 (修正 inFilter 报错) ---
  Future<void> _loadQuestionsFromSupabase() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // 1. 数据对齐：将 "11年级" 统一为数据库修正后的 "grade11"
      String numericPart = widget.grade.replaceAll(RegExp(r'[^0-9]'), '');
      String dbGrade = "grade$numericPart";

      // 2. 学科兼容 (兼容数据库中可能存在的 "数学" 和 "Math")
      List<String> subjectSearchList = [widget.subjectId];
      if (widget.subjectId == '数学') subjectSearchList.add('Math');
      if (widget.subjectId == '物理') subjectSearchList.add('Physics');

      // 3. 构建多维度查询
      // 注意：这里使用了 .inFilter 解决了你遇到的报错问题
      final response = await supabase
          .from('questions')
          .select()
          .inFilter('subject', subjectSearchList)
          .eq('grade', dbGrade)
          .limit(widget.questionLimit);

      if (response != null && (response as List).isNotEmpty) {
        final List<Question> loaded = [];
        for (var data in response) {
          // 像素级 Options 解析 logic
          List<String> opts = [];
          var rawOptions = data['options'];
          if (rawOptions is List) {
            opts = List<String>.from(rawOptions);
          } else if (rawOptions is String) {
            try {
              var decoded = jsonDecode(rawOptions);
              if (decoded is List) opts = List<String>.from(decoded);
            } catch (e) {
              opts = rawOptions.split(RegExp(r',\s*'));
            }
          }

          loaded.add(Question(
            id: data['id']?.toString() ?? "",
            content: data['content']?.toString() ?? "Content Missing",
            subject: _mapStringToSubject(widget.subjectId),
            grade: int.tryParse(numericPart) ?? 10,
            type: QuestionType.choice,
            difficulty: 3,
            tags: (data['tags'] is List) ? List<String>.from(data['tags']) : [],
            options: opts.length >= 2 ? opts : ['A', 'B', 'C', 'D'],
            answer: data['answer']?.toString() ?? "",
            explanation:
                data['explanation']?.toString() ?? "No explanation available.",
          ));
        }

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
      debugPrint("❌ 严重错误: $e");
      _handleError(e.toString());
    }
  }

  Subject _mapStringToSubject(String sub) {
    if (sub.contains('物理')) return Subject.physics;
    if (sub.contains('化学')) return Subject.chemistry;
    return Subject.math;
  }

  void _handleEmptyResult() {
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("库中暂无匹配的母语题目: ${widget.subjectId} $dbGrade"),
      backgroundColor: Colors.black87,
    ));
    Navigator.pop(context);
  }

  String get dbGrade =>
      "grade${widget.grade.replaceAll(RegExp(r'[^0-9]'), '')}";

  void _handleError(String err) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text("工厂连接异常"),
              content: Text("请检查网络或表结构：\n$err"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("返回重试"))
              ],
            ));
  }

  void _startGlobalTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) setState(() => _totalTimeSpent++);
    });
  }

  // --- 交互与动画逻辑 ---
  void _handleAnswer(String option) {
    if (_selectedAnswer != null) return;

    setState(() => _selectedAnswer = option);

    String correct = _questions[_currentIndex].answer;
    if (option == correct || option.startsWith(correct)) {
      _correctCount++;
    }

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        if (_currentIndex < _questions.length - 1) {
          _fadeController.reverse().then((_) {
            setState(() {
              _currentIndex++;
              _selectedAnswer = null;
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
                )));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body:
            Center(child: CircularProgressIndicator(color: Color(0xFFE82127))),
      );
    }

    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: Text("数据正在注入...")));
    }

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
              minHeight: 3,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 15, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _teslaActionIcon(Icons.close, () => Navigator.pop(context)),
                  Text("${_currentIndex + 1} / ${_questions.length}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 16)),
                  _teslaActionIcon(Icons.ios_share, () {}),
                ],
              ),
            ),
            Expanded(
              child: FadeTransition(
                opacity: _fadeController,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (question.tags.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: const Color(0xFFE82127).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(question.tags.first.toUpperCase(),
                              style: const TextStyle(
                                  color: Color(0xFFE82127),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10)),
                        ),
                      Text(
                        question.content,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                            color: Color(0xFF1D1D1F)),
                      ),
                      const SizedBox(height: 48),
                      ...question.options.map((opt) => _buildOptionCard(opt)),
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

  Widget _teslaActionIcon(IconData icon, VoidCallback onTap) {
    return _TeslaScaleWrapperInternal(
      onTap: onTap,
      child: Icon(icon, color: Colors.black26, size: 22),
    );
  }

  Widget _buildOptionCard(String text) {
    bool isSelected = _selectedAnswer == text;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _TeslaScaleWrapperInternal(
        onTap: () => _handleAnswer(text),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFF1D1D1F) : const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1D1D1F),
                    fontSize: 17,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_outline,
                    color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 内部物理引擎：Tesla 0.93 缩放 ---
class _TeslaScaleWrapperInternal extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _TeslaScaleWrapperInternal({required this.child, required this.onTap});
  @override
  State<_TeslaScaleWrapperInternal> createState() =>
      __TeslaScaleWrapperInternalState();
}

class __TeslaScaleWrapperInternalState extends State<_TeslaScaleWrapperInternal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
