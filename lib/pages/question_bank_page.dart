import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learnest_fresh/core/constants.dart' as core;
import 'package:learnest_fresh/models/question.dart';
import 'package:learnest_fresh/providers/app_state.dart';
import 'package:learnest_fresh/services/navigation_service.dart';
import 'package:learnest_fresh/theme/app_theme.dart' as theme;
import 'package:learnest_fresh/widgets/question_card.dart';

class QuestionBankPage extends StatefulWidget {
  final String topic;
  final String? message;
  final int? level;

  const QuestionBankPage({
    super.key,
    required this.topic,
    this.message,
    this.level,
  });

  @override
  State<QuestionBankPage> createState() => _QuestionBankPageState();
}

class _QuestionBankPageState extends State<QuestionBankPage> {
  int _wrongCount = 0;
  final int _maxWrongBeforeHelp = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate),
            onPressed: () => NavigationService().navigateToCalculator(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (widget.message != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(theme.AppTheme.padding),
              color: theme.AppTheme.primary.withOpacity(0.1),
              child: Text(
                widget.message!,
                style: TextStyle(color: theme.AppTheme.primary),
              ),
            ),
          Expanded(
            child: Consumer<AppState>(
              builder: (context, appState, _) {
                final questions = appState.getQuestionsByTopic(widget.topic);

                if (questions.isEmpty) {
                  return const Center(child: Text('暂无题目'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(theme.AppTheme.padding),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    return QuestionCard(
                      question: question,
                      onAnswer: (isCorrect) {
                        if (!isCorrect) {
                          _wrongCount++;
                          if (_wrongCount >= _maxWrongBeforeHelp) {
                            _showAIHelpDialog(question);
                          }
                        } else {
                          _wrongCount = 0;
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAIHelpDialog(Question question) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('需要帮助吗？'),
        content: Text('需要帮助吗？我们的AI老师可以为您提供一对一辅导。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('继续做题'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              NavigationService().navigateToAITeacher(
                question: question,
                difficulty: '需要帮助理解基础概念',
              );
            },
            child: const Text('找AI老师'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(core.Subject subject) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Text(
          core.ThemeConstants.subjectIcons[subject] ?? '',
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(core.ThemeConstants.subjectNames[subject] ?? ''),
        subtitle: const Text('继续学习...'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: 实现题库跳转
        },
      ),
    );
  }
}
