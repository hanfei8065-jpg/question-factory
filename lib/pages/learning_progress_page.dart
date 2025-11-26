import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/user_progress.dart';
import '../models/knowledge_point.dart';

class LearningProgressPage extends StatefulWidget {
  final UserProgress progress;
  final List<KnowledgePoint> knowledgePoints;

  const LearningProgressPage({
    super.key,
    required this.progress,
    required this.knowledgePoints,
  });

  @override
  State<LearningProgressPage> createState() => _LearningProgressPageState();
}

class _LearningProgressPageState extends State<LearningProgressPage> {
  int _selectedPeriod = 7; // 默认显示7天
  String? _selectedPointId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学习进度'),
        actions: [
          PopupMenuButton<int>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 7, child: Text('最近7天')),
              const PopupMenuItem(value: 30, child: Text('最近30天')),
              const PopupMenuItem(value: 90, child: Text('最近90天')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverallProgress(),
            const SizedBox(height: 24),
            _buildLearningStreak(),
            const SizedBox(height: 24),
            _buildTrendChart(),
            const SizedBox(height: 24),
            _buildKnowledgePointsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallProgress() {
    final progress = widget.progress.calculateOverallProgress();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '整体学习进度',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    color: _getProgressColor(progress),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getProgressDescription(progress),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningStreak() {
    final streak = widget.progress.getLongestStreak();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.local_fire_department, color: Colors.orange, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '连续学习',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$streak 天',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart() {
    final weeklyTrend = widget.progress.getWeeklyTrend();
    final spots = weeklyTrend.entries.map((e) {
      final daysAgo = DateTime.now().difference(e.key).inDays;
      return FlSpot(daysAgo.toDouble(), e.value.toDouble());
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '学习趋势',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 1 != 0) return const Text('');
                          final date = DateTime.now().subtract(
                            Duration(days: value.toInt()),
                          );
                          return Text('${date.month}/${date.day}');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 1 != 0) return const Text('');
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: weeklyTrend.values
                      .reduce((max, value) => value > max ? value : max)
                      .toDouble(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKnowledgePointsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '知识点掌握情况',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...widget.knowledgePoints.map((point) {
          final mastery =
              widget.progress.knowledgePointMastery[point.id] ?? 0.0;
          final status = widget.progress.getPracticeStatus(point.id);

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedPointId = point.id;
                });
                _showPointDetails(point);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            point.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildStatusChip(status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: mastery,
                      backgroundColor: Colors.grey[200],
                      color: _getProgressColor(mastery),
                      minHeight: 6,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '掌握度: ${(mastery * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '练习次数: ${widget.progress.practiceCount[point.id] ?? 0}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatusChip(PracticeStatus status) {
    Color color;
    String label;

    switch (status) {
      case PracticeStatus.notStarted:
        color = Colors.grey;
        label = '未开始';
        break;
      case PracticeStatus.inProgress:
        color = Colors.blue;
        label = '学习中';
        break;
      case PracticeStatus.needMorePractice:
        color = Colors.orange;
        label = '需要练习';
        break;
      case PracticeStatus.needReview:
        color = Colors.red;
        label = '需要复习';
        break;
      case PracticeStatus.mastered:
        color = Colors.green;
        label = '已掌握';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  void _showPointDetails(KnowledgePoint point) {
    final mastery = widget.progress.knowledgePointMastery[point.id] ?? 0.0;
    final history = widget.progress.masteryHistory[point.id] ?? [];
    final practiceCount = widget.progress.practiceCount[point.id] ?? 0;
    final lastPractice = widget.progress.lastPracticeDate[point.id];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(point.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(point.description),
              const SizedBox(height: 16),
              const Text(
                '掌握度历史',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (history.isEmpty)
                const Text('暂无练习记录')
              else
                SizedBox(
                  height: 100,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minY: 0,
                      maxY: 1,
                      lineBarsData: [
                        LineChartBarData(
                          spots: history.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value);
                          }).toList(),
                          isCurved: true,
                          color: _getProgressColor(mastery),
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: _getProgressColor(mastery).withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text('练习次数: $practiceCount'),
              if (lastPractice != null)
                Text('最后练习: ${_formatDate(lastPractice)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.red;
    if (progress < 0.6) return Colors.orange;
    if (progress < 0.8) return Colors.blue;
    return Colors.green;
  }

  String _getProgressDescription(double progress) {
    if (progress < 0.3) return '继续加油!';
    if (progress < 0.6) return '正在进步!';
    if (progress < 0.8) return '掌握得不错!';
    return '表现优秀!';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }
}
