import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../models/question_solution.dart';

class SolutionPage extends StatefulWidget {
  final String question;
  final String answer;
  final String explanation;
  final String subject;
  final String difficulty;
  final List<String> keywords;
  final List<String> relatedConcepts;

  const SolutionPage({
    super.key,
    required this.question,
    required this.answer,
    required this.explanation,
    required this.subject,
    required this.difficulty,
    required this.keywords,
    required this.relatedConcepts,
  });

  @override
  State<SolutionPage> createState() => _SolutionPageState();
}

class _SolutionPageState extends State<SolutionPage> {
  int _currentStep = 0;
  bool _showHints = false;
  List<String> _steps = [];

  @override
  void initState() {
    super.initState();
    _parseSteps();
  }

  void _parseSteps() {
    // 将解析拆分成步骤
    _steps = widget.explanation
        .split('\n')
        .where((step) => step.trim().isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('解题过程'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.lightbulb_outline,
              color: _showHints ? Colors.yellow : Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showHints = !_showHints;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 题目卡片
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(widget.difficulty),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.difficulty,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.subject,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Math.tex(
                    widget.question,
                    textStyle: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),

          // 关键知识点
          if (_showHints)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '关键知识点',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.keywords.map((keyword) {
                        return Chip(
                          label: Text(keyword),
                          backgroundColor: Colors.blue.withOpacity(0.1),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '相关概念',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.relatedConcepts.map((concept) {
                        return ActionChip(
                          label: Text(concept),
                          onPressed: () {
                            // TODO: 跳转到概念详情页
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

          // 解题步骤
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                final isCurrentStep = index == _currentStep;
                return Card(
                  color: isCurrentStep ? Colors.blue.withOpacity(0.1) : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCurrentStep
                          ? Colors.blue
                          : Colors.grey,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Math.tex(_steps[index]),
                    onTap: () {
                      setState(() {
                        _currentStep = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _currentStep > 0
                    ? () {
                        setState(() {
                          _currentStep--;
                        });
                      }
                    : null,
                child: const Text('上一步'),
              ),
              Text('${_currentStep + 1}/${_steps.length}'),
              TextButton(
                onPressed: _currentStep < _steps.length - 1
                    ? () {
                        setState(() {
                          _currentStep++;
                        });
                      }
                    : null,
                child: const Text('下一步'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
      case '简单':
        return Colors.green;
      case 'medium':
      case '中等':
        return Colors.orange;
      case 'hard':
      case '困难':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
