import 'package:flutter/material.dart';
import 'dart:async';
import 'app_question_arena_page.dart';

/// Duolingo-style AI Chat Setup for Question Bank
/// User chats with Dr. Logic mascot to configure practice session
class AppQuestionBankPage extends StatefulWidget {
  const AppQuestionBankPage({super.key});

  @override
  State<AppQuestionBankPage> createState() => _AppQuestionBankPageState();
}

class _AppQuestionBankPageState extends State<AppQuestionBankPage>
    with SingleTickerProviderStateMixin {
  // Chat state
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  // Selection state
  String? _selectedSubject;
  int? _selectedGrade;
  int? _selectedQuantity;

  // Current step in the flow
  int _currentStep = 0;

  // Robot animation state
  String _robotState = 'idle'; // 'idle', 'happy', 'thinking'

  // Animation controller
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Start conversation after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _addAIMessage(_getStepMessage(0));
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _getStepMessage(int step) {
    switch (step) {
      case 0:
        return "Hi! Ready to learn? What subject shall we conquer today? 📚";
      case 1:
        return "Great choice! Which grade level? 🎓";
      case 2:
        return "Got it. How many questions for this session? 💪";
      case 3:
        return "Setting up your arena... Let's go! 🚀";
      default:
        return "";
    }
  }

  void _addAIMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _robotState = 'happy'; // Robot celebrates user choice
    });

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Reset robot state and move to next step
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _robotState = 'idle';
      });

      // Add AI response for next step
      Future.delayed(const Duration(milliseconds: 400), () {
        _currentStep++;
        if (_currentStep <= 3) {
          _addAIMessage(_getStepMessage(_currentStep));

          // If final step, launch arena
          if (_currentStep == 3) {
            _launchArena();
          }
        }
      });
    });
  }

  void _handleSubjectSelect(String subject) {
    setState(() {
      _selectedSubject = subject;
    });
    _addUserMessage(subject);
  }

  void _handleGradeSelect(int grade) {
    setState(() {
      _selectedGrade = grade;
    });
    _addUserMessage('Grade $grade');
  }

  void _handleQuantitySelect(int quantity, String label) {
    setState(() {
      _selectedQuantity = quantity;
    });
    _addUserMessage(label);
  }

  void _launchArena() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppQuestionArenaPage(
            subjectId: _selectedSubject?.toLowerCase() ?? 'math',
            grade: 'G$_selectedGrade',
            questionLimit: _selectedQuantity ?? 10,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            _buildHeader(),

            // Robot Avatar
            _buildRobotAvatar(),

            // Chat History
            Expanded(
              child: _buildChatHistory(),
            ),

            // Interaction Area (Chips/Buttons based on current step)
            _buildInteractionArea(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Question Arena Setup',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRobotAvatar() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.2),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Robot image with state-based animation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    transform: _robotState == 'happy'
                        ? (Matrix4.identity()..scale(1.1))
                        : Matrix4.identity(),
                    child: Image.asset(
                      'assets/images/robot/robot_idle.png',
                      width: 100,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF07C160),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.psychology,
                            size: 50,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Dr. Logic',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF358373),
                    ),
                  ),
                  Text(
                    _robotState == 'happy' ? 'Great choice! 🎉' : 'Your AI Learning Coach',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatHistory() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildChatBubble(message, index);
      },
    );
  }

  Widget _buildChatBubble(ChatMessage message, int index) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(message.timestamp),
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: message.isUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message.isUser) ...[
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF07C160),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.smart_toy,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: message.isUser
                            ? const Color(0xFFE8F5F1)
                            : const Color(0xFF07C160),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: message.isUser
                              ? const Radius.circular(16)
                              : const Radius.circular(4),
                          bottomRight: message.isUser
                              ? const Radius.circular(4)
                              : const Radius.circular(16),
                        ),
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          fontSize: 15,
                          color: message.isUser
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  if (message.isUser) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF358373),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInteractionArea() {
    // Don't show options if we're past step 2 or if already selected for this step
    if (_currentStep > 2) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentStep == 0 && _selectedSubject == null)
            _buildSubjectOptions(),
          if (_currentStep == 1 && _selectedGrade == null)
            _buildGradeOptions(),
          if (_currentStep == 2 && _selectedQuantity == null)
            _buildQuantityOptions(),
        ],
      ),
    );
  }

  Widget _buildSubjectOptions() {
    final subjects = [
      {'id': 'Math', 'icon': Icons.calculate, 'color': Color(0xFF3B82F6)},
      {'id': 'Physics', 'icon': Icons.science, 'color': Color(0xFF8B5CF6)},
      {'id': 'Chemistry', 'icon': Icons.biotech, 'color': Color(0xFFEC4899)},
      {'id': 'Olympiad', 'icon': Icons.emoji_events, 'color': Color(0xFFF59E0B)},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: subjects.map((subject) {
        return _buildChoiceChip(
          label: subject['id'] as String,
          icon: subject['icon'] as IconData,
          color: subject['color'] as Color,
          onTap: () => _handleSubjectSelect(subject['id'] as String),
        );
      }).toList(),
    );
  }

  Widget _buildGradeOptions() {
    final grades = [
      {'grade': 9, 'label': 'Grade 9'},
      {'grade': 10, 'label': 'Grade 10'},
      {'grade': 11, 'label': 'Grade 11'},
      {'grade': 12, 'label': 'Grade 12'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: grades.map((g) {
        return _buildChoiceChip(
          label: g['label'] as String,
          icon: Icons.school,
          color: const Color(0xFF07C160),
          onTap: () => _handleGradeSelect(g['grade'] as int),
        );
      }).toList(),
    );
  }

  Widget _buildQuantityOptions() {
    final quantities = [
      {'qty': 5, 'label': '5 (Warmup)', 'icon': Icons.local_fire_department},
      {'qty': 10, 'label': '10 (Standard)', 'icon': Icons.fitness_center},
      {'qty': 20, 'label': '20 (Challenge)', 'icon': Icons.sports_martial_arts},
    ];

    return Column(
      children: quantities.map((q) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _handleQuantitySelect(
                q['qty'] as int,
                q['label'] as String,
              ),
              icon: Icon(q['icon'] as IconData, size: 20),
              label: Text(
                q['label'] as String,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF07C160),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chat message data model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
