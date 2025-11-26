import 'dart:math' as math;
import 'package:flutter/material.dart';

class DynamicCameraGuide extends StatefulWidget {
  final VoidCallback onComplete;
  final bool show;

  const DynamicCameraGuide({
    Key? key,
    required this.onComplete,
    required this.show,
  }) : super(key: key);

  @override
  State<DynamicCameraGuide> createState() => _DynamicCameraGuideState();
}

class _DynamicCameraGuideState extends State<DynamicCameraGuide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentStep = 0;

  final List<GuideStep> _steps = [
    GuideStep(
      icon: Icons.photo_camera,
      title: '保持手机水平',
      description: '手机与桌面保持平行，避免倾斜',
      animation: _buildHorizontalAnimation,
    ),
    GuideStep(
      icon: Icons.height,
      title: '保持适当距离',
      description: '与题目保持25-30厘米的距离',
      animation: _buildDistanceAnimation,
    ),
    GuideStep(
      icon: Icons.wb_sunny,
      title: '注意光线',
      description: '确保环境光线充足，避免阴影',
      animation: _buildLightAnimation,
    ),
    GuideStep(
      icon: Icons.crop_free,
      title: '对准边框',
      description: '将题目完整放入绿色边框内',
      animation: _buildFrameAnimation,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show) return const SizedBox.shrink();

    final step = _steps[_currentStep];
    return Container(
      color: Colors.black87,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Icon(step.icon, size: 48, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              step.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                step.description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(child: step.animation(_animation)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < _steps.length; i++)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _currentStep
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _nextStep,
              child: Text(
                _currentStep < _steps.length - 1 ? '下一步' : '开始拍摄',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _buildHorizontalAnimation(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: (animation.value - 0.5) * 0.2,
          child: Container(
            margin: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.phone_android, size: 48, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildDistanceAnimation(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(48),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.photo_camera, size: 48, color: Colors.white),
              Positioned(
                bottom: 50 + animation.value * 50,
                child: Container(
                  width: 200,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Center(
                    child: Text('试卷', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
              Positioned(
                bottom: 60 + animation.value * 50,
                child: Container(
                  width: 2,
                  height: 100,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildLightAnimation(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(48),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 200,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Text('试卷', style: TextStyle(color: Colors.white)),
                ),
              ),
              for (double angle = 0; angle < 360; angle += 45)
                Positioned(
                  left: 100 + 80 * math.cos(angle * math.pi / 180),
                  top: 60 + 80 * math.sin(angle * math.pi / 180),
                  child: Transform.rotate(
                    angle: angle * math.pi / 180,
                    child: Container(
                      width: 20,
                      height: 2,
                      color: Colors.yellow.withOpacity(animation.value),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildFrameAnimation(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(48),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 200,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color.lerp(
                      Colors.white,
                      Colors.green,
                      animation.value,
                    )!,
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text('试卷', style: TextStyle(color: Colors.white)),
                ),
              ),
              for (int i = 0; i < 4; i++)
                Positioned(
                  left: i % 2 == 0 ? 80 : 280,
                  top: i < 2 ? 40 : 160,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.lerp(
                        Colors.white,
                        Colors.red,
                        animation.value,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class GuideStep {
  final IconData icon;
  final String title;
  final String description;
  final Widget Function(Animation<double>) animation;

  GuideStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.animation,
  });
}
