import 'package:flutter/material.dart';
import '../main.dart'; // 跳转主页用

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 淡入 + 轻微放大效果 (呼吸感)
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // 2.5秒后跳转，留足时间展示品牌
    Future.delayed(const Duration(milliseconds: 2500), () async {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainNavigator(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // VI 标准色值
    const Color primaryGreen = Color(0xFF358373);
    const Color textDark = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: Colors.white, // 纯白底，大厂风
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- 官方 VI Logo (代码绘制) ---
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CustomPaint(
                    painter: _OfficialLogoPainter(color: primaryGreen),
                  ),
                ),

                // ---------------------------
                const SizedBox(height: 30),

                // App Name
                const Text(
                  'Learnist.AI',
                  style: TextStyle(
                    fontSize: 32, // 更大一点
                    fontWeight: FontWeight.w800, // 更粗一点
                    color: primaryGreen,
                    letterSpacing: 1.0,
                    fontFamily: 'Arial', // 使用系统安全字体
                  ),
                ),

                const SizedBox(height: 16),

                // Slogan
                const Text(
                  '来自未来的学习方式',
                  style: TextStyle(
                    fontSize: 16,
                    color: textDark,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 4.0, // 宽字间距，极其高级
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- 植入官方 VI Logo 绘制逻辑 ---
class _OfficialLogoPainter extends CustomPainter {
  final Color color;
  _OfficialLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth =
          8.0 // 线条厚实一点
      ..strokeCap = StrokeCap
          .round // 圆头，符合 "Soft UI"
      ..style = PaintingStyle.stroke;

    final double w = size.width;
    final double h = size.height;
    final double gap = w * 0.25; // 中间留空

    // 左括号 [
    Path leftBracket = Path();
    leftBracket.moveTo(w * 0.3, 0); // 上横
    leftBracket.lineTo(0, 0); // 左上角
    leftBracket.lineTo(0, h); // 左竖线
    leftBracket.lineTo(w * 0.3, h); // 下横
    canvas.drawPath(leftBracket, paint);

    // 右括号 ]
    Path rightBracket = Path();
    rightBracket.moveTo(w * 0.7, 0);
    rightBracket.lineTo(w, 0);
    rightBracket.lineTo(w, h);
    rightBracket.lineTo(w * 0.7, h);
    canvas.drawPath(rightBracket, paint);

    // 中间的小斜杠 / (点睛之笔，代表光/灵感)
    final Paint slashPaint = Paint()
      ..color =
          const Color(0xFF5FCEB3) // 亮青色点缀
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(w * 0.4, h * 0.7),
      Offset(w * 0.6, h * 0.3),
      slashPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
