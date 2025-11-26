import 'package:flutter/material.dart';
import '../models/knowledge_network.dart';
import '../models/knowledge_point.dart';
import 'package:graphview/graphview.dart';

class KnowledgeMapPage extends StatefulWidget {
  final KnowledgeNetwork network;
  final List<KnowledgePoint> points;

  const KnowledgeMapPage({
    super.key,
    required this.network,
    required this.points,
  });

  @override
  State<KnowledgeMapPage> createState() => _KnowledgeMapPageState();
}

class _KnowledgeMapPageState extends State<KnowledgeMapPage> {
  late Graph graph;
  late Algorithm algorithm;
  String? selectedPointId;
  double _zoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeGraph();
  }

  void _initializeGraph() {
    graph = Graph()..isTree = false;
    algorithm = FruchtermanReingoldAlgorithm(iterations: 1000);

    // 添加节点
    for (var point in widget.points) {
      graph.addNode(Node.Id(point.id));
    }

    // 添加边
    widget.network.adjacencyList.forEach((from, toList) {
      for (var to in toList) {
        graph.addEdge(
          Node.Id(from),
          Node.Id(to),
          paint: Paint()
            ..color = Colors.blue[100]!
            ..strokeWidth = 2,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('知识图谱'),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              setState(() {
                _zoomLevel = (_zoomLevel + 0.1).clamp(0.5, 2.0);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              setState(() {
                _zoomLevel = (_zoomLevel - 0.1).clamp(0.5, 2.0);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              constrained: false,
              boundaryMargin: const EdgeInsets.all(100),
              minScale: 0.5,
              maxScale: 2.0,
              child: GraphView(
                graph: graph,
                algorithm: algorithm,
                paint: Paint()
                  ..color = Colors.black
                  ..strokeWidth = 1
                  ..style = PaintingStyle.stroke,
                builder: (Node node) {
                  final pointId = node.key?.value as String;
                  final point = widget.network.points[pointId]!;
                  final isSelected = selectedPointId == pointId;
                  final importance = widget.network.calculateImportance(
                    pointId,
                  );

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPointId = pointId;
                      });
                      _showKnowledgePointDetails(point);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue
                            : _getNodeColor(importance),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        point.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (selectedPointId != null) _buildKnowledgePointInfo(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showLegend,
        child: const Icon(Icons.info_outline),
      ),
    );
  }

  Widget _buildKnowledgePointInfo() {
    final point = widget.network.points[selectedPointId]!;
    final prerequisites = widget.network.getPrerequisites(selectedPointId!);
    final dependents = widget.network.getDependents(selectedPointId!);

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            point.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(point.description),
          if (prerequisites.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('前置知识:', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: prerequisites.map((id) {
                return Chip(
                  label: Text(widget.network.points[id]!.name),
                  backgroundColor: Colors.blue[100],
                );
              }).toList(),
            ),
          ],
          if (dependents.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('后续知识:', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: dependents.map((id) {
                return Chip(
                  label: Text(widget.network.points[id]!.name),
                  backgroundColor: Colors.green[100],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Color _getNodeColor(double importance) {
    if (importance > 1.5) return Colors.red[100]!;
    if (importance > 1.0) return Colors.orange[100]!;
    if (importance > 0.5) return Colors.yellow[100]!;
    return Colors.green[100]!;
  }

  void _showKnowledgePointDetails(KnowledgePoint point) {
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
              if (point.examples.isNotEmpty) ...[
                const Text(
                  '相关例题:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...point.examples.map((example) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('• $example'),
                  );
                }),
              ],
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

  void _showLegend() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('图例说明'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLegendItem(Colors.red[100]!, '核心知识点'),
            _buildLegendItem(Colors.orange[100]!, '重要知识点'),
            _buildLegendItem(Colors.yellow[100]!, '基础知识点'),
            _buildLegendItem(Colors.green[100]!, '扩展知识点'),
            const SizedBox(height: 16),
            const Text(
              '提示：\n'
              '• 点击节点可查看详细信息\n'
              '• 使用双指缩放查看更多细节\n'
              '• 蓝色连线表示知识点之间的关联',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('了解了'),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
