import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// 仿数码相机的四个90度角抓手取景框
class CameraCornerFrame extends StatelessWidget {
  final double frameSize; // 取景框大小（正方形边长）
  final double cornerLength; // 角的长度
  final double cornerWidth; // 角的粗细

  const CameraCornerFrame({
    super.key,
    this.frameSize = 280,
    this.cornerLength = 40,
    this.cornerWidth = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: frameSize,
        height: frameSize,
        child: Stack(
          children: [
            // 左上角
            Positioned(
              top: 0,
              left: 0,
              child: _buildCorner(
                isTopLeft: true,
              ),
            ),
            // 右上角
            Positioned(
              top: 0,
              right: 0,
              child: _buildCorner(
                isTopRight: true,
              ),
            ),
            // 左下角
            Positioned(
              bottom: 0,
              left: 0,
              child: _buildCorner(
                isBottomLeft: true,
              ),
            ),
            // 右下角
            Positioned(
              bottom: 0,
              right: 0,
              child: _buildCorner(
                isBottomRight: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner({
    bool isTopLeft = false,
    bool isTopRight = false,
    bool isBottomLeft = false,
    bool isBottomRight = false,
  }) {
    return SizedBox(
      width: cornerLength,
      height: cornerLength,
      child: CustomPaint(
        painter: _CornerPainter(
          cornerWidth: cornerWidth,
          isTopLeft: isTopLeft,
          isTopRight: isTopRight,
          isBottomLeft: isBottomLeft,
          isBottomRight: isBottomRight,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final double cornerWidth;
  final bool isTopLeft;
  final bool isTopRight;
  final bool isBottomLeft;
  final bool isBottomRight;

  _CornerPainter({
    required this.cornerWidth,
    this.isTopLeft = false,
    this.isTopRight = false,
    this.isBottomLeft = false,
    this.isBottomRight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.brandPrimary
      ..strokeWidth = cornerWidth
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (isTopLeft) {
      // 左上角：竖线 + 横线
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTopRight) {
      // 右上角：横线 + 竖线
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (isBottomLeft) {
      // 左下角：竖线 + 横线
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else if (isBottomRight) {
      // 右下角：横线 + 竖线
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
