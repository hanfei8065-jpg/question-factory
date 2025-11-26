import 'package:flutter/material.dart';
import 'dart:math' as math;

class CelebrationOverlay extends StatefulWidget {
  final String message;
  final Duration duration;

  const CelebrationOverlay({
    super.key,
    required this.message,
    required this.duration,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final List<Confetti> _confetti = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40.0,
      ),
    ]).animate(_controller);

    // 生成五彩纸屑
    for (var i = 0; i < 50; i++) {
      _confetti.add(
        Confetti(
          color: Color(
            (math.Random().nextDouble() * 0xFFFFFF).toInt(),
          ).withOpacity(1.0),
          position: Offset(
            math.Random().nextDouble() * MediaQuery.of(context).size.width,
            -20,
          ),
        ),
      );
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 半透明黑色背景
        Container(color: Colors.black54),

        // 庆祝文字
        Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Text(
              widget.message,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.black26,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 五彩纸屑
        CustomPaint(
          painter: ConfettiPainter(confetti: _confetti),
          size: Size.infinite,
        ),
      ],
    );
  }
}

class Confetti {
  Offset position;
  final Color color;
  double velocity = math.Random().nextDouble() * 2 + 1;
  double angle = math.Random().nextDouble() * math.pi;

  Confetti({required this.position, required this.color});

  void update() {
    position = position.translate(
      math.cos(angle) * velocity,
      math.sin(angle) * velocity + 1,
    );
    angle += math.Random().nextDouble() * 0.1 - 0.05;
  }
}

class ConfettiPainter extends CustomPainter {
  final List<Confetti> confetti;

  ConfettiPainter({required this.confetti});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var particle in confetti) {
      paint.color = particle.color;
      canvas.drawCircle(particle.position, 2, paint);
      particle.update();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
