import 'package:flutter/material.dart';
import '../widgets/camera_guide_overlay.dart';

class AnimatedCameraPreview extends StatefulWidget {
  final Widget child;
  final bool showGuide;
  final VoidCallback onDismissGuide;
  final VoidCallback? onTap;
  final Function(bool)? onStabilityChange;

  const AnimatedCameraPreview({
    super.key,
    required this.child,
    this.showGuide = false,
    required this.onDismissGuide,
    this.onTap,
    this.onStabilityChange,
  });

  @override
  State<AnimatedCameraPreview> createState() => _AnimatedCameraPreviewState();
}

class _AnimatedCameraPreviewState extends State<AnimatedCameraPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _borderAnimation;

  bool _isFocusing = false;
  bool _isStable = true;

  void _setStability(bool stable) {
    if (_isStable != stable) {
      setState(() {
        _isStable = stable;
      });
      widget.onStabilityChange?.call(stable);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _borderAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startFocusAnimation() {
    setState(() {
      _isFocusing = true;
    });
    _controller.forward().then((_) {
      _controller.reverse().then((_) {
        setState(() {
          _isFocusing = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 相机预览
        GestureDetector(
          onTapDown: (details) {
            _startFocusAnimation();
            widget.onTap?.call();
          },
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _getBorderColor(),
                      width: _borderAnimation.value,
                    ),
                  ),
                  child: widget.child,
                ),
              );
            },
          ),
        ),

        // 辅助网格
        CustomPaint(
          painter: GridPainter(
            color: Colors.white.withOpacity(0.3),
            strokeWidth: 1,
          ),
        ),

        // 状态指示器
        if (_isFocusing)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '正在对焦...',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

        // 稳定性指示器
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isStable
                    ? Colors.green.withOpacity(0.7)
                    : Colors.orange.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _isStable ? '手机很稳,可以拍照啦' : '请保持手机稳定',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),

        // 引导蒙层
        if (widget.showGuide)
          CameraGuideOverlay(onDismiss: widget.onDismissGuide),
      ],
    );
  }

  Color _getBorderColor() {
    if (_isFocusing) {
      return Colors.yellow;
    }
    if (_isStable) {
      return Colors.green;
    }
    return Colors.white.withOpacity(0.3);
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  GridPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    // Draw the outer rectangle
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw horizontal lines
    for (var i = 1; i < 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical lines
    for (var i = 1; i < 3; i++) {
      final x = size.width * i / 3;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw focus point at center
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    const pointSize = 10.0;

    canvas.drawCircle(
      Offset(centerX, centerY),
      pointSize,
      paint..style = PaintingStyle.stroke,
    );

    // Draw cross at center
    canvas.drawLine(
      Offset(centerX - pointSize, centerY),
      Offset(centerX + pointSize, centerY),
      paint,
    );
    canvas.drawLine(
      Offset(centerX, centerY - pointSize),
      Offset(centerX, centerY + pointSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
