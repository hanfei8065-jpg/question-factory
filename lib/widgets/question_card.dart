import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../core/constants.dart';
import '../models/question.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final Function(bool isCorrect) onAnswer;

  const QuestionCard({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  String? _selectedAnswer;
  bool? _isCorrect;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.margin),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Math.tex(
              widget.question.content,
              textStyle: Theme.of(context).textTheme.titleSmall,
            ),
            if (widget.question.type == QuestionType.choice) ...[
              const SizedBox(height: 16),
              ...widget.question.options.map((option) {
                final isSelected = option == _selectedAnswer;
                final showResult = _isCorrect != null;
                final isCorrect = option == widget.question.answer;

                return RadioListTile<String>(
                  title: Math.tex(
                    option,
                    textStyle: Theme.of(context).textTheme.bodyMedium,
                  ),
                  value: option,
                  groupValue: _selectedAnswer,
                  onChanged: _isCorrect != null
                      ? null
                      : (value) {
                          setState(() {
                            _selectedAnswer = value;
                            _isCorrect = value == widget.question.answer;
                          });
                          widget.onAnswer(_isCorrect!);
                        },
                  selected: isSelected,
                  activeColor: showResult
                      ? (isCorrect ? AppTheme.success : AppTheme.error)
                      : null,
                );
              }).toList(),
            ],
            if (widget.question.type == QuestionType.fill)
              TextField(
                decoration: InputDecoration(
                  hintText: '请输入答案',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  ),
                ),
                onSubmitted: (value) {
                  setState(() {
                    _selectedAnswer = value;
                    _isCorrect = value == widget.question.answer;
                  });
                  widget.onAnswer(_isCorrect!);
                },
              ),
            if (_isCorrect != null) ...[
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '正确答案：',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    WidgetSpan(
                      child: Math.tex(
                        widget.question.answer,
                        textStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: AppTheme.success),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '解析：',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    WidgetSpan(
                      child: Math.tex(
                        widget.question.explanation,
                        textStyle: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
