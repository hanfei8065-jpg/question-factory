import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../services/openai_service.dart';
import 'calculator_selection_page.dart';
import 'package:confetti/confetti.dart';

/// 全新的做题页 - 学生学习AI解题过程
class SolvingPage extends StatefulWidget {
  final List<File> questionImages; // 题目截图列表（支持1-3题）
  
  const SolvingPage({
    super.key,
    required this.questionImages,
  });

  @override
  State<SolvingPage> createState() => _SolvingPageState();
}

class _SolvingPageState extends State<SolvingPage> {
  int _currentQuestionIndex = 0; // 当前选中的题目
  final TextEditingController _answerController = TextEditingController();
  final ConfettiController _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  
  // 每个题目的AI解题数据
  List<QuestionSolution> _solutions = [];
  bool _isLoading = true;
  bool _showBingo = false;

  @override
  void initState() {
    super.initState();
    _loadAllSolutions();
  }

  @override
  void dispose() {
    _answerController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  /// 一次性加载所有题目的AI解题过程和答案
  Future<void> _loadAllSolutions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final solutions = <QuestionSolution>[];
      
      for (final image in widget.questionImages) {
        // 调用OpenAI API获取解题过程和答案
        final result = await OpenAIService().getSolutionProcess(image);
        solutions.add(QuestionSolution(
          solutionProcess: result['process'] as String,
          correctAnswer: result['answer'] as String,
        ));
      }

      setState(() {
        _solutions = solutions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI解题失败：$e')),
        );
      }
    }
  }

  /// 提交答案验证
  void _submitAnswer() {
    final userAnswer = _answerController.text.trim();
    final correctAnswer = _solutions[_currentQuestionIndex].correctAnswer;

    if (userAnswer == correctAnswer) {
      // 答案正确！
      setState(() {
        _showBingo = true;
      });
      _confettiController.play();
      
      // 2.5秒后隐藏Bingo
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) {
          setState(() {
            _showBingo = false;
          });
        }
      });
    } else {
      // 答案错误
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('答案不对，再想想看！'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// 直接查看答案
  void _showAnswer() {
    final answer = _solutions[_currentQuestionIndex].correctAnswer;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('正确答案'),
        content: Text(
          answer,
          style: TextStyle(
            fontSize: AppTheme.fontSizeXL,
            fontWeight: AppTheme.fontWeightBold,
            color: AppTheme.brandPrimary,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('解题学习'),
        backgroundColor: AppTheme.brandPrimary,
        foregroundColor: Colors.white,
        actions: [
          // 右上角计算器图标
          IconButton(
            icon: const Icon(Icons.calculate_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CalculatorSelectionPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 顶部：题目截图区（多题模式可切换）
              _buildQuestionImagesSection(),
              
              // 中间：AI解题过程展示区
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildSolutionProcessSection(),
              ),
              
              // 底部：输入框+发送按钮 | 答案按钮
              _buildBottomInputSection(),
            ],
          ),
          
          // Bingo动画层
          if (_showBingo) _buildBingoOverlay(),
          
          // 烟花动画
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.2,
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
        ],
      ),
    );
  }

  /// 构建顶部题目截图区
  Widget _buildQuestionImagesSection() {
    if (widget.questionImages.length == 1) {
      // 单题模式：直接显示大图
      return Container(
        width: double.infinity,
        height: 200,
        color: AppTheme.backgroundLight,
        child: Image.file(
          widget.questionImages[0],
          fit: BoxFit.contain,
        ),
      );
    } else {
      // 多题模式：显示3个可切换的缩略图
      return Container(
        height: 120,
        color: AppTheme.backgroundLight,
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(widget.questionImages.length, (index) {
            final isSelected = index == _currentQuestionIndex;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentQuestionIndex = index;
                  _answerController.clear();
                });
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.brandPrimary
                        : AppTheme.borderLight,
                    width: isSelected ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM - 1),
                  child: Image.file(
                    widget.questionImages[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }),
        ),
      );
    }
  }

  /// 构建AI解题过程展示区
  Widget _buildSolutionProcessSection() {
    final solution = _solutions[_currentQuestionIndex];
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI解题过程',
            style: TextStyle(
              fontSize: AppTheme.fontSizeL,
              fontWeight: AppTheme.fontWeightBold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: AppTheme.spacing12),
          Container(
            padding: EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Text(
              solution.solutionProcess,
              style: TextStyle(
                fontSize: AppTheme.fontSizeM,
                color: AppTheme.textPrimary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建底部输入区
  Widget _buildBottomInputSection() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing16),
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
          // 输入框（内嵌发送按钮，模仿微信）
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _answerController,
                      decoration: InputDecoration(
                        hintText: '输入你的答案...',
                        hintStyle: TextStyle(color: AppTheme.textPlaceholder),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing16,
                          vertical: AppTheme.spacing12,
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  // 发送按钮（在输入框右侧）
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: AppTheme.brandPrimary,
                    ),
                    onPressed: _submitAnswer,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: AppTheme.spacing12),
          // 答案按钮
          ElevatedButton(
            onPressed: _showAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.brandSecondary,
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacing20,
                vertical: AppTheme.spacing12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
              ),
            ),
            child: const Text(
              '答案',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建Bingo庆祝遮罩层
  Widget _buildBingoOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bingo!',
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: AppTheme.successGreen,
                shadows: [
                  Shadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTheme.spacing24),
            Text(
              '答案正确！',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: AppTheme.fontWeightMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 题目解题数据模型
class QuestionSolution {
  final String solutionProcess; // AI生成的解题过程
  final String correctAnswer; // 正确答案

  QuestionSolution({
    required this.solutionProcess,
    required this.correctAnswer,
  });
}
