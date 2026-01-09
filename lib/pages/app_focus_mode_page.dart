// [LEARNEST_FOCUS_MODE_PAGE_V9.0_TOTAL_RESTORE] - 100% 原始逻辑 + lang 参数闭环版
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
  final String lang; // ✅ 植入：接收语言参数
  final int questionLimit;
  final String topic;

  const AppFocusModePage({
    super.key,
    required this.subjectId,
    required this.grade,
    required this.lang, // ✅ 植入：设置为必须传入
    required this.questionLimit,
    required this.topic,
  });

  @override
  State<AppFocusModePage> createState() => _AppFocusModePageState();
}

class _AppFocusModePageState extends State<AppFocusModePage>
    with TickerProviderStateMixin {
  // --- 核心业务状态 (完全保留) ---
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _correctCount = 0;
  Timer? _timer;
  int _totalTimeSpent = 0;
  bool _isLoading = true;
  String? _selectedAnswer;

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

  // --- 🚀 核心逻辑：工厂对齐级检索 (植入 lang 过滤) ---
  Future<void> _loadQuestionsFromSupabase() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // 1. 数据对齐：widget.grade 已经是 'grade10' 格式（由上一页转换）
      String dbGrade = widget.grade;

      // 2. 构建多维度查询 (对齐工厂标准的 subject_id, grade_id, lang)
      final response = await supabase
          .from('questions')
          .select()
          .eq('subject_id', widget.subjectId.toLowerCase()) // 对齐工厂 ID
          .eq('grade_id', dbGrade) // 对齐工厂 ID
          .eq('lang', widget.lang) // ✅ 核心修复：只取对应语言的题
          .order('id', ascending: false) // 优先取最新产出的题
          .limit(widget.questionLimit);

      if (response != null && (response as List).isNotEmpty) {
        final List<Question> loaded = [];
        for (var data in response) {
          // 使用我们在 Question Model 里定义的 fromMap，这样最稳
          loaded.add(Question.fromMap(data));
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

  // --- 以下原始逻辑 100% 保留，未做任何删减 ---

  Subject _mapStringToSubject(String sub) {
    if (sub.contains('物理')) return Subject.physics;
    if (sub.contains('化学')) return Subject.chemistry;
    return Subject.math;
  }

  void _handleEmptyResult() {
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          "库中暂无匹配的 ${widget.lang} 题目: ${widget.subjectId} ${widget.grade}"),
      backgroundColor: Colors.black87,
    ));
    Navigator.pop(context);
  }

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
                      if (question.tags != null && question.tags!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: const Color(0xFFE82127).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(question.tags!.first.toUpperCase(),
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

// --- 内部物理引擎：Tesla 0.93 缩放 (保持原样) ---
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
