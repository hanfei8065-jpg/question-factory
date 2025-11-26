import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';

class CameraGuidePage extends StatefulWidget {
  const CameraGuidePage({super.key});

  @override
  State<CameraGuidePage> createState() => _CameraGuidePageState();
}

class _CameraGuidePageState extends State<CameraGuidePage> {
  final List<CameraGuideStep> _steps = [
    CameraGuideStep(
      title: '对准题目',
      description: '将题目放置在取景框内，保持手机稳定',
      icon: Icons.center_focus_strong,
    ),
    CameraGuideStep(
      title: '保持清晰',
      description: '确保题目字迹清晰可见，避免反光和阴影',
      icon: Icons.visibility,
    ),
    CameraGuideStep(
      title: '等待对焦',
      description: '等待黄色对焦框变为绿色，表示对焦完成',
      icon: Icons.camera,
    ),
    CameraGuideStep(
      title: '点击拍摄',
      description: '轻触拍摄按钮即可完成拍摄',
      icon: Icons.touch_app,
    ),
  ];

  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Stack(
          children: [
            // 模拟相机预览
            Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _currentStep == 2 ? Colors.green : Colors.yellow,
                    width: 2,
                  ),
                ),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Container(
                    color: Colors.black54,
                    child: Icon(
                      _steps[_currentStep].icon,
                      size: 64,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ),

            // 引导说明
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _steps[_currentStep].title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _steps[_currentStep].description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 步骤指示器
                        Row(
                          children: List.generate(
                            _steps.length,
                            (index) => Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentStep == index
                                    ? Colors.white
                                    : Colors.white30,
                              ),
                            ),
                          ),
                        ),
                        // 按钮
                        TextButton(
                          onPressed: () async {
                            if (_currentStep < _steps.length - 1) {
                              setState(() {
                                _currentStep++;
                              });
                            } else {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool(
                                'has_seen_camera_guide',
                                true,
                              );
                              if (!mounted) return;
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text(
                            _currentStep == _steps.length - 1 ? '开始拍题' : '下一步',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 关闭按钮
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CameraGuideStep {
  final String title;
  final String description;
  final IconData icon;

  CameraGuideStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}
