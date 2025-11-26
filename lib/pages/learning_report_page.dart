import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/progress_tracker.dart';
import '../theme/theme.dart';

class LearningReportPage extends StatefulWidget {
  const LearningReportPage({super.key});

  @override
  State<LearningReportPage> createState() => _LearningReportPageState();
}

class _LearningReportPageState extends State<LearningReportPage> {
  final ProgressTracker _progressTracker = ProgressTracker();
  late Future<LearningStatistics> _statisticsFuture;
  late Future<Map<String, DailyProgress>> _recentProgressFuture;
  late Future<LearningRecommendation> _recommendationFuture;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    _progressTracker.init().then((_) {
      setState(() {
        _statisticsFuture = _progressTracker.getStatistics();
        _recentProgressFuture = _progressTracker.getRecentProgress(7);
        _recommendationFuture = _progressTracker.getRecommendation();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('学习报告')),
      body: RefreshIndicator(
        onRefresh: () async {
          _initData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 总体统计
              FutureBuilder<LearningStatistics>(
                future: _statisticsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final stats = snapshot.data!;
                    return _buildOverallStats(stats);
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),

              const SizedBox(height: 24),

              // 近期进度图表
              const Text(
                '近期学习情况',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: FutureBuilder<Map<String, DailyProgress>>(
                  future: _recentProgressFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return _buildProgressChart(snapshot.data!);
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),

              const SizedBox(height: 24),

              // 学习建议
              const Text(
                '学习建议',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              FutureBuilder<LearningRecommendation>(
                future: _recommendationFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return _buildRecommendations(snapshot.data!);
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverallStats(LearningStatistics stats) {
    final accuracy = stats.totalQuestions == 0
        ? 0.0
        : (stats.correctQuestions / stats.totalQuestions) * 100;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '总体统计',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '完成题目',
                  '${stats.totalQuestions}',
                  Icons.assignment_turned_in,
                ),
                _buildStatItem(
                  '正确率',
                  '${accuracy.toStringAsFixed(1)}%',
                  Icons.check_circle,
                ),
                _buildStatItem(
                  '总用时',
                  '${(stats.totalTimeSpent / 60).round()}分钟',
                  Icons.timer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildProgressChart(Map<String, DailyProgress> progressData) {
    final sortedDates = progressData.keys.toList()..sort();
    final spots = <FlSpot>[];

    for (var i = 0; i < sortedDates.length; i++) {
      final progress = progressData[sortedDates[i]]!;
      final accuracy = progress.questionsCompleted == 0
          ? 0.0
          : (progress.correctAnswers / progress.questionsCompleted) * 100;
      spots.add(FlSpot(i.toDouble(), accuracy));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < sortedDates.length) {
                  final date = DateTime.parse(sortedDates[value.toInt()]);
                  return Text('${date.month}/${date.day}');
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}%');
              },
              interval: 20,
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: (sortedDates.length - 1).toDouble(),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(LearningRecommendation recommendation) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  '当前水平: ${recommendation.currentLevel}级',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('推荐难度:', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: recommendation.recommendedDifficulties
                  .map(
                    (level) => Chip(
                      label: Text('$level级'),
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.1),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text('需要关注:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...recommendation.focusAreas.map(
              (area) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_right, size: 16),
                    Text(area),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
