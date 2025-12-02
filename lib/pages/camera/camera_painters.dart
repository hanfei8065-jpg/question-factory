import 'package:flutter/material.dart';
import 'dart:ui';

/// JadeAperturePainter - High-tech lens cap with animated breach
/// Closed (0.0): Logo at center. Open (1.0): Brackets become viewfinder corners
class JadeAperturePainter extends CustomPainter {
  final double animationValue;
  final Size screenSize;

  JadeAperturePainter({required this.animationValue, required this.screenSize});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Outer circle - WeChat Green solid fill (fades out during animation)
    if (animationValue < 1.0) {
      final Paint circlePaint = Paint()
        ..color = Color(0xFF07C160).withOpacity(1.0 - animationValue)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, circlePaint);
    }

    // Logo symbol - White bracket/sharp lines
    final Paint logoPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double bracketWidth = radius * 0.4;
    final double bracketHeight = radius * 0.8;

    // Calculate positions based on animation
    // Closed: brackets at center
    // Open: left bracket -> top-left, right bracket -> bottom-right
    final Offset leftBracketClosedPos = Offset(
      center.dx - bracketWidth,
      center.dy,
    );
    final Offset leftBracketOpenPos = Offset(
      40, // Top-left corner padding
      80, // SafeArea top
    );
    final Offset leftBracketPos = Offset.lerp(
      leftBracketClosedPos,
      leftBracketOpenPos,
      animationValue,
    )!;

    final Offset rightBracketClosedPos = Offset(
      center.dx + bracketWidth,
      center.dy,
    );
    final Offset rightBracketOpenPos = Offset(
      screenSize.width - 40,
      screenSize.height - 120, // Above bottom bar
    );
    final Offset rightBracketPos = Offset.lerp(
      rightBracketClosedPos,
      rightBracketOpenPos,
      animationValue,
    )!;

    // Left bracket [ (scales up during animation)
    final double scale = 1.0 + animationValue * 1.5;
    final double leftWidth = bracketWidth * 0.3 * scale;
    final double leftHeight = bracketHeight / 2 * scale;

    canvas.drawLine(
      Offset(leftBracketPos.dx + leftWidth, leftBracketPos.dy - leftHeight),
      Offset(leftBracketPos.dx, leftBracketPos.dy - leftHeight),
      logoPaint,
    );
    canvas.drawLine(
      Offset(leftBracketPos.dx, leftBracketPos.dy - leftHeight),
      Offset(leftBracketPos.dx, leftBracketPos.dy + leftHeight),
      logoPaint,
    );
    canvas.drawLine(
      Offset(leftBracketPos.dx, leftBracketPos.dy + leftHeight),
      Offset(leftBracketPos.dx + leftWidth, leftBracketPos.dy + leftHeight),
      logoPaint,
    );

    // Right bracket ] (scales up during animation)
    final double rightWidth = bracketWidth * 0.3 * scale;
    final double rightHeight = bracketHeight / 2 * scale;

    canvas.drawLine(
      Offset(rightBracketPos.dx - rightWidth, rightBracketPos.dy - rightHeight),
      Offset(rightBracketPos.dx, rightBracketPos.dy - rightHeight),
      logoPaint,
    );
    canvas.drawLine(
      Offset(rightBracketPos.dx, rightBracketPos.dy - rightHeight),
      Offset(rightBracketPos.dx, rightBracketPos.dy + rightHeight),
      logoPaint,
    );
    canvas.drawLine(
      Offset(rightBracketPos.dx, rightBracketPos.dy + rightHeight),
      Offset(rightBracketPos.dx - rightWidth, rightBracketPos.dy + rightHeight),
      logoPaint,
    );

    // Center slash / (fades out during animation)
    if (animationValue < 0.8) {
      final Paint slashPaint = Paint()
        ..color = Colors.white.withOpacity(1.0 - animationValue / 0.8)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(center.dx - bracketWidth * 0.2, center.dy + bracketHeight * 0.3),
        Offset(center.dx + bracketWidth * 0.2, center.dy - bracketHeight * 0.3),
        slashPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant JadeAperturePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// SniperCrosshairPainter - 98k hairline crosshair for active camera mode
class SniperCrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Paint crosshairPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Horizontal line
    canvas.drawLine(
      Offset(center.dx - 40, center.dy),
      Offset(center.dx + 40, center.dy),
      crosshairPaint,
    );

    // Vertical line
    canvas.drawLine(
      Offset(center.dx, center.dy - 40),
      Offset(center.dx, center.dy + 40),
      crosshairPaint,
    );

    // Center dot
    canvas.drawCircle(center, 2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// CropFramePainter - Premium crop frame with WeChat Green corners and grid
class CropFramePainter extends CustomPainter {
  final Rect cropRect;

  CropFramePainter({required this.cropRect});

  @override
  void paint(Canvas canvas, Size size) {
    const Color wechatGreen = Color(0xFF07C160);

    // Draw thick corner handles
    final Paint cornerPaint = Paint()
      ..color = wechatGreen
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double cornerLength = 30;

    // Top-Left
    canvas.drawLine(
      cropRect.topLeft,
      cropRect.topLeft + Offset(cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      cropRect.topLeft,
      cropRect.topLeft + Offset(0, cornerLength),
      cornerPaint,
    );

    // Top-Right
    canvas.drawLine(
      cropRect.topRight,
      cropRect.topRight + Offset(-cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      cropRect.topRight,
      cropRect.topRight + Offset(0, cornerLength),
      cornerPaint,
    );

    // Bottom-Left
    canvas.drawLine(
      cropRect.bottomLeft,
      cropRect.bottomLeft + Offset(cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      cropRect.bottomLeft,
      cropRect.bottomLeft + Offset(0, -cornerLength),
      cornerPaint,
    );

    // Bottom-Right
    canvas.drawLine(
      cropRect.bottomRight,
      cropRect.bottomRight + Offset(-cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      cropRect.bottomRight,
      cropRect.bottomRight + Offset(0, -cornerLength),
      cornerPaint,
    );

    // Draw 3x3 grid
    final Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Vertical lines
    for (int i = 1; i <= 2; i++) {
      final double x = cropRect.left + (cropRect.width * i / 3);
      canvas.drawLine(
        Offset(x, cropRect.top),
        Offset(x, cropRect.bottom),
        gridPaint,
      );
    }

    // Horizontal lines
    for (int i = 1; i <= 2; i++) {
      final double y = cropRect.top + (cropRect.height * i / 3);
      canvas.drawLine(
        Offset(cropRect.left, y),
        Offset(cropRect.right, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CropFramePainter oldDelegate) {
    return oldDelegate.cropRect != cropRect;
  }
}
