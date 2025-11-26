import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: '智能拍题',
      description: '拍照即可识别题目，AI助手帮你解答难题',
      image: 'assets/images/onboarding_camera.png',
      backgroundColor: const Color(0xFFE3F2FD),
    ),
    OnboardingItem(
      title: '题库练习',
      description: '海量优质题库，针对性训练，查漏补缺',
      image: 'assets/images/onboarding_library.png',
      backgroundColor: const Color(0xFFF3E5F5),
    ),
    OnboardingItem(
      title: 'AI名师',
      description: '智能辅导，个性化学习计划，全天候答疑解惑',
      image: 'assets/images/onboarding_ai.png',
      backgroundColor: const Color(0xFFE8F5E9),
    ),
    OnboardingItem(
      title: '学习追踪',
      description: '科学分析学习数据，让进步可见',
      image: 'assets/images/onboarding_progress.png',
      backgroundColor: const Color(0xFFFFF3E0),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景渐变
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return Container(
                color: item.backgroundColor,
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 图片
                      Expanded(
                        flex: 2,
                        child: Image.asset(item.image, fit: BoxFit.contain),
                      ),
                      // 文字说明
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                item.description,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 底部指示器和按钮
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 页面指示器
                  Row(
                    children: List.generate(
                      _items.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  // 下一步/开始按钮
                  ElevatedButton(
                    onPressed: _currentPage == _items.length - 1
                        ? _finishOnboarding
                        : () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                    child: Text(
                      _currentPage == _items.length - 1 ? '开始使用' : '下一步',
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
}

class OnboardingItem {
  final String title;
  final String description;
  final String image;
  final Color backgroundColor;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.image,
    required this.backgroundColor,
  });
}
