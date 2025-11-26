import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../core/constants.dart' hide Subject;
import '../models/question.dart';
import '../services/navigation_service.dart';
import '../services/ai_service.dart';

class AITeacherPage extends StatefulWidget {
  final Question? question;
  final String? topic;
  final String? difficulty;

  const AITeacherPage({super.key, this.question, this.topic, this.difficulty});

  @override
  State<AITeacherPage> createState() => _AITeacherPageState();
}

class _AITeacherPageState extends State<AITeacherPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  Subject _selectedSubject = Subject.math;

  // 新增状态
  bool _isExplaining = false;
  String _currentStep = '';
  final List<String> _explanationSteps = [];

  @override
  void initState() {
    super.initState();
    if (widget.question != null) {
      _startExplanation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startExplanation() async {
    setState(() {
      _isExplaining = true;
      _currentStep = '让我来帮你分析这道题...';
      _explanationSteps.clear();
    });

    try {
      final steps = await AIService().explainQuestion(widget.question!);
      setState(() {
        _explanationSteps.addAll(steps);
        if (steps.isEmpty) {
          _explanationSteps.add('抱歉，我暂时无法解释这道题。要不要换一道试试？');
        }
      });
    } catch (e) {
      setState(() {
        _explanationSteps.add(
          '抱歉，AI服务出现了一点问题。\n'
          '让我用基本的方式给你讲解：\n\n'
          '题目要求：\n${widget.question!.content}\n\n'
          '关键知识点：${widget.question!.tags.join("、")}\n\n'
          '解题步骤：\n${widget.question!.explanation}\n\n'
          '建议：多做几道相关题目来巩固。',
        );
      });
      debugPrint('AI解释失败: $e');
    } finally {
      setState(() {
        _isExplaining = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final message = _controller.text;
    _controller.clear();

    setState(() {
      _messages.add({'isUser': true, 'text': message, 'time': DateTime.now()});
    });

    try {
      setState(() {
        _messages.add({
          'isUser': false,
          'text': '让我想想...',
          'time': DateTime.now(),
          'isLoading': true,
        });
      });

      final reply = await AIService().chat(
        message,
        _selectedSubject.toString().split('.').last,
      );

      setState(() {
        _messages.removeLast();
        _messages.add({'isUser': false, 'text': reply, 'time': DateTime.now()});
      });
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add({
          'isUser': false,
          'text': '抱歉，我现在有点问题，晚点再问我吧~ 😅',
          'time': DateTime.now(),
          'isError': true,
        });
      });
      debugPrint('AI回复失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI名师')),
      body: Column(
        children: [
          if (widget.question == null) _buildSubjectSelector(),
          Expanded(
            child: widget.question != null
                ? _buildQuestionExplanation()
                : _buildChatView(),
          ),
          if (widget.question == null) _buildInputBar(),
          if (!_isExplaining && _explanationSteps.isNotEmpty)
            _buildPracticeButton(),
        ],
      ),
    );
  }

  Widget _buildQuestionExplanation() {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.padding),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('原题', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Math.tex(
                  widget.question!.content,
                  textStyle: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_isExplaining)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.padding),
              child: Row(
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Text(_currentStep)),
                ],
              ),
            ),
          ),
        ..._explanationSteps.map(
          (step) => Card(
            margin: const EdgeInsets.only(top: AppTheme.margin),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.padding),
              child: Math.tex(
                step,
                textStyle: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildSubjectSelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: Subject.values.map((subject) {
          final isSelected = subject == _selectedSubject;
          return GestureDetector(
            onTap: () => setState(() => _selectedSubject = subject),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Row(
                  children: [
                    Text(SubjectConstants.icons[subject] ?? ''),
                    const SizedBox(width: 8),
                    Text(
                      SubjectConstants.names[subject] ?? '',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    final isLoading = message['isLoading'] as bool? ?? false;
    final isError = message['isError'] as bool? ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? AppTheme.primary
                    : isError
                    ? AppTheme.error.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading) ...[
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      message['text'],
                      style: TextStyle(
                        color: isUser
                            ? Colors.white
                            : isError
                            ? AppTheme.error
                            : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isUser) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return const CircleAvatar(
      radius: 16,
      backgroundColor: AppTheme.primary,
      child: Icon(Icons.person, color: Colors.white, size: 20),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: '输入你的问题...',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send),
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.padding),
        child: Row(
          children: [
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  minimumSize: const Size.fromHeight(AppTheme.buttonHeight),
                ),
                onPressed: () {
                  NavigationService().navigateToQuestionBankFromAI(
                    topic: widget.question!.tags.first,
                    level: widget.question!.difficulty,
                  );
                },
                child: const Text('去做练习'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
