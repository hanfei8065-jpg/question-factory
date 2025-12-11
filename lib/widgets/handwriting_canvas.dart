import 'package:flutter/material.dart';

/// 手写画板 - 计算器输入板顶部的涂鸦区域
/// 用于手写数字、字母、草稿计算
class HandwritingCanvas extends StatefulWidget {
  const HandwritingCanvas({super.key});

  @override
  State<HandwritingCanvas> createState() => _HandwritingCanvasState();
}

class _HandwritingCanvasState extends State<HandwritingCanvas> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _currentStroke = [details.localPosition];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentStroke.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _strokes.add(List.from(_currentStroke));
      _currentStroke = [];
    });
  }

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5), // 浅灰背景
      child: Stack(
        children: [
          // Drawing Area
          GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: CustomPaint(
              painter: _StrokePainter(
                strokes: _strokes,
                currentStroke: _currentStroke,
              ),
              size: Size.infinite,
            ),
          ),

          // Clear Button (Top Right)
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.clear, color: Colors.black54),
              onPressed: _clearCanvas,
              tooltip: 'Clear',
            ),
          ),
        ],
      ),
    );
  }
}

/// 自定义画笔绘制器
class _StrokePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;

  _StrokePainter({required this.strokes, required this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 绘制已完成的笔画
    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path();
      path.moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    // 绘制当前笔画
    if (currentStroke.length >= 2) {
      final path = Path();
      path.moveTo(currentStroke.first.dx, currentStroke.first.dy);
      for (int i = 1; i < currentStroke.length; i++) {
        path.lineTo(currentStroke[i].dx, currentStroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_StrokePainter oldDelegate) => true;
}
