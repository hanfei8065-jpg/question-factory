import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class HandwritingWorkspacePage extends StatefulWidget {
  const HandwritingWorkspacePage({super.key});

  @override
  State<HandwritingWorkspacePage> createState() =>
      _HandwritingWorkspacePageState();
}

class _HandwritingWorkspacePageState extends State<HandwritingWorkspacePage> {
  List<List<Offset>> _strokes = [];
  List<List<Offset>> _redoStrokes = [];
  bool _showGrid = true;
  double _gridSize = 30.0;
  Color _currentColor = Colors.black;
  double _currentStrokeWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('手写演算区'),
        actions: [
          IconButton(
            icon: Icon(_showGrid ? Icons.grid_on : Icons.grid_off),
            onPressed: () {
              setState(() {
                _showGrid = !_showGrid;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _strokes.isNotEmpty
                ? () {
                    setState(() {
                      _redoStrokes.add(_strokes.removeLast());
                    });
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: _redoStrokes.isNotEmpty
                ? () {
                    setState(() {
                      _strokes.add(_redoStrokes.removeLast());
                    });
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _strokes.clear();
                _redoStrokes.clear();
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 绘制网格
          if (_showGrid)
            CustomPaint(painter: GridPainter(_gridSize), size: Size.infinite),

          // 绘制手写内容
          GestureDetector(
            onPanStart: (details) {
              setState(() {
                _strokes.add([details.localPosition]);
                _redoStrokes.clear(); // 清除重做记录
              });
            },
            onPanUpdate: (details) {
              setState(() {
                _strokes.last.add(details.localPosition);
              });
            },
            onPanEnd: (details) {
              // 笔画结束后可以添加任何后处理逻辑
            },
            child: CustomPaint(
              painter: HandwritingPainter(
                strokes: _strokes,
                strokeColor: _currentColor,
                strokeWidth: _currentStrokeWidth,
              ),
              size: Size.infinite,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildColorButton(Colors.black),
            _buildColorButton(Colors.blue),
            _buildColorButton(Colors.red),
            _buildStrokeWidthButton(1.0),
            _buildStrokeWidthButton(2.0),
            _buildStrokeWidthButton(4.0),
            IconButton(
              icon: const Icon(Icons.grid_3x3),
              onPressed: () {
                _showGridSizeDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentColor = color;
        });
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _currentColor == color
                ? Colors.grey[400]!
                : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildStrokeWidthButton(double width) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentStrokeWidth = width;
        });
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(
            color: _currentStrokeWidth == width
                ? Colors.grey[400]!
                : Colors.transparent,
            width: 2,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: width * 2,
            height: width * 2,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  void _showGridSizeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('调整网格大小'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: _gridSize,
                    min: 20,
                    max: 50,
                    divisions: 6,
                    label: _gridSize.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _gridSize = value;
                      });
                      this.setState(() {}); // 更新主界面
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
}

class GridPainter extends CustomPainter {
  final double gridSize;

  GridPainter(this.gridSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.5;

    // 绘制竖线
    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // 绘制横线
    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) =>
      gridSize != oldDelegate.gridSize;
}

class HandwritingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final Color strokeColor;
  final double strokeWidth;

  HandwritingPainter({
    required this.strokes,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;

      final path = Path();
      path.moveTo(stroke[0].dx, stroke[0].dy);

      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(HandwritingPainter oldDelegate) =>
      strokes != oldDelegate.strokes ||
      strokeColor != oldDelegate.strokeColor ||
      strokeWidth != oldDelegate.strokeWidth;
}
