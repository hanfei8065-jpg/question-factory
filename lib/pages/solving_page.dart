import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import '../services/user_progress_service.dart';
import '../services/openai_service.dart'; // ✅ 接入真实 AI 服务
import 'calculator_selection_page.dart';

/// Clean & Immersive Solving Page with Real AI Integration
class SolvingPage extends StatefulWidget {
  final String imagePath;
  final int rotationCount;
  // questionText 可选，如果上一步 OCR 已经识别了最好，没有就让 AI 自己看图
  final String? questionText;

  const SolvingPage({
    super.key,
    required this.imagePath,
    this.rotationCount = 0,
    this.questionText,
  });

  @override
  State<SolvingPage> createState() => _SolvingPageState();
}

class _SolvingPageState extends State<SolvingPage> {
  final TextEditingController _answerController = TextEditingController();
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 3),
  );

  // Services
  final _progressService = UserProgressService();
  final _aiService = OpenAIService(); // ✅ 实例化 AI 服务

  // State
  bool _isLoadingSolution = true; // 页面一进来就开始加载
  String _robotState = 'thinking'; // 初始状态为思考中
  int _earnedXP = 0;

  // Data from AI
  String _solutionProcess = ""; // AI 返回的解题步骤
  String _correctAnswer = ""; // AI 返回的最终答案
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // 🚀 页面初始化时，立即触发 AI 解题
    _fetchRealSolution();
  }

  /// 调用 OpenAI/DeepSeek 获取真实解题数据
  Future<void> _fetchRealSolution() async {
    try {
      // 1. 构造图片文件对象
      final imageFile = File(widget.imagePath);

      // 2. 调用服务 (这里复用你现有的 getSolutionProcess 方法)
      // 注意：根据 Claude 查到的信息，这个方法返回 Map<String, dynamic>
      // 包含 'process' 和 'answer'
      final result = await _aiService.getSolutionProcess(imageFile);

      if (!mounted) return;

      setState(() {
        _solutionProcess = result['process'] ?? "无法生成解题步骤，请重试。";
        // 简单清洗答案，去除空格以便比对
        _correctAnswer = (result['answer'] ?? "").trim();
        _isLoadingSolution = false;
        _robotState = 'idle'; // 思考完毕
      });
    } catch (e) {
      debugPrint("AI Error: $e");
      if (!mounted) return;
      setState(() {
        _errorMessage = "AI 解题失败，请检查网络连接。\n$e";
        _isLoadingSolution = false;
        _robotState = 'idle';
      });
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  // 提交用户输入的答案进行比对
  void _onSubmitAnswer() {
    final input = _answerController.text.trim();
    if (input.isEmpty) return;

    FocusScope.of(context).unfocus();

    // 简单的比对逻辑，后续可以升级为模糊匹配
    final isCorrect = input.toLowerCase() == _correctAnswer.toLowerCase();

    if (isCorrect) {
      setState(() => _robotState = 'happy');
      _triggerBingoMoment();
    } else {
      _showWrongAnswerSnackbar();
    }
  }

  // 直接显示答案
  void _onRevealAnswer() {
    if (_correctAnswer.isEmpty) return;

    setState(() {
      _answerController.text = _correctAnswer;
      _robotState = 'happy';
    });
    // 直接看答案也给一个小庆祝，或者你可以选择不给 XP
    _triggerBingoMoment(giveXP: false);
  }

  void _triggerBingoMoment({bool giveXP = true}) async {
    bool rankedUp = false;
    if (giveXP) {
      const xpReward = 50;
      rankedUp = await _progressService.addXP(xpReward);
      await _progressService.incrementSolved();
      await _progressService.updateStreak();
      setState(() => _earnedXP = xpReward);
    } else {
      setState(() => _earnedXP = 0);
    }

    _confettiController.play();
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.heavyImpact();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (giveXP) _showTrophyDialog(rankedUp);
    });
  }

  void _onCalculatorTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CalculatorSelectionPage()),
    );
  }

  void _showWrongAnswerSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('还不对哦，再试试？'),
        backgroundColor: Color(0xFF1E293B),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showTrophyDialog(bool rankedUp) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 64, color: Color(0xFFFFD700)),
            const SizedBox(height: 16),
            const Text(
              'BINGO!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF07C160),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'XP +$_earnedXP',
              style: const TextStyle(fontSize: 18, color: Color(0xFF64748B)),
            ),
            if (rankedUp) ...[
              const SizedBox(height: 8),
              const Text(
                'Level Up! 🚀',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF07C160),
              ),
              child: const Text(
                'Awesome!',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgGrey = Color(0xFFF5F7FA);
    const Color wechatGreen = Color(0xFF07C160);
    const Color darkGrey = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkGrey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(
              _robotState == 'thinking'
                  ? Icons.psychology
                  : _robotState == 'happy'
                  ? Icons.emoji_emotions
                  : Icons.smart_toy,
              color: wechatGreen,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _isLoadingSolution ? 'AI 分析中...' : 'Dr. Logic',
              style: const TextStyle(
                color: darkGrey,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calculate_outlined,
              color: darkGrey,
              size: 28,
            ),
            onPressed: _onCalculatorTap,
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Stack(
        children: [
          Column(
            children: [
              // ----------------------------------------
              // 2. Middle Content Stream (Scrollable)
              // ----------------------------------------
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // A. Image Preview
                      if (widget.imagePath.isNotEmpty)
                        Container(
                          height: 120,
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(File(widget.imagePath)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                      // B. Error Message (if any)
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),

                      // C. Loading Skeleton
                      if (_isLoadingSolution && _errorMessage == null)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const CircularProgressIndicator(
                                color: wechatGreen,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "正在识别题目并生成解题步骤...",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),

                      // D. AI Solution Content (Markdown Text)
                      if (!_isLoadingSolution && _solutionProcess.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            // 这里直接显示文本，如果项目有 flutter_markdown 可以换成 MarkdownBody
                            child: Text(
                              _solutionProcess,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: darkGrey,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // ----------------------------------------
              // 3. Bottom Input Bar (Fixed)
              // ----------------------------------------
              Container(
                padding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 12,
                  bottom: 12 + MediaQuery.of(context).padding.bottom,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, -2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.mic_none_rounded, color: darkGrey),
                      onPressed: () {
                        // Voice Input TODO
                      },
                    ),
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: bgGrey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _answerController,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _onSubmitAnswer(),
                          enabled: !_isLoadingSolution, // 加载时禁用输入
                          decoration: InputDecoration(
                            hintText: _isLoadingSolution
                                ? '等待题目解析...'
                                : '请自己演算并输入答案哦...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            suffixIcon: GestureDetector(
                              onTap: _onSubmitAnswer,
                              child: const Icon(
                                Icons.check_circle,
                                color: wechatGreen,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _isLoadingSolution ? null : _onRevealAnswer,
                      child: Opacity(
                        opacity: _isLoadingSolution ? 0.5 : 1.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: bgGrey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '答案',
                            style: TextStyle(
                              color: darkGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Confetti Overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14159 / 2,
              gravity: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
