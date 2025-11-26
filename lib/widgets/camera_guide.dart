import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraGuide extends StatefulWidget {
  final VoidCallback onDismiss;

  const CameraGuide({super.key, required this.onDismiss});

  @override
  State<CameraGuide> createState() => _CameraGuideState();
}

class _CameraGuideState extends State<CameraGuide> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _guides = [
    _GuideItem(
      icon: Icons.photo_camera,
      title: '拍摄姿势',
      description: '保持手机水平，与试卷保持约25-30厘米的距离',
    ),
    _GuideItem(
      icon: Icons.wb_sunny,
      title: '光线要求',
      description: '确保环境光线充足，避免强光和阴影',
    ),
    _GuideItem(
      icon: Icons.crop,
      title: '取景建议',
      description: '将题目完整放入取景框内，避免遮挡和倾斜',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _guides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _markGuideAsShown();
      widget.onDismiss();
    }
  }

  Future<void> _markGuideAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('camera_guide_shown', true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _guides.length,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  final guide = _guides[index];
                  return _buildGuidePage(guide);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: widget.onDismiss,
                    child: const Text(
                      '跳过',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < _guides.length; i++)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == _currentPage
                                ? Colors.white
                                : Colors.white38,
                          ),
                        ),
                    ],
                  ),
                  TextButton(
                    onPressed: _nextPage,
                    child: Text(
                      _currentPage < _guides.length - 1 ? '下一步' : '开始使用',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidePage(_GuideItem guide) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(guide.icon, size: 120, color: Colors.white70),
        const SizedBox(height: 32),
        Text(
          guide.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            guide.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _GuideItem {
  final IconData icon;
  final String title;
  final String description;

  const _GuideItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
