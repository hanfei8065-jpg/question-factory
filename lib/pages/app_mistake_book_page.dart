import 'package:flutter/material.dart';
import '../models/mistake.dart';
import '../services/mistake_book_service.dart';

class MistakeBookPage extends StatefulWidget {
  const MistakeBookPage({super.key});

  @override
  State<MistakeBookPage> createState() => _MistakeBookPageState();
}

class _MistakeBookPageState extends State<MistakeBookPage> {
  final _mistakeBookService = MistakeBookService();
  List<Mistake>? _mistakes;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMistakes();
  }

  Future<void> _loadMistakes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final mistakes = await _mistakeBookService.getAllMistakes();

      setState(() {
        _mistakes = mistakes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载失败：$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('错题本'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMistakes),
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
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadMistakes, child: const Text('重试')),
          ],
        ),
      );
    }

    if (_mistakes == null || _mistakes!.isEmpty) {
      return const Center(
        child: Text(
          '暂无错题\n拍照解题时可以添加到错题本',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: _mistakes!.length,
      itemBuilder: (context, index) {
        final mistake = _mistakes![index];
        return _MistakeCard(
          mistake: mistake,
          onDelete: () async {
            await _mistakeBookService.removeMistake(mistake.id);
            _loadMistakes();
          },
          onToggleMastered: () async {
            await _mistakeBookService.markAsReviewed(
              mistake.id,
              mastered: !mistake.mastered,
            );
            _loadMistakes();
          },
        );
      },
    );
  }
}

class _MistakeCard extends StatelessWidget {
  final Mistake mistake;
  final VoidCallback onDelete;
  final VoidCallback onToggleMastered;

  const _MistakeCard({
    required this.mistake,
    required this.onDelete,
    required this.onToggleMastered,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    color: _getDifficultyColor(mistake.difficulty),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    mistake.difficulty,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  mistake.subject,
                  style: const TextStyle(color: Colors.grey),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    mistake.mastered
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    color: mistake.mastered ? Colors.green : Colors.grey,
                  ),
                  onPressed: onToggleMastered,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('删除确认'),
                        content: const Text('确定要删除这道题目吗？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              onDelete();
                            },
                            child: const Text(
                              '删除',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(mistake.question),
            const Divider(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('答案：'),
                Expanded(child: Text(mistake.answer)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('解析：'),
                Expanded(child: Text(mistake.explanation)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '添加时间：${_formatDate(mistake.createdAt)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            if (mistake.reviewedAt != null)
              Text(
                '最后复习：${_formatDate(mistake.reviewedAt!)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case '简单':
        return Colors.green;
      case '中等':
        return Colors.orange;
      case '困难':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
