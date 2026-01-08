import 'dart:io';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class SolvingPage extends StatefulWidget {
  final String imagePath;
  const SolvingPage({super.key, required this.imagePath});

  @override
  State<SolvingPage> createState() => _SolvingPageState();
}

class _SolvingPageState extends State<SolvingPage> {
  final TextEditingController _answerController = TextEditingController();
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 2),
  );
  bool _showBingo = false;
  bool _showCalculatorOverlay = false;
  String? _selectedCalculator;
  final List<Offset> _scribblePoints = [];
  bool _isAnswerRevealed = false;
  final String _solutionProcess = '1. 设未知数 x\n2. 方程两边同时减去 2\n3. 得到 x = 3';
  final String _correctAnswer = '3';
  final bool _isLoading = false;

  @override
  void dispose() {
    _answerController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    final userAnswer = _answerController.text.trim();
    if (userAnswer == _correctAnswer) {
      setState(() => _showBingo = true);
      _confettiController.play();
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) setState(() => _showBingo = false);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFFFF7ED),
          content: Text(
            '答案不完全正确，再检查一下？',
            style: TextStyle(color: Colors.black87),
          ),
        ),
      );
    }
  }

  void _revealAnswer() {
    setState(() => _isAnswerRevealed = true);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('正确答案'),
        content: Text(
          _correctAnswer,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF358373),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void _toggleCalculator([String? calculator]) {
    setState(() {
      _showCalculatorOverlay = !_showCalculatorOverlay;
      _selectedCalculator = calculator;
      if (!_showCalculatorOverlay) _scribblePoints.clear();
    });
  }

  Widget _buildBingoOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Bingo!',
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Color(0xFF22C55E),
              ),
            ),
            SizedBox(height: 24),
            Text('答案正确！', style: TextStyle(fontSize: 24, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // ✅ 100% 清理后的解题区域：只有标题和过程
  Widget _buildSolutionSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI解题过程',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8),
              ],
            ),
            child: Text(
              _solutionProcess,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF334155),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _answerController,
                decoration: const InputDecoration(
                  hintText: '输入你的答案...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _revealAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF358373),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              '答案',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('解题学习'),
        backgroundColor: const Color(0xFF358373),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate_outlined),
            onPressed: () => _toggleCalculator('Standard'),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                height: 200,
                color: Colors.white,
                child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
              ),
              Expanded(child: _buildSolutionSection()),
              _buildBottomInputSection(),
            ],
          ),
          if (_showBingo) _buildBingoOverlay(),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
          if (_showCalculatorOverlay)
            Positioned.fill(
              child: GestureDetector(
                onPanUpdate: (d) =>
                    setState(() => _scribblePoints.add(d.localPosition)),
                onPanEnd: (_) =>
                    setState(() => _scribblePoints.add(const Offset(-1, -1))),
                child: Container(
                  color: Colors.black.withOpacity(0.55),
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: _ScribblePainter(_scribblePoints),
                        size: Size.infinite,
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.48,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '计算器: ${_selectedCalculator ?? ''}',
                              style: const TextStyle(
                                fontSize: 22,
                                color: Color(0xFF358373),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        right: 24,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: _toggleCalculator,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScribblePainter extends CustomPainter {
  final List<Offset> points;
  _ScribblePainter(this.points);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != const Offset(-1, -1) &&
          points[i + 1] != const Offset(-1, -1)) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
