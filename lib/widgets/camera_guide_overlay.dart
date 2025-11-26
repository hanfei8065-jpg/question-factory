import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CameraGuideOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const CameraGuideOverlay({super.key, required this.onDismiss});

  @override
  State<CameraGuideOverlay> createState() => _CameraGuideOverlayState();
}

class _CameraGuideOverlayState extends State<CameraGuideOverlay> {
  int _currentStep = 0;
  final List<GuideStep> _steps = [
    GuideStep(
      title: '将试卷放好',
      description: '把试卷放在桌子上,保持平整',
      animation: 'assets/animations/place_paper.json',
    ),
    GuideStep(
      title: '对准试题',
      description: '让黄色框框套住整个题目',
      animation: 'assets/animations/align_camera.json',
    ),
    GuideStep(
      title: '保持稳定',
      description: '双手握稳手机,等待小绿灯亮起',
      animation: 'assets/animations/hold_steady.json',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.8),
      child: Stack(
        children: [
          // 中心内容
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Lottie.asset(
                    _steps[_currentStep].animation,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _steps[_currentStep].title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _steps[_currentStep].description,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisSize: MainAxisSize.min,
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
              ],
            ),
          ),

          // 底部按钮
          Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_currentStep > 0)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentStep--;
                      });
                    },
                    child: const Text(
                      '上一步',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                const SizedBox(width: 32),
                ElevatedButton(
                  onPressed: () {
                    if (_currentStep < _steps.length - 1) {
                      setState(() {
                        _currentStep++;
                      });
                    } else {
                      widget.onDismiss();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 48),
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    _currentStep < _steps.length - 1 ? '下一步' : '开始拍题',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 跳过按钮
          Positioned(
            top: 48,
            right: 16,
            child: TextButton(
              onPressed: widget.onDismiss,
              child: const Text('跳过', style: TextStyle(color: Colors.white70)),
            ),
          ),
        ],
      ),
    );
  }
}

class GuideStep {
  final String title;
  final String description;
  final String animation;

  GuideStep({
    required this.title,
    required this.description,
    required this.animation,
  });
}
