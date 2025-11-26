import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// 长条裁剪框 - 用于上传图片后快速捕捉题目区域
class CropBarOverlay extends StatefulWidget {
  final File imageFile;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const CropBarOverlay({
    super.key,
    required this.imageFile,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<CropBarOverlay> createState() => _CropBarOverlayState();
}

class _CropBarOverlayState extends State<CropBarOverlay> {
  late Rect _cropRect;
  late Size _imageSize;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCropRect();
  }

  Future<void> _initializeCropRect() async {
    try {
      // 获取图片尺寸
      final image = Image.file(widget.imageFile);
      final completer = image.image.resolve(const ImageConfiguration());
      completer.addListener(ImageStreamListener(
        (info, _) {
          if (mounted) {
            final width = info.image.width.toDouble();
            final height = info.image.height.toDouble();
            
            if (width > 0 && height > 0) {
              setState(() {
                _imageSize = Size(width, height);
                // 初始化为中间的长条（宽度100%，高度20%）
                _cropRect = Rect.fromLTWH(
                  0,
                  height * 0.4,
                  width,
                  height * 0.2,
                );
                _isInitialized = true;
              });
            }
          }
        },
        onError: (exception, stackTrace) {
          print('图片加载错误: $exception');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('图片加载失败')),
            );
            widget.onCancel();
          }
        },
      ));
    } catch (e) {
      print('初始化裁剪框错误: $e');
      if (mounted) {
        widget.onCancel();
      }
    }
  }

  void _updateCropRect(Offset delta, String handle) {
    setState(() {
      switch (handle) {
        case 'top':
          _cropRect = Rect.fromLTRB(
            _cropRect.left,
            (_cropRect.top + delta.dy).clamp(0.0, _cropRect.bottom - 50),
            _cropRect.right,
            _cropRect.bottom,
          );
          break;
        case 'bottom':
          _cropRect = Rect.fromLTRB(
            _cropRect.left,
            _cropRect.top,
            _cropRect.right,
            (_cropRect.bottom + delta.dy).clamp(_cropRect.top + 50, _imageSize.height),
          );
          break;
        case 'left':
          _cropRect = Rect.fromLTRB(
            (_cropRect.left + delta.dx).clamp(0.0, _cropRect.right - 50),
            _cropRect.top,
            _cropRect.right,
            _cropRect.bottom,
          );
          break;
        case 'right':
          _cropRect = Rect.fromLTRB(
            _cropRect.left,
            _cropRect.top,
            (_cropRect.right + delta.dx).clamp(_cropRect.left + 50, _imageSize.width),
            _cropRect.bottom,
          );
          break;
        case 'topLeft':
          _cropRect = Rect.fromLTRB(
            (_cropRect.left + delta.dx).clamp(0.0, _cropRect.right - 50),
            (_cropRect.top + delta.dy).clamp(0.0, _cropRect.bottom - 50),
            _cropRect.right,
            _cropRect.bottom,
          );
          break;
        case 'topRight':
          _cropRect = Rect.fromLTRB(
            _cropRect.left,
            (_cropRect.top + delta.dy).clamp(0.0, _cropRect.bottom - 50),
            (_cropRect.right + delta.dx).clamp(_cropRect.left + 50, _imageSize.width),
            _cropRect.bottom,
          );
          break;
        case 'bottomLeft':
          _cropRect = Rect.fromLTRB(
            (_cropRect.left + delta.dx).clamp(0.0, _cropRect.right - 50),
            _cropRect.top,
            _cropRect.right,
            (_cropRect.bottom + delta.dy).clamp(_cropRect.top + 50, _imageSize.height),
          );
          break;
        case 'bottomRight':
          _cropRect = Rect.fromLTRB(
            _cropRect.left,
            _cropRect.top,
            (_cropRect.right + delta.dx).clamp(_cropRect.left + 50, _imageSize.width),
            (_cropRect.bottom + delta.dy).clamp(_cropRect.top + 50, _imageSize.height),
          );
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: widget.onCancel,
          ),
          title: const Text('加载中...', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 背景图片
            Center(
              child: Image.file(
                widget.imageFile,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          '图片加载失败',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 半透明遮罩层（玻璃磨砂效果）
            Positioned.fill(
              child: CustomPaint(
                painter: _CropOverlayPainter(
                  cropRect: _cropRect,
                  imageSize: _imageSize,
                ),
              ),
            ),

            // 可拖动的裁剪框边缘
            ..._buildDragHandles(),

            // 顶部工具栏
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: widget.onCancel,
                  ),
                  Text(
                    '调整裁剪区域',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppTheme.fontSizeL,
                      fontWeight: AppTheme.fontWeightBold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check, color: AppTheme.brandPrimary, size: 28),
                    onPressed: widget.onConfirm,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDragHandles() {
    final screenSize = MediaQuery.of(context).size;
    final scaleX = screenSize.width / _imageSize.width;
    final scaleY = screenSize.height / _imageSize.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final scaledRect = Rect.fromLTWH(
      _cropRect.left * scale + (screenSize.width - _imageSize.width * scale) / 2,
      _cropRect.top * scale + (screenSize.height - _imageSize.height * scale) / 2,
      _cropRect.width * scale,
      _cropRect.height * scale,
    );

    return [
      // 四个角
      _buildCornerHandle('topLeft', scaledRect.topLeft),
      _buildCornerHandle('topRight', scaledRect.topRight),
      _buildCornerHandle('bottomLeft', scaledRect.bottomLeft),
      _buildCornerHandle('bottomRight', scaledRect.bottomRight),

      // 四条边
      _buildEdgeHandle('top', Offset(scaledRect.center.dx, scaledRect.top)),
      _buildEdgeHandle('bottom', Offset(scaledRect.center.dx, scaledRect.bottom)),
      _buildEdgeHandle('left', Offset(scaledRect.left, scaledRect.center.dy)),
      _buildEdgeHandle('right', Offset(scaledRect.right, scaledRect.center.dy)),
    ];
  }

  Widget _buildCornerHandle(String handle, Offset position) {
    return Positioned(
      left: position.dx - 12,
      top: position.dy - 12,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) {
          print('Corner $handle dragged: ${details.delta}');
          _updateCropRect(details.delta, handle);
        },
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.brandPrimary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildEdgeHandle(String handle, Offset position) {
    return Positioned(
      left: position.dx - 6,
      top: position.dy - 6,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) {
          print('Edge $handle dragged: ${details.delta}');
          _updateCropRect(details.delta, handle);
        },
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.brandPrimary, width: 1),
          ),
        ),
      ),
    );
  }
}

class _CropOverlayPainter extends CustomPainter {
  final Rect cropRect;
  final Size imageSize;

  _CropOverlayPainter({
    required this.cropRect,
    required this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 计算缩放和偏移
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final scaledRect = Rect.fromLTWH(
      cropRect.left * scale + (size.width - imageSize.width * scale) / 2,
      cropRect.top * scale + (size.height - imageSize.height * scale) / 2,
      cropRect.width * scale,
      cropRect.height * scale,
    );

    // 绘制半透明遮罩
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(scaledRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withOpacity(0.6)
        ..style = PaintingStyle.fill,
    );

    // 绘制裁剪框边框
    canvas.drawRect(
      scaledRect,
      Paint()
        ..color = AppTheme.brandPrimary
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect;
  }
}
