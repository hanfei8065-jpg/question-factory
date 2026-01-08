import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_solving_page.dart'; // 确保路径正确
import '../core/constants.dart'; // ✅ 新增：引入 Subject 枚举

// --- Tesla 0.93 缩放物理引擎 ---
class TeslaScaleWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const TeslaScaleWrapper({super.key, required this.child, this.onTap});
  @override
  State<TeslaScaleWrapper> createState() => _TeslaScaleWrapperState();
}

class _TeslaScaleWrapperState extends State<TeslaScaleWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.93,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

class AppImageEditorPage extends StatefulWidget {
  final String imagePath;
  final Subject subject; // ✅ 新增：接收从首页传来的学科枚举

  const AppImageEditorPage({
    super.key,
    required this.imagePath,
    required this.subject, // ✅ 必填
  });

  @override
  State<AppImageEditorPage> createState() => _AppImageEditorPageState();
}

class _AppImageEditorPageState extends State<AppImageEditorPage> {
  late Rect cropRect;
  bool _isInitialized = false;
  int _rotationCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final size = MediaQuery.of(context).size;
      final padding = MediaQuery.of(context).padding;

      // ✅ 物理级对齐：锁定屏幕绝对几何中心（计算 SafeArea 偏移）
      double safeAreaCenterY =
          padding.top + (size.height - padding.top - padding.bottom - 100) / 2;

      cropRect = Rect.fromCenter(
        center: Offset(size.width / 2, safeAreaCenterY),
        width: 312, // 首页瞄准框宽度
        height: 160, // 首页瞄准框高度
      );
      _isInitialized = true;
    }
  }

  // 丝滑拖拽逻辑
  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      final delta = details.delta;
      final touchPos = details.localPosition;
      bool isTopLeft = (touchPos - cropRect.topLeft).distance < 35;
      bool isTopRight = (touchPos - cropRect.topRight).distance < 35;
      bool isBottomLeft = (touchPos - cropRect.bottomLeft).distance < 35;
      bool isBottomRight = (touchPos - cropRect.bottomRight).distance < 35;

      if (isTopLeft) {
        cropRect = Rect.fromLTRB(
          cropRect.left + delta.dx,
          cropRect.top + delta.dy,
          cropRect.right,
          cropRect.bottom,
        );
      } else if (isTopRight) {
        cropRect = Rect.fromLTRB(
          cropRect.left,
          cropRect.top + delta.dy,
          cropRect.right + delta.dx,
          cropRect.bottom,
        );
      } else if (isBottomLeft) {
        cropRect = Rect.fromLTRB(
          cropRect.left + delta.dx,
          cropRect.top,
          cropRect.right,
          cropRect.bottom + delta.dy,
        );
      } else if (isBottomRight) {
        cropRect = Rect.fromLTRB(
          cropRect.left,
          cropRect.top,
          cropRect.right + delta.dx,
          cropRect.bottom + delta.dy,
        );
      } else if (cropRect.contains(touchPos)) {
        cropRect = cropRect.shift(delta);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. 全景预览（无黑布）
          Positioned.fill(
            child: RotatedBox(
              quarterTurns: _rotationCount,
              child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
            ),
          ),

          // 2. 九宫格层（处理手势）
          Positioned.fill(
            child: GestureDetector(
              onPanUpdate: _handlePanUpdate,
              child: CustomPaint(
                painter: _TeslaCropPainter(cropRect: cropRect),
              ),
            ),
          ),

          // 3. 顶部 UI（对齐首页零件）
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 25,
                  left: 20,
                  child: TeslaScaleWrapper(
                    onTap: () => Navigator.pop(context),
                    child: _buildCircleBtn(Icons.arrow_back_ios_new, size: 22),
                  ),
                ),
                Positioned(
                  top: 25,
                  right: 20,
                  child: TeslaScaleWrapper(
                    child: _buildCircleBtn(
                      Icons.help_outline,
                      size: 33,
                    ), // 大小 33 对齐首页
                  ),
                ),
              ],
            ),
          ),

          // 4. 底部白色底座（高度 100, 按键居中）
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 重拍
                  TeslaScaleWrapper(
                    onTap: () => Navigator.pop(context),
                    child: _buildCircleBtn(
                      Icons.refresh,
                      size: 33,
                      isDark: true,
                    ),
                  ),

                  // ✅ 核心修复：点击后传递完整的参数给解题页
                  TeslaScaleWrapper(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppSolvingPage(
                            imagePath: widget.imagePath,
                            cropRect: cropRect,
                            subject: widget.subject, // ✅ 修复：此处已补全 subject 参数
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 88,
                      height: 88, // 对齐首页拍摄键
                      decoration: const BoxDecoration(
                        color: Color(0xFF23D160),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ),

                  // 旋转
                  TeslaScaleWrapper(
                    onTap: () => setState(() => _rotationCount++),
                    child: _buildCircleBtn(
                      Icons.rotate_90_degrees_ccw,
                      size: 33,
                      isDark: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleBtn(
    IconData icon, {
    double size = 24,
    bool isDark = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withOpacity(0.05)
            : Colors.black.withOpacity(0.25),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: isDark ? Colors.black : Colors.white,
        size: size,
      ),
    );
  }
}

// --- 坚定版九宫格绘制逻辑 ---
class _TeslaCropPainter extends CustomPainter {
  final Rect cropRect;
  _TeslaCropPainter({required this.cropRect});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 暗化层
    final paint = Paint()..color = Colors.black.withOpacity(0.5);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRect(cropRect),
      ),
      paint,
    );

    // 2. 坚定版爪子：厚度 3.5, 长度 22
    final handlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    const double l = 22.0;

    canvas.drawLine(
      cropRect.topLeft,
      cropRect.topLeft.translate(l, 0),
      handlePaint,
    );
    canvas.drawLine(
      cropRect.topLeft,
      cropRect.topLeft.translate(0, l),
      handlePaint,
    );
    canvas.drawLine(
      cropRect.topRight,
      cropRect.topRight.translate(-l, 0),
      handlePaint,
    );
    canvas.drawLine(
      cropRect.topRight,
      cropRect.topRight.translate(0, l),
      handlePaint,
    );
    canvas.drawLine(
      cropRect.bottomLeft,
      cropRect.bottomLeft.translate(l, 0),
      handlePaint,
    );
    canvas.drawLine(
      cropRect.bottomLeft,
      cropRect.bottomLeft.translate(0, -l),
      handlePaint,
    );
    canvas.drawLine(
      cropRect.bottomRight,
      cropRect.bottomRight.translate(-l, 0),
      handlePaint,
    );
    canvas.drawLine(
      cropRect.bottomRight,
      cropRect.bottomRight.translate(0, -l),
      handlePaint,
    );

    // 3. 辅助细线
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 0.5;
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(cropRect.left, cropRect.top + cropRect.height * i / 3),
        Offset(cropRect.right, cropRect.top + cropRect.height * i / 3),
        gridPaint,
      );
      canvas.drawLine(
        Offset(cropRect.left + cropRect.width * i / 3, cropRect.top),
        Offset(cropRect.left + cropRect.width * i / 3, cropRect.bottom),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
