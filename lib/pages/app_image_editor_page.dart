import 'dart:io';
import 'package:flutter/material.dart';
import 'app_solution_page.dart';

/// 图片裁剪编辑页
/// 接收相机拍摄的图片，提供九宫格裁剪框，确认后传给解题页
class AppImageEditorPage extends StatefulWidget {
  final String imagePath;

  const AppImageEditorPage({super.key, required this.imagePath});

  @override
  State<AppImageEditorPage> createState() => _AppImageEditorPageState();
}

class _AppImageEditorPageState extends State<AppImageEditorPage> {
  Rect _cropRect = Rect.zero;
  Size _imageSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final image = Image.file(File(widget.imagePath));
    final completer = await image.image.resolve(const ImageConfiguration());
    completer.addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        setState(() {
          _imageSize = Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          );
          // 默认裁剪框：图片中心80%区域
          final margin = _imageSize.width * 0.1;
          _cropRect = Rect.fromLTWH(
            margin,
            margin * 2,
            _imageSize.width - margin * 2,
            _imageSize.height - margin * 4,
          );
        });
      }),
    );
  }

  void _onConfirm() {
    // 跳转到解题页，传递原图路径（实际项目中应传递裁剪后的图片）
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SolvingPage(imagePath: widget.imagePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('调整裁剪框', style: TextStyle(color: Colors.white)),
      ),
      body: _imageSize == Size.zero
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // 图片预览
                Center(
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                  ),
                ),

                // 裁剪框覆盖层
                Positioned.fill(
                  child: CustomPaint(painter: _CropOverlayPainter(_cropRect)),
                ),

                // 底部确认按钮
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 40,
                  child: Center(
                    child: GestureDetector(
                      onTap: _onConfirm,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFF07C160),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF07C160).withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// 裁剪框绘制器（九宫格+暗化外围）
class _CropOverlayPainter extends CustomPainter {
  final Rect cropRect;

  _CropOverlayPainter(this.cropRect);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 暗化裁剪框外的区域
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(cropRect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.6));

    // 2. 绘制裁剪框边框
    canvas.drawRect(
      cropRect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // 3. 绘制九宫格线
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1;

    // 横线
    for (int i = 1; i < 3; i++) {
      final y = cropRect.top + (cropRect.height / 3) * i;
      canvas.drawLine(
        Offset(cropRect.left, y),
        Offset(cropRect.right, y),
        gridPaint,
      );
    }

    // 竖线
    for (int i = 1; i < 3; i++) {
      final x = cropRect.left + (cropRect.width / 3) * i;
      canvas.drawLine(
        Offset(x, cropRect.top),
        Offset(x, cropRect.bottom),
        gridPaint,
      );
    }

    // 4. 绘制四个角的拖拽手柄
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final handleSize = 12.0;
    final corners = [
      cropRect.topLeft,
      cropRect.topRight,
      cropRect.bottomLeft,
      cropRect.bottomRight,
    ];

    for (final corner in corners) {
      canvas.drawCircle(corner, handleSize / 2, handlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect;
  }
}
