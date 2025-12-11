import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/translation_service.dart';
import 'app_focus_mode_page.dart';

class AppQuestionBankPage extends StatefulWidget {
  const AppQuestionBankPage({super.key});

  @override
  State<AppQuestionBankPage> createState() => _AppQuestionBankPageState();
}

class _AppQuestionBankPageState extends State<AppQuestionBankPage>
    with SingleTickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  // State Machine
  int _currentStep = 0; // 0: Subject, 1: Grade, 2: Quantity, 3: Launch
  String _robotState = 'idle'; // idle, happy, thinking

  // Selections
  String? _selectedSubject;
  String? _selectedGrade;
  int? _selectedQuantity;

  @override
  void initState() {
    super.initState();
    // Initial Greeting
    Future.delayed(const Duration(milliseconds: 500), () {
      _addAIMessage(Tr.get('chat_intro'));
    });
  }

  void _addAIMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: false));
      _robotState = 'idle';
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _robotState = 'happy'; // Robot celebrates user input
    });
    _scrollToBottom();

    // Auto-advance logic
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _nextStep();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
      _robotState = 'idle';
    });

    switch (_currentStep) {
      case 1:
        _addAIMessage(Tr.get('chat_grade'));
        break;
      case 2:
        _addAIMessage(Tr.get('chat_quantity'));
        break;
      case 3:
        _addAIMessage(Tr.get('chat_launch'));
        _launchArena();
        break;
    }
  }

  void _launchArena() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      // Convert selection to params
      // Map subject display name back to ID if needed, or assume English IDs
      // Simple mapping for now:
      String subjectId = 'math';
      if (_selectedSubject != null) {
        // Should map based on Tr keys in real app, simplified here
        if (_selectedSubject!.contains('Phys') ||
            _selectedSubject!.contains('物'))
          subjectId = 'physics';
        else if (_selectedSubject!.contains('Chem') ||
            _selectedSubject!.contains('化'))
          subjectId = 'chemistry';
        else if (_selectedSubject!.contains('Olym') ||
            _selectedSubject!.contains('奥'))
          subjectId = 'olympiad';
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppQuestionArenaPage(
            subjectId: subjectId,
            grade: _selectedGrade ?? '10',
            questionLimit: _selectedQuantity ?? 10,
            topic: 'General',
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
            // 1. Dr. Logic Avatar Area
            Container(
              height: 180,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: _robotState == 'happy' ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFF07C160),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.smart_toy,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Dr. Logic",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),

            // 2. Chat List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Align(
                    alignment: msg.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: msg.isUser
                            ? const Color(0xFFE8F5F1)
                            : const Color(0xFF07C160),
                        borderRadius: BorderRadius.circular(20).copyWith(
                          topLeft: msg.isUser
                              ? const Radius.circular(20)
                              : const Radius.circular(0),
                          topRight: msg.isUser
                              ? const Radius.circular(0)
                              : const Radius.circular(20),
                        ),
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          color: msg.isUser
                              ? const Color(0xFF07C160)
                              : Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 3. Interaction Area
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: _buildInteractionArea(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionArea() {
    if (_currentStep == 0) {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _buildChip(Tr.get('subject_math')),
          _buildChip(Tr.get('subject_physics')),
          _buildChip(Tr.get('subject_chem')),
          _buildChip(Tr.get('subject_olympiad')),
        ],
      );
    } else if (_currentStep == 1) {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _buildChip("Grade 9", val: "9"),
          _buildChip("Grade 10", val: "10"),
          _buildChip("Grade 11", val: "11"),
          _buildChip("Grade 12", val: "12"),
        ],
      );
    } else if (_currentStep == 2) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton("5 Questions (Warmup)", 5),
          const SizedBox(height: 8),
          _buildButton("10 Questions (Standard)", 10),
          const SizedBox(height: 8),
          _buildButton("20 Questions (Challenge)", 20),
        ],
      );
    }
    return const SizedBox(
      height: 50,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildChip(String label, {String? val}) {
    return ActionChip(
      label: Text(label),
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFE2E8F0)),
      onPressed: () {
        if (_currentStep == 0) _selectedSubject = label;
        if (_currentStep == 1) _selectedGrade = val ?? label;
        _addUserMessage(label);
      },
    );
  }

  Widget _buildButton(String label, int val) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF07C160),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          _selectedQuantity = val;
          _addUserMessage(label);
        },
        child: Text(label),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}
