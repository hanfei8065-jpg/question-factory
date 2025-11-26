import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class BatchResultsPage extends StatefulWidget {
  final List<Map<String, dynamic>> results;

  const BatchResultsPage({super.key, required this.results});

  @override
  State<BatchResultsPage> createState() => _BatchResultsPageState();
}

class _BatchResultsPageState extends State<BatchResultsPage> {
  int _currentIndex = 0;
  bool _showAnswer = false;

  void _nextQuestion() {
    if (_currentIndex < widget.results.length - 1) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
      });
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showAnswer = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.results[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('题目 ${_currentIndex + 1}/${widget.results.length}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '题目',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Math.tex(
                            result['question'] as String,
                            textStyle: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showAnswer) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '答案',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Math.tex(
                              result['answer'] as String,
                              textStyle: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '解析',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Math.tex(
                              result['explanation'] as String,
                              textStyle: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.padding),
              child: Column(
                children: [
                  if (!_showAnswer)
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        minimumSize: const Size.fromHeight(
                          AppTheme.buttonHeight,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _showAnswer = true;
                        });
                      },
                      child: const Text('查看答案和解析'),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (_currentIndex > 0)
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(
                                AppTheme.buttonHeight,
                              ),
                            ),
                            onPressed: _previousQuestion,
                            child: const Text('上一题'),
                          ),
                        ),
                      if (_currentIndex > 0 &&
                          _currentIndex < widget.results.length - 1)
                        const SizedBox(width: 8),
                      if (_currentIndex < widget.results.length - 1)
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              minimumSize: const Size.fromHeight(
                                AppTheme.buttonHeight,
                              ),
                            ),
                            onPressed: _nextQuestion,
                            child: const Text('下一题'),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
