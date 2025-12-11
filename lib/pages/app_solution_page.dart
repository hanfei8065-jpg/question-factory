import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';

class SolvingPage extends StatefulWidget {
  final String imagePath;
  final int rotationCount;

  const SolvingPage({
    super.key,
    required this.imagePath,
    this.rotationCount = 0,
  });

  @override
  State<SolvingPage> createState() => _SolvingPageState();
}

class _SolvingPageState extends State<SolvingPage> {
  final TextEditingController _answerController = TextEditingController();
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 3),
  );

  bool _isAnswerRevealed = false;

  // Mock data
  final String _correctAnswer = "42";
  final List<Map<String, String>> _mockSteps = [
    {'title': 'Step 1: 识别题目类型', 'content': '这是一道代数方程求解问题，需要使用一元二次方程公式。'},
    {'title': 'Step 2: 整理方程', 'content': '将方程整理为标准形式: x² - 2x + 1 = 0'},
    {
      'title': 'Step 3: 应用求根公式',
      'content': '使用公式 x = (-b ± √(b²-4ac)) / 2a\n代入 a=1, b=-2, c=1',
    },
  ];

  @override
  void dispose() {
    _answerController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onSubmitAnswer() {
    final input = _answerController.text.trim();

    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入答案'), duration: Duration(seconds: 1)),
      );
      return;
    }

    if (input == _correctAnswer) {
      // BINGO! 🎉
      _triggerBingoMoment();
    } else {
      // Wrong answer
      _showWrongAnswerSnackbar();
    }
  }

  void _triggerBingoMoment() {
    // 1. Play confetti
    _confettiController.play();

    // 2. Play system sound
    SystemSound.play(SystemSoundType.click);

    // 3. Show trophy dialog
    Future.delayed(const Duration(milliseconds: 300), () {
      _showTrophyDialog();
    });
  }

  void _showTrophyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy icon (placeholder)
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD700), // Gold
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'BINGO! 🎉',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF07C160),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '恭喜你答对了！',
                style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF07C160),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: const Text(
                  '太棒了！',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWrongAnswerSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('还不对哦，再试试？'),
            const Spacer(),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                // TODO: Navigate to Arena
                debugPrint('Navigate to Arena');
              },
              child: const Text(
                '去挑战区 >',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: const Color(0xFF1E293B),
      ),
    );
  }

  void _onRevealAnswerTap() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('查看答案'),
        content: const Text('查看答案会消耗一次"提示机会"，确定要查看吗？\n\n提示: 尝试自己解答可以获得更多积分！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('再想想'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isAnswerRevealed = true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF07C160),
            ),
            child: const Text('确定查看'),
          ),
        ],
      ),
    );
  }

  void _onAskDrLogic() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dr. Logic AI助手功能开发中...'),
        duration: Duration(seconds: 2),
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
        title: const Text(
          '解题详情',
          style: TextStyle(
            color: darkGrey,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: darkGrey),
            onPressed: () {
              debugPrint('Share solution');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header: Cropped image
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Transform.rotate(
                            angle: widget.rotationCount * 3.14159 / 2,
                            child: Image.file(
                              File(widget.imagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      // Solution steps
                      ..._mockSteps.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.value['title']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: darkGrey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  entry.value['content']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF64748B),
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      // Final answer card (masked)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: GestureDetector(
                          onTap: _isAnswerRevealed ? null : _onRevealAnswerTap,
                          child: Stack(
                            children: [
                              // Base card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: wechatGreen,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: wechatGreen.withOpacity(0.1),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '最终答案',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: wechatGreen,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'x = $_correctAnswer',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: darkGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Blur mask (if not revealed)
                              if (!_isAnswerRevealed)
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: BackdropFilter(
                                      filter: ui.ImageFilter.blur(
                                        sigmaX: 8,
                                        sigmaY: 8,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFB9E4D4,
                                          ).withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(
                                              Icons.lock_outline,
                                              size: 32,
                                              color: Colors.white,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              '点击查看答案',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Helper bar
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: OutlinedButton.icon(
                            onPressed: _onAskDrLogic,
                            icon: const Icon(Icons.psychology_outlined),
                            label: const Text('Ask Dr. Logic'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: wechatGreen,
                              side: const BorderSide(
                                color: wechatGreen,
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom input bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Input field
                    Expanded(
                      child: TextField(
                        controller: _answerController,
                        decoration: InputDecoration(
                          hintText: 'Enter your answer...',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                          filled: true,
                          fillColor: bgGrey,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _onSubmitAnswer(),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Submit button
                    ElevatedButton(
                      onPressed: _onSubmitAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: wechatGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '提交',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Confetti layer (top center)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14159 / 2, // Down
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.3,
              colors: const [
                Color(0xFF07C160),
                Color(0xFFFFD700),
                Color(0xFF3B82F6),
                Color(0xFFF59E0B),
                Color(0xFFEC4899),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
