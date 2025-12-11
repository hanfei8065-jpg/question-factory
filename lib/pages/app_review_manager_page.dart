import 'package:flutter/material.dart';
import '../models/review_item.dart';
import '../services/review_service.dart';
import 'package:fl_chart/fl_chart.dart';

class ReviewManagerPage extends StatefulWidget {
  const ReviewManagerPage({super.key});

  @override
  State<ReviewManagerPage> createState() => _ReviewManagerPageState();
}

class _ReviewManagerPageState extends State<ReviewManagerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReviewService _reviewService = ReviewService();
  List<ReviewItem> _dueItems = [];
  List<ReviewItem> _upcomingItems = [];
  List<String> _allTags = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReviewData();
  }

  Future<void> _loadReviewData() async {
    await _reviewService.initialize();
    setState(() {
      _dueItems = _reviewService.getDueReviewItems();
      _upcomingItems = _reviewService.getUpcomingReviewItems();
      _allTags = _getAllTags();
    });
  }

  List<String> _getAllTags() {
    final Set<String> tags = {};
    for (var item in [..._dueItems, ..._upcomingItems]) {
      tags.addAll(item.tags);
    }
    return tags.toList()..sort();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('错题复习管理'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '待复习'),
            Tab(text: '即将复习'),
            Tab(text: '学习分析'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDueReviewList(),
          _buildUpcomingReviewList(),
          _buildAnalysisView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 弹出添加新错题的对话框
          _showAddMistakeDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDueReviewList() {
    if (_dueItems.isEmpty) {
      return const Center(child: Text('暂无待复习的题目'));
    }

    return ListView.builder(
      itemCount: _dueItems.length,
      itemBuilder: (context, index) {
        return _buildReviewItemCard(_dueItems[index], true);
      },
    );
  }

  Widget _buildUpcomingReviewList() {
    if (_upcomingItems.isEmpty) {
      return const Center(child: Text('最近没有需要复习的题目'));
    }

    return ListView.builder(
      itemCount: _upcomingItems.length,
      itemBuilder: (context, index) {
        return _buildReviewItemCard(_upcomingItems[index], false);
      },
    );
  }

  Widget _buildAnalysisView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '掌握度趋势',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(height: 200, child: LineChart(_mainData())),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTagAnalysis(),
        ],
      ),
    );
  }

  Widget _buildReviewItemCard(ReviewItem item, bool isDue) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text('问题 ${item.questionId}'),
        subtitle: Text(
          isDue ? '应复习时间: 已超时' : '下次复习: ${_formatDate(item.nextReviewDate)}',
          style: TextStyle(color: isDue ? Colors.red : null),
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            '${item.reviewCount}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.note != null) ...[
                  const Text(
                    '笔记:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(item.note!),
                  const SizedBox(height: 8),
                ],
                const Text(
                  '标签:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8,
                  children: item.tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      backgroundColor: Colors.blue[100],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('完成复习'),
                      onPressed: () => _completeReview(item),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('编辑'),
                      onPressed: () => _editReviewItem(item),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete),
                      label: const Text('删除'),
                      onPressed: () => _deleteReviewItem(item),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagAnalysis() {
    if (_allTags.isEmpty) {
      return const Card(
        child: Padding(padding: EdgeInsets.all(16), child: Text('暂无标签数据')),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '知识点分布',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...(_allTags.map((tag) {
              final items = _reviewService.getItemsByTag(tag);
              final masteryLevel = items.isEmpty
                  ? 0.0
                  : items.fold<double>(
                          0,
                          (sum, item) => sum + item.masteryLevel,
                        ) /
                        items.length;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tag),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: masteryLevel,
                      backgroundColor: Colors.grey[200],
                      color: _getMasteryColor(masteryLevel),
                    ),
                  ],
                ),
              );
            })),
          ],
        ),
      ),
    );
  }

  LineChartData _mainData() {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.black12),
      ),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: 1,
      lineBarsData: [
        LineChartBarData(
          spots: [
            const FlSpot(0, 0.3),
            const FlSpot(1, 0.5),
            const FlSpot(2, 0.4),
            const FlSpot(3, 0.6),
            const FlSpot(4, 0.8),
            const FlSpot(5, 0.7),
            const FlSpot(6, 0.9),
          ],
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return '今天';
    } else if (difference.inDays == 1) {
      return '明天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天后';
    } else {
      return '${date.month}月${date.day}日';
    }
  }

  Color _getMasteryColor(double mastery) {
    if (mastery < 0.3) return Colors.red;
    if (mastery < 0.6) return Colors.orange;
    if (mastery < 0.8) return Colors.blue;
    return Colors.green;
  }

  void _showAddMistakeDialog() {
    // TODO: 实现添加新错题的对话框
  }

  Future<void> _completeReview(ReviewItem item) async {
    // 弹出评分对话框
    final result = await showDialog<double>(
      context: context,
      builder: (context) => _MasteryLevelDialog(),
    );

    if (result != null) {
      await _reviewService.completeReview(item.id, result);
      _loadReviewData();
    }
  }

  void _editReviewItem(ReviewItem item) {
    // TODO: 实现编辑错题的对话框
  }

  Future<void> _deleteReviewItem(ReviewItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这道题目吗？这将删除所有相关的复习记录。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _reviewService.removeReviewItem(item.id);
      _loadReviewData();
    }
  }
}

class _MasteryLevelDialog extends StatefulWidget {
  @override
  _MasteryLevelDialogState createState() => _MasteryLevelDialogState();
}

class _MasteryLevelDialogState extends State<_MasteryLevelDialog> {
  double _masteryLevel = 0.5;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('评估掌握程度'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('请评估你对这道题的掌握程度'),
          const SizedBox(height: 16),
          Slider(
            value: _masteryLevel,
            onChanged: (value) {
              setState(() {
                _masteryLevel = value;
              });
            },
            divisions: 10,
            label: '${(_masteryLevel * 100).round()}%',
          ),
          Text(
            _getMasteryLevelDescription(_masteryLevel),
            style: TextStyle(color: _getMasteryLevelColor(_masteryLevel)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_masteryLevel),
          child: const Text('确定'),
        ),
      ],
    );
  }

  String _getMasteryLevelDescription(double level) {
    if (level < 0.2) return '完全不会';
    if (level < 0.4) return '有点印象';
    if (level < 0.6) return '基本理解';
    if (level < 0.8) return '掌握较好';
    return '完全掌握';
  }

  Color _getMasteryLevelColor(double level) {
    if (level < 0.2) return Colors.red;
    if (level < 0.4) return Colors.orange;
    if (level < 0.6) return Colors.blue;
    if (level < 0.8) return Colors.green;
    return Colors.green[700]!;
  }
}
