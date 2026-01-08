import 'package:flutter/material.dart';

/// 98k 狙击镜样式描边
class SniperReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double frameSize = size.shortestSide * 0.68;
    final double frameLeft = (size.width - frameSize) / 2;
    final double frameTop = (size.height - frameSize) / 2;
    final double cornerLen = 36;
    final double cornerWidth = 6;
    final double crossLen = 18;
    final double crossWidth = 3;
    final Color primaryColor = const Color(
      0xFF358373,
    ); // Learnist Academic Light VI 主色
    final Color whiteColor = Colors.white;

    final Paint clawPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = cornerWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // 四角L形
    canvas.drawLine(
      Offset(frameLeft, frameTop),
      Offset(frameLeft + cornerLen, frameTop),
      clawPaint,
    );
    canvas.drawLine(
      Offset(frameLeft, frameTop),
      Offset(frameLeft, frameTop + cornerLen),
      clawPaint,
    );
    canvas.drawLine(
      Offset(frameLeft + frameSize, frameTop),
      Offset(frameLeft + frameSize - cornerLen, frameTop),
      clawPaint,
    );
    canvas.drawLine(
      Offset(frameLeft + frameSize, frameTop),
      Offset(frameLeft + frameSize, frameTop + cornerLen),
      clawPaint,
    );
    canvas.drawLine(
      Offset(frameLeft, frameTop + frameSize),
      Offset(frameLeft + cornerLen, frameTop + frameSize),
      clawPaint,
    );
    canvas.drawLine(
      Offset(frameLeft, frameTop + frameSize),
      Offset(frameLeft, frameTop + frameSize - cornerLen),
      clawPaint,
    );
    canvas.drawLine(
      Offset(frameLeft + frameSize, frameTop + frameSize),
      Offset(frameLeft + frameSize - cornerLen, frameTop + frameSize),
      clawPaint,
    );
    canvas.drawLine(
      Offset(frameLeft + frameSize, frameTop + frameSize),
      Offset(frameLeft + frameSize, frameTop + frameSize - cornerLen),
      clawPaint,
    );

    // 中心十字
    final Paint crossPaint = Paint()
      ..color = whiteColor
      ..strokeWidth = crossWidth
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
    final Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(
      center.translate(-crossLen, 0),
      center.translate(crossLen, 0),
      crossPaint,
    );
    canvas.drawLine(
      center.translate(0, -crossLen),
      center.translate(0, crossLen),
      crossPaint,
    );

    // 中心圆
    canvas.drawCircle(center, 12, crossPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 裁剪网格描边
class GridPainter extends CustomPainter {
  final Rect rect;
  GridPainter(this.rect);

  @override
  void paint(Canvas canvas, Size size) {
    final Color whiteColor = Colors.white;
    final Paint borderPaint = Paint()
      ..color = whiteColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, borderPaint);

    final Paint gridPaint = Paint()
      ..color = whiteColor.withOpacity(0.25)
      ..strokeWidth = 1.2;
    for (int i = 1; i < 3; i++) {
      final dx = rect.left + i * rect.width / 3;
      canvas.drawLine(Offset(dx, rect.top), Offset(dx, rect.bottom), gridPaint);
      final dy = rect.top + i * rect.height / 3;
      canvas.drawLine(Offset(rect.left, dy), Offset(rect.right, dy), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 裁剪遮罩背景
class CropOverlayPainter extends CustomPainter {
  final Rect rect;
  CropOverlayPainter(this.rect);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint maskPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    Path mask = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    mask.addRect(rect);
    canvas.drawPath(mask, maskPaint);

    // 句柄描边
    final Color primaryColor = const Color(0xFF358373);
    final Paint handlePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final r = rect;
    final len = 28.0;
    canvas.drawLine(r.topLeft, r.topLeft + Offset(len, 0), handlePaint);
    canvas.drawLine(r.topLeft, r.topLeft + Offset(0, len), handlePaint);
    canvas.drawLine(r.topRight, r.topRight + Offset(-len, 0), handlePaint);
    canvas.drawLine(r.topRight, r.topRight + Offset(0, len), handlePaint);
    canvas.drawLine(r.bottomLeft, r.bottomLeft + Offset(len, 0), handlePaint);
    canvas.drawLine(r.bottomLeft, r.bottomLeft + Offset(0, -len), handlePaint);
    canvas.drawLine(
      r.bottomRight,
      r.bottomRight + Offset(-len, 0),
      handlePaint,
    );
    canvas.drawLine(
      r.bottomRight,
      r.bottomRight + Offset(0, -len),
      handlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 学术范围描边
class AcademicScopePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double frameSize = size.shortestSide * 0.68;
    final double frameLeft = (size.width - frameSize) / 2;
    final double frameTop = (size.height - frameSize) / 2;
    final double cornerLen = 32;
    final double cornerWidth = 4;
    final double crossLen = 16;
    final double crossWidth = 2.5;
    final Color primaryColor = const Color(0xFF358373);
    final Color whiteColor = Colors.white;

    final Paint clawPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = cornerWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final Paint linePaint = Paint()
      ..color = whiteColor
      ..strokeWidth = crossWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 四角L形
    canvas.drawLine(
      Offset(frameLeft, frameTop),
      Offset(frameLeft + cornerLen, frameTop),
      clawPaint,
    );
    canvas.drawLine(
      Offset(frameLeft, frameTop),
      Offset(frameLeft, frameTop + cornerLen),
      clawPaint,
    );
    canvas.drawLine(
      Offset(frameLeft + frameSize, frameTop),
      Offset(frameLeft + frameSize - cornerLen, frameTop),
      clawPaint,
    );
    canvas.drawLine(
      Offset(frameLeft + frameSize, frameTop),
      Offset(frameLeft + frameSize, frameTop + cornerLen),
      clawPaint,
    );
    canvas.drawLine(
      Offset(frameLeft, frameTop + frameSize),
      Offset(frameLeft + cornerLen, frameTop + frameSize),
      clawPaint,
    );
    canvas.drawLine(
      Offset(frameLeft, frameTop + frameSize),
      Offset(frameLeft, frameTop + frameSize - cornerLen),
      clawPaint,
    );
    canvas.drawLine(
      Offset(frameLeft + frameSize, frameTop + frameSize),
      Offset(frameLeft + frameSize - cornerLen, frameTop + frameSize),
      clawPaint,
    );
    canvas.drawLine(
      Offset(frameLeft + frameSize, frameTop + frameSize),
      Offset(frameLeft + frameSize, frameTop + frameSize - cornerLen),
      clawPaint,
    );

    // 中心十字
    final Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(
      center.translate(-crossLen, 0),
      center.translate(crossLen, 0),
      linePaint,
    );
    canvas.drawLine(
      center.translate(0, -crossLen),
      center.translate(0, crossLen),
      linePaint,
    );

    // 中心圆
    canvas.drawCircle(center, 10, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}