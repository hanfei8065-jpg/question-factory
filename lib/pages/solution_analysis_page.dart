import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../models/solution_step.dart';
import '../models/knowledge_point.dart';

class SolutionAnalysisPage extends StatefulWidget {
  final List<SolutionStep> steps;
  final List<KnowledgePoint> knowledgePoints;

  const SolutionAnalysisPage({
    super.key,
    required this.steps,
    required this.knowledgePoints,
  });

  @override
  State<SolutionAnalysisPage> createState() => _SolutionAnalysisPageState();
}

class _SolutionAnalysisPageState extends State<SolutionAnalysisPage> {
  int _currentStep = 0;
  bool _showHint = false;
  Map<String, bool> _expandedKnowledgePoints = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('解题步骤分析'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () {
              setState(() {
                _showHint = !_showHint;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 步骤进度指示器
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  '第 ${_currentStep + 1} 步 / 共 ${widget.steps.length} 步',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LinearProgressIndicator(
                    value: ((_currentStep + 1) / widget.steps.length),
                    backgroundColor: Colors.grey[200],
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          // 主要内容区域
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 步骤说明
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    '${_currentStep + 1}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    widget.steps[_currentStep].description,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (widget.steps[_currentStep].formula.isNotEmpty)
                              Center(
                                child: Math.tex(
                                  widget.steps[_currentStep].formula,
                                  textStyle: const TextStyle(fontSize: 20),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // 提示信息
                    if (_showHint && widget.steps[_currentStep].hint != null)
                      Card(
                        color: Colors.yellow[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.lightbulb, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text(
                                    '提示',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(widget.steps[_currentStep].hint!),
                            ],
                          ),
                        ),
                      ),

                    // 相关知识点
                    const SizedBox(height: 16),
                    const Text(
                      '相关知识点',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._buildKnowledgePoints(),
                  ],
                ),
              ),
            ),
          ),

          // 底部导航区
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _currentStep > 0
                        ? () {
                            setState(() {
                              _currentStep--;
                            });
                          }
                        : null,
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back),
                        SizedBox(width: 8),
                        Text('上一步'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _currentStep < widget.steps.length - 1
                        ? () {
                            setState(() {
                              _currentStep++;
                            });
                          }
                        : null,
                    child: const Row(
                      children: [
                        Text('下一步'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildKnowledgePoints() {
    final currentStepPoints = widget.steps[_currentStep].knowledgePoints;
    final relevantPoints = widget.knowledgePoints
        .where((kp) => currentStepPoints.contains(kp.id))
        .toList();

    return relevantPoints.map((point) {
      final isExpanded = _expandedKnowledgePoints[point.id] ?? false;

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedKnowledgePoints[point.id] = expanded;
            });
          },
          title: Row(
            children: [
              Text(
                point.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
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
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(point.description),
                  if (point.examples.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      '例题:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...point.examples.map((example) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('• $example'),
                      );
                    }),
                  ],
                  if (point.relatedPoints.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      '相关知识点:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8,
                      children: point.relatedPoints.map((relatedId) {
                        final relatedPoint = widget.knowledgePoints.firstWhere(
                          (kp) => kp.id == relatedId,
                        );
                        return Chip(
                          label: Text(relatedPoint.name),
                          backgroundColor: Colors.grey[200],
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
