import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../widgets/aitutor_sheet.dart';
import '../services/session_poster_generator.dart';

class SessionSummaryPage extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final int xpEarned;
  final List<Map<String, dynamic>>
  wrongQuestions; // Using Map to match current Arena format
  final String subjectId;

  const SessionSummaryPage({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.xpEarned,
    required this.wrongQuestions,
    required this.subjectId,
  });

  @override
  State<SessionSummaryPage> createState() => _SessionSummaryPageState();
}

class _SessionSummaryPageState extends State<SessionSummaryPage>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // ✅✅ Track which questions have been reviewed
  final Set<int> _reviewedQuestions = {};

  @override
  void initState() {
    super.initState();

    // Confetti setup
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Stats animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // Trigger animations
    Future.delayed(const Duration(milliseconds: 300), () {
      _confettiController.play();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  double get _accuracy => widget.totalQuestions == 0
      ? 0.0
      : (widget.score / widget.totalQuestions) * 100;

  Color get _accuracyColor {
    if (_accuracy >= 80) return const Color(0xFF07C160); // Green
    if (_accuracy >= 60) return const Color(0xFFFFA500); // Orange
    return const Color(0xFFFF4D4F); // Red
  }

  String get _performanceMessage {
    if (_accuracy >= 90) return '太棒了！你是学霸！🌟';
    if (_accuracy >= 80) return '很好！继续保持！💪';
    if (_accuracy >= 70) return '不错！再接再厉！📚';
    if (_accuracy >= 60) return '还可以，继续努力！🔥';
    return '加油！多练习会更好！💡';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back button - must use "Back to Home"
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Stack(
          children: [
            // Main Content
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Title with animation
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: const Text(
                          '🎉 Session Complete!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Performance message
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          _performanceMessage,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFF64748B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Stats Card
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildStatsCard(),
                      ),

                      const SizedBox(height: 24),

                      // Wrong Questions Section
                      if (widget.wrongQuestions.isNotEmpty) ...[
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildWrongQuestionsSection(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Action Buttons
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildActionButtons(),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // Confetti Overlay
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: 3.14 / 2, // Down
                maxBlastForce: 5,
                minBlastForce: 2,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                gravity: 0.3,
                colors: const [
                  Color(0xFF07C160),
                  Color(0xFFFFA500),
                  Color(0xFF1E90FF),
                  Color(0xFFFF4D4F),
                  Color(0xFFFFD700),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular Accuracy Display
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 12,
                    backgroundColor: const Color(0xFFF0F0F0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _accuracyColor.withOpacity(0.2),
                    ),
                  ),
                ),
                // Progress circle
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: _accuracy / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(_accuracyColor),
                  ),
                ),
                // Center text
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_accuracy.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: _accuracyColor,
                      ),
                    ),
                    const Text(
                      'Accuracy',
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.check_circle,
                label: 'Correct',
                value: '${widget.score}/${widget.totalQuestions}',
                color: const Color(0xFF07C160),
              ),
              Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
              _buildStatItem(
                icon: Icons.star,
                label: 'XP Earned',
                value: '+${widget.xpEarned}',
                color: const Color(0xFFFFA500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildWrongQuestionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFFF4D4F),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Review Your Mistakes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.wrongQuestions.length} question${widget.wrongQuestions.length > 1 ? 's' : ''} to review',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),

          // Wrong Questions List
          ...widget.wrongQuestions.asMap().entries.map((entry) {
            final index = entry.key;
            final q = entry.value;
            final isReviewed = _reviewedQuestions.contains(index);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isReviewed
                    ? const Color(0xFFF0FDF4) // Green tint if reviewed
                    : const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isReviewed
                      ? const Color(0xFF07C160).withOpacity(0.3)
                      : const Color(0xFFFFE5E5),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isReviewed
                              ? const Color(0xFF07C160)
                              : const Color(0xFFFF4D4F),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          q['question'] ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF1E293B),
                            height: 1.4,
                          ),
                        ),
                      ),
                      // ✅✅ Reviewed badge
                      if (isReviewed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF07C160),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '已复习',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (q['explanation'] != null &&
                      q['explanation'].toString().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            size: 16,
                            color: Color(0xFFFFA500),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              q['explanation'].toString(),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // ✅✅ AI Review Button
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isReviewed
                          ? null
                          : () => _showAIReview(index, q),
                      icon: Icon(
                        isReviewed ? Icons.check_circle : Icons.psychology,
                        size: 18,
                      ),
                      label: Text(
                        isReviewed ? '已通过AI验证' : 'AI辅导 - 验证理解',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isReviewed
                            ? const Color(0xFF07C160)
                            : const Color(0xFF358373),
                        side: BorderSide(
                          color: isReviewed
                              ? const Color(0xFF07C160).withOpacity(0.5)
                              : const Color(0xFF358373),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Share Report Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _handleShareReport,
            icon: const Icon(Icons.share, size: 20),
            label: const Text(
              'Share Report',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF07C160),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Back to Home Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.home, size: 20),
            label: const Text(
              'Back to Home',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1E293B),
              side: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ✅✅ Show AI Review sheet
  void _showAIReview(int questionIndex, Map<String, dynamic> question) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false, // Force user to complete or close
      builder: (context) => AITutorSheet(
        wrongQuestion: question,
        onVerified: () {
          // Mark question as reviewed
          setState(() {
            _reviewedQuestions.add(questionIndex);
          });
        },
        onClose: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _handleShareReport() async {
    // 显示加载提示
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF07C160)),
              ),
              const SizedBox(height: 16),
              Text(
                '正在生成精美海报...',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // 🎨 调用海报生成器
      await SessionPosterGenerator.shareReport(
        context: context,
        score: widget.score,
        totalQuestions: widget.totalQuestions,
        xpEarned: widget.xpEarned,
        accuracy: _accuracy,
        subjectName: _getSubjectName(widget.subjectId),
      );

      // 关闭加载对话框
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // 关闭加载对话框
      if (mounted) {
        Navigator.of(context).pop();
      }

      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分享失败，请重试'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: '重试',
              textColor: Colors.white,
              onPressed: _handleShareReport,
            ),
          ),
        );
      }
    }
  }

  // 📚 根据 subjectId 返回科目名称
  String _getSubjectName(String subjectId) {
    switch (subjectId.toLowerCase()) {
      case 'math':
        return 'Mathematics';
      case 'physics':
        return 'Physics';
      case 'chemistry':
        return 'Chemistry';
      case 'olympiad':
        return 'Olympiad';
      default:
        return 'Mathematics';
    }
  }
}
