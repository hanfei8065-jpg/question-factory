import 'package:flutter/material.dart';
import '../models/user_progress.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';

class LearningInsightPage extends StatefulWidget {
  final List<Question> solvedQuestions;
  final UserProgress progress;

  const LearningInsightPage({
    super.key,
    required this.solvedQuestions,
    required this.progress,
  });

  @override
  State<LearningInsightPage> createState() => _LearningInsightPageState();
}

class _LearningInsightPageState extends State<LearningInsightPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('学习分析'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '知识图谱'),
            Tab(text: '错题分析'),
            Tab(text: '学习建议'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildKnowledgeMap(),
          _buildMistakeAnalysis(),
          _buildLearningAdvice(),
        ],
      ),
    );
  }

  Widget _buildKnowledgeMap() {
    // 构建知识图谱视图
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '知识掌握程度',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: RadarChart(
                    RadarChartData(
                      dataSets: [
                        RadarDataSet(
                          dataEntries: [
                            const RadarEntry(value: 0.8),
                            const RadarEntry(value: 0.7),
                            const RadarEntry(value: 0.9),
                            const RadarEntry(value: 0.6),
                            const RadarEntry(value: 0.85),
                          ],
                        ),
                      ],
                      radarShape: RadarShape.polygon,
                      radarBorderData: const BorderSide(color: Colors.blue),
                      tickBorderData: const BorderSide(
                        color: Colors.transparent,
                      ),
                      gridBorderData: const BorderSide(
                        color: Colors.grey,
                        width: 0.5,
                      ),
                      ticksTextStyle: const TextStyle(
                        color: Colors.transparent,
                      ),
                      titleTextStyle: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                      titlePositionPercentageOffset: 0.2,
                      titles: const ['代数', '几何', '微积分', '统计', '三角函数'],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return const ListTile(
              title: Text('知识点连接'),
              subtitle: Text('显示知识点之间的关联'),
              trailing: Icon(Icons.arrow_forward_ios),
            );
          }, childCount: 5),
        ),
      ],
    );
  }

  Widget _buildMistakeAnalysis() {
    // 构建错题分析视图
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '错题分布',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [BarChartRodData(y: 5, color: Colors.red)],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [BarChartRodData(y: 3, color: Colors.red)],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [BarChartRodData(y: 7, color: Colors.red)],
                        ),
                        BarChartGroupData(
                          x: 3,
                          barRods: [BarChartRodData(y: 4, color: Colors.red)],
                        ),
                      ],
                      titlesData: const FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: _getBottomTitles,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return const ListTile(
              title: Text('常见错误类型'),
              subtitle: Text('分析错题原因和解决方案'),
              trailing: Icon(Icons.arrow_forward_ios),
            );
          }, childCount: 5),
        ),
      ],
    );
  }

  Widget _buildLearningAdvice() {
    // 构建学习建议视图
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '今日建议',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildAdviceItem(
                  icon: Icons.trending_up,
                  title: '重点突破',
                  description: '建议复习微积分相关知识点',
                ),
                const Divider(),
                _buildAdviceItem(
                  icon: Icons.schedule,
                  title: '复习计划',
                  description: '今天需要复习的错题: 5道',
                ),
                const Divider(),
                _buildAdviceItem(
                  icon: Icons.emoji_events,
                  title: '能力提升',
                  description: '代数能力有待提高',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '学习目标',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: 0.7,
                  backgroundColor: Colors.grey[200],
                  color: Colors.blue,
                ),
                const SizedBox(height: 8),
                const Text('本周完成度: 70%', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdviceItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(description, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _getBottomTitles(double value, TitleMeta meta) {
  String text;
  switch (value.toInt()) {
    case 0:
      text = '代数';
      break;
    case 1:
      text = '几何';
      break;
    case 2:
      text = '微积分';
      break;
    case 3:
      text = '统计';
      break;
    default:
      text = '';
  }
  return SideTitleWidget(axisSide: meta.axisSide, child: Text(text));
}
