import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class EdgeDetectionOverlay extends StatelessWidget {
  final List<Offset> corners;
  final Size previewSize;
  final Size screenSize;

  const EdgeDetectionOverlay({
    super.key,
    required this.corners,
    required this.previewSize,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: screenSize,
      painter: EdgeDetectionPainter(
        corners: corners,
        previewSize: previewSize,
        screenSize: screenSize,
      ),
    );
  }
}

class EdgeDetectionPainter extends CustomPainter {
  final List<Offset> corners;
  final Size previewSize;
  final Size screenSize;

  EdgeDetectionPainter({
    required this.corners,
    required this.previewSize,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (corners.isEmpty) return;

    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // 计算缩放比例
    final double scaleX = screenSize.width / previewSize.width;
    final double scaleY = screenSize.height / previewSize.height;

    // 转换坐标点
    final scaledPoints = corners.map((point) {
      return Offset(point.dx * scaleX, point.dy * scaleY);
    }).toList();

    // 绘制边框
    final path = Path();
    path.moveTo(scaledPoints[0].dx, scaledPoints[0].dy);
    for (int i = 1; i < scaledPoints.length; i++) {
      path.lineTo(scaledPoints[i].dx, scaledPoints[i].dy);
    }
    path.close();

    canvas.drawPath(path, paint);

    // 绘制角点
    final cornerPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 10.0
      ..style = PaintingStyle.fill;

    for (var point in scaledPoints) {
      canvas.drawCircle(point, 4.0, cornerPaint);
    }
  }

  @override
  bool shouldRepaint(EdgeDetectionPainter oldDelegate) {
    return true;
  }
}
