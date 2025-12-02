import 'package:flutter/material.dart';
import '../services/openai_service.dart';

/// AI辅导界面 - 分析错题并生成验证性问题
class AITutorSheet extends StatefulWidget {
  final Map<String, dynamic> wrongQuestion;
  final VoidCallback? onVerified; // 用户通过验证后的回调
  final VoidCallback? onClose;

  const AITutorSheet({
    super.key,
    required this.wrongQuestion,
    this.onVerified,
    this.onClose,
  });

  @override
  State<AITutorSheet> createState() => _AITutorSheetState();
}

class _AITutorSheetState extends State<AITutorSheet> {
  final _openAIService = OpenAIService();

  // 状态管理
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // AI生成的内容
  String _explanation = '';
  String _verificationQuestion = '';
  List<String> _options = [];
  int _correctAnswerIndex = -1;

  // 用户交互
  int? _selectedOption;
  bool _hasAnswered = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _generateVerification();
  }

  Future<void> _generateVerification() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await _openAIService.generateVerificationQuestion(
        widget.wrongQuestion,
      );

      setState(() {
        _explanation = result['explanation'] as String;
        _verificationQuestion = result['new_question'] as String;
        _options = List<String>.from(result['options']);
        _correctAnswerIndex = result['correct_answer'] as int;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _handleOptionSelect(int index) {
    if (_hasAnswered) return;

    setState(() {
      _selectedOption = index;
      _hasAnswered = true;
      _isCorrect = index == _correctAnswerIndex;
    });

    // 如果答对了，延迟后通知父组件
    if (_isCorrect) {
      Future.delayed(const Duration(seconds: 2), () {
        widget.onVerified?.call();
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          const Divider(height: 1),

          // Content
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _hasError
                ? _buildErrorState()
                : _buildChatInterface(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.psychology,
              color: Color(0xFF358373),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI名师辅导',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  '让我帮你理解这道题',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF64748B)),
            onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF358373),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '🤔 AI导师正在分析...',
            style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),
          const Text(
            '即将生成专属辅导内容',
            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFFF4D4F)),
            const SizedBox(height: 16),
            const Text(
              '生成失败',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _generateVerification,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF358373),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInterface() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step 1: 原题回顾
          _buildOriginalQuestion(),
          const SizedBox(height: 20),

          // Step 2: AI解释
          _buildAIExplanation(),
          const SizedBox(height: 24),

          // Step 3: 验证性问题
          _buildVerificationQuestion(),
          const SizedBox(height: 24),

          // Step 4: 结果反馈
          if (_hasAnswered) _buildFeedback(),
        ],
      ),
    );
  }

  Widget _buildOriginalQuestion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE5E5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4D4F),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '你答错的题目',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.wrongQuestion['question'] ?? '',
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1E293B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIExplanation() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF358373),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'AI导师的分析',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF358373),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _explanation,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF358373).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.quiz, size: 18, color: Color(0xFF358373)),
              SizedBox(width: 8),
              Text(
                '现在来试试这道类似的题目',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF358373),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 题目内容
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: Text(
            _verificationQuestion,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1E293B),
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 选项
        ..._options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isSelected = _selectedOption == index;
          final isCorrectOption = index == _correctAnswerIndex;

          Color backgroundColor;
          Color borderColor;
          Color textColor;
          IconData? icon;

          if (!_hasAnswered) {
            // 未答题状态
            backgroundColor = isSelected
                ? const Color(0xFFE8F5F1)
                : Colors.white;
            borderColor = isSelected
                ? const Color(0xFF358373)
                : const Color(0xFFE2E8F0);
            textColor = const Color(0xFF1E293B);
            icon = null;
          } else {
            // 已答题状态
            if (isCorrectOption) {
              backgroundColor = const Color(0xFFE8F5E9);
              borderColor = const Color(0xFF07C160);
              textColor = const Color(0xFF07C160);
              icon = Icons.check_circle;
            } else if (isSelected && !_isCorrect) {
              backgroundColor = const Color(0xFFFFEBEE);
              borderColor = const Color(0xFFFF4D4F);
              textColor = const Color(0xFFFF4D4F);
              icon = Icons.cancel;
            } else {
              backgroundColor = Colors.white;
              borderColor = const Color(0xFFE2E8F0);
              textColor = const Color(0xFF64748B);
              icon = null;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => _handleOptionSelect(index),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: borderColor,
                    width: isSelected || isCorrectOption && _hasAnswered
                        ? 2
                        : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: icon != null
                            ? borderColor.withOpacity(0.1)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Center(
                        child: icon != null
                            ? Icon(icon, color: borderColor, size: 18)
                            : Text(
                                String.fromCharCode(65 + index), // A, B, C, D
                                style: TextStyle(
                                  color: borderColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor,
                          height: 1.4,
                          fontWeight:
                              isSelected || (isCorrectOption && _hasAnswered)
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFeedback() {
    return AnimatedOpacity(
      opacity: _hasAnswered ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isCorrect
                ? [
                    const Color(0xFF07C160).withOpacity(0.1),
                    const Color(0xFF07C160).withOpacity(0.05),
                  ]
                : [
                    const Color(0xFFFFA500).withOpacity(0.1),
                    const Color(0xFFFFA500).withOpacity(0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isCorrect
                ? const Color(0xFF07C160)
                : const Color(0xFFFFA500),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _isCorrect ? Icons.celebration : Icons.psychology,
              size: 48,
              color: _isCorrect
                  ? const Color(0xFF07C160)
                  : const Color(0xFFFFA500),
            ),
            const SizedBox(height: 12),
            Text(
              _isCorrect ? '🎉 太棒了！你掌握了！' : '🤔 还有点难度？没关系！',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _isCorrect
                    ? const Color(0xFF07C160)
                    : const Color(0xFFFFA500),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isCorrect
                  ? '你已经理解了这个知识点的核心概念，继续保持！'
                  : '让我们换一个角度理解这个概念。多练习几次就会掌握的！',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            if (!_isCorrect) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _generateVerification,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('再试一题'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFFA500),
                  side: const BorderSide(color: Color(0xFFFFA500), width: 1.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
