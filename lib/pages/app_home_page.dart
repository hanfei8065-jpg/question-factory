import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:learnest_fresh/pages/app_explore_setup_page.dart';
import 'package:learnest_fresh/pages/app_profile_page.dart';
import 'package:learnest_fresh/pages/app_camera_page.dart';
import 'package:learnest_fresh/pages/calculator_selection_page.dart';
import 'package:learnest_fresh/services/translation_service.dart';

/// v0 设计规范 - 精确实现版本 + 相机预览模式
/// 所有位置、尺寸、颜色严格按照 design-spec.html
/// 支持白天/夜晚主题切换
class AppHomePage extends StatefulWidget {
  const AppHomePage({super.key});

  @override
  State<AppHomePage> createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 跟随系统深色模式
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 主题颜色
    final bgColor = isDarkMode ? Colors.black : Colors.white;
    // navBgColor 已废弃，底部导航色统一为圆球色
    final navBorderColor = isDarkMode
        ? const Color(0xFF1F2937)
        : const Color(0xFFE5E5E5);
    final activeColor = isDarkMode ? Colors.white : Colors.black;
    final inactiveColor = isDarkMode
        ? const Color(0xFF6B7280)
        : const Color(0xFF9CA3AF);

    // 动态创建页面列表
    final pages = [
      HomeDashboard(isDarkMode: isDarkMode),
      const AppQuestionBankPage(),
      const TutorPlaceholderPage(),
      const AppProfilePage(),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: pages[_currentIndex],
      // 底部导航 - 严格按照 v0 规范,支持主题切换
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEFEEEE),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.40),
              offset: const Offset(0, 6),
              blurRadius: 16,
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              offset: const Offset(0, 12),
              blurRadius: 32,
              spreadRadius: -4,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 18),
              blurRadius: 48,
              spreadRadius: -6,
            ),
          ],
          border: Border(top: BorderSide(color: navBorderColor, width: 1)),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.camera_alt_outlined,
                  label: '拍题',
                  index: 0,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
                _buildNavItem(
                  icon: Icons.grid_view_outlined,
                  label: '题库',
                  index: 1,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
                _buildNavItem(
                  icon: Icons.lightbulb_outline,
                  label: '名师',
                  index: 2,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  label: '我的',
                  index: 3,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final isActive = _currentIndex == index;
    final color = isActive ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: () => _onNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// 首页主内容 - 相机预览模式
// ============================================
class HomeDashboard extends StatefulWidget {
  final bool isDarkMode;

  const HomeDashboard({super.key, required this.isDarkMode});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with WidgetsBindingObserver {
  String _selectedCategory = '数学';
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCouponPressed = false;
  bool _isLanguagePressed = false;
  bool _isCalculatorPressed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('相机初始化错误: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 主题颜色配置
    final isDark = widget.isDarkMode;
    final calculatorBg = isDark ? Colors.white : Colors.black;
    final calculatorIconColor = isDark ? const Color(0xFF1F2937) : Colors.white;

    return SafeArea(
      child: Stack(
        children: [
          // ====== 相机预览背景 (全屏) ======
          if (_isCameraInitialized && _cameraController != null)
            Positioned.fill(child: CameraPreview(_cameraController!))
          else
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),

          // ====== 所有UI元素悬浮在相机上 ======
          Column(
            children: [
              // ====== 1. 中央主内容区域 ======
              Expanded(
                child: Stack(
                  children: [
                    // 中央白色/黑色金属圆圈
                    Center(child: _buildMetalCircle(isDark)),
                  ],
                ),
              ),

              // ====== 2. 分类标签区域 ======
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCategoryTab('数学', isDark),
                    _buildCategoryTab('物理', isDark),
                    _buildCategoryTab('化学', isDark),
                    _buildCategoryTab('奥数', isDark),
                  ],
                ),
              ),

              // ====== 3. 动作按钮区域 ======
              Container(
                height: 140,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 左侧按钮 (相册)
                    _buildSideButton(
                      icon: Icons.photo_library_outlined,
                      onTap: _onPhotoLibraryTap,
                    ),

                    // 中央大红色按钮
                    _buildLargeRedButton(),

                    // 右侧按钮 (手电筒)
                    _buildSideButton(
                      icon: Icons.flashlight_on_outlined,
                      onTap: _onFlashlightTap,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ====== Header 按钮悬浮在最上层 ======
          // 优惠券 (左上角)
          Positioned(left: 16, top: 24, child: _buildCouponBadge()),

          // 语言切换按钮
          Positioned(
            right: 72,
            top: 42,
            child: _buildLanguageButton(calculatorBg, calculatorIconColor),
          ),

          // 计算器按钮
          Positioned(
            right: 16,
            top: 42,
            child: _buildCalculatorButton(calculatorBg, calculatorIconColor),
          ),
        ],
      ),
    );
  }

  // ====== Header 组件 ======

  Widget _buildCouponBadge() {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isCouponPressed = true),
      onTapUp: (_) {
        setState(() => _isCouponPressed = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('优惠券功能开发中...')));
      },
      onTapCancel: () => setState(() => _isCouponPressed = false),
      child: AnimatedScale(
        scale: _isCouponPressed ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Transform.rotate(
          angle: -0.21,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFEFEEEE),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.40),
                  offset: const Offset(0, 6),
                  blurRadius: 16,
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.20),
                  offset: const Offset(0, 12),
                  blurRadius: 32,
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  offset: const Offset(0, 18),
                  blurRadius: 48,
                  spreadRadius: -6,
                ),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\$50',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B7280),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('✨', style: TextStyle(fontSize: 12)),
                    Text('✨', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(Color bgColor, Color iconColor) {
    return ValueListenableBuilder<String>(
      valueListenable: Tr.locale,
      builder: (context, currentLocale, _) {
        return GestureDetector(
          onTapDown: (_) => setState(() => _isLanguagePressed = true),
          onTapUp: (_) {
            setState(() => _isLanguagePressed = false);
            Tr.setLocale(currentLocale == 'zh' ? 'en' : 'zh');
          },
          onTapCancel: () => setState(() => _isLanguagePressed = false),
          child: AnimatedScale(
            scale: _isLanguagePressed ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEFEEEE),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.40),
                    offset: const Offset(0, 6),
                    blurRadius: 16,
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.20),
                    offset: const Offset(0, 12),
                    blurRadius: 32,
                    spreadRadius: -4,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    offset: const Offset(0, 18),
                    blurRadius: 48,
                    spreadRadius: -6,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.language_rounded,
                  size: 28,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalculatorButton(Color bgColor, Color iconColor) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isCalculatorPressed = true),
      onTapUp: (_) {
        setState(() => _isCalculatorPressed = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CalculatorSelectionPage(),
          ),
        );
      },
      onTapCancel: () => setState(() => _isCalculatorPressed = false),
      child: AnimatedScale(
        scale: _isCalculatorPressed ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFEFEEEE),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.40),
                offset: const Offset(0, 6),
                blurRadius: 16,
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                offset: const Offset(0, 12),
                blurRadius: 32,
                spreadRadius: -4,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, 18),
                blurRadius: 48,
                spreadRadius: -6,
              ),
            ],
          ),
          child: Icon(
            Icons.calculate_rounded,
            size: 20,
            color: const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  // ====== 中央金属圆圈 + 相机爪子 ======

  Widget _buildMetalCircle(bool isDark) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // 中央金属圆圈
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFFF5F5F5),
                        const Color(0xFFE0E0E0),
                        const Color(0xFFC0C0C0),
                      ]
                    : [
                        const Color(0xFF303030),
                        const Color(0xFF202020),
                        const Color(0xFF101010),
                      ],
                stops: const [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.5 : 0.8),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          // 四个相机爪子（内角都朝向圆圈中心）
          // 左上角（内角朝右下）
          Positioned(
            left: -40,
            top: -40,
            child: Transform.rotate(
              angle: 3.14159, // 180度反转
              child: _buildCornerClaw(),
            ),
          ),
          // 右上角（内角朝左下）
          Positioned(
            right: -40,
            top: -40,
            child: Transform.rotate(
              angle: -1.5708, // -90度反转
              child: _buildCornerClaw(),
            ),
          ),
          // 右下角（内角朝左上）
          Positioned(
            right: -40,
            bottom: -40,
            child: _buildCornerClaw(), // 0度反转
          ),
          // 左下角（内角朝右上）
          Positioned(
            left: -40,
            bottom: -40,
            child: Transform.rotate(
              angle: 1.5708, // 90度反转
              child: _buildCornerClaw(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerClaw() {
    return CustomPaint(size: const Size(60, 60), painter: CornerClawPainter());
  }

  // ====== 分类标签 ======

  Widget _buildCategoryTab(String label, bool isDark) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          color: isSelected ? const Color(0xFFEFEEEE) : const Color(0xFF6B7280),
        ),
      ),
    );
  }

  // ====== 动作按钮 ======

  Widget _buildSideButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFEFEEEE),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.40),
              offset: const Offset(0, 6),
              blurRadius: 16,
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              offset: const Offset(0, 12),
              blurRadius: 32,
              spreadRadius: -4,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 18),
              blurRadius: 48,
              spreadRadius: -6,
            ),
          ],
        ),
        child: Icon(
          icon == Icons.photo_library_outlined
              ? Icons.photo_library_rounded
              : icon == Icons.flashlight_on_outlined
              ? Icons.flashlight_on_rounded
              : icon,
          size: 20,
          color: const Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildLargeRedButton() {
    return GestureDetector(
      onTap: _onCameraTap,
      child: Container(
        width: 112,
        height: 112,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // 白色球体 - 无反光
          color: const Color(0xFFEFEEEE),
          shape: BoxShape.circle,
          boxShadow: [
            // 底部主阴影 - 球体压在桌面上
            BoxShadow(
              color: Colors.black.withOpacity(0.40),
              offset: const Offset(0, 6),
              blurRadius: 16,
              spreadRadius: -2,
            ),
            // 环境阴影
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              offset: const Offset(0, 12),
              blurRadius: 32,
              spreadRadius: -4,
            ),
            // 深层阴影 - 增加球体立体感
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 18),
              blurRadius: 48,
              spreadRadius: -6,
            ),
          ],
        ),
        child: const Icon(Icons.add, size: 48, color: Color(0xFF6B7280)),
      ),
    );
  }

  // ====== 按钮事件 ======

  void _onCameraTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AppCameraPage()),
    );
  }

  void _onPhotoLibraryTap() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('相册功能开发中...')));
  }

  void _onFlashlightTap() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('手电筒功能开发中...')));
  }
}

// ============================================
// 名师占位页面
// ============================================
class TutorPlaceholderPage extends StatelessWidget {
  const TutorPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lightbulb_outline, size: 80, color: Color(0xFFFBBF24)),
          SizedBox(height: 20),
          Text(
            '名师',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Coming Soon',
            style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

// ====== 相机爪子绘制器 ======
class CornerClawPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEFEEEE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // 绘制90度角的L形爪子
    // 内角在中心，两条线向外延伸
    path.moveTo(20, 0); // 从上方开始
    path.lineTo(20, 20); // 竖线到内角
    path.lineTo(0, 20); // 横线向左

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
