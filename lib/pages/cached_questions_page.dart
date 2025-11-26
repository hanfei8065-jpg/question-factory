import 'package:flutter/material.dart';
import '../services/question_cache_service.dart';
import '../core/constants.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../pages/question_result_page.dart';

class CachedQuestionsPage extends StatefulWidget {
  const CachedQuestionsPage({super.key});

  @override
  State<CachedQuestionsPage> createState() => _CachedQuestionsPageState();
}

class _CachedQuestionsPageState extends State<CachedQuestionsPage> {
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final questions = await QuestionCacheService().getAllCachedQuestions();
      questions.sort((a, b) {
        final dateA = DateTime.parse(a['timestamp'] as String);
        final dateB = DateTime.parse(b['timestamp'] as String);
        return dateB.compareTo(dateA);
      });

      setState(() {
        _questions = questions;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载缓存失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('离线题库'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuestions,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: TextStyle(color: AppTheme.error)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadQuestions, child: const Text('重试')),
          ],
        ),
      );
    }

    if (_questions.isEmpty) {
      return const Center(child: Text('暂无缓存题目'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.padding),
      itemCount: _questions.length,
      itemBuilder: (context, index) {
        final question = _questions[index];
        final timestamp = DateTime.parse(question['timestamp'] as String);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Math.tex(
              question['question'] as String,
              textStyle: Theme.of(context).textTheme.bodyMedium,
            ),
            subtitle: Text(
              '缓存时间: ${_formatDate(timestamp)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuestionResultPage(
                    isCorrect: true,
                    question: question['question'] as String,
                    answer: question['answer'] as String,
                    explanation: question['explanation'] as String,
                    subject: question['subject'] as String,
                    difficulty: question['difficulty'] as String,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}天前';
    } else {
      return '${date.year}-${date.month}-${date.day}';
    }
  }
}
