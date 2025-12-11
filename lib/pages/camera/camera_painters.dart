import 'package:flutter/material.dart';

/// WeChat Minimalism Style Camera Painter
/// Simple Green Circle with White Border - Clean & Minimal
class JadeAperturePainter extends CustomPainter {
  final double animationValue;
  final Size screenSize;

  JadeAperturePainter({this.animationValue = 1.0, required this.screenSize});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) * 0.85 * animationValue;

    // WeChat Green (#07C160)
    final Paint circlePaint = Paint()
      ..color = const Color(0xFF07C160)
      ..style = PaintingStyle.fill;

    // White Border
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // Draw solid green circle
    canvas.drawCircle(center, radius, circlePaint);

    // Draw white border
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(JadeAperturePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Simple Frame Painter for Camera Guide
class FramePainter extends CustomPainter {
  final Color color;
  final double cornerLength;
  final double strokeWidth;

  FramePainter({
    this.color = const Color(0xFF07C160),
    this.cornerLength = 40.0,
    this.strokeWidth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left corner
    canvas.drawLine(const Offset(0, 0), Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, cornerLength), paint);

    // Top-right corner
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - cornerLength),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - cornerLength, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(FramePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.cornerLength != cornerLength ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Crop Frame Painter for Image Cropping
class CropFramePainter extends CustomPainter {
  final Rect cropRect;
  final Color borderColor;
  final double borderWidth;

  CropFramePainter({
    required this.cropRect,
    this.borderColor = const Color(0xFF07C160),
    this.borderWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    // Draw crop rectangle
    canvas.drawRect(cropRect, borderPaint);

    // Draw corner handles
    final handleSize = 20.0;
    final handlePaint = Paint()
      ..color = borderColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left handle
    canvas.drawLine(
      Offset(cropRect.left, cropRect.top),
      Offset(cropRect.left + handleSize, cropRect.top),
      handlePaint,
    );
    canvas.drawLine(
      Offset(cropRect.left, cropRect.top),
      Offset(cropRect.left, cropRect.top + handleSize),
      handlePaint,
    );

    // Top-right handle
    canvas.drawLine(
      Offset(cropRect.right, cropRect.top),
      Offset(cropRect.right - handleSize, cropRect.top),
      handlePaint,
    );
    canvas.drawLine(
      Offset(cropRect.right, cropRect.top),
      Offset(cropRect.right, cropRect.top + handleSize),
      handlePaint,
    );

    // Bottom-left handle
    canvas.drawLine(
      Offset(cropRect.left, cropRect.bottom),
      Offset(cropRect.left + handleSize, cropRect.bottom),
      handlePaint,
    );
    canvas.drawLine(
      Offset(cropRect.left, cropRect.bottom),
      Offset(cropRect.left, cropRect.bottom - handleSize),
      handlePaint,
    );

    // Bottom-right handle
    canvas.drawLine(
      Offset(cropRect.right, cropRect.bottom),
      Offset(cropRect.right - handleSize, cropRect.bottom),
      handlePaint,
    );
    canvas.drawLine(
      Offset(cropRect.right, cropRect.bottom),
      Offset(cropRect.right, cropRect.bottom - handleSize),
      handlePaint,
    );
  }

  @override
  bool shouldRepaint(CropFramePainter oldDelegate) {
    return oldDelegate.cropRect != cropRect ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}

/// Sniper Crosshair Painter
class SniperCrosshairPainter extends CustomPainter {
  final double animationValue;
  final Size screenSize;

  SniperCrosshairPainter({this.animationValue = 1.0, required this.screenSize});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final color = Color(0xFF07C160);

    final Paint paint = Paint()
      ..color = color.withOpacity(0.8 * animationValue)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final lineLength = 30.0 * animationValue;
    final gap = 10.0;

    // Horizontal line (left)
    canvas.drawLine(
      Offset(center.dx - gap - lineLength, center.dy),
      Offset(center.dx - gap, center.dy),
      paint,
    );

    // Horizontal line (right)
    canvas.drawLine(
      Offset(center.dx + gap, center.dy),
      Offset(center.dx + gap + lineLength, center.dy),
      paint,
    );

    // Vertical line (top)
    canvas.drawLine(
      Offset(center.dx, center.dy - gap - lineLength),
      Offset(center.dx, center.dy - gap),
      paint,
    );

    // Vertical line (bottom)
    canvas.drawLine(
      Offset(center.dx, center.dy + gap),
      Offset(center.dx, center.dy + gap + lineLength),
      paint,
    );

    // Center dot
    canvas.drawCircle(
      center,
      3.0 * animationValue,
      Paint()
        ..color = color.withOpacity(0.6 * animationValue)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(SniperCrosshairPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
