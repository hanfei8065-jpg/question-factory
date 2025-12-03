import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_camera_page.dart';
import 'camera_guide_page.dart';

/// 专业启动页面 (Splash Screen)
/// 显示品牌 Logo，2 秒后导航到主应用
/// 严格遵循 WeChat VI 视觉系统
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器 (1 秒动画)
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // 淡入动画 (0.0 → 1.0)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // 缩放动画 (0.8 → 1.0) - 轻微放大效果
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // 启动动画
    _animationController.forward();

    // 2 秒后导航到下一页面
    Timer(const Duration(seconds: 2), _navigateToNextPage);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 检查引导状态并导航到相应页面
  Future<void> _navigateToNextPage() async {
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedOnboarding =
          prefs.getBool('hasCompletedOnboarding') ?? false;

      if (!mounted) return;

      // 使用淡入淡出过渡动画
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return hasCompletedOnboarding
                ? const AppCameraPage()
                : const CameraGuidePage();
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } catch (e) {
      // 如果出错，默认进入相机页面
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AppCameraPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 纯白背景 (WeChat VI 标准)
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 中心 Logo 区域
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildLogo(),
              ),
            ),
          ),

          // 底部文字 "Powered by Dr. Logic"
          Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const Text(
                'Powered by Dr. Logic',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF969696), // WeChat VI 三级文本色
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建 Logo (尝试加载图片，失败则显示 Fallback)
  Widget _buildLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo 图片或 Fallback 图标
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            // 轻微阴影效果
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF07C160).withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
              // 图片加载失败时显示 Fallback
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackLogo();
              },
            ),
          ),
        ),

        const SizedBox(height: 24),

        // 品牌名称
        const Text(
          'Learnist.AI',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111111), // WeChat VI 主文本色
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 8),

        // 品牌标语
        const Text(
          'Smart Learning, Real Understanding',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF808080), // WeChat VI 次要文本色
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  /// Fallback Logo (当图片加载失败时显示)
  /// 使用 WeChat VI 标准渐变色
  Widget _buildFallbackLogo() {
    return Container(
      decoration: BoxDecoration(
        // WeChat Green 渐变背景 (VI 系统标准)
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF09D46D), // Gradient Start
            Color(0xFF07C160), // WeChat Green Primary
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: Icon(Icons.auto_awesome, size: 64, color: Colors.white),
      ),
    );
  }
}
