import 'package:flutter/material.dart';
import '../models/difficulty_level.dart';
import '../models/knowledge_point.dart';

class PracticeRecommendationPage extends StatefulWidget {
  final List<KnowledgePoint> masterPoints; // 已掌握的知识点
  final List<KnowledgePoint> weakPoints; // 薄弱知识点
  final DifficultyLevel currentLevel; // 当前难度级别

  const PracticeRecommendationPage({
    super.key,
    required this.masterPoints,
    required this.weakPoints,
    required this.currentLevel,
  });

  @override
  State<PracticeRecommendationPage> createState() =>
      _PracticeRecommendationPageState();
}

class _PracticeRecommendationPageState
    extends State<PracticeRecommendationPage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('练习建议')),
      body: Column(
        children: [
          // 难度等级展示
          _buildDifficultyCard(),

          // 标签选项
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildTabButton('今日建议', 0),
                const SizedBox(width: 16),
                _buildTabButton('知识点分析', 1),
                const SizedBox(width: 16),
                _buildTabButton('进阶规划', 2),
              ],
            ),
          ),

          // 内容区域
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildDailyRecommendations(),
                _buildKnowledgeAnalysis(),
                _buildProgressionPlan(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '当前难度: ${widget.currentLevel.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildDifficultyStars(widget.currentLevel.level),
              ],
            ),
            const SizedBox(height: 8),
            Text(widget.currentLevel.description),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
          foregroundColor: isSelected ? Colors.white : Colors.black87,
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildDailyRecommendations() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日建议练习题数: ${widget.currentLevel.recommendedDailyCount}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            '练习重点:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...widget.weakPoints.take(3).map((point) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.priority_high, color: Colors.orange),
                title: Text(point.name),
                subtitle: Text(point.description),
                trailing: Text(
                  '难度: ${point.difficulty}',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          const Text(
            '巩固练习:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...widget.masterPoints.take(2).map((point) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(point.name),
                subtitle: Text(point.description),
                trailing: Text(
                  '难度: ${point.difficulty}',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildKnowledgeAnalysis() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKnowledgeChart(),
          const SizedBox(height: 24),
          const Text(
            '薄弱知识点',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...widget.weakPoints.map((point) => _buildKnowledgePointCard(point)),
          const SizedBox(height: 24),
          const Text(
            '已掌握知识点',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...widget.masterPoints.map(
            (point) => _buildKnowledgePointCard(point),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressionPlan() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '进阶路线',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildProgressionTimeline(),
          const SizedBox(height: 24),
          const Text(
            '特征分析',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...widget.currentLevel.characteristics.map((char) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.arrow_right, color: Colors.blue),
                title: Text(char),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDifficultyStars(int level) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < level ? Icons.star : Icons.star_border,
          color: Colors.amber,
        );
      }),
    );
  }

  Widget _buildKnowledgeChart() {
    // 这里可以添加知识点掌握情况的图表
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: Text('知识点掌握度图表')),
    );
  }

  Widget _buildKnowledgePointCard(KnowledgePoint point) {
    final bool isMastered = widget.masterPoints.contains(point);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isMastered ? Icons.check_circle : Icons.warning,
          color: isMastered ? Colors.green : Colors.orange,
        ),
        title: Text(point.name),
        subtitle: Text(point.description),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '难度: ${point.difficulty}',
            style: TextStyle(color: Colors.blue[800], fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressionTimeline() {
    return Column(
      children: [
        _buildTimelineItem('当前等级', widget.currentLevel.name, true, Colors.blue),
        _buildTimelineItem('下一目标', '提高准确度和速度', false, Colors.orange),
        _buildTimelineItem('长期目标', '掌握更高难度题型', false, Colors.green),
      ],
    );
  }

  Widget _buildTimelineItem(
    String title,
    String description,
    bool isCurrent,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isCurrent ? color : Colors.grey[300],
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCurrent ? color : Colors.grey[600],
                ),
              ),
              Text(description),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
